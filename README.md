Original idea and AHK v1 script by Joe Winograd:
https://www.experts-exchange.com/articles/33932/

This project is a heavily modified AutoHotkey v2 version
with major rewrites and additional features.

# Mouse Monitor Switcher Ultimate

多显示器鼠标快速切换工具（AutoHotkey v2）

支持：

* 鼠标跨屏动画
* PowerToys 风格动画
* 鼠标位置记忆
* 自定义快捷键
* 开机启动
* 屏幕方向感知
* 多显示器识别

适用于：

* 多屏办公
* 超宽屏
* 横竖混合屏
* 程序员
* 设计师
* 股票/监控屏
* 游戏副屏

---

# 功能特性

## 1. 鼠标快速跨屏切换
通过快捷键瞬间将鼠标移动到指定显示器。

# 2. PowerToys 风格动画
可选开启微软 PowerToys 风格平滑动画。
默认：开启（可关闭）

# 3. 记忆鼠标位置
切换回某个显示器时：
自动回到该显示器上次鼠标位置。
默认：关闭

# 4. 屏幕方向感知
自动识别：
* 横屏
* 竖屏

# 5. 多显示器识别
托盘菜单：识别显示器
会在每个屏幕中央显示巨大编号。

# 7. 自定义快捷键

支持：

| 符号 | 含义    |
| -- | ----- |
| ^  | Ctrl  |
| !  | Alt   |
| +  | Shift |
| #  | Win   |

示例：

| 配置  | 实际快捷键              |
| --- | ------------------ |
| ^!  | Ctrl + Alt         |
| #!  | Win + Alt          |
| ^+# | Ctrl + Shift + Win |

例如：

```text id="gzjlwm"
^!
```

表示：

```text id="9djlwm"
Ctrl + Alt
```

最终快捷键：

```text id="vxjlwm"
Ctrl + Alt + 1
```

---

# 安装方法

## 方式 1（推荐）

windows10/11 系统直接运行 MouseMonitorSwitcher.exe
其它系统暂未测试


## 方式 2

安装：

[AutoHotkey v2 官方网站](https://www.autohotkey.com/?utm_source=chatgpt.com)

然后双击：

```text id="oyjlwm"
MouseMonitorSwitcher.ahk
```

即可运行。

---

# 开机启动

托盘菜单：

```text id="q0jlwm"
开机启动
```

开启后：

软件会自动创建启动快捷方式。

位置：

```text id="m5jlwm"
%AppData%\Microsoft\Windows\Start Menu\Programs\Startup
```

---


# 配置文件

程序首次运行会生成：

```text id="92jlwm"
MouseMonitorSwitcher.ini
```

# 常见问题

## 1. 快捷键无效

检查：

* 是否与其他软件冲突
* 是否开启管理员权限
* 是否正确安装 AHK v2

---

## 2. 游戏中无法移动鼠标

某些全屏游戏会锁定鼠标。

建议：

* 使用无边框窗口模式
* 以管理员权限运行脚本

---

## 3. 鼠标位置不准确

可能是：

* DPI 缩放
* 显示器排列
* 特殊超宽屏

脚本已启用 DPI 感知。

如仍异常：

尝试重新插拔显示器。

---

# 推荐快捷键

推荐：

```text id="5jjlwm"
Ctrl + Alt
```

即：

```text id="6xjlwm"
^!
```

原因：

* 不易冲突
* 单手方便
* 兼容大多数软件

---

# 系统要求

* Windows 10 / 11
* AutoHotkey v2

# 许可证

* MIT License for modifications and additions.
* Original source attribution retained.
