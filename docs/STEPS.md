# Envisle 主 STEPS

- 活跃步骤块：`1`
- 挂起步骤块：`0`
- 关闭步骤归档：[`docs/archive/steps-closed.md`](archive/steps-closed.md)

关闭索引：[`T-001 v1 讨论成果驱动的项目初始化`](archive/steps-closed.md#steps-t-001-v1)、[`T-004 v1 首个 MVP 产品路径与公开名称决策`](archive/steps-closed.md#steps-t-004-v1)、[`T-002 v2 macOS Runtime Provider 探针`](archive/steps-closed.md#steps-t-002-v2)、[`T-003 v3 Environment 领域模型与 Provider 契约基线`](archive/steps-closed.md#steps-t-003-v3)。

<a id="steps-t-005-v2"></a>
## T-005 v2 — 全局漂移审查与最终产品方案定稿

- 状态：`in_progress`
- 块所有者：主 Agent；只读子 Agent 分领域审查，主 Agent 为唯一工作区写入者和汇总者。
- 执行授权：用户于 2026-08-19 先要求全局 review 与产品定稿，随后明确指出 Android 是当前最高优先级、macOS 只是需要实现的平台之一，并要求按最新讨论更新 docs。
- 目的意图：保留 v1 已完成的防漂移证据，把“macOS 权限化软件平台”纠正为 Android-first 的跨平台 Environment 产品；macOS 降为参考实现，Android 普通 APK、OEM/AOSP 和 guest 形态按真实权限分层，不实现正式产品功能。
- 完成判据：产品定义、平台优先级、Android 能力分叉、macOS reference profile、平台无关契约、Decision/P0/P1/P2/TODO 一致；事实和预测分离；review、检查、提交与推送闭环。
- 版本变更：`v1 → v2`；原因是用户纠正核心产品范围。v1 的源码/文档/市场/安全审查证据继续有效，v1 的“macOS 产品定位”提案被 v2 取代，未进入 accepted Decision。

### Step 1 — 全局事实、源码、文档与外部证据审查

- 状态：`completed`
- 步骤开场摘要：并行审查代码契约、安全模型、文档任务状态、macOS 交付限制和当前竞品定位，建立漂移清单与证据边界；只修正不涉及方案取舍的客观漂移。
- 完成判据：仓库/远端/测试状态已核验；所有 P0/P1 漂移可定位；外部时效性事实有一手来源；冻结基线未被修改。

- 完成证据：六个只读审查覆盖源码契约、文档状态、产品架构、安全、macOS 交付与竞品；定位并修复 T-003/语言状态、MVP container 验收、未实现 capability/provenance、D-006、历史市场假设与层数等客观漂移。代码契约另发现 Provider observation、stop/reconcile、quarantine、lease/revision、disk/audit 和 mount namespace 等产品化前 P1；不在本 Task 改代码。

### Step 2 — 记录 Android-first 跨平台产品决策并同步文档

- 状态：`completed`
- 步骤开场摘要：把 Android 第一、跨平台产品定义、macOS 参考实现和 Android 交付权限分叉写入 Decision/P0/P1/P2；不把 Android 未获权限写成产品事实。
- 完成判据：Android 是产品优先级而非未来路线；macOS 是 reference profile 而非全局定义；普通 APK、OEM/AOSP 与完整 Android guest 的差异可检索；D-005/D-007 的适用范围明确。

- 完成证据：`D-008` 已接受 Android-first 跨平台定义；P0/P1/P2 文档统一区分 Android host/guest、Public APK/Enterprise/OEM-AOSP Profiles，并将 D-002/D-005/D-007 限定为 macOS reference profile；未冻结 Android 未验证 Runtime 或全局实现语言。

### Step 3 — 独立 review、验证与关闭

- 状态：`in_progress`
- 步骤开场摘要：执行独立只读复核、项目检查和远端一致性核验，修复范围内问题后归档 T-005/M-03。
- 完成判据：review 无未处理 P0/P1；`make check` 与文档/路径检查通过；任务归档、提交拆分和 GitHub 推送可追溯。

- 当前证据：主 Agent 已完成全量 diff 自审，确认 Android host/guest 与三类交付 Profile 分离、D-002/D-005/D-007 只缩小适用范围而未改写历史证据；`make check` 通过。独立复核尚未执行，因此本步骤与 T-005/M-03 保持 `in_progress`。
