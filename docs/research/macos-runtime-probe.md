# macOS Runtime Provider 探针结论

## 身份与范围

- Probe：`P-ENVI-001 macOS ARM64 Linux Managed VM Capability Probe`
- Parent Base Revision：`b835f18367daa4ce8cd5642516bd1945a9254705`
- Probe Outcome：`promote-findings`
- Probe commits：`0a23059`、`69ea09c`、`e0740b2`
- 实测宿主：Apple M2、arm64、macOS 26.5.1 (`25F80`)、SDK 26.5、Swift 6.3.2
- Guest 材料：Alpine 3.24.1 aarch64 netboot，Linux `6.18.35-0-virt`

Probe 是 Parent 外部的可抛弃验证工程，不参加 Envisle 构建、测试或发布；本文件只回流证据与契约约束，不回流实验实现。

## 已实测

| 能力 | 结果 | 证据边界 |
| --- | --- | --- |
| Host capability | 通过 | `VZVirtualMachine.isSupported=true`，Apple Hypervisor 可用；旧系统/错误架构/能力缺失可解释拒绝。 |
| Entitlement 与启动 | 通过 | 仅带 `com.apple.security.virtualization` 的本地签名 runner 真实启动 ARM64 Linux。 |
| 生命周期 | 通过 | create/start/guest-ready/poweroff/restart/delete 闭环。 |
| 独立磁盘 | 通过 | 两个实例使用不同路径与 inode 的 64 MiB RAW disk。 |
| 默认共享 | 通过 | 未配置 share 的 guest 不存在 `envisle-share` tag。 |
| 只读共享 | 通过 | guest 可读授权文件，写入得到 read-only filesystem，宿主文件未变化。 |
| NAT 与 guest 间隔离 | 观察通过 | 两台 VM 并发取得不同地址；第二台不能连接第一台持续监听的 TCP 服务。只代表当前双实例组合。 |
| host-to-guest 默认拒绝 | 未通过 | 未声明产品端口规则时，宿主仍能连接 guest `:8080`。 |
| 端口 allow/revoke | 未验证 | 极简 initramfs 无 nftables/iptables；不得将材料缺失伪装成已实现策略。 |

## 根因证据

首次 `VZErrorDomain Code=1` 不是平台 No-Go：Alpine `vmlinuz-virt` 是压缩 kernel，vfkit 对同一输入明确报告必须使用未压缩 kernel。用 Linux v6.18 官方 `extract-vmlinux` 得到 ARM64 `Image-virt` 后进入 guest；第二次失败由 overlay 使用旧 cpio 格式导致，改为 `newc` 后闭环通过。

这两次失败证明 Runtime 层必须保留原始错误和启动材料 provenance，不能把所有 start failure 压成单一布尔值，也不能自动换后端。

## Go/No-Go

- Provider：`conditional Go`。生命周期、存储、NAT、串口与显式只读 virtiofs 足以进入契约设计。
- Network policy：`No-Go as VZNAT-only`。默认无 host 入站必须由 guest firewall/policy agent 执行。
- Product implementation：`not promoted`。Swift Probe、shell asset builder、Alpine overlay 和 ad-hoc signing 只作参考；正式实现须在 Parent 依据 `T-003 v3` 重写。

## T-003 输入

Network Broker 契约至少需要：desired policy、applied policy version、default deny、explicit allow、revoke、guest attestation/health、fail-closed state 和原始失败。做对了是未授权端口从宿主不可达，allow 后仅指定端口可达，revoke 后再次不可达；典型失败是 UI 显示“未发布”但 guest firewall 没有应用，或 agent 失联时继续保持旧 allow。
