# 音频文件说明

## 目录结构

```
assets/audio/
├── sfx/           # 音效文件目录
│   ├── attack.mp3
│   ├── hit.mp3
│   ├── skill.mp3
│   ├── kill.mp3
│   ├── coin.mp3
│   ├── exp.mp3
│   ├── levelup.mp3
│   ├── wave.mp3
│   ├── boss.mp3
│   ├── victory.mp3
│   ├── defeat.mp3
│   ├── heal.mp3
│   ├── critical.mp3
│   ├── pickup.mp3
│   ├── upgrade.mp3
│   └── shield.mp3
└── music/         # 背景音乐目录（预留）
```

## 音效文件列表

| 文件名 | 触发时机 | 建议时长 | 建议风格 |
|--------|----------|----------|----------|
| attack.mp3 | 玩家普通攻击 | 0.1-0.2秒 | 刀剑挥舞声 |
| hit.mp3 | 敌人受击 | 0.1-0.2秒 | 击中声 |
| skill.mp3 | 释放技能 | 0.2-0.3秒 | 武功特效声 |
| kill.mp3 | 击杀敌人 | 0.2-0.3秒 | 敌人死亡声 |
| coin.mp3 | 拾取金币 | 0.1-0.2秒 | 金币叮当声 |
| exp.mp3 | 拾取经验球 | 0.1秒 | 轻微吸收声 |
| levelup.mp3 | 角色升级 | 0.3-0.5秒 | 升级音效 |
| wave.mp3 | 新波次开始 | 0.3-0.5秒 | 警报/战鼓声 |
| boss.mp3 | BOSS出现 | 0.5-1秒 | BOSS登场声 |
| victory.mp3 | 游戏胜利 | 1-2秒 | 胜利音乐 |
| defeat.mp3 | 游戏失败 | 1-2秒 | 失败音乐 |
| heal.mp3 | 治疗回血 | 0.2秒 | 治愈声 |
| critical.mp3 | 暴击攻击 | 0.1-0.2秒 | 重击声 |
| pickup.mp3 | 拾取道具 | 0.1秒 | 轻微拾取声 |
| upgrade.mp3 | 技能升级 | 0.2-0.3秒 | 强化声 |
| shield.mp3 | 护盾激活 | 0.3秒 | 护盾展开声 |

## 音频格式要求

- **格式**: MP3 或 WAV
- **采样率**: 44100Hz 或 48000Hz
- **声道**: 单声道或立体声
- **比特率**: 128kbps 或更高

## 使用方法

1. 将音效文件放入 `assets/audio/sfx/` 目录
2. 确保文件名与上表一致
3. 游戏会自动加载外部音效文件
4. 如果外部文件不存在，会自动使用Web Audio API生成的备用音效

## 音量控制

游戏内置音量控制，默认音量为50%。可通过以下方式调整：

```javascript
AudioManager.setVolume(0.8);  // 设置音量为80%
AudioManager.toggle();         // 开关音效
```

## 武侠风格音效建议

为了配合游戏的武侠古风主题，建议音效风格：

- **攻击音效**: 刀剑相击、掌风呼啸
- **技能音效**: 内力释放、气功波动
- **升级音效**: 突破境界、经脉打通
- **BOSS音效**: 威压感、震撼感
- **胜利音效**: 凯旋、豪迈
- **失败音效**: 悲壮、遗憾

## 推荐音效资源网站

- [爱给网](https://www.aigei.com/sound/) - 免费音效素材
- [淘声网](https://www.tosound.com/) - 免费音效搜索
- [Freesound](https://freesound.org/) - 国际免费音效库
- [OpenGameArt](https://opengameart.org/) - 游戏素材资源

---

**提示**: 如果暂时没有合适的音效文件，游戏会使用Web Audio API自动生成占位音效，不影响游戏正常运行。
