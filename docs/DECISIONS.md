# OSDeck 主 DECISIONS

<a id="d-001"></a>
## D-001 — 初始化不冻结产品路径、公开品牌或实现语言

- 日期：2026-08-19
- 一句话结论：在运行探针与用户决策前，只固化 `Environment + capability-aware Provider` 共同边界；`OSDeck` 仅作工作代号。
- 背景与触发原因：讨论给出 Runtime Platform 愿景与 Flutter/Rust/原生 adapter 候选；广度调研又发现 Local Control Plane 能更低成本验证差异化，同时 `OSDeck` 已有活动 GitHub 软件组织/仓库。
- 产生上下文：Project `OSDeck`，Milestone `M-01`，Task `T-001 v1`，Step 1。
- 被否决的选项及理由：
  - 初始化时直接生成 Flutter/Rust/Swift 大型工程：会把候选技术栈误写为冻结事实。
  - 直接把 OSDeck 宣布为可用公开品牌：已有软件命名冲突，缺少正式商标结论。
  - 因冲突立即替用户改名：品牌选择属于用户宏观决策，当前只需阻止无意锁定。
- 受影响实体与由此产生的约束：`M-01` 只关闭初始化与产品/名称决策，`M-02` 按 `T-002` 探针在先、`T-003` 契约基线在后推进；任何产品代码骨架、公开品牌或发布配置都必须先完成产品路径与名称决策。
- 状态：`accepted`
- 相关提交：本条所在提交。
