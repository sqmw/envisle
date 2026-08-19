# Envisle 主 DECISIONS

历史 Decision：[`D-001`](archive/decisions-superseded.md#d-001) 已由 `D-002`、`D-003`、`D-004` 完整取代。

<a id="d-002"></a>
## D-002 — MVP 采用 VM 边界的 Managed Runtime Platform

- 日期：2026-08-19
- 一句话结论：首个 MVP 由项目创建并拥有 Environment，以一实例一受管 VM 作为默认安全边界，默认无宿主共享和入站网络，数据共享只能通过产品的显式授权进入。
- 背景与触发原因：用户的目的不是管理已有 Runtime，而是安装产品后直接获得外部应用默认不可干扰的独立环境，并由产品决定可控共享。
- 产生上下文：Project（当时工作代号 `OSDeck`），Milestone `M-01`，Task `T-004 v1`，Step 1。
- 被否决的选项及理由：
  - Local Control Plane：依赖已有第三方 Runtime，无法让项目统一拥有隔离、磁盘、网络和共享策略。
  - Host container 作为默认安全边界：共享宿主内核且宿主/平台差异大，无法一致承载完整 OS Environment 的隔离语义。
  - 所有 guest 同时进入 MVP：许可、镜像、图形和设备面过宽，不能形成可证伪的首个安全闭环。
- 受影响实体与由此产生的约束：`T-002` 优先验证 Apple silicon + macOS 26 上 ARM64 Linux VM；`T-003` 必须包含 Storage/Share/Network broker 与 capability-aware Provider 契约；macOS/Windows/Android guest 后置；容器只能作为 VM 内工作负载优化。
- 状态：`accepted`
- 相关提交：本条所在提交。

<a id="d-003"></a>
## D-003 — 公开名称采用 Envisle

- 日期：2026-08-19
- 一句话结论：项目标准名称改为 `Envisle`，GitHub repository slug 改为 `envisle`；`OSDeck` 与 `osdesk` 仅作为历史旧称保留。
- 背景与触发原因：`OSDeck` 已有活动软件组织与仓库；用户授权直接选择新名称并通过 `gh` 修改已发布仓库。
- 产生上下文：Project，Milestone `M-01`，Task `T-004 v1`，Step 2。
- 被否决的选项及理由：
  - Envclave：容易暗示当前威胁模型不提供的硬件 Enclave / TEE 保障。
  - RunHaven / EnvHaven / GuestNest / RealmForge：存在明显项目、软件或品牌冲突。
  - 暂不改名：继续积累 README、包名和外部链接迁移成本。
- 受影响实体与由此产生的约束：项目当前真相、P0/P1/P2 文档、后续模块/package 命名和 GitHub remote 统一使用 `Envisle/envisle`；旧称只在讨论来源、名称调研、迁移 Decision 和历史归档中保留。
- 状态：`accepted`
- 相关提交：本条所在提交。

<a id="d-004"></a>
## D-004 — 实现语言继续等待 Runtime 探针

- 日期：2026-08-19
- 一句话结论：产品路径与名称已冻结，但 UI、Core、Provider 和 guest agent 的实现语言继续保持未冻结，直到 T-002 提供调用边界、打包、权限和性能证据。
- 背景与触发原因：T-004 已关闭产品与品牌分叉；Flutter/Rust/Swift 的合理边界仍取决于 Virtualization.framework entitlement、进程边界、guest agent 交付和跨平台复用证据。
- 产生上下文：Project `Envisle`，Milestone `M-01`，Task `T-004 v1`，Step 3。
- 被否决的选项及理由：立即生成多语言大型工程会把未验证的进程与 FFI 边界固化，并扩大 T-002 探针成本。
- 受影响实体与由此产生的约束：`T-002` 使用最小、隔离的探针工程；`T-003` 基于实测结果再冻结模块语言与接口。不得以 D-002 已冻结产品方向为由推定技术栈也已冻结。
- 状态：`accepted`
- 相关提交：本条所在提交。
