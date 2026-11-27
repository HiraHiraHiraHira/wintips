# wintips

Windows 快捷键与隐藏操作速查表。单页静态站点，无运行时框架、无外部 CDN 依赖，离线也能正常打开。

线上地址：<https://wintips.hiralia.com>

## 特性

- 78 条快捷键，覆盖 8 个分类：窗口与桌面、文本与输入、系统与急救、文件与鼠标组合、浏览器神技、Win + R 快捷指令、PowerToys、常用办公
- 关键词实时搜索，支持忽略空格（`Win+V` 和 `Win + V` 等价）与多词匹配
- 键帽样式渲染、桌面侧边栏与移动端横向分类栏
- 零外链：Tailwind 样式在构建期生成，字体走系统字体栈

## 目录结构

```
.
├── src/
│   ├── index.html        # 页面结构与内联脚本（数据 + 渲染逻辑）
│   └── styles.css        # Tailwind 入口 + 自定义样式
├── scripts/
│   └── build.sh          # 构建到 dist/
├── deploy/
│   ├── nginx.conf        # 1Panel / OpenResty 虚拟主机模板
│   └── deploy.sh         # 幂等部署脚本
├── dist/                 # 构建产物（不提交）
├── tailwind.config.js
├── package.json
└── LICENSE
```

## 本地开发

```bash
npm install
npm run dev     # 监听 src/ 变化，输出到 dist/assets/main.css
```

另开一个终端用任意静态服务器预览，例如：

```bash
python3 -m http.server 8080 --directory dist
```

## 构建

```bash
npm run build
```

产物只有两个文件：`dist/index.html` 和 `dist/assets/main.css`。

## 部署

面向 1Panel + OpenResty 的服务器：

```bash
bash deploy/deploy.sh
```

脚本会构建、同步 `dist/` 到 `/opt/1panel/www/sites/wintips.hiralia.com/index/`、按模板写 vhost、`nginx -t` 校验后重载，并做一次回源自检。

换域名：

```bash
DOMAIN=foo.example.com bash deploy/deploy.sh
```

> 如果 1Panel 面板里对该站点做过「保存 / 重启」，面板可能用数据库里的配置覆盖手写的 vhost，重跑一次 `deploy.sh` 即可恢复。

## 新增或修改条目

所有内容都在 `src/index.html` 的 `SHORTCUTS` 数组里：

```js
{ cat: 'window', title: '窗口贴边分屏', desc: '左右贴边分屏对照查看', keys: 'Win + ← / →' },
```

`cat` 取值对应 `CATEGORIES` 里的分类 id，新增分类时两边都要加。`keys` 里的 `+`、`/`、`→` 会被渲染成键帽之间的分隔符。

## 技术栈

- 原生 HTML / CSS / JavaScript，无框架
- Tailwind CSS 3（构建期编译，非 CDN 运行时）
- 部署层：1Panel + OpenResty（Nginx）

## License

[MIT](LICENSE)
