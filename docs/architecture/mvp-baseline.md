# macOS Reference Profile 基线：受管隔离环境

本文件只约束 Apple silicon + macOS 26 的 ARM64 Linux VM reference profile，不定义 Envisle 的跨平台产品范围。Android-first 全局方向见 [`D-008`](../DECISIONS.md#d-008) 与 [`最终产品方向`](../product/final-product-proposal.md)。

## 产品目标

产品安装后直接创建并拥有独立 `Environment`，而不是只聚合用户已安装的第三方 Runtime。环境之间默认隔离；宿主与环境的数据交换必须通过产品创建、展示、撤销并记录的共享授权。

## 威胁模型

MVP 必须防止：

- 一个 Environment 直接读写另一个 Environment 的磁盘、进程或网络服务；
- 普通宿主应用通过默认共享目录、开放端口或继承配置意外干扰 guest；
- 未经产品授权的数据路径被自动暴露给 guest；
- Runtime 降级、共享扩大或网络开放在用户不可见时发生。

MVP 不宣称抵御：

- 拥有 root / Administrator 权限的宿主操作者；
- 宿主内核、hypervisor、固件或硬件被攻破；
- 同一宿主用户下可绕过平台 sandbox、直接篡改 VM 磁盘文件的恶意非沙箱进程；
- 物理访问和离线磁盘攻击。

第三项若要进入正式安全承诺，必须另行实现并验证认证加密存储、独立 broker 和密钥生命周期；仅依赖目录隐藏或同用户 Unix 权限不构成证明。

## 隔离模型

```text
Product UI / CLI
        |
Environment Control Plane
        |
Environment Supervisor
   |          |          |
Storage     Share      Network
Broker      Broker     Policy
        |
Platform VM Provider
        |
one managed VM per Environment
        |
Guest Agent
```

- 默认安全边界：每个 Environment 一台项目受管 VM。
- Container：只作为 VM 内部的工作负载与分发优化，不替代 VM 隔离边界。
- Provider：MVP 使用 Apple Virtualization.framework；跨平台 Provider 后续按相同上层契约接入。
- Guest Agent：只暴露版本化的最小策略协议，实施默认拒绝、显式端口授权、策略查询和失联租约；优雅关机等能力须使用独立最小协议，MVP 不提供任意宿主命令注入。

## 默认策略

### Storage

- 每个 Environment 使用独立磁盘和身份材料。
- 磁盘、状态、日志、缓存和镜像全部位于仓库与 Syncthing 目录之外。
- 删除、克隆与恢复必须经过产品生命周期，不允许用共享目录充当主数据盘。
- MVP 依赖宿主平台的数据保护与进程权限；认证加密磁盘列为独立安全增强，不伪装成已完成能力。

### Share

- 默认没有宿主目录挂载。
- 一条共享授权至少包含 source、target Environment、guest mount point、`read_only/read_write`、生命周期和撤销状态。
- `read_write` 不是默认值；敏感目录、密钥目录和产品状态目录永不允许共享。
- 授权创建、挂载、失败和撤销必须进入审计记录；后端不支持动态撤销时应明确要求停止 Environment，而不是静默保留挂载。

### Network

- 默认允许经 NAT 的出站访问；默认没有宿主入站端口。
- Environment 之间默认互相不可达。
- 端口发布和环境间网络必须由产品显式创建，并在界面中持续可见。
- Runtime 初始化失败时不得静默切换到隔离更弱的后端。
- `P-ENVI-001` 已实测 VZNAT 允许宿主直接连接 guest 服务，因此 NAT attachment 不是 host-to-guest 防火墙；默认拒绝、端口 allow/revoke 和实际策略证明必须由 Network Broker + guest policy agent 实施。Agent 未就绪、evidence 过期、策略身份不匹配或 evidence 不属于当前 RuntimeInstanceID 时不得 ready；策略租约超时后 guest 必须自行恢复默认拒绝，宿主不能确认隔离时必须停止 VM。

## macOS Reference 范围

- Host：Apple silicon + macOS 26。
- Guest：项目提供的 ARM64 Linux 最小镜像。
- 生命周期：create、start、graceful stop、force stop、delete。
- 数据：独立磁盘；显式只读共享；读写共享只有在撤销语义实测闭环后启用。
- 网络：NAT 出站；无默认入站；单端口显式发布。
- 可观测：宿主能力、Provider、guest 架构、状态、共享、端口和原始失败原因可见。

## macOS Reference 排除项

- macOS、Windows、Android guest 的正式支持；
- Container 作为顶层隔离边界；
- 跨 ISA TCG 作为交互性能路径；
- GPU、USB、桥接网络、环境间共享网络；
- 跨主机迁移、云托管、统一快照语义；
- 抵御宿主管理员或内核失陷的安全承诺。

## 验收标准

1. 创建两个 Environment 后，二者磁盘、进程和默认网络互不可见。
2. 未授权时 guest 看不到任何宿主目录；创建只读共享后只能读取指定目录，撤销后共享不可继续使用。
3. 未发布端口时宿主不能连接 guest 服务；发布后只有指定端口可达，撤销后恢复不可达。
4. 关闭应用或 Environment 异常退出后，状态可恢复且不会遗留未记录的挂载或端口。
5. Provider、实际架构和隔离配置可查询；任何降级都必须显式失败或由用户批准。
6. 所有运行数据均在仓库和同步目录之外。
