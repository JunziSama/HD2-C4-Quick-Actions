![HD2 C4 Quick Actions — C4 游戏画面封面](assets/cover.png)

# HD2 C4 Quick Actions

[English](README.en.md) · [繁體中文](README.zh-TW.md)

《绝地潜兵 2》C4 的 **PC 鼠标键盘 Mod**：手持 C4 引爆器时，**左键丢出 C4，右键引爆 C4**。装备 C4 后自动启用，不受游戏当前选择的 C4 射击模式影响；其他武器保持原本的鼠标操作。当前 0.7.1 版不读取手柄输入。

## 安装

1. 退出游戏，单独安装 [Bingus Shared Loader v18](https://github.com/CowboyBingus/BingusSharedLoader/releases/tag/v18)。
2. 将 [HD2-C4-Quick-Actions-v0.7.1-PC.zip](dist/HD2-C4-Quick-Actions-v0.7.1-PC.zip) 导入 Mod Manager，启用本 Mod 和 Loader，然后部署。
3. 停用旧版 C4 Quick Actions，同一时间只启用一个版本。

`dist/` 中的 ZIP 是可导入的 Mod 安装包；GitHub 的 Source code ZIP 是项目源码。要移除 Mod，请在 Mod Manager 中停用并重新部署。构建安装包只会在本地生成文件，不会自动修改游戏目录。

## 操作与行为

| PC 输入 | C4 动作 |
| --- | --- |
| 鼠标左键 | 丢出 C4 |
| 鼠标右键 | 引爆 C4 |

手持 C4 引爆器后，先松开鼠标左右键，再按下要使用的按键。无需 F6；长按不会连续触发，同时按下左右键时优先引爆。如果右键短按恰好遇到短暂的角色状态拦截，Mod 会在最多 200 毫秒内重新检查同一把 C4 是否可执行引爆；松开右键不会取消这次短暂等待。

R 键保留游戏原本的补弹行为。补弹、打开菜单、显示界面光标或游戏失焦会取消等待并暂停自定义输入；恢复后需要先松开鼠标键再重新按下。F7 可写入诊断日志标记。

Mod 沿用游戏原生的 C4 动作流程，不直接生成炸药或爆炸。右键原本的瞄准行为保留；切换其他武器或暂停时，会恢复游戏原本的武器输入。

## 兼容性与验证

0.7.1 针对 Steam 游戏版本 **`25480438`**。运行时在接管 C4 和调用动作前，会核对 `game.dll` 的哈希及 28 处原生代码指纹。

测试者反馈 0.7.0 在游戏中可以丢出和引爆 C4，但部分右键短按未触发。该次本地日志确认原生动作曾启动，也记录到短暂的角色状态拦截。0.7.1 的短按修复已通过离线检查，**尚未在游戏中验证**。多人游戏及特殊界面、移动状态仍需测试。

更早的 0.6.x 实机记录对应游戏版本 `24826606`。验证范围详见[验证记录](docs/VALIDATION.md)。仓库保留了历史手柄代码和安装包，但当前版本不读取手柄输入。

## 从源码构建

需要 Python 3.10+ 和 LuaJIT 2.1：

```bash
python -B scripts/check_pc.py
python -B scripts/build.py --loader /path/to/BingusSharedLoader-v18
```

打包工具版本固定在 [dependencies.lock.json](dependencies.lock.json)。详见[构建说明](docs/BUILDING.md)、[架构说明](docs/ARCHITECTURE.md)和[研究资料](research/README.md)。

项目原创代码和文档采用 [MIT 许可证](LICENSE)；外部依赖与游戏素材仍适用各自的条款，详见[第三方说明](THIRD_PARTY.md)。研究、实现和文档曾使用 AI 辅助；实机观察与模拟检查在验证记录中分别标明。

本仓库保留了 [etxp/HD2-C4-Quick-Actions](https://github.com/etxp/HD2-C4-Quick-Actions) 早期的 Git 历史；这里的 PC 专用版本是该工作的独立后续版本。
