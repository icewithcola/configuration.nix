{ ... }:
{
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 33554432;
    "net.core.wmem_max" = 33554432;
    "net.core.rmem_default" = 33554432;
    "net.core.wmem_default" = 33554432;
    "net.core.netdev_max_backlog" = 16384;
    "net.netfilter.nf_conntrack_udp_timeout" = 10;
    "net.netfilter.nf_conntrack_udp_timeout_stream" = 30;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
