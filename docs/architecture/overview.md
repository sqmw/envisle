# 架构边界

## 问题建模

用户面对的是 `Environment`；系统面对的是不同隔离与执行模型。统一的目标是资源身份、状态、能力发现和安全生命周期，不是伪造完全相同的底层语义。

```text
User / CLI / UI
       |
Environment Application Service
       |
Capability-aware Runtime Router
       |
Provider adapters（长期扩展视图；MVP 仅 managed VM）
  |          |          |
Container    VM         Emulator / Device
```

## 最小数据表示

`T-003 v3` 已在 `EnvisleDomain` 冻结首个 Swift 值类型与语言无关 Guest Policy JSON：

- Identity：Environment、Provider 与每次启动唯一的 RuntimeInstance ID；`id`、`name`、`provider_id`、`kind`
- Placement：`host_os`、`host_arch`、`guest_os`、`guest_arch`
- State：规范化 lifecycle + Provider 原始状态；`running` 不等于 `ready`
- Capabilities：当前源码只冻结创建、启动、停止、删除与安全策略查询/隔离等 Managed VM 最低能力；暂停、快照、终端与显示仍是未来扩展
- Provenance：当前源码保留 Provider ID、原生资源 ID 与原始状态；实际 accelerator、配置来源和回退句柄尚待正式 Provider observation 契约补齐
- Policy：固定默认拒绝、显式共享/端口授权、schema/revision/digest、租约，以及分别由 Guest Agent/Host Share Broker 提供的 Network/Share applied evidence

## 方案取舍

- 公共模型使用 capability set，而不是要求每个 Provider 实现所有方法；Managed Runtime MVP 的最低安全 capability 由领域 profile 固定派生，调用方不能省略。
- 核心层只依赖 Provider contract；平台 SDK、CLI、QMP/XPC/HCS 类型留在 adapter 内。
- Router 返回选择理由和拒绝理由，不能只返回一个 runtime 名称。
- Provider 状态转换必须保留原始错误，不能吞并成笼统布尔值。
- 镜像、快照与设备仍属 Provider 专题契约；Network Broker 与最小 Guest Policy 协议已进入公共模型，但真实 transport/firewall 尚未实现。

## 证据边界

产品路径已冻结为 [`Managed Runtime Platform`](mvp-baseline.md)；[`T-002 实测`](../research/macos-runtime-probe.md)支持 Apple ARM64 Linux VM Provider 条件性 Go，但证明 VZNAT 不能单独提供 host-to-guest 默认拒绝。`T-003 v3` 已冻结单进程 Swift 宿主、纯领域 Package 与语言无关 Guest Policy v1；详见 [`Environment 契约`](environment-contracts.md)与 [`D-007`](../DECISIONS.md#d-007)。

## 验证思路

一个合格的最小 Provider 探针应证明：

1. 后端不存在时能返回可解释的不可用原因，不导致应用崩溃。
2. 资源发现保留原始 ID，重复刷新不会复制资源。
3. UI/API 只暴露 capability 允许的动作。
4. 启停结果与 Provider 原始状态一致，失败保留原始错误码。
5. 正式 Provider observation 报告实际 accelerator；许可敏感路径在未来 Provider admission 层报告 review gate。两者当前均未在领域契约实现。
6. Network Broker 的 desired/applied policy 分离；guest policy agent 未证明默认拒绝时，不得把“未声明端口规则”显示为“宿主不可达”。
