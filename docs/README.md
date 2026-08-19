# Envisle 文档路由

## 固定首读

1. `../AGENTS.md`：P0 项目边界。
2. `../README.md`：用户入口与当前定位。
3. [`agent-context/current.md`](agent-context/current.md)：P1 当前真相、风险和下一步。
4. [`TODO.md`](TODO.md) / [`STEPS.md`](STEPS.md)：任务与执行证据。

## 按关键词路由

- `讨论 / 来源 / share / chat2api` → [`research/discussion-source.md`](research/discussion-source.md)
- `竞品 / Apple / Windows / Android / QEMU / 许可` → [`research/breadth-scan.md`](research/breadth-scan.md)
- `名称 / Envisle / OSDeck / osdesk / rename` → [`research/name-selection.md`](research/name-selection.md)
- `Environment / Provider / Runtime Router / capability` → [`architecture/overview.md`](architecture/overview.md)
- `MVP / control plane / runtime platform / 产品路径` → [`architecture/product-options.md`](architecture/product-options.md)
- `隔离 / 威胁模型 / 数据共享 / 网络策略 / MVP 冻结基线` → [`architecture/mvp-baseline.md`](architecture/mvp-baseline.md)
- `模块 / 源码 / 测试 / 入口` → [`architecture/code-map.md`](architecture/code-map.md)
- `为什么 / 决策 / 名称冲突` → [`DECISIONS.md`](DECISIONS.md)

## 分层

- P0：`../AGENTS.md`
- P1：`agent-context/current.md`、`TODO.md`、`STEPS.md`、`DECISIONS.md`
- P2：`architecture/`、`research/`
- P3：`archive/`

主 DECISIONS 只保留当前有效结论；被取代正文位于 [`archive/decisions-superseded.md`](archive/decisions-superseded.md)。

## 低成本定位与校验

```bash
rg "Environment|Provider|Runtime Router|capability" README.md AGENTS.md docs
rg --files
make check
```
