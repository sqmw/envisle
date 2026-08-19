# Done Log

<a id="t-001"></a>
## 2026-08-19 — T-001 讨论成果驱动的项目初始化

- 任务定义版本：`v1`
- 结果摘要：从公开讨论快照建立了证据分层的项目基线，初始化 Git、P0-P3 文档导航、任务/决策体系、共同架构边界和统一检查入口；未冻结产品路径、品牌或实现语言。
- 验证方式：`git diff --check`、`bash -n scripts/check-project.sh`、`make check`，以及从仓库外目录直接调用检查脚本；只读 review 的 5 项发现全部闭环复核。
- 相关提交：本条所在提交。
- 文档索引：[`讨论来源`](../research/discussion-source.md)、[`广度调研`](../research/breadth-scan.md)、[`架构边界`](../architecture/overview.md)、[`产品路径`](../architecture/product-options.md)、[`关闭步骤`](steps-closed.md#steps-t-001-v1)。
- 遗留风险：首个 MVP 路径与公开名称待 `T-004`；Runtime 探针待 `T-002`；领域契约待 `T-003`。

<a id="t-004"></a>
## 2026-08-19 — T-004 首个 MVP 产品路径与公开名称决策

- 任务定义版本：`v1`
- 结果摘要：冻结 Managed Runtime Platform 产品路径，以一 Environment 一受管 VM 为默认安全边界，以显式、可撤销、可审计授权控制共享和入站端口；公开名称确定为 `Envisle`，GitHub repository 已迁移为 `sqmw/envisle`。
- 验证方式：架构/Decision/TODO/P1 一致性 review；`git diff --check`、`bash -n scripts/check-project.sh`、`make check`；GitHub 新 URL 200、旧 URL 301、origin/默认分支/visibility/远端 head 核验。
- 相关提交：`b55c57b` 与本条所在提交。
- 文档索引：[`MVP 冻结基线`](../architecture/mvp-baseline.md)、[`名称选择`](../research/name-selection.md)、[`有效 Decisions`](../DECISIONS.md)、[`关闭步骤`](steps-closed.md#steps-t-004-v1)。
- 遗留风险：Runtime 尚未实测；正式商标检索未做；认证加密存储与抵御同用户恶意宿主进程不在 MVP 已承诺能力内。

<a id="t-002"></a>
## 2026-08-19 — T-002 macOS Runtime Provider 探针

- 任务定义版本：`v2`
- 结果摘要：Apple M2/macOS 26.5.1 上 ARM64 Linux VM Provider 获得条件性 Go；生命周期、独立磁盘、默认无共享和显式只读共享实测通过。VZNAT 观察到 guest 间不可达，但允许宿主直接连接 guest，因此端口默认拒绝必须由 Network Broker + guest policy agent 实现。
- 验证方式：7 个 Swift 测试、host JSON、signed VM 多次启动/停止、双实例并发网络、只读写入拒绝、独立 inode、delete 后目录消失、仓库内 state 拒绝、代码/证据 review 与 Parent `make check`。
- 相关提交：Parent 本条所在提交；Probe `0a23059`、`69ea09c`、`e0740b2`。
- 文档索引：[`Probe 结论`](../research/macos-runtime-probe.md)、[`D-005`](../DECISIONS.md#d-005)、[`MVP 基线`](../architecture/mvp-baseline.md)、[`关闭步骤`](steps-closed.md#steps-t-002-v2)。
- 遗留风险：产品级 guest firewall/agent、端口 allow/revoke、write-share 撤销、持久系统镜像、崩溃恢复、性能与分发签名尚未验证；由 `T-003 v3` 先承接契约边界。
