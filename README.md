# EchoChat

一个基于 Electron + Vue 3 + NestJS 的现代化企业协同办公桌面应用。

## 🌟 项目亮点

### 技术栈
- **前端**: Vue 3 + TypeScript + Electron
- **后端**: NestJS + Prisma + MySQL
- **实时通讯**: WebSocket
- **文件存储**: MinIO
- **工程化**: Monorepo (Workspace) 架构

### 核心功能
1. **即时通讯**
   - 支持私聊/群聊
   - 多媒体消息（文本/图片/文件/语音）
   - 消息已读/未读状态
   - 在线状态实时同步

2. **组织架构**
   - 完整的企业组织架构树
   - 部门/成员管理
   - 灵活的权限控制

3. **工作协同**
   - 工时填报
   - 加班管理
   - 考勤系统
   - 月度报告

4. **项目管理**
   - 项目创建与跟踪
   - 成员协作
   - 文件共享
   - 进度监控

5. **文档协作**
   - 实时协作编辑
   - 版本历史记录
   - 文档权限管理

## 📁 项目结构

### 开发环境

```bash
# 同时启动前端和后端
npm run dev

# 单独启动前端
npm run dev:electron

# 单独启动后端
npm run dev:backend
```

## 🚀 快速开始

### 环境要求

- Node.js >= 16
- MySQL >= 8.0
- MinIO Server

### 安装依赖

```bash
# 安装所有依赖（包括子项目）
npm install
```

### 构建

```bash
# 构建整个项目
npm run build

# 分别构建
npm run build:electron
npm run build:backend
```

## 🎯 技术特点

1. **Monorepo 工程化**
   - 使用 npm workspaces 管理多个包
   - 统一的依赖管理
   - 一致的开发体验

2. **现代化前端架构**
   - 基于 Vue 3 Composition API
   - TypeScript 类型安全
   - Tailwind CSS 原子化样式

3. **高性能后端**
   - NestJS 模块化架构
   - Prisma ORM 数据库操作
   - WebSocket 实时通讯

4. **桌面端优化**
   - 原生窗口管理
   - 系统托盘集成
   - 离线数据支持

## 📄 License

MIT License
