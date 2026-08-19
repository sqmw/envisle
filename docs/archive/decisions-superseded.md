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
- 取代关系：产品路径由 [`D-002`](../DECISIONS.md#d-002) 承接；公开名称由 [`D-003`](../DECISIONS.md#d-003) 承接；实现语言约束现由 [`D-006`](../DECISIONS.md#d-006) 承接。
- 相关提交：D-001 所在初始化提交 `a66ecbc`；取代记录位于本次迁移提交。

<a id="d-004"></a>
## D-004 — 实现语言继续等待 Runtime 探针

- 日期：2026-08-19
- 原结论：产品路径与名称已冻结，但 UI、Core、Provider 和 guest agent 的实现语言保持未冻结，直到 T-002 提供调用边界、打包、权限和性能证据。
- 背景与触发原因：T-004 已关闭产品与品牌分叉；Flutter/Rust/Swift 的合理边界仍取决于 Virtualization.framework entitlement、进程边界、guest agent 交付和跨平台复用证据。
- 产生上下文：Project `Envisle`，Milestone `M-01`，Task `T-004 v1`，Step 3。
- 被否决的选项及理由：立即生成多语言大型工程会把未验证的进程与 FFI 边界固化，并扩大 T-002 探针成本。
- 原受影响实体与约束：`T-002` 使用最小隔离 Probe；`T-003` 基于实测结果再冻结模块语言与接口。
- 状态：`superseded`
- 取代关系：T-002 已完成；当前“Swift 可行但不自动冻结全栈”的约束由 [`D-006`](../DECISIONS.md#d-006) 承接。
- 相关提交：D-004 所在提交 `b55c57b`；取代记录位于本条所在 Parent 提交。
