# Envisle 主 STEPS

- 活跃步骤块：`1`
- 挂起步骤块：`0`
- 关闭步骤归档：[`docs/archive/steps-closed.md`](archive/steps-closed.md)

关闭索引：[`T-001 v1 讨论成果驱动的项目初始化`](archive/steps-closed.md#steps-t-001-v1)、[`T-004 v1 首个 MVP 产品路径与公开名称决策`](archive/steps-closed.md#steps-t-004-v1)、[`T-002 v2 macOS Runtime Provider 探针`](archive/steps-closed.md#steps-t-002-v2)。

<a id="steps-t-003-v3"></a>
## T-003 v3 — Environment 领域模型与 Provider 契约基线

- 状态：`in_progress`
- 块所有者：主 Agent
- 执行授权：用户于 2026-08-19 明确要求“按照你的建议推进”；此前同时授权由 Agent 综合选择最佳 MVP 方案。本块据此执行并冻结最小 macOS MVP 的契约基线。
- 目的意图：把探针已证明的 VM 隔离能力变成产品可依赖、可测试的领域契约，使每个 Environment 的生命周期、独立存储、共享授权、端口授权和真实策略状态都由 Envisle 统一拥有；本轮只建立纯领域源码与架构测试，不实现 UI、正式 Virtualization.framework Provider、guest 镜像、Windows/Android Provider 或认证加密存储。
- 当前假设与取舍：宿主 MVP 采用单一签名进程和 Swift 分层模块，领域层不依赖 Apple API；guest policy agent 保持独立进程，以版本化语言无关协议连接，暂不冻结其实现语言；默认无共享和入站，策略无法证明时 Environment 不进入 ready。
- 完成判据：唯一术语和状态机已写入源码/文档；Runtime Router、Provider、Storage/Share/Network Broker 以及 desired/applied policy 契约具备清晰边界；默认拒绝、显式放行、撤销、能力不足和策略失配均有自动化测试；Decision、代码地图和当前真相同步，review 与项目检查通过。

### Step 1 — 冻结模块、进程、语言边界与安全不变量

- 状态：`completed`
- 步骤开场摘要：基于 T-002 实测证据，把单进程 Swift 宿主、平台无关领域层、原生 Provider 适配层、独立 guest policy agent 及 fail-closed ready 判定记录为可追溯架构决策。
- 完成判据：Decision 明确收益、成本、风险、迁移触发条件和不变量；未把 Probe 源码直接提升为产品实现。

### Step 2 — 实现最小领域模型与 Provider/Broker 契约

- 状态：`completed`
- 步骤开场摘要：在 Parent 仓库从零建立 Swift Package，只实现纯领域类型、状态转换、能力路由、授权与 desired/applied policy 对账，不接入平台框架。
- 完成判据：源码职责单一、无 Virtualization.framework 依赖；Environment 只有在 Runtime 与目标策略均已实际满足时才可 ready；不支持能力返回稳定且可解释的失败。

### Step 3 — 建立架构测试与文档导航

- 状态：`in_progress`
- 步骤开场摘要：用测试固定生命周期、默认拒绝、授权撤销、策略失配和 Provider 路由语义，并同步 README、架构说明、代码地图与工具链基线。
- 完成判据：核心正反路径均有自动化证据；Agent 可从文档入口定位模块、入口、测试和安全边界；长期文档不含机器绝对路径。

### Step 4 — Review、验证并关闭 T-003 / M-02

- 状态：`not_started`
- 步骤开场摘要：检查实现与冻结决策一致性，运行 Swift 测试和项目检查，修复范围内问题后归档步骤与完成证据。
- 完成判据：review 无未处理的范围内问题；验证通过；T-003 与 M-02 状态、Done Log、当前真相一致；提交可追溯并推送远端。
