# 已关闭步骤块

<a id="steps-t-001-v1"></a>
## T-001 v1 — 讨论成果驱动的项目初始化

- 关闭记录：[Done Log / T-001](done-log.md#t-001)
- 任务定义版本：`v1`
- 块所有者：`/root`
- 最后更新时间：`2026-08-19 Asia/Shanghai`
- 写入模式：`single-writer`；subagent 仅做只读研究与 review，`/root` 是唯一工作区写入者和汇总者。
- 执行授权：`implicit`；来源为用户本轮初始化指令；范围限 T-001 v1。
- 目的意图：把公开讨论中的产品愿景收敛成一个能继续验证和开发的 OSDeck 仓库；补入一手资料的广度核验与任务基线，但不把候选技术栈、远期平台矩阵或许可敏感能力冻结为既定实现，也不提前实现产品功能。

### Step 1 — 讨论取证与广度调研

- 步骤开场摘要：继续“讨论成果驱动的项目初始化”，执行 Step 1；先提取讨论快照，再并行核验关键平台能力，最后分离事实、推断和待验证项。
- 本步产出：讨论摘要、官方来源索引、能力/风险矩阵与 MVP 收敛依据。
- 完成判据：讨论内容可追溯；关键架构主张由一手资料核验；无法确认项被显式标记。
- 边界：不把搜索摘要当证据；不修改外部系统；不开始功能实现。
- 风险标注：分享快照不含原始引用。
- 所需确认依据：无；用户已授权只读取证。
- 状态：`已完成`
- 实测结果：公开 API 通过 `curl` 返回标题、时间与 4 条消息；Apple、Windows、Android、QEMU 和竞品结论已重新核验。产品路径分叉与名称冲突当时记录为 [`D-001`](decisions-superseded.md#d-001) / `T-004`。

### Step 2 — 初始化项目与文档骨架

- 步骤开场摘要：继续“讨论成果驱动的项目初始化”，执行 Step 2；先初始化版本管理与最小目录，再写项目/架构/研究入口，最后提供统一检查命令。
- 本步产出：Git、README、项目 Agent 入口、ignore 规则、文档分层、最小工程骨架与 Makefile。
- 完成判据：入口真实存在；无机器专属绝对路径；职责和实现边界清楚。
- 边界：不实现 Runtime Provider、UI 或真实环境生命周期。
- 风险标注：技术栈仍需探针验证。
- 所需确认依据：无；采用可逆初始化。
- 状态：`已完成`
- 实测结果：Git `main`、P0-P3 文档、检查入口和仓库外运行数据约束已建立；没有创建绑定 Flutter/Rust/Swift 的产品代码骨架。

### Step 3 — Review、验证与可回退提交

- 步骤开场摘要：继续“讨论成果驱动的项目初始化”，执行 Step 3；先做结构和证据 review，再运行项目检查，最后同步状态并提交。
- 本步产出：review 结论、检查记录、关闭归档与 Git 提交。
- 完成判据：检查通过；无未回写的中高风险发现；任务记录一致；提交可定位。
- 边界：不扩大到后续产品功能。
- 风险标注：产品路径和品牌仍待用户决策。
- 所需确认依据：无；仅执行低风险验证与提交。
- 状态：`已完成`
- 实测结果：review 的 3 项 P1、2 项 P2 均修正并由只读复核确认 `5/5 PASS`；`git diff --check`、`bash -n`、根目录与 `/tmp` 两种入口的 `make check`/脚本检查均通过。ShellCheck 本机不可用，已由 Bash 语法检查覆盖最低门槛。相关提交为本条所在提交。

- 关闭结果：`done`
- 遗留风险：产品路径、公开名称、实现语言和 Runtime 实测仍由 `T-004`、`T-002`、`T-003` 承接。

<a id="steps-t-004-v1"></a>
## T-004 v1 — 首个 MVP 产品路径与公开名称决策

- 关闭记录：[Done Log / T-004](done-log.md#t-004)
- 任务定义版本：`v1`
- 块所有者：`/root`
- 最后更新时间：`2026-08-19 Asia/Shanghai`
- 写入模式：`single-writer`。
- 执行授权：`explicit`；用户要求综合选择满足独立环境与项目受控共享的 MVP，并授权通过 `gh` 修改 GitHub 仓库名称。
- 目的意图：冻结由项目创建并拥有隔离实例的 Runtime Platform，以 VM 为默认边界、产品授权为唯一默认共享路径；选择新名称并完成本地和 GitHub 迁移，不实现 Runtime、UI 或 guest agent。

### Step 1 — 冻结产品与安全边界

- 状态：`已完成`
- 实测结果：接受 `D-002`；选择 Managed Runtime Platform，以一 Environment 一受管 VM 为默认边界，container 仅作 VM 内优化，共享、环境间通信和入站端口默认关闭；威胁模型不覆盖宿主 root/管理员、内核/hypervisor 失陷和同用户恶意非沙箱进程直接篡改磁盘。

### Step 2 — 选择新名称并核验迁移目标

- 状态：`已完成`
- 实测结果：接受 `D-003`；选择 `Envisle/envisle`。重命名前 GitHub 目标仓库不存在，GitHub、npm、PyPI、Cargo 与公开网页未发现精确同名软件；该结果是工程冲突初筛，不是正式商标意见。

### Step 3 — 执行本地与 GitHub 名称迁移

- 状态：`已完成`
- 实测结果：有效项目术语迁移为 Envisle；提交 `b55c57b` 已推送。GitHub 从 `sqmw/osdesk` 重命名为 `sqmw/envisle`，仍为 `PUBLIC`、默认分支仍为 `main`；origin 已更新为新 URL，旧 URL 返回到新 URL 的重定向。

### Step 4 — Review、验证与关闭

- 状态：`已完成`
- 实测结果：架构、Decision、任务定义、P1 当前真相与公开名称一致性 review 无未闭环发现；`git diff --check`、Bash 语法和 `make check` 通过；新 URL、旧 URL 重定向、origin、默认分支和远端 head 均已核验。`T-002/T-003` 升级为 `v2` 以承接冻结边界。

- 关闭结果：`done`
- 遗留风险：正式商标检索未做；Runtime 可行性、共享撤销语义和实现语言仍由 `T-002 v2`、`T-003 v2` 承接。

<a id="steps-t-002-v2"></a>
## T-002 v2 — macOS Runtime Provider 探针

- 关闭记录：[Done Log / T-002](done-log.md#t-002)
- 任务定义版本：`v2`
- 块所有者：`/root`
- 最后更新时间：`2026-08-19 Asia/Shanghai`
- 写入模式：`single-writer`；Probe 源码位于 Parent 外部，Parent 产品代码保持未实现。
- 执行授权：`implicit`；用户明确同意按建议推进 ARM64 Linux VM Probe、低负载本机验证、结果回流、提交和推送。
- 目的意图：用默认可抛弃的 Probe 验证 Apple silicon + macOS 26 上受管 ARM64 Linux VM 的宿主能力、生命周期、独立磁盘、NAT、共享/端口与失败边界；运行数据置于同步目录外，实验实现不直接进入产品。

### Step 1 — 建立 Probe 身份并核验宿主前置条件

- 状态：`已完成`
- 实测结果：创建 `P-ENVI-001`，Base Revision=`b835f18367daa4ce8cd5642516bd1945a9254705`。宿主为 Apple M2/arm64、macOS 26.5.1、Hypervisor 可用、SDK 26.5、Swift 6.3.2、24 GiB；运行数据使用仓库外 `ENVISLE_PROBE_STATE_DIR`，启动材料收敛为约 19 MiB 的 Alpine aarch64 netboot 输入。

### Step 2 — 实现并验证 Host Capability Probe

- 状态：`已完成`
- 实测结果：Probe `0a23059` 输出版本化 JSON；本机 Provider=`apple_virtualization_framework`、accelerator=`apple_hypervisor`、支持状态为真。旧 macOS、非 arm64、Hypervisor/Virtualization 缺失、CPU/内存不足均独立拒绝且无 fallback；离线测试与 JSON 检查通过。

### Step 3 — 实现并实测最小 ARM64 Linux VM 闭环

- 状态：`已完成`
- 实测结果：Probe `69ea09c` 真实完成 create/start/ready/poweroff/restart/delete、两块独立 RAW disk、默认无 share、显式只读 virtiofs 和并发双 VM 网络检查。guest-to-guest TCP 在观察组合中不可达，但宿主可在无声明端口规则时连接 guest，证明 VZNAT 不是 host-to-guest firewall。压缩 kernel 与旧 cpio 两个启动失败均保留原始证据并修正，未 fallback。

### Step 4 — Review、回流结论并关闭 Probe

- 状态：`已完成`
- 实测结果：review 的空 share 参数、moving latest、日志旧尾、仓库内 state 风险均闭环；host 入站策略缺口转为 `D-005` 和 `T-003 v3` 硬约束。Probe `e0740b2` 进入 `closed/promote-findings`；仅回流证据和契约，未提升实验实现。Parent `make check`、链接、Git/远端一致性均通过。

- 关闭结果：`done`；Provider=`conditional Go`，VZNAT-only 端口策略=`No-Go`。
- 相关提交：Parent 本条所在提交；Probe `0a23059`、`69ea09c`、`e0740b2`。
- 遗留风险：guest firewall 的 default deny/allow/revoke/attestation、write-share 撤销、产品 guest image、崩溃恢复、性能和分发签名由后续任务验证。

<a id="steps-t-003-v3"></a>
## T-003 v3 — Environment 领域模型与 Provider 契约基线

- 关闭记录：[Done Log / T-003](done-log.md#t-003)
- 任务定义版本：`v3`
- 块所有者：主 Agent；单一工作树写入，独立 Agent 只读 review。
- 最后更新时间：`2026-08-19 Asia/Shanghai`
- 执行授权：用户明确要求按 Agent 推荐推进，并已授权由 Agent 综合选择最佳 MVP 方案。
- 目的意图：把 Probe 的 VM 隔离证据变成产品可依赖、可测试的 Environment/Provider/Broker 契约；不实现 UI、正式 Provider、guest 镜像、Windows/Android Provider 或认证加密存储。

### Step 1 — 冻结模块、进程、语言边界与安全不变量

- 状态：`已完成`
- 实测结果：接受 `D-007`；macOS MVP 采用单一签名 Swift 宿主，纯领域模块不依赖 Apple API，Guest Policy Agent 以版本化语言无关协议独立运行；未提升 Probe 源码。

### Step 2 — 实现最小领域模型与 Provider/Broker 契约

- 状态：`已完成`
- 实测结果：从零建立 `EnvisleDomain` Swift Package，包含身份/放置、生命周期、Provider/Router、Storage/Share/Network Broker、Guest Policy 消息、授权集合、desired/applied policy、租约与 ready 判定；无 Virtualization.framework、SwiftUI 或 AppKit 依赖。

### Step 3 — 建立架构测试与文档导航

- 状态：`已完成`
- 实测结果：25 个测试覆盖合法/非法生命周期、failed 删除门禁、默认空授权、share/port allow/revoke、Guest Policy 四消息与响应关联、RuntimeInstance evidence、Share 新鲜度、invalid desired、租约失效、最低 capability 与跨架构拒绝；README、代码地图、架构和当前真相同步。

### Step 4 — Review、验证并关闭 T-003 / M-02

- 状态：`已完成`
- 实测结果：第一轮独立工程 review 发现 6 个 P1，Step 3 重开并全部修复；第二轮确认 `6/6 PASS`、无新增 P0/P1。debug/release 测试、`make check`、`git diff --check`、链接/路径/依赖检查均通过，提交已推送。

### 变更记录

- 2026-08-19：第一轮 review 后重开 Step 3，补齐 failed 删除、RuntimeInstanceID、Share freshness、响应关联、Managed Runtime 固定安全 profile、invalid desired 和授权撤销反例；Task 定义仍为 `v3`。

- 关闭结果：`done`；Milestone `M-02` 同步关闭。
- 遗留风险：领域测试不等于真实 guest firewall/transport，也不构成正式安全认证；Guest Policy Agent 仍需独立 Probe。
