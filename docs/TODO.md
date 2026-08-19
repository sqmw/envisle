# Envisle 主 TODO

## 项目目标

Envisle 安装后创建并拥有独立 Environment，以受管 VM 为默认安全边界，并通过项目显式授权控制宿主共享与网络入口。当前先验证 Apple silicon + macOS 26 上的 ARM64 Linux 环境闭环。

## Milestones

<a id="m-01"></a>
### M-01 可执行的项目基线

- 状态：`in_progress`
- 达成状态：仓库具备明确的产品边界、来源可追溯的技术判断、低上下文文档入口和可继续开发的最小工程骨架。
- 验收标准：项目约束、当前真相、架构边界、研究证据、验证入口和后续任务均可从 `README.md` / `docs/README.md` 定位；初始化检查通过；Git 提交可回退。
- 归属 Task：`T-001`、`T-004`

<a id="m-02"></a>
### M-02 macOS Apple Silicon 探针闭环

- 状态：`pending`
- 达成状态：用最小探针验证首发平台的 Runtime Provider 可行性，并形成可冻结的 MVP 方案。
- 验收标准：宿主能力探测、至少一个 guest 路径、生命周期最小闭环和失败证据均可复现；是否采用 Flutter/Rust/Swift 的边界由实测支持。
- 归属 Task：`T-002`、`T-003`（按顺序推进：先以 `T-002` 取得探针证据，再由 `T-003` 定义契约基线）。

## Active Tasks

<a id="t-002"></a>
### T-002 macOS Runtime Provider 探针

- 标准任务名称：`macOS Runtime Provider 探针`
- 任务定义版本：`v1`
- 状态：`pending`
- 优先级：`P0`
- 主归属 Milestone：`M-02`
- 必要依赖：`T-001`。
- 是什么：验证 Apple Silicon macOS 上 macOS/Linux/Android 候选 Runtime 的最小能力和宿主约束。
- 边界：只做隔离探针与证据，不进入产品化 UI、镜像目录或跨平台抽象的正式实现。
- 做完算什么：每条候选路径有可复现实测结果、失败边界和 Go/No-Go 结论。
- 当前步骤：待开始（不预建步骤块）。

<a id="t-003"></a>
### T-003 Environment 领域模型与 Provider 契约基线

- 标准任务名称：`Environment 领域模型与 Provider 契约基线`
- 任务定义版本：`v1`
- 状态：`pending`
- 优先级：`P1`
- 主归属 Milestone：`M-02`
- 必要依赖：`T-001`；应吸收 `T-002` 的实测证据后再冻结接口。
- 是什么：定义统一 Environment 生命周期、能力声明、Runtime Router 输入输出和 Provider 边界。
- 边界：只定义最小领域契约和架构测试，不预先承诺全部 host/guest 组合。
- 做完算什么：领域术语唯一、能力不可用可解释、Provider 可替换、契约测试覆盖核心状态转换。
- 当前步骤：待开始（不预建步骤块）。

<a id="t-004"></a>
### T-004 首个 MVP 产品路径与公开名称决策

- 标准任务名称：`首个 MVP 产品路径与公开名称决策`
- 任务定义版本：`v1`
- 状态：`in_progress`
- 优先级：`P0`
- 主归属 Milestone：`M-01`
- 必要依赖：`T-001`。
- 是什么：基于调研证据选择 Runtime Platform 或 Local Control Plane 作为首个 MVP，并决定公开名称策略。
- 边界：只做宏观方向、验收标准与品牌处理决策；不在该任务中实现 Provider 或制作视觉品牌。
- 做完算什么：产品路径、首批 Provider、首个端到端验收和名称处理结论得到用户明确确认，并记录为后续冻结基线。
- 当前步骤：[STEPS / T-004 v1](STEPS.md#steps-t-004-v1)

## 当前风险与阻塞

- 讨论快照中的引用标识不包含原始链接，相关技术事实必须重新由一手资料核验。
- `Envisle` 已完成工程冲突初筛，但商标可用性仍需在域名、商店或付费品牌投入前正式复核；详见 `D-003`。
- macOS / Windows / Android 的虚拟化、镜像分发和许可边界不同，不能把能力矩阵当作统一承诺。
- 当前计划外活跃 Task 占比：`0/3`。

## 已关闭索引

- `T-001 讨论成果驱动的项目初始化` — `done`，2026-08-19；[关闭证据](archive/done-log.md#t-001)。
