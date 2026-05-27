#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn
Persistent

; =========================================================
; Original AHK v1 script and concept:
; Joe Winograd
; https://www.experts-exchange.com/articles/33932/
; =========================================================

CoordMode "Mouse", "Screen"

global 软件版本 := "v1.1.0"
global 作者名称 := "John-github"

global GitHub地址 :=
    "https://github.com/John-githu/Mouse-Monitor-Switcher-Ultimate"

global 配置文件 :=
    A_ScriptDir . "\MouseMonitorSwitcher.ini"

if !FileExist(配置文件)
{
    IniWrite("^!", 配置文件, "设置", "快捷键")
    IniWrite("0", 配置文件, "设置", "记忆位置")
    IniWrite("1", 配置文件, "设置", "PowerToys动画")
}

global 快捷键修饰符 :=
    IniRead(
        配置文件,
        "设置",
        "快捷键",
        "^!"
    )

global 启用记忆位置 :=
(
    IniRead(
        配置文件,
        "设置",
        "记忆位置",
        "0"
    ) = "1"
)


global 启用PowerToys动画 :=
(
    IniRead(
        配置文件,
        "设置",
        "PowerToys动画",
        "1"
    ) = "1"
)

global 动画步数 := 45
global 动画速度 := 2

global 正在动画移动 := false

try
{
    DllCall(
        "SetProcessDpiAwarenessContext",
        "ptr",
        -4,
        "ptr"
    )
}

global 显示器鼠标位置 := Map()

global 显示器编号列表 := [
    "1","2","3","4","5","6","7","8","9",
    "a","b","c","d","e","f","g","h","i",
    "j","k","l","m","n","o","p","q","r",
    "s","t","u","v","w","x","y","z"
]

global 显示器映射 := Map()

Loop 显示器编号列表.Length
{
    显示器映射[
        显示器编号列表[A_Index]
    ] := A_Index
}

注册快捷键()

构建托盘菜单()

TraySetIcon("shell32.dll", 44)

设置托盘提示()

SetTimer(
    更新鼠标位置记忆,
    200
)

return

设置托盘提示()
{
    global 软件版本
    global 快捷键修饰符

    A_IconTip :=
    (
    "鼠标跨显示器切换

版本：
" 软件版本 "

快捷键：
" 快捷键修饰符 "1~9"
    )
}

注册快捷键()
{
    global 快捷键修饰符
    global 显示器编号列表

    显示器数量 :=
        MonitorGetCount()

    try Hotkey(
        快捷键修饰符 . "0",
        "Off"
    )

    Loop 显示器数量
    {
        try
        {
            Hotkey(
                快捷键修饰符
                . 显示器编号列表[A_Index],
                "Off"
            )
        }
    }

    Hotkey(
        快捷键修饰符 . "0",
        移动到主显示器
    )

    Loop 显示器数量
    {
        Hotkey(
            快捷键修饰符
            . 显示器编号列表[A_Index],
            移动到指定显示器
        )
    }
}

构建托盘菜单()
{
    global 启用记忆位置
    global 启用PowerToys动画

    A_TrayMenu.Delete()

    A_TrayMenu.Add(
        "识别显示器",
        识别显示器
    )

    A_TrayMenu.Add(
        "显示器信息",
        显示显示器信息
    )

    A_TrayMenu.Add()

    A_TrayMenu.Add(
        "记忆鼠标位置",
        切换记忆位置
    )

    if 启用记忆位置
        A_TrayMenu.Check("记忆鼠标位置")

    A_TrayMenu.Add(
        "PowerToys 风格动画",
        切换PowerToys动画
    )

    if 启用PowerToys动画
        A_TrayMenu.Check("PowerToys 风格动画")

    A_TrayMenu.Add(
        "设置快捷键",
        设置快捷键
    )

    A_TrayMenu.Add(
        "开机启动",
        切换开机启动
    )

    if 是否开机启动()
        A_TrayMenu.Check("开机启动")

    A_TrayMenu.Add()

    A_TrayMenu.Add(
        "关于",
        显示关于
    )

    A_TrayMenu.Add()

    A_TrayMenu.Add(
        "重新加载",
        (*) => Reload()
    )

    A_TrayMenu.Add(
        "退出",
        (*) => ExitApp()
    )
}

移动到指定显示器(当前热键)
{
    global 快捷键修饰符
    global 显示器映射

    编号 :=
        SubStr(
            当前热键,
            StrLen(快捷键修饰符) + 1
        )

    if !显示器映射.Has(编号)
        return

    动画移动鼠标(
        显示器映射[编号]
    )
}

移动到主显示器(*)
{
    动画移动鼠标(
        MonitorGetPrimary()
    )
}

动画移动鼠标(显示器序号)
{
    global 正在动画移动
    global 启用记忆位置
    global 显示器鼠标位置
    global 启用PowerToys动画

    正在动画移动 := true

    MouseGetPos(
        &起始X,
        &起始Y
    )

    MonitorGetWorkArea(
        显示器序号,
        &左,
        &上,
        &右,
        &下
    )

    宽度 := 右 - 左
    高度 := 下 - 上

    if (
        启用记忆位置
        && 显示器鼠标位置.Has(显示器序号)
    )
    {
        保存位置 :=
            显示器鼠标位置[显示器序号]

        目标X :=
            左
            + Round(
                宽度
                * 保存位置.x
            )

        目标Y :=
            上
            + Round(
                高度
                * 保存位置.y
            )

        目标X :=
            Max(
                左 + 2,
                Min(右 - 2, 目标X)
            )

        目标Y :=
            Max(
                上 + 2,
                Min(下 - 2, 目标Y)
            )
    }
    else
    {
        目标X :=
            左 + Floor(宽度 / 2)

        目标Y :=
            上 + Floor(高度 / 2)
    }

    if 启用PowerToys动画
    {
        步数 := 60
        速度 := 4
    }
    else
    {
        步数 := 35
        速度 := 6
    }

    Loop 步数
    {
        t := A_Index / 步数

        平滑值 :=
            (t >= 1)
            ? 1
            : 1 - (2 ** (-10 * t))

        x := Round(
            起始X
            + ((目标X - 起始X) * 平滑值)
        )

        y := Round(
            起始Y
            + ((目标Y - 起始Y) * 平滑值)
        )

        DllCall(
            "SetCursorPos",
            "int", x,
            "int", y
        )

        DllCall("Sleep", "UInt", 1)
    }

    DllCall(
        "SetCursorPos",
        "int", 目标X,
        "int", 目标Y
    )

    Sleep(50)

    正在动画移动 := false
}

更新鼠标位置记忆()
{
    global 正在动画移动
    global 启用记忆位置
    global 显示器鼠标位置

    if !启用记忆位置
        return

    if 正在动画移动
        return

    MouseGetPos(
        &鼠标X,
        &鼠标Y
    )

    显示器数量 :=
        MonitorGetCount()

    Loop 显示器数量
    {
        MonitorGetWorkArea(
            A_Index,
            &左,
            &上,
            &右,
            &下
        )

        if (
            鼠标X >= 左
            && 鼠标X <= 右
            && 鼠标Y >= 上
            && 鼠标Y <= 下
        )
        {
            宽度 := 右 - 左
            高度 := 下 - 上

            相对X :=
                (鼠标X - 左) / 宽度

            相对Y :=
                (鼠标Y - 上) / 高度

            相对X :=
                Max(
                    0,
                    Min(1, 相对X)
                )

            相对Y :=
                Max(
                    0,
                    Min(1, 相对Y)
                )

            显示器鼠标位置[A_Index] := {
                x: 相对X,
                y: 相对Y
            }

            break
        }
    }
}

切换记忆位置(*)
{
    global 启用记忆位置
    global 配置文件

    启用记忆位置 :=
        !启用记忆位置

    IniWrite(
        启用记忆位置 ? "1" : "0",
        配置文件,
        "设置",
        "记忆位置"
    )

    构建托盘菜单()
}

切换PowerToys动画(*)
{
    global 启用PowerToys动画
    global 配置文件

    启用PowerToys动画 :=
        !启用PowerToys动画

    IniWrite(
        启用PowerToys动画 ? "1" : "0",
        配置文件,
        "设置",
        "PowerToys动画"
    )

    构建托盘菜单()
}

设置快捷键(*)
{
    global 快捷键修饰符

    窗口 := Gui()

    窗口.Title := "设置快捷键"

    窗口.SetFont(
        "s10",
        "微软雅黑"
    )

    窗口.AddText(
        "w420",
        "^ = Ctrl`n"
        "! = Alt`n"
        "+ = Shift`n"
        "# = Win`n`n"
        "示例：`n"
        "^! = Ctrl + Alt`n"
        "#! = Win + Alt`n"
        "^+# = Ctrl + Shift + Win`n`n"

		 "实际快捷键：`n"
        "Ctrl+Alt+1 → 显示器1`n"
        "Ctrl+Alt+2 → 显示器2`n"
    )
	

    输入框 :=
        窗口.AddEdit(
            "w320",
            快捷键修饰符
        )

    确定按钮 :=
        窗口.AddButton(
            "w100 Default",
            "确定"
        )

    确定按钮.OnEvent(
        "Click",
        (*) =>
        (
            保存快捷键(
                窗口,
                输入框.Text
            )
        )
    )

    窗口.Show(
        "AutoSize Center"
    )
}

保存快捷键(窗口, 新快捷键)
{
    global 快捷键修饰符
    global 配置文件

    新快捷键 :=
        Trim(新快捷键)

    if 新快捷键 = ""
        return

    快捷键修饰符 :=
        新快捷键

    IniWrite(
        快捷键修饰符,
        配置文件,
        "设置",
        "快捷键"
    )

    注册快捷键()

    设置托盘提示()

    窗口.Destroy()
}

切换开机启动(*)
{
    快捷方式 :=
        A_Startup
        . "\MouseMonitorSwitcher.lnk"

    if FileExist(快捷方式)
    {
        FileDelete(快捷方式)
    }
    else
    {
        FileCreateShortcut(
            A_ScriptFullPath,
            快捷方式,
            A_ScriptDir
        )
    }

    构建托盘菜单()
}

是否开机启动()
{
    快捷方式 :=
        A_Startup
        . "\MouseMonitorSwitcher.lnk"

    return FileExist(快捷方式)
}

识别显示器(*)
{
    窗口列表 := []

    显示器数量 :=
        MonitorGetCount()

    Loop 显示器数量
    {
        MonitorGetWorkArea(
            A_Index,
            &左,
            &上,
            &右,
            &下
        )

        中心X :=
            左 + Floor((右 - 左) / 2)

        中心Y :=
            上 + Floor((下 - 上) / 2)

        窗口 := Gui(
            "+AlwaysOnTop -Caption +ToolWindow"
        )

        窗口.BackColor := "Black"

        窗口.SetFont(
            "s42 cWhite Bold",
            "微软雅黑"
        )

        窗口.AddText(
            "Center",
            A_Index
        )

        窗口.Show(
            "x" (中心X - 80)
            " y" (中心Y - 60)
            " w160 h120 NoActivate"
        )

        窗口列表.Push(窗口)
    }

    Sleep(2500)

    for 窗口 in 窗口列表
    {
        try 窗口.Destroy()
    }
}

显示显示器信息(*)
{
    信息 := ""

    显示器数量 :=
        MonitorGetCount()

    Loop 显示器数量
    {
        MonitorGetWorkArea(
            A_Index,
            &左,
            &上,
            &右,
            &下
        )

        宽度 := 右 - 左
        高度 := 下 - 上

        信息 .=
        (
        "显示器 " A_Index "`n"
        "分辨率：" 宽度 " x " 高度 "`n"
        "左：" 左 "`n"
        "上：" 上 "`n"
        "右：" 右 "`n"
        "下：" 下 "`n`n"
        )
    }

    MsgBox(
        信息,
        "显示器信息"
    )
}

显示关于(*)
{
    global 软件版本
    global 作者名称
    global GitHub地址

    窗口 := Gui()

    窗口.Title := "关于"

    窗口.SetFont(
        "s10",
        "微软雅黑"
    )

    窗口.AddText(
        "w500 Center",
        "鼠标跨显示器切换"
    )

    窗口.AddText(
        "w500",
        "版本：" 软件版本
    )

    窗口.AddText(
        "w500",
        "作者：" 作者名称
    )

    窗口.AddText(
        "w500",
        "GitHub："
    )

    链接 :=
        窗口.AddText(
            "cBlue",
            GitHub地址
        )

    链接.SetFont(
        "underline"
    )

    链接.OnEvent(
        "Click",
        打开GitHub
    )

    检查更新按钮 :=
        窗口.AddButton(
            "w100",
            "检查更新"
        )

    检查更新按钮.OnEvent(
        "Click",
        打开GitHub
    )

    按钮 :=
        窗口.AddButton(
            "x+10 w100 Default",
            "关闭"
        )

    按钮.OnEvent(
        "Click",
        (*) => 窗口.Destroy()
    )

    窗口.Show(
        "AutoSize Center"
    )
}

打开GitHub(*)
{
    global GitHub地址

    Run(GitHub地址)
}
