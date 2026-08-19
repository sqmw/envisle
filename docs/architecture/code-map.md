# 代码地图

## 当前状态

项目尚未进入实现，因此没有源代码模块。此文件用于防止初始化目录被误认为已经确定技术栈或模块所有权。

| 区域 | 当前职责 | 入口 | 测试 | 状态 |
| --- | --- | --- | --- | --- |
| 项目规则 | 项目边界与首读路由 | `AGENTS.md` | `make check` | 已建立 |
| 用户入口 | 定位、状态与验证入口 | `README.md` | `make check` | 已建立 |
| 任务追踪 | Milestone / Task / Step / Decision | `docs/TODO.md` | 文档链接检查 | 已建立 |
| 架构基线 | Environment、Provider、产品路径 | `docs/architecture/` | 文档链接检查 | 已建立 |
| 研究证据 | 讨论与外部一手资料 | `docs/research/` | 人工来源 review | 已建立 |
| 产品代码 | Core、Provider、UI、CLI | 待 MVP 路径决策 | 待定义 | 未建立 |

新增产品模块时必须在本表记录职责、入口、源码路径、上下游边界、对应测试、专题文档和检索关键词。
