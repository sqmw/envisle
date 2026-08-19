# 已取代 Decisions

<a id="d-001"></a>
## D-001 — 初始化不冻结产品路径、公开品牌或实现语言

- 日期：2026-08-19
- 原结论：在运行探针与用户决策前，只固化 `Environment + capability-aware Provider` 共同边界；`OSDeck` 仅作工作代号。
- 背景与触发原因：讨论给出 Runtime Platform 愿景与 Flutter/Rust/原生 adapter 候选；广度调研又发现 Local Control Plane 能更低成本验证差异化，同时 `OSDeck` 已有活动 GitHub 软件组织/仓库。
- 产生上下文：Project（当时工作代号 `OSDeck`），Milestone `M-01`，Task `T-001 v1`，Step 1。
- 被否决的选项及理由：
  - 初始化时直接生成 Flutter/Rust/Swift 大型工程：会把候选技术栈误写为冻结事实。
  - 直接把 OSDeck 宣布为可用公开品牌：已有软件命名冲突，缺少正式商标结论。
  - 因冲突立即替用户改名：当时品牌选择尚无用户授权。
- 原受影响实体与约束：`M-01` 先关闭初始化与产品/名称决策，`M-02` 按探针在先、契约在后推进。
- 状态：`superseded`
- 取代关系：产品路径由 [`D-002`](../DECISIONS.md#d-002) 承接；公开名称由 [`D-003`](../DECISIONS.md#d-003) 承接；实现语言未冻结约束由 [`D-004`](../DECISIONS.md#d-004) 承接。
- 相关提交：D-001 所在初始化提交 `a66ecbc`；取代记录位于本次迁移提交。
