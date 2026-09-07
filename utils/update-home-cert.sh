#!/usr/bin/env bash
set -Eeuo pipefail

readonly CERT_DOMAIN='*.home.lolicon.cyou'
readonly CERT_SOURCE_HOST='root@ks'
readonly CERT_SOURCE_PATH='/var/lib/acme/home.lolicon.cyou/fullchain.pem'

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname -- "$SCRIPT_DIR")"
readonly SECRETS_DIR="$REPO_ROOT/secrets"
readonly AGE_RULES="$SECRETS_DIR/secrets.nix"
readonly AGE_SECRET='loli-cer.age'
readonly AGE_SECRET_PATH="$SECRETS_DIR/$AGE_SECRET"

TEMP_DIR="$(mktemp -d)"
readonly FULLCHAIN="$TEMP_DIR/fullchain.pem"
readonly ENCRYPTED_CERT="$TEMP_DIR/$AGE_SECRET"
STAGED_SECRET=''

cleanup() {
	rm -rf -- "$TEMP_DIR"
	if [[ -n "$STAGED_SECRET" ]]; then
		rm -f -- "$STAGED_SECRET"
	fi
}
trap cleanup EXIT

run_agenix() {
	if command -v agenix >/dev/null 2>&1; then
		agenix "$@"
		return
	fi

	if ! command -v nix >/dev/null 2>&1; then
		echo 'Neither agenix nor nix is available.' >&2
		return 1
	fi

	local agenix_source
	agenix_source="$(
		cd -- "$REPO_ROOT"
		nix eval --raw --impure --expr \
			'toString ((builtins.getFlake (toString ./.)).inputs.agenix.outPath)'
	)"
	nix run "$agenix_source" -- "$@"
}

echo "Pulling the $CERT_DOMAIN full chain from $CERT_SOURCE_HOST..."
ssh "$CERT_SOURCE_HOST" "cat -- '$CERT_SOURCE_PATH'" >"$FULLCHAIN"

if [[ ! -s "$FULLCHAIN" ]]; then
	echo "The fetched certificate is empty: $CERT_SOURCE_HOST:$CERT_SOURCE_PATH" >&2
	exit 1
fi

certificate_count="$(grep -c '^-----BEGIN CERTIFICATE-----$' "$FULLCHAIN" || true)"
if ((certificate_count < 2)); then
	echo "Expected a full chain, but found $certificate_count certificate(s)." >&2
	exit 1
fi

if ! openssl x509 -in "$FULLCHAIN" -noout -checkend 0 >/dev/null; then
	echo 'The fetched leaf certificate is expired.' >&2
	exit 1
fi

if ! openssl x509 -in "$FULLCHAIN" -noout -ext subjectAltName |
	grep -Fq "DNS:$CERT_DOMAIN"; then
	echo "The fetched certificate does not cover $CERT_DOMAIN." >&2
	exit 1
fi

echo "Encrypting the new full chain with agenix..."
(
	cd -- "$TEMP_DIR"
	RULES="$AGE_RULES" run_agenix -e "$AGE_SECRET" <"$FULLCHAIN"
)

if [[ ! -s "$ENCRYPTED_CERT" ]]; then
	echo 'agenix did not produce an encrypted certificate.' >&2
	exit 1
fi

STAGED_SECRET="$(mktemp "$SECRETS_DIR/.${AGE_SECRET}.XXXXXX")"
cp -- "$ENCRYPTED_CERT" "$STAGED_SECRET"
chmod --reference="$AGE_SECRET_PATH" "$STAGED_SECRET"
mv -f -- "$STAGED_SECRET" "$AGE_SECRET_PATH"
STAGED_SECRET=''

echo "Updated $AGE_SECRET_PATH."
