# Envisle 主 TODO

## 项目目标

Envisle 安装后创建并拥有独立 Environment，以受管 VM 为默认安全边界，并通过项目显式授权控制宿主共享与网络入口。当前先验证 Apple silicon + macOS 26 上的 ARM64 Linux 环境闭环。

## Milestones

<a id="m-01"></a>
### M-01 可执行的项目基线

- 状态：`done`
- 达成状态：仓库具备明确的产品边界、来源可追溯的技术判断、低上下文文档入口和可继续开发的最小工程骨架。
- 验收标准：项目约束、当前真相、架构边界、研究证据、验证入口和后续任务均可从 `README.md` / `docs/README.md` 定位；初始化检查通过；Git 提交可回退。
- 归属 Task：`T-001`、`T-004`

<a id="m-02"></a>
### M-02 macOS Apple Silicon 探针闭环

- 状态：`in_progress`
- 达成状态：用最小探针验证 Apple silicon + macOS 26 上 ARM64 Linux 受管 VM 的 Runtime Provider 可行性，并形成可冻结的 Provider 契约。
- 验收标准：宿主能力探测、ARM64 Linux guest 生命周期、默认隔离、显式共享/端口和失败证据均可复现；Provider、Broker 与实现语言边界由实测支持。
- 归属 Task：`T-002`、`T-003`（按顺序推进：先以 `T-002` 取得探针证据，再由 `T-003` 定义契约基线）。

## Active Tasks

<a id="t-002"></a>
### T-002 macOS Runtime Provider 探针

- 标准任务名称：`macOS Runtime Provider 探针`
- 任务定义版本：`v2`
- 旧版本摘要：`v1` 原计划同时验证 macOS/Linux/Android 候选 Runtime；已由 `D-002` 收窄为首个可证伪闭环。
- 状态：`in_progress`
- 优先级：`P0`
- 主归属 Milestone：`M-02`
- 必要依赖：`T-001`。
- 是什么：验证 Apple silicon + macOS 26 上由项目创建并管理 ARM64 Linux VM 的最小能力、默认隔离和宿主约束。
- 边界：只做宿主能力、生命周期、独立磁盘、NAT、显式共享/端口的隔离探针与证据；不进入产品化 UI，不验证 macOS/Windows/Android guest，不冻结跨平台实现。
- 做完算什么：host probe 与 create/start/stop/delete 可复现；guest 就绪、独立磁盘、默认网络隔离及最小共享/端口策略有成功或明确失败证据，并形成 Go/No-Go 结论。
- 当前步骤：[STEPS / T-002 v2](STEPS.md#steps-t-002-v2)

<a id="t-003"></a>
### T-003 Environment 领域模型与 Provider 契约基线

- 标准任务名称：`Environment 领域模型与 Provider 契约基线`
- 任务定义版本：`v2`
- 旧版本摘要：`v1` 只定义通用生命周期与 Provider；`v2` 根据 `D-002` 加入产品拥有的 Storage/Share/Network broker 边界。
- 状态：`pending`
- 优先级：`P1`
- 主归属 Milestone：`M-02`
- 必要依赖：`T-001`；应吸收 `T-002 v2` 的实测证据后再冻结接口。
- 是什么：定义统一 Environment 生命周期、能力声明、Runtime Router 输入输出，以及 Storage/Share/Network broker 与 Provider 边界。
- 边界：只定义首个 ARM64 Linux 受管 VM 闭环所需的最小领域契约和架构测试，不预先承诺全部 host/guest 组合或认证加密存储。
- 做完算什么：领域术语唯一、默认隔离策略可表达、共享和端口必须经 broker 授权、能力不可用可解释、Provider 可替换，契约测试覆盖核心状态转换。
- 当前步骤：待开始（不预建步骤块）。

## 当前风险与阻塞

- 讨论快照中的引用标识不包含原始链接，相关技术事实必须重新由一手资料核验。
- `Envisle` 已完成工程冲突初筛，但商标可用性仍需在域名、商店或付费品牌投入前正式复核；详见 `D-003`。
- macOS / Windows / Android 的虚拟化、镜像分发和许可边界不同，不能把能力矩阵当作统一承诺。
- 当前计划外活跃 Task 占比：`0/2`。

## 已关闭索引

- `T-001 讨论成果驱动的项目初始化` — `done`，2026-08-19；[关闭证据](archive/done-log.md#t-001)。
- `T-004 首个 MVP 产品路径与公开名称决策` — `done`，2026-08-19；[关闭证据](archive/done-log.md#t-004)。
