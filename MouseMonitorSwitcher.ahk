#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn
Persistent

; =========================================================
; Mouse Monitor Switcher Ultimate
; AutoHotkey v2
;
; Original AHK v1 script and concept:
; Joe Winograd
; https://www.experts-exchange.com/articles/33932/
;
; GitHub:
; https://github.com/John-githu/
; Mouse-Monitor-Switcher-Ultimate
;
; Features:
; - Multi-monitor mouse switching
; - Smooth mouse animation
; - PowerToys-style animation
; - Mouse trail effects
; - Monitor mouse position memory
; - Custom hotkeys
; - Startup support
; - Portrait/Landscape awareness
; - Monitor identification
; - About dialog
; - Update checker
;
; Author:
; John-githu
;
; Version:
; v1.0.0
; =========================================================

; =========================================================
; App Info
; =========================================================

global AppVersion := "v1.0.0"

global AppAuthor := "John-githu"

global GitHubURL :=
    "https://github.com/John-githu/Mouse-Monitor-Switcher-Ultimate?tab=readme-ov-file"

; =========================================================
; Config
; =========================================================

global SettingsFile :=
    A_ScriptDir . "\MouseMonitorSwitcher.ini"

; =========================================================
; Default Config
; =========================================================

if !FileExist(SettingsFile)
{
    IniWrite(
        "^!",
        SettingsFile,
        "General",
        "HotkeyModifiers"
    )

    ; 默认关闭
    IniWrite(
        "0",
        SettingsFile,
        "General",
        "RememberPosition"
    )

    IniWrite(
        "0",
        SettingsFile,
        "General",
        "RunAtStartup"
    )

    IniWrite(
        "0",
        SettingsFile,
        "General",
        "EnableMouseTrail"
    )

    ; 默认开启 PowerToys 动画
    IniWrite(
        "1",
        SettingsFile,
        "General",
        "EnablePowerToysAnimation"
    )
}

; =========================================================
; Load Config
; =========================================================

global HotkeyModifiers :=
    IniRead(
        SettingsFile,
        "General",
        "HotkeyModifiers",
        "^!"
    )

global EnableRememberPosition :=
(
    IniRead(
        SettingsFile,
        "General",
        "RememberPosition",
        "0"
    ) = "1"
)

global EnableMouseTrail :=
(
    IniRead(
        SettingsFile,
        "General",
        "EnableMouseTrail",
        "0"
    ) = "1"
)

global EnablePowerToysAnimation :=
(
    IniRead(
        SettingsFile,
        "General",
        "EnablePowerToysAnimation",
        "1"
    ) = "1"
)

; =========================================================
; Animation
; =========================================================

global AnimationSpeed := 6
global AnimationSteps := 40

; =========================================================
; DPI Awareness
; =========================================================

try
{
    DllCall(
        "SetProcessDpiAwarenessContext",
        "ptr",
        -4,
        "ptr"
    )
}

; =========================================================
; Monitor IDs
; =========================================================

global MonitorIDs := [
    "1","2","3","4","5","6","7","8","9",
    "a","b","c","d","e","f","g","h","i","j",
    "k","l","m","n","o","p","q","r","s","t",
    "u","v","w","x","y","z"
]

global MonitorNums := Map()

Loop MonitorIDs.Length
{
    MonitorNums[MonitorIDs[A_Index]] := A_Index
}

global OrigMonitorCount := MonitorGetCount()

; =========================================================
; Mouse Memory
; =========================================================

global MonitorMousePositions := Map()

; =========================================================
; Init
; =========================================================

RegisterHotkeys()

BuildTrayMenu()

TraySetIcon("shell32.dll", 44)

SetTrayTooltip()

return

; =========================================================
; Tray Tooltip
; =========================================================

SetTrayTooltip()
{
    global AppVersion
    global HotkeyModifiers

    A_IconTip :=
    (
    "Mouse Monitor Switcher Ultimate

版本：
" AppVersion "

快捷键：

" HotkeyModifiers "1~9
" HotkeyModifiers "a~z

0 = 主显示器"
    )
}

; =========================================================
; Register Hotkeys
; =========================================================

RegisterHotkeys()
{
    global HotkeyModifiers
    global OrigMonitorCount
    global MonitorIDs

    try Hotkey(
        HotkeyModifiers . "0",
        "Off"
    )

    Loop OrigMonitorCount
    {
        try
        {
            key :=
                HotkeyModifiers
                . MonitorIDs[A_Index]

            Hotkey(
                key,
                "Off"
            )
        }
    }

    Hotkey(
        HotkeyModifiers . "0",
        MoveToPrimary
    )

    Loop OrigMonitorCount
    {
        key :=
            HotkeyModifiers
            . MonitorIDs[A_Index]

        Hotkey(
            key,
            MoveToMonitor
        )
    }
}

; =========================================================
; Tray Menu
; =========================================================

BuildTrayMenu()
{
    global EnableRememberPosition
    global EnableMouseTrail
    global EnablePowerToysAnimation

    A_TrayMenu.Delete()

    A_TrayMenu.Add(
        "识别显示器",
        IdentifyMonitors
    )

    A_TrayMenu.Add(
        "显示显示器信息",
        ShowMonitorInfo
    )

    A_TrayMenu.Add()

    A_TrayMenu.Add(
        "记忆鼠标位置",
        ToggleRememberPosition
    )

    if EnableRememberPosition
        A_TrayMenu.Check("记忆鼠标位置")

    A_TrayMenu.Add(
        "鼠标轨迹特效",
        ToggleMouseTrail
    )

    if EnableMouseTrail
        A_TrayMenu.Check("鼠标轨迹特效")

    A_TrayMenu.Add(
        "PowerToys 风格动画",
        TogglePowerToysAnimation
    )

    if EnablePowerToysAnimation
        A_TrayMenu.Check("PowerToys 风格动画")

    A_TrayMenu.Add(
        "设置快捷键",
        ConfigureHotkeys
    )

    A_TrayMenu.Add(
        "开机启动",
        ToggleStartup
    )

    if StartupEnabled()
        A_TrayMenu.Check("开机启动")

    A_TrayMenu.Add()

    A_TrayMenu.Add(
        "检查更新",
        CheckUpdate
    )

    A_TrayMenu.Add(
        "关于",
        ShowAbout
    )

    A_TrayMenu.Add()

    A_TrayMenu.Add(
        "重新加载",
        ReloadScript
    )

    A_TrayMenu.Add(
        "退出",
        ExitScript
    )
}

; =========================================================
; Hotkeys
; =========================================================

MoveToMonitor(ThisHotkey)
{
    global HotkeyModifiers
    global MonitorNums

    id :=
        SubStr(
            ThisHotkey,
            StrLen(HotkeyModifiers) + 1
        )

    if !MonitorNums.Has(id)
        return

    mon := MonitorNums[id]

    MoveMouseAnimated(mon)
}

MoveToPrimary(*)
{
    mon := MonitorGetPrimary()

    MoveMouseAnimated(mon)
}

; =========================================================
; Move Mouse Animated
; =========================================================

MoveMouseAnimated(mon)
{
    global AnimationSteps
    global AnimationSpeed
    global EnableRememberPosition
    global MonitorMousePositions
    global EnableMouseTrail
    global EnablePowerToysAnimation

    CheckMonitorChange()

    MouseGetPos(&startX, &startY)

    MonitorGet(
        mon,
        &L,
        &T,
        &R,
        &B
    )

    width := R - L
    height := B - T

    isPortrait := height > width

    ; =====================================================
    ; Target Position
    ; =====================================================

    if (
        EnableRememberPosition
        && MonitorMousePositions.Has(mon)
    )
    {
        pos :=
            MonitorMousePositions[mon]

        targetX := pos.x
        targetY := pos.y
    }
    else
    {
        if isPortrait
        {
            targetX :=
                L + Floor(width / 2)

            targetY :=
                T + Floor(height * 0.35)
        }
        else
        {
            targetX :=
                L + Floor(width / 2)

            targetY :=
                T + Floor(height / 2)
        }
    }

    ; =====================================================
    ; Save Current Position
    ; =====================================================

    currentMon := GetCurrentMonitor()

    if currentMon > 0
    {
        MonitorMousePositions[currentMon] := {
            x: startX,
            y: startY
        }
    }

    ; =====================================================
    ; Animation Style
    ; =====================================================

    if EnablePowerToysAnimation
    {
        steps := 60
        speed := 4
    }
    else
    {
        steps := AnimationSteps
        speed := AnimationSpeed
    }

    Loop steps
    {
        t := A_Index / steps

        ; easeOutExpo

        smooth :=
            (t >= 1)
            ? 1
            : 1 - (2 ** (-10 * t))

        x := Round(
            startX
            + ((targetX - startX) * smooth)
        )

        y := Round(
            startY
            + ((targetY - startY) * smooth)
        )

        DllCall(
            "SetCursorPos",
            "int", x,
            "int", y
        )

        ; =================================================
        ; Mouse Trail
        ; =================================================

        if EnableMouseTrail
        {
            ToolTip(
                "✦",
                x + 16,
                y + 16
            )

            SetTimer(
                RemoveTrailTooltip,
                -30
            )
        }

        Sleep(speed)
    }

    DllCall(
        "SetCursorPos",
        "int", targetX,
        "int", targetY
    )
}

; =========================================================
; Remove Tooltip
; =========================================================

RemoveTrailTooltip()
{
    ToolTip()
}

; =========================================================
; Current Monitor
; =========================================================

GetCurrentMonitor()
{
    MouseGetPos(&mx, &my)

    mons := MonitorGetCount()

    Loop mons
    {
        MonitorGet(
            A_Index,
            &L,
            &T,
            &R,
            &B
        )

        if (
            mx >= L
            && mx <= R
            && my >= T
            && my <= B
        )
        {
            return A_Index
        }
    }

    return 0
}

; =========================================================
; Toggle Remember Position
; =========================================================

ToggleRememberPosition(*)
{
    global EnableRememberPosition
    global SettingsFile

    EnableRememberPosition :=
        !EnableRememberPosition

    IniWrite(
        EnableRememberPosition ? "1" : "0",
        SettingsFile,
        "General",
        "RememberPosition"
    )

    BuildTrayMenu()
}

; =========================================================
; Toggle Mouse Trail
; =========================================================

ToggleMouseTrail(*)
{
    global EnableMouseTrail
    global SettingsFile

    EnableMouseTrail :=
        !EnableMouseTrail

    IniWrite(
        EnableMouseTrail ? "1" : "0",
        SettingsFile,
        "General",
        "EnableMouseTrail"
    )

    BuildTrayMenu()
}

; =========================================================
; Toggle PowerToys Animation
; =========================================================

TogglePowerToysAnimation(*)
{
    global EnablePowerToysAnimation
    global SettingsFile

    EnablePowerToysAnimation :=
        !EnablePowerToysAnimation

    IniWrite(
        EnablePowerToysAnimation ? "1" : "0",
        SettingsFile,
        "General",
        "EnablePowerToysAnimation"
    )

    BuildTrayMenu()
}

; =========================================================
; Configure Hotkeys
; =========================================================

ConfigureHotkeys(*)
{
    global HotkeyModifiers

    guiObj := Gui()

    guiObj.Title := "设置快捷键"

    guiObj.SetFont(
        "s10",
        "Segoe UI"
    )

    guiObj.AddText(
        "w520",
        "请输入快捷键修饰符："
    )

    guiObj.AddText(
        "w520",
        "^ = Ctrl`n"
        "! = Alt`n"
        "+ = Shift`n"
        "# = Win"
    )

    guiObj.AddText(
        "w520",
        "示例：`n"
        "^! = Ctrl + Alt`n"
        "#! = Win + Alt`n"
        "^+# = Ctrl + Shift + Win"
    )

    guiObj.AddText(
        "w520",
        "实际快捷键：`n"
        "Ctrl+Alt+1 → 显示器1`n"
        "Ctrl+Alt+2 → 显示器2`n"
        "Ctrl+Alt+0 → 主显示器"
    )

    editBox :=
        guiObj.AddEdit(
            "w400",
            HotkeyModifiers
        )

    okBtn :=
        guiObj.AddButton(
            "Default w100",
            "确定"
        )

    cancelBtn :=
        guiObj.AddButton(
            "x+10 w100",
            "取消"
        )

    okBtn.OnEvent(
        "Click",
        (*) =>
        (
            SaveHotkeys(
                guiObj,
                editBox.Text
            )
        )
    )

    cancelBtn.OnEvent(
        "Click",
        (*) => guiObj.Destroy()
    )

    guiObj.Show(
        "AutoSize Center"
    )
}

SaveHotkeys(guiObj, newHotkey)
{
    global HotkeyModifiers
    global SettingsFile

    newHotkey := Trim(newHotkey)

    if newHotkey = ""
        return

    HotkeyModifiers := newHotkey

    IniWrite(
        HotkeyModifiers,
        SettingsFile,
        "General",
        "HotkeyModifiers"
    )

    RegisterHotkeys()

    SetTrayTooltip()

    guiObj.Destroy()

    MsgBox(
        "快捷键已更新为：`n`n"
        HotkeyModifiers
    )
}

; =========================================================
; Startup
; =========================================================

ToggleStartup(*)
{
    link :=
        A_Startup
        . "\MouseMonitorSwitcher.lnk"

    if FileExist(link)
    {
        FileDelete(link)
    }
    else
    {
        FileCreateShortcut(
            A_ScriptFullPath,
            link,
            A_ScriptDir
        )
    }

    BuildTrayMenu()
}

StartupEnabled()
{
    link :=
        A_Startup
        . "\MouseMonitorSwitcher.lnk"

    return FileExist(link)
}

; =========================================================
; Identify Monitors
; =========================================================

IdentifyMonitors(*)
{
    guis := []

    mons := MonitorGetCount()

    Loop mons
    {
        MonitorGet(
            A_Index,
            &L,
            &T,
            &R,
            &B
        )

        cx :=
            L + Floor((R - L) / 2)

        cy :=
            T + Floor((B - T) / 2)

        g := Gui(
            "+AlwaysOnTop -Caption +ToolWindow"
        )

        g.BackColor := "Black"

        g.SetFont(
            "s48 cWhite Bold",
            "Segoe UI"
        )

        g.AddText(
            "Center",
            A_Index
        )

        g.Show(
            "x" (cx - 80)
            " y" (cy - 60)
            " w160 h120 NoActivate"
        )

        guis.Push(g)
    }

    Sleep(3000)

    for g in guis
    {
        try g.Destroy()
    }
}

; =========================================================
; Monitor Info
; =========================================================

ShowMonitorInfo(*)
{
    txt := ""

    mons := MonitorGetCount()

    Loop mons
    {
        MonitorGet(
            A_Index,
            &L,
            &T,
            &R,
            &B
        )

        name := MonitorGetName(A_Index)

        txt .=
        (
        "显示器 " A_Index "`n"
        "名称: " name "`n"
        "Left: " L "`n"
        "Top: " T "`n"
        "Right: " R "`n"
        "Bottom: " B "`n`n"
        )
    }

    MsgBox(txt)
}

; =========================================================
; Check Monitor Changes
; =========================================================

CheckMonitorChange()
{
    global OrigMonitorCount

    current := MonitorGetCount()

    if current != OrigMonitorCount
    {
        MsgBox(
            "显示器数量发生变化，脚本将重新加载"
        )

        Reload()
    }
}

; =========================================================
; About
; =========================================================

ShowAbout(*)
{
    global AppVersion
    global AppAuthor
    global GitHubURL

    aboutGui := Gui()

    aboutGui.Title := "关于"

    ; =====================================================
    ; Title
    ; =====================================================

    aboutGui.SetFont(
        "s12 Bold",
        "Segoe UI"
    )

    aboutGui.AddText(
        "w580 Center",
        "Mouse Monitor Switcher Ultimate"
    )

    ; =====================================================
    ; Version
    ; =====================================================

    aboutGui.SetFont(
        "s9",
        "Segoe UI"
    )

    aboutGui.AddText(
        "w580 Center",
        "版本 " AppVersion
    )

    ; =====================================================
    ; Description
    ; =====================================================

    aboutGui.AddText(
        "w580",
        "
(
多显示器鼠标快速切换工具

功能特性：

• 鼠标跨屏动画
• PowerToys 风格动画
• 鼠标轨迹特效
• 鼠标位置记忆
• 自定义快捷键
• 开机启动
• 屏幕方向感知
• 多显示器识别

)"
    )

    ; =====================================================
    ; Author
    ; =====================================================

    aboutGui.SetFont(
        "s9 Bold",
        "Segoe UI"
    )

    ; =====================================================
    ; GitHub
    ; =====================================================

    aboutGui.SetFont(
        "s9",
        "Segoe UI"
    )

    aboutGui.AddText(
        "xm y+12",
        "GitHub："
    )

    githubLink :=
        aboutGui.AddText(
            "cBlue",
            GitHubURL
        )

    githubLink.SetFont(
        "underline"
    )

    githubLink.OnEvent(
        "Click",
        OpenGitHub
    )

    ; =====================================================
    ; Original Source
    ; =====================================================

    aboutGui.AddText(
        "xm y+15",
        "Original AHK v1 concept:"
    )

    originalLink :=
        aboutGui.AddText(
            "cBlue",
            "https://www.experts-exchange.com/articles/33932/"
        )

    originalLink.SetFont(
        "underline"
    )

    originalLink.OnEvent(
        "Click",
        OpenOriginalArticle
    )

    ; =====================================================
    ; Buttons
    ; =====================================================

    checkBtn :=
        aboutGui.AddButton(
            "xm y+20 w120",
            "检查更新"
        )

    checkBtn.OnEvent(
        "Click",
        CheckUpdate
    )

    closeBtn :=
        aboutGui.AddButton(
            "x+15 w100 Default",
            "关闭"
        )

    closeBtn.OnEvent(
        "Click",
        (*) => aboutGui.Destroy()
    )

    aboutGui.Show(
        "AutoSize Center"
    )
}

; =========================================================
; Open GitHub
; =========================================================

OpenGitHub(*)
{
    global GitHubURL

    Run(GitHubURL)
}

; =========================================================
; Open Original Article
; =========================================================

OpenOriginalArticle(*)
{
    Run(
        "https://www.experts-exchange.com/articles/33932/"
    )
}

; =========================================================
; Check Update
; =========================================================

CheckUpdate(*)
{
    global GitHubURL
    global AppVersion

    result := MsgBox(
        "当前版本：" AppVersion "`n`n"
        "是否打开 GitHub 检查更新？",
        "检查更新",
        "YesNo Icon?"
    )

    if result = "Yes"
    {
        Run(GitHubURL)
    }
}

; =========================================================
; Reload
; =========================================================

ReloadScript(*)
{
    Reload()
}

; =========================================================
; Exit
; =========================================================

ExitScript(*)
{
    result := MsgBox(
        "确定退出？",
        "退出",
        "YesNo Icon?"
    )

    if result = "Yes"
        ExitApp()
}
