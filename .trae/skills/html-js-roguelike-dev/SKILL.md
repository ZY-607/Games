---
name: "html-js-roguelike-dev"
description: "提供HTML/JS肉鸽游戏开发的核心技术支持，包括Canvas渲染、随机生成系统、实时战斗系统和升级系统。当用户需要开发HTML/JS肉鸽游戏时调用。"
---

# HTML/JS肉鸽游戏开发助手

## 功能说明

本技能专注于HTML/JS肉鸽游戏的技术实现，提供以下核心功能：

1. **Canvas渲染系统**：使用HTML5 Canvas API实现游戏画面渲染，支持精灵动画、特效和场景绘制
2. **随机生成系统**：实现基于种子的随机关卡、敌人和奖励生成
3. **实时战斗系统**：开发流畅的实时战斗机制，包括碰撞检测和AI行为
4. **升级系统**：实现三选一BD构建机制，支持技能组合和流派形成
5. **数据管理**：提供游戏状态管理和本地存储方案
6. **性能优化**：优化Canvas绘制和游戏循环，确保流畅运行

## 适用场景

- 开发基于HTML/JS的中小型肉鸽游戏
- 实现实时战斗和随机生成机制
- 构建可扩展的升级系统
- 优化游戏性能和用户体验

## 技术栈

- HTML5 Canvas API
- JavaScript (ES6+)
- CSS3
- localStorage

## 开发流程

1. **项目初始化**：搭建基础项目结构，配置开发环境
2. **核心引擎**：实现游戏循环、渲染系统和输入处理
3. **游戏系统**：开发随机生成、战斗和升级系统
4. **内容开发**：设计敌人、关卡和升级选项
5. **美术集成**：集成像素风格美术素材
6. **测试优化**：测试游戏平衡性和性能优化

## 最佳实践

- 使用模块化设计，分离游戏逻辑和渲染
- 实现帧动画和碰撞检测的高效算法
- 优化Canvas绘制，减少不必要的重绘
- 使用种子随机确保游戏的可重复性
- 设计可扩展的升级系统，支持多种流派

## 常见问题

### 性能问题
- **解决方案**：使用requestAnimationFrame优化游戏循环，实现对象池减少GC

### 随机生成平衡性
- **解决方案**：使用加权随机和渐进式难度系统

### 升级系统设计
- **解决方案**：设计互相配合的技能树，确保多种有效BD组合

## 示例代码

### 游戏循环示例
```javascript
function gameLoop() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  update();
  render();
  requestAnimationFrame(gameLoop);
}
```

### 随机生成示例
```javascript
function generateLevel(seed) {
  const rng = new Random(seed);
  // 基于种子生成关卡
}
```

### 三选一升级示例
```javascript
function generateUpgrades(playerLevel) {
  const options = [];
  // 生成三个平衡的升级选项
  return options;
}
```