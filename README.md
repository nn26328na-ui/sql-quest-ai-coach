# SQL Quest AI Coach

高级 SQL 面试闯关项目，适合部署到 GitHub Pages。

它不是 APK，也不是普通题库页。这个版本把原来的 SQL 题库升级成一个 AI 产品项目：

- 浏览器内运行 SQLite，直接判题
- 32 道高级 SQL 面试题
- ADHD 友好的单屏闯关、XP、连胜、短反馈
- AI Coach：不直接泄露答案，而是诊断卡点、给提示、生成面试追问
- Badcase Lab：失败样本会被记录成项目证据
- Project Evidence：可导出本机训练证据 JSON，用于复盘或作品集讲述

## 运行方式

最简单方式：

```bash
python -m http.server 8080
```

然后打开：

```text
http://localhost:8080
```

不要直接双击 `index.html`，因为浏览器可能阻止本地 `fetch` 读取 SQL 文件。

## 部署到 GitHub Pages

1. 新建 GitHub 仓库
2. 上传本目录全部文件
3. 打开仓库 `Settings > Pages`
4. Source 选择 `GitHub Actions`
5. 推送后 workflow 会自动发布静态站点

## AI 设置

默认使用 DeepSeek OpenAI-compatible Chat API：

- Endpoint：`https://api.deepseek.com/chat/completions`
- Model：`deepseek-v4-flash`
- API Key：只保存在本机浏览器 localStorage

如果想要更强的复盘和面试追问，可以把模型改成：

```text
deepseek-v4-pro
```

不要把 API Key 写入仓库。

如果不配置 API Key，项目仍可运行：本地规则教练会根据失败类型给提示。

## 为什么这是 AI 项目

项目底层逻辑：

```text
高级 SQL 面试刷题
-> AI 诊断错误链路和面试表达
-> 记录 eval case 与 badcase
-> 根据失败类型给下一步动作
-> 导出 evidence，支持复盘和面试讲述
```

AI 不负责“替你写答案”，而负责更适合产品项目表达的部分：

- 判断卡点属于语法、表结构、结果粒度、JOIN 放大、窗口排序还是业务口径
- 生成不剧透提示
- 把一次失败转成可复盘的 badcase
- 生成面试官追问，训练解释能力

## 面试表达边界

可以说：

- 基于高级 SQL 题库设计了 AI 面试训练原型
- 构建了浏览器端 SQL 判题链路与 badcase 记录机制
- 设计了 AI Coach 的提示、复盘、面试追问链路
- 用本机训练记录导出 eval evidence

不能说，除非你真的补做了证据：

- 已上线服务真实用户
- 真实提升通过率或面试成功率
- 做过 A/B test
- 接入了企业内部数据库
- 训练或优化了底层模型

## 文件结构

```text
.
├── index.html
├── assets/
│   └── advanced_sql_interview_challenge_pack.sql
├── src/
│   ├── app.js
│   └── styles.css
└── .github/
    └── workflows/
        └── pages.yml
```
"# sql-quest-ai-coach" 
