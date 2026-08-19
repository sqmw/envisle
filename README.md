# OSDeck

> Working codename for a capability-aware local environment platform.

OSDeck 的目标是让用户用统一的 `Environment` 概念理解和控制本机隔离环境，同时保留 Container、VM、Emulator 及不同宿主平台的真实能力差异。

项目当前处于**证据驱动的初始化阶段**。`OSDeck` 只是工作代号；公开品牌与首个产品形态尚未冻结。

## 当前共识

- 用户模型统一为 `Environment`，实现模型按 `Provider` 隔离。
- Runtime Router 必须基于宿主、来宾、架构、许可和能力探测做选择，不能只看操作系统名称。
- 不把容器、完整 VM 和设备模拟器伪装成完全相同的资源。
- 首个验证宿主优先 Apple silicon + macOS 26；这是一项候选基线，需经过探针后才能冻结。
- Android AVF/pKVM 不是普通第三方 APK 可依赖的产品后端。
- 跨 ISA QEMU/TCG 只可作为兼容路径，不能承诺主路径交互性能。

## 当前待决策

首个 MVP 有两条候选路径：

1. `Runtime Platform`：OSDeck 自己提供并编排 Virtualization.framework、Apple `container`、QEMU 等运行后端。
2. `Local Control Plane`：OSDeck 先发现并统一控制用户已安装的 UTM、Docker-compatible engine、Lima/Colima 等运行时。

初始化骨架只固化两条路径共享的 Provider/Capability 边界。对比与验收门见 [`docs/architecture/product-options.md`](docs/architecture/product-options.md)。

## 项目状态

- 已完成初始化：[讨论成果驱动的项目初始化](docs/archive/done-log.md#t-001)
- 下一决策：[首个 MVP 产品路径与公开名称决策](docs/TODO.md#t-004)
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
