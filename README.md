# Envisle

> Independent environments. Controlled bridges.

Envisle 安装后直接创建并拥有独立 `Environment`。每个实例默认以受管 VM 作为隔离边界；环境之间、宿主与环境之间默认不共享数据，只能通过 Envisle 创建、展示、撤销并审计的授权桥梁交换数据。

项目当前处于 **macOS Runtime 探针准备阶段**。公开名称与首个产品模型已经冻结，实现语言和语言级接口尚未冻结。

## 当前共识

- 产品模型为 `Managed Runtime Platform`，不是已有 Runtime 的聚合控制面。
- 用户模型统一为 `Environment`，实现模型按 `Provider` 隔离。
- 一实例一受管 VM 是默认安全边界；Container 只能作为 VM 内工作负载优化。
- 默认无宿主目录共享、无环境间通信、无宿主入站端口。
- Runtime Router 必须基于宿主、来宾、架构、许可和能力探测做选择，不能只看操作系统名称。
- 不把容器、完整 VM 和设备模拟器伪装成完全相同的资源。
- 首个验证宿主为 Apple silicon + macOS 26，首个 guest 为项目提供的 ARM64 Linux 最小镜像；正式支持仍需探针验收。
- Android AVF/pKVM 不是普通第三方 APK 可依赖的产品后端。
- 跨 ISA QEMU/TCG 只可作为兼容路径，不能承诺主路径交互性能。

## MVP 冻结基线

威胁模型、存储/共享/网络默认策略、明确排除项和六条端到端验收标准见 [`docs/architecture/mvp-baseline.md`](docs/architecture/mvp-baseline.md)。产品路径的候选比较及关闭结论见 [`docs/architecture/product-options.md`](docs/architecture/product-options.md)。

## 项目状态

- 已完成初始化：[讨论成果驱动的项目初始化](docs/archive/done-log.md#t-001)
- 当前执行：[首个 MVP 产品路径与公开名称决策](docs/TODO.md#t-004)
- 当前真相：[`docs/agent-context/current.md`](docs/agent-context/current.md)
- 讨论来源：[`docs/research/discussion-source.md`](docs/research/discussion-source.md)
- 广度调研：[`docs/research/breadth-scan.md`](docs/research/breadth-scan.md)
- 架构边界：[`docs/architecture/overview.md`](docs/architecture/overview.md)

## 使用与验证

当前没有可运行的产品代码。初始化检查入口：

```bash
make check
```

做对时命令退出码为 `0`，并确认必需入口、内部 Markdown 链接和同步目录安全约束存在；典型失败是入口缺失、相对链接失效或把运行数据目录放入仓库。

## 本机与运行数据边界

本仓库可能由 Syncthing 复制到其他机器。未来的 VM 磁盘、系统镜像、下载包、缓存、日志、数据库、快照、密钥和运行状态不得放入仓库；代码应通过 `OSDECK_STATE_DIR`、`OSDECK_CACHE_DIR` 等运行时目录变量解析。变量的最终名称在实现前由领域模型任务确认。

## License

尚未选择项目许可证。在许可证确定前，不应把本仓库视为已授权公开分发。
