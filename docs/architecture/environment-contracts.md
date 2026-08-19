# Environment 领域与 Provider 契约 v1（macOS Reference）

本契约是 `T-003 v3` 关闭时形成的 macOS reference contract，不是 Android-first 全局契约。跨平台方向见 [`D-008`](../DECISIONS.md#d-008)；后续 Contract v2 必须保留本文历史证据，并把 Swift、VZNAT 与 Guest Agent 实施细节留在对应 Platform Profile。

## 问题建模

Envisle 不能把“VM 进程已启动”“策略命令已发送”和“用户环境已安全可用”混为一个状态。首个 MVP 把事实分为四层：

1. `EnvironmentLifecycle`：Envisle 对资源生命周期的规范化状态；
2. `DesiredEnvironmentPolicy`：用户通过 Broker 明确授权后的完整目标状态；
3. `AppliedNetworkPolicyEvidence`：guest policy agent 实际实施并回报的 firewall 状态；
4. `AppliedSharePolicyEvidence`：宿主 Share Broker 实际观察到的共享状态。

```text
Share / Port authorization
          |
          v
 Desired policy ---network---> Guest policy agent --- network evidence
          |
          +-----shares----> Host Share Broker -------- share evidence
          |                                              |
          +----------------------+-----------------------+
                                 v
 Runtime is running AND both policy components match
                       |
                 Environment ready
```

`ready` 是运行事实与两类安全事实的逻辑与。VM 已运行但任一 evidence 缺失，或网络 evidence 失联/过期，或任一组件的版本/摘要不匹配时，Environment 均保持 `notReady`；应用层随后必须要求 Network Broker 隔离，若 Broker 返回 `runtime_stop_required` 则停止 VM。

## 数据表示

### 身份与放置

- `EnvironmentID`：Environment 的稳定身份；不可用 Provider 资源 ID 代替。
- `ProviderID` + `providerResourceID`：保留原生 Provider 身份和原始状态。
- `EnvironmentPlacement`：精确表示 host OS/architecture、guest OS/architecture 和 runtime kind。
- Runtime Router 只选择放置完全匹配且拥有全部必需 capability 的 Provider；不存在静默跨 ISA fallback。

### 生命周期

```text
defined -> preparing -> stopped -> starting -> running
                            ^                    |
                            |                    v
                            +----- stopping <----+

defined / stopped -> deleting -> deleted
active operation --failure-> failed --reconcile-> stopped or deleted
```

转换由 Provider 证据驱动。请求 start 只进入 `starting`；收到实际 started 证据后才进入 `running`。`failed` 不代表 Runtime 已停止，必须先由 observe 证明为 stopped/deleted，才能继续启动或删除。非法跳转返回带原状态与事件的错误，不能改写当前状态。

### 策略身份与租约

每个策略使用 `(schema, revision, digest)` 标识：

- `schema` 控制数据契约兼容性；v1 当前值为 `1`；
- `revision` 单调区分一次授权集合变更；
- `digest` 绑定完整策略内容，防止 revision 相同但内容漂移；
- `PolicyLease` 指定宿主刷新间隔与 guest 失联后恢复默认拒绝的最长时间。

每次 start 产生新的 `RuntimeInstanceID`。Network 与 Share evidence 必须同时绑定当前实例；上一启动周期的 evidence 即使 revision/digest 相同且仍在时间窗口内，也不能用于本次 ready。

宿主只接受同一 Environment、当前 RuntimeInstanceID、同一 schema/revision/digest 且状态为 `enforced` 的 Network 与 Share evidence；网络侧还要求 agent 为 `healthy` 且 evidence 未陈旧/过期，Share evidence 最长有效 5 秒并须重新 observe。Guest Agent 必须以本地单调时钟执行 fail-closed 租约；宿主传入的 Unix 毫秒只用于 evidence 新鲜度判断，不能替代 guest 自身 watchdog。

### Guest Policy v1

`GuestPolicyApplyRequest/Response` 与 `GuestPolicyObserveRequest/Response` 是带 request ID 的版本化 JSON 消息，字段使用稳定的 `snake_case`，ID 编码为单个字符串。请求与响应都必须拒绝未知 protocol version；响应还必须与原请求的 request ID、Environment、RuntimeInstanceID 及适用的 policy version 对账，不能猜测兼容或接受串线响应。Guest 只接收 `DesiredNetworkPolicy` 投影，不能替宿主 Share Broker 证明共享状态；网络策略包含：

- 固定的 host inbound 默认拒绝与 guest peer 拒绝基线；
- 零个或多个显式 TCP/UDP guest 端口授权；
- 策略身份与 fail-closed 租约。

当前只冻结消息语义和 JSON 表示，未冻结传输方式，也未证明认证、加密、防重放、agent 升级和 guest 内 firewall 实现；这些是正式 Agent Probe 的硬验收项，不能由 Codable 测试替代。

`digest` 在领域层是 Policy Compiler 生成的不透明内容标识；规范化编码和摘要算法尚未实现，不能把测试中的示例字符串当作密码学证明。

## 模块、进程与语言边界

| 边界 | MVP 决策 | 依赖规则 |
| --- | --- | --- |
| `EnvisleDomain` | Swift Package 纯领域库 | 只能依赖 Swift/Foundation 值类型；禁止依赖 Virtualization.framework、SwiftUI 或 AppKit |
| macOS Control Plane | 后续在同一签名用户进程内以 Swift 实现 | 只通过领域协议调用 Broker/Provider，不持有 guest firewall 细节 |
| Apple Runtime Provider | 后续 Swift adapter | 可依赖 Virtualization.framework；必须保留原始错误和实际能力 |
| Guest Policy Agent | VM 内独立进程 | 只依赖版本化 guest policy 协议；实现语言待 Agent Probe 后决定 |
| UI | 不在 T-003 范围 | 只能展示领域层允许的动作和实际状态，不推断 Provider 能力 |

不在出现第二个正式宿主 Provider 或已证明的权限/故障隔离需求前引入 Rust Core、FFI 或 helper 进程。迁移触发条件与回退边界见 [`D-007`](../DECISIONS.md#d-007)。

## Provider 与 Broker 职责

- `RuntimeProvider`：create/start/stop/delete/observe VM 资源，只负责运行时生命周期。
- `StorageBroker`：每个 Environment 分配与释放唯一系统盘；真实磁盘路径不得进入公共领域模型。
- `ShareBroker`：创建或撤销宿主资源授权并查询宿主侧 applied evidence；返回 `applied` 或 `runtime_restart_required`，不能把请求成功冒充为访问已撤销。
- `NetworkBroker`：提交 desired policy、查询 applied evidence、进入 quarantine；apply receipt 只证明 Agent 接受目标版本，不证明 policy 已 enforced。
- `GuestPolicyTransport`：承载版本化 apply/observe 消息；不向 UI 或 Provider 暴露任意 guest 命令执行接口。

## 方案取舍

- 单进程 Swift 宿主减少 entitlement、签名、FFI、IPC 和状态重放面；代价是首阶段不直接复用 Windows 宿主代码。
- capability set 比“所有 Provider 同一接口能力”更诚实；`routeManagedEnvironment` 从领域内固定的 `ManagedRuntimeSecurityProfile` 派生最低能力，调用方不能传空 required set 降级。缺失 `applied_network_policy_query`、`applied_share_policy_query` 或 `quarantine` 的 Provider 不能承载本 MVP。
- 租约把宿主崩溃/失联转化为有界 fail-closed，而不是永久保留最后一次端口 allow；代价是需要周期刷新、时序测试和 guest watchdog。
- 只读共享是 v1 唯一访问级别；动态撤销未获证据时以重启 Environment 完成撤销，不承诺热更新。

## 证据边界

已实测证据仍来自 [`P-ENVI-001`](../research/macos-runtime-probe.md)：Apple ARM64 Linux VM 生命周期、独立磁盘、默认无共享、只读共享和 VZNAT 行为。T-003 的 Swift 测试只证明领域状态、路由、JSON 表示与 fail-closed 判定逻辑；没有启动 VM，也没有实施真实 firewall/share。

## 验证思路与委托边界

当前由 AI/Agent 负责具体 Swift 类型、Provider adapter、Agent transport、错误映射、自动化测试和日志证据；用户只需验收产品级语义：默认隔离是否真实成立、授权是否可见可撤销、失败是否明确。

- 做对了：`make check` 的 25 个测试全部通过；运行中 Environment 只有在相同 Environment、当前 RuntimeInstanceID 的 Network 与 Share evidence 都匹配且新鲜、网络租约有效时才 ready；缺能力的 Provider 返回逐项拒绝原因。
- 典型失败：VM 一启动就显示 ready；stop 失败后直接 delete；上一启动周期 evidence 被重放；apply receipt 被当作 enforced；响应 request ID/Environment/Runtime/版本串线仍被接受；agent 失联后旧 allow 无限期存在；share revoke 返回成功但挂载仍可用且界面无重启提示；ARM64 需求静默路由到 x86_64/TCG。
- 下一实现门槛：只有当 guest policy agent Probe 证明受认证传输、默认 drop、端口 allow/revoke、租约超时自隔离和失联恢复后，才能把 Network Broker 从契约提升为产品安全能力。
