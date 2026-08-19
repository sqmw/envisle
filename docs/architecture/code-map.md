# 代码地图

## 当前状态

项目已建立首个纯领域 Swift Package；没有 UI、可执行程序、正式 Provider 或 guest agent。`P-ENVI-001` 是 Parent 外部且已关闭的 Probe，实验代码未提升。

| 区域 | 当前职责 | 入口 | 测试 | 状态 |
| --- | --- | --- | --- | --- |
| 项目规则 | 项目边界与首读路由 | `AGENTS.md` | `make check` | 已建立 |
| 用户入口 | 定位、状态与验证入口 | `README.md` | `make check` | 已建立 |
| 任务追踪 | Milestone / Task / Step / Decision | `docs/TODO.md` | 文档链接检查 | 已建立 |
| 架构基线 | Environment、Provider、产品路径 | `docs/architecture/` | 文档链接检查 | 已建立 |
| 研究证据 | 讨论与外部一手资料 | `docs/research/` | 人工来源 review | 已建立 |
| Swift Package | 包与工具链入口 | `Package.swift` | `swift test` | 已建立 |
| 核心身份与放置 | Environment/Provider/RuntimeInstance ID、host/guest/arch | `Sources/EnvisleDomain/CoreTypes.swift` | `RuntimeRouterTests`、`PolicyTests` | 已建立 |
| 生命周期 | 规范状态、事件与合法转换 | `Sources/EnvisleDomain/EnvironmentLifecycle.swift` | `EnvironmentLifecycleTests` | 已建立 |
| 策略与证据 | 默认拒绝、授权/撤销、版本/摘要、租约、applied evidence | `Sources/EnvisleDomain/Policy.swift` | `AuthorizationTests`、`PolicyTests`、`ReadinessTests` | 已建立 |
| 安全就绪判定 | Runtime 与 desired/applied policy 对账 | `Sources/EnvisleDomain/Readiness.swift` | `ReadinessTests` | 已建立 |
| Provider/Router | capability、精确路由、原始资源与错误 | `Sources/EnvisleDomain/RuntimeProvider.swift` | `RuntimeRouterTests` | 已建立 |
| Broker/Agent 边界 | Storage、Share、Network、Guest Policy JSON 消息与响应关联 | `Sources/EnvisleDomain/BrokerContracts.swift` | `GuestPolicyProtocolTests`、`PolicyTests` | 已建立 |
| 平台实现 | UI、macOS Control Plane、Apple Provider、guest agent | 待后续 Task | 待后续 Probe/实现测试 | 未建立 |

## 依赖方向

`EnvisleDomain` 不依赖 Apple UI 或虚拟化框架。后续 Control Plane、Broker 与 Provider 只能向内依赖领域契约；平台原生类型和运行数据路径不能反向进入领域模型。完整语义见 [`environment-contracts.md`](environment-contracts.md)。

新增产品模块时必须在本表记录职责、入口、源码路径、上下游边界、对应测试、专题文档和检索关键词。
