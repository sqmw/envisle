# Envisle 主 TODO

## 项目目标

Envisle 安装后创建并拥有独立 Environment，以受管 VM 为默认安全边界，并通过项目显式授权控制宿主共享与网络入口。Apple ARM64 Linux Runtime 已取得条件性 Go，Environment / Provider / Broker 契约基线已完成。

## Milestones

<a id="m-01"></a>
### M-01 可执行的项目基线

- 状态：`done`
- 达成状态：仓库具备明确的产品边界、来源可追溯的技术判断、低上下文文档入口和可继续开发的最小工程骨架。
- 验收标准：项目约束、当前真相、架构边界、研究证据、验证入口和后续任务均可从 `README.md` / `docs/README.md` 定位；初始化检查通过；Git 提交可回退。
- 归属 Task：`T-001`、`T-004`

<a id="m-02"></a>
### M-02 macOS Apple Silicon 探针闭环

- 状态：`done`
- 达成状态：用最小探针验证 Apple silicon + macOS 26 上 ARM64 Linux 受管 VM 的 Runtime Provider 可行性，并形成可冻结的 Provider 契约。
- 验收标准：宿主能力探测、ARM64 Linux guest 生命周期、默认隔离、显式共享与端口边界（包括 VZNAT-only 的 No-Go）及失败证据均可复现；Provider、Broker 与实现语言边界由 Probe 和领域反例测试共同支持。
- 归属 Task：`T-002`、`T-003`（按顺序推进：先以 `T-002` 取得探针证据，再由 `T-003` 定义契约基线）。

## Active Tasks

（暂无。Guest Policy Agent Probe 是当前推荐候选，但尚未建立或授权为正式 Task。）

## 当前风险与阻塞

- 讨论快照中的引用标识不包含原始链接，相关技术事实必须重新由一手资料核验。
- `Envisle` 已完成工程冲突初筛，但商标可用性仍需在域名、商店或付费品牌投入前正式复核；详见 `D-003`。
- macOS / Windows / Android 的虚拟化、镜像分发和许可边界不同，不能把能力矩阵当作统一承诺。
- 当前领域测试与独立工程 review 不是正式安全认证；真实 guest firewall/transport 进入产品前仍需冻结审核计划并做 Probe。
- 当前计划外活跃 Task 占比：`0/0`（当前无活跃 Task）。

## 已关闭索引

- `T-001 讨论成果驱动的项目初始化` — `done`，2026-08-19；[关闭证据](archive/done-log.md#t-001)。
- `T-004 首个 MVP 产品路径与公开名称决策` — `done`，2026-08-19；[关闭证据](archive/done-log.md#t-004)。
- `T-002 macOS Runtime Provider 探针` — `done`，2026-08-19；[关闭证据](archive/done-log.md#t-002)。
- `T-003 Environment 领域模型与 Provider 契约基线` — `done`，2026-08-19；[关闭证据](archive/done-log.md#t-003)。
