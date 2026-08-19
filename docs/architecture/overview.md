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
Provider adapters
  |          |          |
Container    VM         Emulator / Device
```

## 最小数据表示

初始化只确定可迁移字段，不冻结语言级类型：

- Identity：`id`、`name`、`provider_id`、`kind`
- Placement：`host_os`、`host_arch`、`guest_os`、`guest_arch`
- State：规范化状态 + Provider 原始状态
- Capabilities：发现、创建、启动、停止、暂停、快照、终端、显示、删除等独立声明
- Provenance：原始 Provider ID、版本、配置来源与可回退命令
- Policy：许可审查、权限、架构与性能 profile

## 方案取舍

- 公共模型使用 capability set，而不是要求每个 Provider 实现所有方法。
- 核心层只依赖 Provider contract；平台 SDK、CLI、QMP/XPC/HCS 类型留在 adapter 内。
- Router 返回选择理由和拒绝理由，不能只返回一个 runtime 名称。
- Provider 状态转换必须保留原始错误，不能吞并成笼统布尔值。
- 镜像、快照、网络、设备和 guest agent 属于 Provider 专题契约，未验证前不进入公共最小模型。

## 证据边界

产品路径已冻结为 [`Managed Runtime Platform`](mvp-baseline.md)；实现语言、Provider 语言级接口与 public API 仍须由后续任务结合探针结果确定。

## 验证思路

一个合格的最小 Provider 探针应证明：

1. 后端不存在时能返回可解释的不可用原因，不导致应用崩溃。
2. 资源发现保留原始 ID，重复刷新不会复制资源。
3. UI/API 只暴露 capability 允许的动作。
4. 启停结果与 Provider 原始状态一致，失败保留原始错误码。
5. QEMU 路径报告实际 accelerator；许可敏感路径报告 review gate。
