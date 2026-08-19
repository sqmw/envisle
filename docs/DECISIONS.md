# Envisle 主 DECISIONS

历史 Decision：[`D-001`](archive/decisions-superseded.md#d-001) 已由 `D-002`、`D-003`、`D-006` 完整取代；[`D-004`](archive/decisions-superseded.md#d-004) 已由 `D-006` 取代。

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

<a id="d-005"></a>
## D-005 — Apple ARM64 Linux Provider 条件性 Go，端口策略归 Network Broker

- 日期：2026-08-19
- 一句话结论：Apple Virtualization.framework 上 ARM64 Linux 受管 VM 的生命周期、独立磁盘、NAT 和只读共享进入 Go；VZNAT 单独不能兑现 host-to-guest 默认拒绝，Network Broker 必须通过 guest firewall/policy agent 实施、撤销并证明端口策略后，产品才能宣称默认无入站端口。
- 背景与触发原因：`P-ENVI-001` 在 Apple M2/macOS 26.5.1 上完成真实 VM 闭环；无 Envisle 入站规则时宿主仍能连接 guest 服务，而并发的第二个 guest 不能连接第一个 guest 服务。
- 产生上下文：Project `Envisle`，Milestone `M-02`，Task `T-002 v2`，Step 4；Probe Outcome=`promote-findings`。
- 被否决的选项及理由：
  - 直接把 VZNAT 解释为“默认无入站”：与宿主 TCP 实测冲突，会产生虚假安全承诺。
  - 因端口策略缺口否决整个 VM Provider：生命周期、存储、guest 间隔离和只读共享已有独立成功证据，问题位于可单独设计的 guest 网络策略层。
  - 直接提升 Probe 实现：实验代码、ad-hoc 签名和 initramfs overlay 未承担产品质量与分发约束，违反 Probe Promotion 边界。
- 受影响实体与由此产生的约束：`T-003` 升级为 `v3`，契约必须包含 guest firewall 的默认拒绝、显式 allow、revoke、策略状态/版本证明和失败关闭；Provider 仍须报告实际 Apple Hypervisor 与原始错误；产品实现必须在 Parent 重写，不复制 Probe 源码。
- 状态：`accepted`
- 相关提交：本条所在提交；Probe commits `0a23059`、`69ea09c`、`e0740b2`。

<a id="d-006"></a>
## D-006 — Probe 证明 Swift 可行但不自动冻结产品语言

- 日期：2026-08-19
- 一句话结论：T-002 已证明 Swift 可调用、签名并运行 Apple Virtualization.framework，但这只证明 macOS adapter 的可行实现路径；UI、Core、正式 Provider 和 guest policy agent 的语言与进程边界仍由 `T-003 v3` 结合契约确定。
- 背景与触发原因：`D-004` 的等待条件已由 T-002 满足；Probe 使用 Swift 6.3.2 成功运行 VM，但没有比较 FFI、打包、跨平台 Core、guest agent 分发或产品维护成本。
- 产生上下文：Project `Envisle`，Milestone `M-02`，Task `T-002 v2`，Step 4。
- 被否决的选项及理由：
  - 因 Probe 成功立即冻结全栈 Swift：把“一个原生 adapter 可行”越界推断为“全部模块最优”，证据不足。
  - 继续声称还在等待 Runtime 探针：T-002 已完成，会让当前真相停留在失效条件。
- 受影响实体与由此产生的约束：`T-003 v3` 必须显式决定模块、进程与语言边界；在其关闭前不生成正式多语言产品骨架。Swift Probe 代码不提升，只作为调用与 entitlement 证据。
- 状态：`accepted`
- 相关提交：本条所在提交；取代 `D-004`。

<a id="d-007"></a>
## D-007 — macOS MVP 采用单进程 Swift 宿主与语言无关 Guest Policy 协议

- 日期：2026-08-19
- 一句话结论：macOS MVP 的 Control Plane、Broker 编排和 Apple Runtime Provider 位于同一签名用户进程，以 Swift 分层实现；纯领域模块不依赖 Apple API，guest policy agent 是 VM 内独立进程并通过版本化、语言无关契约交换 desired network policy 与 applied network evidence，宿主 Share Broker 单独证明共享状态，agent 实现语言暂不冻结。
- 背景与触发原因：T-002 已实测 Swift 与 Virtualization.framework、entitlement 和 VM 生命周期可行，同时证明 VZNAT 不能单独兑现宿主到 guest 的默认拒绝；T-003 需要在最少分布式状态和最小打包面下，把生命周期与安全策略的实际状态统一对账。
- 产生上下文：Project `Envisle`，Milestone `M-02`，Task `T-003 v3`，Step 1；用户授权由 Agent 综合选择最佳 MVP 方案并明确要求按建议推进。
- 收益：原生框架调用、签名、entitlement 和错误保真不经过 FFI/IPC；Environment、Broker 与 Provider 在一个事务边界内协调；纯领域模块和版本化 guest 协议仍可独立测试并为未来 Provider 复用。
- 成本与风险：宿主领域代码首阶段不能直接复用于 Windows/Android；单进程故障域较大；若平台数量增加，Swift 领域实现可能出现重复。通过模块依赖单向化、Provider 隔离、稳定值类型和语言无关协议控制迁移成本。
- 被否决的选项及理由：
  - Flutter UI + Rust Core + Swift FFI 立即并行：在没有 UI 或第二平台 Provider 的条件下先引入三套工具链、FFI 生命周期和跨进程/跨语言错误映射，不能补上当前 guest policy 证据缺口。
  - 把正式 Provider 独立为 helper 进程：现阶段没有权限隔离或崩溃恢复的实测收益，却会增加签名、entitlement、IPC、状态重放和错误归因面。
  - 全部逻辑写入 Provider：会把 Environment 语义绑定到 Apple API，阻断替换 Provider 和纯领域测试。
  - 立即冻结 guest agent 为 Swift 或 Rust：T-002 未验证 guest 内分发、升级、静态链接和协议恢复，不足以决定实现语言；协议边界才是当前必须冻结的部分。
- 冻结不变量：一个 Environment 拥有一个受管 VM 与独立系统盘；默认无宿主目录共享、无 host-to-guest allow、无 guest-to-guest 通信承诺；所有共享和端口入口均由 Broker 产生版本化授权；只有 Runtime 已运行、guest agent 健康且 applied policy 与 desired policy 的 revision/digest 一致时 Environment 才为 ready；无法证明策略时必须保持隔离或停止，不能沿用“最后一次成功”宣称安全。
- 迁移触发条件：第二个正式宿主 Provider 出现已证实的重复领域逻辑，或签名/权限/崩溃隔离要求证明必须拆进程时，另立 Decision 评估共享 Rust Core 或 helper；触发前不提前生成多语言骨架。guest agent 的实现语言须在完成传输、升级、失联和 fail-closed Probe 后另行冻结。
- 受影响实体与由此产生的约束：`T-003` 产品源码从纯 Swift 领域 Package 起步，禁止依赖 Virtualization.framework；后续 Apple Provider 才接入原生框架；Network Broker 必须对账 desired/applied policy，不把已发送命令视为已实施；本条补齐并取代 `D-006` 中未决的模块/进程/语言边界。
- 状态：`accepted`
- 相关提交：本条所在提交。
