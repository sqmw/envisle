# Envisle

> Independent environments. Controlled bridges.

Envisle 是跨平台的权限化 `Environment` 系统。它在 Android、macOS、Windows 等宿主上创建彼此独立的实例，并由 Envisle 控制文件、网络、凭据、设备和应用能力如何跨越实例边界。

当前最高产品优先级是 **Android host**；macOS 是当前最成熟的 reference platform，不是产品边界。Apple ARM64 Linux VM Probe 已形成条件性 Go，Android 普通 APK、Enterprise、OEM/AOSP 与完整 Android guest 的能力仍需分别 Probe；尚未实现正式产品 App 或 Provider。

## 当前共识

- 产品模型为 `Managed Runtime Platform`，不是已有 Runtime 的聚合控制面。
- 用户模型统一为 `Environment`，实现模型按 `Provider` 隔离。
- Android、macOS、Windows 是不同 Platform Profile；共享上层身份、授权和证据，不伪造相同 Runtime、镜像、网络或安全语义。
- Android 是第一产品优先级；macOS 参考实现不得覆盖 Android 方向。
- macOS reference profile 以一实例一受管 VM 为默认安全边界；Container 只能作为 VM 内工作负载优化。
- 默认无宿主目录共享、无环境间通信、无宿主入站端口。
- Runtime Router 必须基于宿主、来宾、架构和能力探测做选择，不能只看操作系统名称；许可仍是未来 Provider admission gate，当前领域 Router 尚未实现许可判定。
- 不把容器、完整 VM 和设备模拟器伪装成完全相同的资源。
- 首个已有实测证据的宿主为 Apple silicon + macOS 26，guest 为 ARM64 Linux；这只是 reference profile。当前第一待办是核验 Android 普通 APK、Device Owner、平台签名/AOSP 与 OEM 路径的真实能力矩阵。
- VZNAT 不能单独提供宿主入站默认拒绝；当前契约要求 Network Broker 与 guest policy agent 对账，但 guest root 可修改 guest firewall，因此最终强隔离方案仍需宿主控制的数据面 Probe 和用户解冻决策。
- VM `running` 不等于 Environment `ready`；只有 guest agent 的 Network evidence 与宿主 Share Broker evidence 均匹配 desired policy，且网络租约有效时才 ready。
- Android AVF/pKVM 不是普通第三方 APK 可直接假设拥有的后端；Public APK、Enterprise 与 OEM/AOSP 必须分 profile 验证。
- 跨 ISA QEMU/TCG 只可作为兼容路径，不能承诺主路径交互性能。

## 产品方向与参考基线

跨平台 Android-first 产品方向见 [`docs/product/final-product-proposal.md`](docs/product/final-product-proposal.md) 与 [`D-008`](docs/DECISIONS.md#d-008)。macOS reference profile 的威胁模型、存储/共享/网络默认策略和验收标准见 [`docs/architecture/mvp-baseline.md`](docs/architecture/mvp-baseline.md)。

## 项目状态

- 已完成初始化：[讨论成果驱动的项目初始化](docs/archive/done-log.md#t-001)
- 已冻结 MVP 与公开名称：[首个 MVP 产品路径与公开名称决策](docs/archive/done-log.md#t-004)
- 已完成 Runtime 探针：[macOS Runtime Provider 探针](docs/archive/done-log.md#t-002)
- 已完成领域契约：[Environment 领域模型与 Provider 契约基线](docs/archive/done-log.md#t-003)
- 当前活跃 Task：[`T-005 v2 全局漂移审查与最终产品方案定稿`](docs/TODO.md#t-005)。方向已校正为 Android-first 跨平台产品，正在同步和复核文档。
- 当前真相：[`docs/agent-context/current.md`](docs/agent-context/current.md)
- 讨论来源：[`docs/research/discussion-source.md`](docs/research/discussion-source.md)
- 广度调研：[`docs/research/breadth-scan.md`](docs/research/breadth-scan.md)
- 架构边界：[`docs/architecture/overview.md`](docs/architecture/overview.md)

## 使用与验证

当前只有用于 macOS reference contract 的领域库和自动化测试，没有可运行的产品 App。现有 Package 要求 Apple silicon + macOS 26，使用 Swift tools 6.2，已在 Xcode 26.5 / Swift 6.3.2 实测；这不是 Android 产品工具链结论。统一验证入口：

```bash
make check
```

做对时命令退出码为 `0`，25 个领域/架构测试全部通过，并确认必需入口、内部 Markdown 链接和同步目录安全约束存在；典型失败是 stop 失败后仍可删除、旧 Runtime evidence 被判 ready、Guest Policy 响应串线、Router 绕过最低安全能力、相对链接失效或把运行数据目录放入仓库。

领域与协议的完整验收边界见 [`docs/architecture/environment-contracts.md`](docs/architecture/environment-contracts.md)。

## 本机与运行数据边界

本仓库可能由 Syncthing 复制到其他机器。未来的 VM 磁盘、系统镜像、下载包、缓存、日志、数据库、快照、密钥和运行状态不得放入仓库；代码应通过 `ENVISLE_STATE_DIR`、`ENVISLE_CACHE_DIR` 等运行时目录变量解析。变量的具体解析与迁移契约在引入运行数据的实现 Task 中冻结。

## License

尚未选择项目许可证。在许可证确定前，不应把本仓库视为已授权公开分发。
