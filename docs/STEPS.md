# Envisle 主 STEPS

- 活跃步骤块：`1`
- 挂起步骤块：`0`
- 关闭步骤归档：[`docs/archive/steps-closed.md`](archive/steps-closed.md)

关闭索引：[`T-001 v1 讨论成果驱动的项目初始化`](archive/steps-closed.md#steps-t-001-v1)、[`T-004 v1 首个 MVP 产品路径与公开名称决策`](archive/steps-closed.md#steps-t-004-v1)。

<a id="steps-t-002-v2"></a>
## T-002 v2 — macOS Runtime Provider 探针

- TODO 回链：[T-002](TODO.md#t-002)
- 任务定义版本：`v2`
- 块所有者：`/root`
- 最近更新时间：`2026-08-19 Asia/Shanghai`
- 写入模式：`single-writer`；Probe 源码位于 Parent 外部同级目录，`/root` 是唯一写入者。
- 执行授权：`implicit`；用户于本轮明确同意按建议推进。授权范围为建立并执行 ARM64 Linux VM Probe、低负载本机验证、结果回流、提交和推送；不包括大型系统镜像下载、长时间安装、正式产品代码或冻结实现语言。
- 目的意图：用默认可抛弃的隔离 Probe 验证 Apple silicon + macOS 26 上 Envisle 能否创建并拥有 ARM64 Linux VM，取得宿主能力、生命周期、独立磁盘、NAT、显式共享/端口以及失败边界的实测证据；先做低成本闭环，运行数据置于同步目录外，不把实验实现直接并入产品。
- 定义对账：目标与 [T-002 v2](TODO.md#t-002) 一致；将验证载体收窄为外部 Probe，并把任何大型镜像下载或长时间安装排除在当前授权之外，不改变任务级完成定义。

### Step 1 — 建立 Probe 身份并核验宿主前置条件

- 步骤开场摘要：继续“macOS Runtime Provider 探针”，当前执行 Step 1，目标是让验证对象和宿主基线可追溯；先记录 Probe 出生证明，再检查芯片、系统、SDK、Swift 与虚拟化能力，最后确定不依赖大型下载的最小启动材料。
- 本步产出：外部 Probe、精确 Base Revision、host/toolchain 事实和启动材料策略。
- 完成判据：`PROBE.md` 字段完整；宿主与工具链信息可复现；运行数据目录明确位于仓库与同步目录外；进入实现所需条件没有未知阻塞。
- 边界：不写 VM 产品代码，不下载大型镜像，不启动 VM。
- 风险标注：macOS/SDK 版本或 entitlement 缺失可能使后续步骤形成 No-Go 证据。
- 所需确认依据：无；属于已授权探针的低风险准备。
- 状态：`进行中`
- 实测结果：待执行。

### Step 2 — 实现并验证 Host Capability Probe

- 步骤开场摘要：继续“macOS Runtime Provider 探针”，当前执行 Step 2，目标是把宿主可用性变成机器可读事实；先实现最小 Swift capability probe，再补离线测试和统一命令入口，最后在本机验证成功与失败输出。
- 本步产出：可执行 host probe、结构化结果、测试与说明。
- 完成判据：输出芯片、macOS、Virtualization 支持、CPU/内存边界和所选后端；不满足基线时明确拒绝；检查与测试通过。
- 边界：不启动 guest，不冻结产品接口。
- 风险标注：公开 API 无法直接证明所有 entitlement/签名行为，必须区分静态能力与实际启动证据。
- 所需确认依据：无。
- 状态：`未开始`
- 实测结果：待执行。

### Step 3 — 实现并实测最小 ARM64 Linux VM 闭环

- 步骤开场摘要：继续“macOS Runtime Provider 探针”，当前执行 Step 3，目标是获得 Runtime 的真实启动与隔离证据；先实现独立磁盘、NAT、串口和显式共享配置，再用小型 ARM64 启动材料验证生命周期与策略，最后记录不可闭环项的原始失败。
- 本步产出：最小 VM runner、运行数据布局、生命周期/网络/共享/端口证据。
- 完成判据：create/start/stop/delete 与 guest 就绪可复现；独立磁盘及默认无共享/入站可检查；显式共享和端口至少得到成功证据或可定位的 No-Go 失败。
- 边界：不做完整 Linux 安装、GUI、快照、产品级 guest agent 或大型镜像下载。
- 风险标注：小型 initramfs 可能缺少 virtiofs 或持久化工具；缺失必须记为材料能力边界，不能伪装成平台不支持。
- 所需确认依据：若最小材料仍需明显高负载或大型下载，执行前另行说明；否则无需确认。
- 状态：`未开始`
- 实测结果：待执行。

### Step 4 — Review、回流结论并关闭 Probe

- 步骤开场摘要：继续“macOS Runtime Provider 探针”，当前执行 Step 4，目标是只把可信知识带回主线；先 review 代码与证据边界，再判定 Probe Outcome 和 Go/No-Go，最后同步 Decision、代码地图、任务归档并提交。
- 本步产出：review 结论、`PROBE.md` 终态、Decision、Parent 文档和关闭证据。
- 完成判据：实测与推断分开；Probe 取得允许的终态；T-002、STEPS、Done Log 和 M-02 状态一致；Parent 检查通过且提交可回退。
- 边界：不直接复制 Probe 实现到产品，不启动 T-003。
- 风险标注：若运行证据不足，T-002 必须保持 blocked 或形成 No-Go，不能以编译成功代替运行闭环。
- 所需确认依据：无；若发现必须改变冻结基线则停止并请求解冻。
- 状态：`未开始`
- 实测结果：待执行。
