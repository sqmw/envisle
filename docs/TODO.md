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

<a id="m-03"></a>
### M-03 最终产品方案基线

- 状态：`in_progress`
- 达成状态：仓库当前事实、冻结决策、源码契约和外部平台证据完成全局防漂移审查；Envisle 的目标用户、核心体验、首发范围、技术架构、分发边界与后续路线形成单一可执行产品方案。
- 验收标准：漂移项逐项闭环；最终方案不把待验证能力写成产品事实；产品定位和架构选择均有证据边界、被否决选项、迁移条件与端到端验收句柄；README/P0/P1/P2/Decision/TODO 一致，review 与项目检查通过。
- 归属 Task：`T-005`。

## Active Tasks

<a id="t-005"></a>
### T-005 全局漂移审查与最终产品方案定稿

- 标准任务名称：`全局漂移审查与最终产品方案定稿`
- 任务定义版本：`v1`
- 状态：`in_progress`
- 优先级：`P0`
- 主归属 Milestone：`M-03`
- 必要依赖：`T-001`、`T-002 v2`、`T-003 v3`、`T-004 v1`。
- 是什么：全量核对项目规则、当前真相、任务与 Decision、领域源码/测试、Probe 和最新外部证据，识别事实/范围/术语/证据漂移；在冻结的 Managed Runtime Platform 与受控共享基线上，确定唯一的最终产品方案和 macOS 首发落地边界。
- 边界：本 Task 可以修正无争议的事实与文档漂移并新增产品 Decision；不实现 UI、正式 Provider、Guest Policy Agent 或运行镜像，不修改 D-002 的默认 VM 隔离和产品受控共享冻结基线，除非用户另行明确解冻。
- 做完算什么：漂移审查有可定位结论；目标用户、核心场景、非目标、宿主/guest、技术栈、模块/进程、数据/网络/共享、分发和阶段路线唯一；每项产品承诺均映射到已实测或待验证证据；独立 review 和 `make check` 通过，提交已推送。
- 当前步骤：Step 1 — 全局事实、源码、文档与外部证据审查；详见 [`docs/STEPS.md`](STEPS.md#steps-t-005-v1)。

## 当前风险与阻塞

- 讨论快照中的引用标识不包含原始链接，相关技术事实必须重新由一手资料核验。
- `Envisle` 已完成工程冲突初筛，但商标可用性仍需在域名、商店或付费品牌投入前正式复核；详见 `D-003`。
- macOS / Windows / Android 的虚拟化、镜像分发和许可边界不同，不能把能力矩阵当作统一承诺。
- 当前领域测试与独立工程 review 不是正式安全认证；真实 guest firewall/transport 进入产品前仍需冻结审核计划并做 Probe。
- 当前计划外活跃 Task 占比：`0/1`。

## 已关闭索引

- `T-001 讨论成果驱动的项目初始化` — `done`，2026-08-19；[关闭证据](archive/done-log.md#t-001)。
- `T-004 首个 MVP 产品路径与公开名称决策` — `done`，2026-08-19；[关闭证据](archive/done-log.md#t-004)。
- `T-002 macOS Runtime Provider 探针` — `done`，2026-08-19；[关闭证据](archive/done-log.md#t-002)。
- `T-003 Environment 领域模型与 Provider 契约基线` — `done`，2026-08-19；[关闭证据](archive/done-log.md#t-003)。
