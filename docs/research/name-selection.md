# 公开名称选择

## 结论

- 标准产品名：`Envisle`
- GitHub repository slug：`envisle`
- 词义：`Environment + Isle`，每个环境是一座默认隔离、只通过项目受控桥梁交换数据的岛。
- 旧称映射：`Envisle` ← `OSDeck`（讨论与本地工作代号）/ `osdesk`（首次发布的 GitHub repository slug）。

## 候选比较

| 候选 | 结果 | 原因 |
| --- | --- | --- |
| Envisle | 采用 | 与隔离实例、受控共享语义直接一致；当前精确软件/包名初筛无命中 |
| Envclave | 否决 | 容易暗示硬件 Enclave / TEE 级安全，与 MVP 威胁模型不符 |
| RunHaven | 否决 | GitHub 已有 2026 年活跃的精确名称仓库 |
| EnvHaven | 否决 | 已有面向 agentic workflow 的同名项目和组织 |
| GuestNest | 否决 | 已有长期运营的住宿品牌，搜索发现性冲突明显 |
| RealmForge | 否决 | GitHub 存在多个活跃项目，名称拥挤 |

## 2026-08-19 初筛证据

- `gh api repos/sqmw/envisle`：重命名前返回 HTTP 404，目标仓库 slug 在当前账号下未占用。
- `gh search repos 'envisle in:name'`：返回空数组。
- [npm registry](https://registry.npmjs.org/envisle)：HTTP 404。
- [PyPI JSON API](https://pypi.org/pypi/envisle/json)：HTTP 404。
- `cargo search envisle --limit 5`：无结果。
- 精确公开网页搜索未发现同名软件、应用或公司结果。

## 证据边界

这是代码托管、主流包注册表和公开网页的冲突初筛，不是全球商标检索或法律意见。开始域名采购、商店发布、付费推广或视觉品牌投入前，触发正式商标与域名复核。

