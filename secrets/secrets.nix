let
  kagura-notebook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtsBUrTKcEIW2UZ2//QeU+PJj3/dxaVCncTg1j7gvAP";
  kagura-PC = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPt9ckkZVYhl21qSJlGoi7i9EyAD+VwL0Fq4rdRO8k6k";
  kagura-nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYFmnBe6VIe2UjpG6UqnsCZ45VBK4eRfMIvm+A/aNd4";
  users = [
    kagura-notebook
    kagura-PC
    kagura-nas
  ];
in
{
  "frp-token.age".publicKeys = users;
  "github-token.age".publicKeys = users;
}
