# Envisle

> Independent environments. Controlled bridges.

Envisle 安装后直接创建并拥有独立 `Environment`。每个实例默认以受管 VM 作为隔离边界；默认不挂载宿主目录、不开放宿主入站端口，数据只能通过 Envisle 创建、展示、撤销并审计的授权桥梁进入环境。默认 NAT 出站仍是数据通道，不能描述成宿主与环境之间“完全不交换数据”。

项目当前处于 **最终产品方案基线审查阶段**。公开名称、VM-first Managed Runtime 模型和首个领域契约已经冻结，macOS ARM64 Linux VM Probe 已形成条件性 Go；尚未实现正式 VM Provider、UI、guest agent 或宿主网络数据面。

## 当前共识

- 产品模型为 `Managed Runtime Platform`，不是已有 Runtime 的聚合控制面。
- 用户模型统一为 `Environment`，实现模型按 `Provider` 隔离。
- 一实例一受管 VM 是默认安全边界；Container 只能作为 VM 内工作负载优化。
- 默认无宿主目录共享、无环境间通信、无宿主入站端口。
- Runtime Router 必须基于宿主、来宾、架构和能力探测做选择，不能只看操作系统名称；许可仍是未来 Provider admission gate，当前领域 Router 尚未实现许可判定。
- 不把容器、完整 VM 和设备模拟器伪装成完全相同的资源。
- 首个验证宿主为 Apple silicon + macOS 26，首个 guest 为项目提供的 ARM64 Linux 最小镜像；Apple M2/macOS 26.5.1 上的生命周期、独立磁盘和只读共享已实测通过。
- VZNAT 不能单独提供宿主入站默认拒绝；当前契约要求 Network Broker 与 guest policy agent 对账，但 guest root 可修改 guest firewall，因此最终强隔离方案仍需宿主控制的数据面 Probe 和用户解冻决策。
- VM `running` 不等于 Environment `ready`；只有 guest agent 的 Network evidence 与宿主 Share Broker evidence 均匹配 desired policy，且网络租约有效时才 ready。
- Android AVF/pKVM 不是普通第三方 APK 可依赖的产品后端。
- 跨 ISA QEMU/TCG 只可作为兼容路径，不能承诺主路径交互性能。

## MVP 冻结基线

威胁模型、存储/共享/网络默认策略、明确排除项和六条端到端验收标准见 [`docs/architecture/mvp-baseline.md`](docs/architecture/mvp-baseline.md)。产品路径的候选比较及关闭结论见 [`docs/architecture/product-options.md`](docs/architecture/product-options.md)。

## 项目状态

- 已完成初始化：[讨论成果驱动的项目初始化](docs/archive/done-log.md#t-001)
- 已冻结 MVP 与公开名称：[首个 MVP 产品路径与公开名称决策](docs/archive/done-log.md#t-004)
- 已完成 Runtime 探针：[macOS Runtime Provider 探针](docs/archive/done-log.md#t-002)
- 已完成领域契约：[Environment 领域模型与 Provider 契约基线](docs/archive/done-log.md#t-003)
- 当前活跃 Task：[`T-005 全局漂移审查与最终产品方案定稿`](docs/TODO.md#t-005)。审查已确认 Guest Agent 不能单独承担对抗 guest root 的最终网络权威，正在等待最终产品方案的解冻决策。
- 当前真相：[`docs/agent-context/current.md`](docs/agent-context/current.md)
- 讨论来源：[`docs/research/discussion-source.md`](docs/research/discussion-source.md)
- 广度调研：[`docs/research/breadth-scan.md`](docs/research/breadth-scan.md)
- 架构边界：[`docs/architecture/overview.md`](docs/architecture/overview.md)

## 使用与验证

当前只有领域库和自动化测试，没有可运行的产品 App。要求 Apple silicon + macOS 26；Package 使用 Swift tools 6.2，已在 Xcode 26.5 / Swift 6.3.2 实测。统一验证入口：

```bash
make check
```

做对时命令退出码为 `0`，25 个领域/架构测试全部通过，并确认必需入口、内部 Markdown 链接和同步目录安全约束存在；典型失败是 stop 失败后仍可删除、旧 Runtime evidence 被判 ready、Guest Policy 响应串线、Router 绕过最低安全能力、相对链接失效或把运行数据目录放入仓库。

领域与协议的完整验收边界见 [`docs/architecture/environment-contracts.md`](docs/architecture/environment-contracts.md)。

## 本机与运行数据边界

本仓库可能由 Syncthing 复制到其他机器。未来的 VM 磁盘、系统镜像、下载包、缓存、日志、数据库、快照、密钥和运行状态不得放入仓库；代码应通过 `ENVISLE_STATE_DIR`、`ENVISLE_CACHE_DIR` 等运行时目录变量解析。变量的具体解析与迁移契约在引入运行数据的实现 Task 中冻结。

## License

尚未选择项目许可证。在许可证确定前，不应把本仓库视为已授权公开分发。
