# Envisle 主 STEPS

- 活跃步骤块：`1`
- 挂起步骤块：`0`
- 关闭步骤归档：[`docs/archive/steps-closed.md`](archive/steps-closed.md)

关闭索引：[`T-001 v1 讨论成果驱动的项目初始化`](archive/steps-closed.md#steps-t-001-v1)、[`T-004 v1 首个 MVP 产品路径与公开名称决策`](archive/steps-closed.md#steps-t-004-v1)、[`T-002 v2 macOS Runtime Provider 探针`](archive/steps-closed.md#steps-t-002-v2)、[`T-003 v3 Environment 领域模型与 Provider 契约基线`](archive/steps-closed.md#steps-t-003-v3)。

<a id="steps-t-005-v1"></a>
## T-005 v1 — 全局漂移审查与最终产品方案定稿

- 状态：`in_progress`
- 块所有者：主 Agent；只读子 Agent 分领域审查，主 Agent 为唯一工作区写入者和汇总者。
- 执行授权：用户于 2026-08-19 明确要求“全部 review 一下是否漂移，然后讨论并定下我们最终的产品方案”。
- 目的意图：把仓库当前代码、任务状态、架构文档、项目规则、Probe 证据和最新外部平台/竞品事实统一对账，先修复不改变冻结基线的漂移，再形成一个可执行的最终产品方案；保持一 Environment 一受管 VM、默认无共享/入站和产品授权桥梁不变，不实现正式产品功能。
- 完成判据：所有发现按严重度、证据和处置归档；最终产品方案覆盖目标用户、核心体验、首发范围、技术栈、模块/进程、数据/安全、分发、路线与验收；事实和预测分离；Decision/P0/P1/P2/TODO 一致；review、检查、提交与推送闭环。

### Step 1 — 全局事实、源码、文档与外部证据审查

- 状态：`in_progress`
- 步骤开场摘要：并行审查代码契约、安全模型、文档任务状态、macOS 交付限制和当前竞品定位，建立漂移清单与证据边界；只修正不涉及方案取舍的客观漂移。
- 完成判据：仓库/远端/测试状态已核验；所有 P0/P1 漂移可定位；外部时效性事实有一手来源；冻结基线未被修改。

### Step 2 — 比较候选并确定最终产品方案

- 状态：`not_started`
- 步骤开场摘要：在已核验约束内比较 2–3 条产品收敛路径，按用户价值、差异化、实现风险、证据缺口和退出条件选定唯一方案。
- 完成判据：目标用户与核心任务唯一；Must/Should/Not now 明确；技术栈、进程、Provider、Guest、Broker、镜像、分发和阶段路线无互相冲突；被否决选项与触发重评条件可追溯。

### Step 3 — 记录 Decision 并同步产品与项目文档

- 状态：`not_started`
- 步骤开场摘要：把最终方案写入唯一产品基线与 Decision，修正 P0/P1/P2 漂移，更新代码地图、研究证据和当前真相，不把预测写成完成事实。
- 完成判据：README、AGENTS、当前真相、TODO、Decision、产品方案和代码地图一致；文档入口可低成本定位；历史只在归档保留。

### Step 4 — Review、验证与关闭

- 状态：`not_started`
- 步骤开场摘要：执行独立只读复核、项目检查和远端一致性核验，修复范围内问题后归档 T-005/M-03。
- 完成判据：review 无未处理 P0/P1；`make check` 与文档/路径检查通过；任务归档、提交拆分和 GitHub 推送可追溯。
