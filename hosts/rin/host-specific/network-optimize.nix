{ config, ... }:
{
  boot.kernel.sysctl = {
    # 缓冲区调优
    "net.core.rmem_max" = 33554432;
    "net.core.wmem_max" = 33554432;
    "net.core.rmem_default" = 33554432;
    "net.core.wmem_default" = 33554432;

    # 提高每 CPU 核心的入站队列上限
    "net.core.netdev_max_backlog" = 16384;

    # UDP 超时
    "net.netfilter.nf_conntrack_udp_timeout" = 10;
    "net.netfilter.nf_conntrack_udp_timeout_stream" = 30;

    # 拥塞控制
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
