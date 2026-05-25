; =========================================================
; Mouse Monitor Switcher Ultimate
; AutoHotkey v2
;
; Original AHK v1 script and concept:
; Joe Winograd
; https://www.experts-exchange.com/articles/33932/
;
; This version:
; - Fully rewritten for AutoHotkey v2
; - Major architectural changes
; - Added animations
; - Added GUI
; - Added monitor memory
; - Added PowerToys-style transitions
; - Added mouse trail effects
; - Added DPI improvements
; - Added startup integration
;
; Modified and extended by: YOUR_NAME
; =========================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; =========================================================
; Multi Monitor Mouse Switcher Ultimate
; AutoHotkey v2
;
; 功能：
; 1. 多显示器鼠标切换
; 2. 鼠标跨屏动画
; 3. PowerToys 风格动画（可选）
; 4. 鼠标轨迹特效（可选）
; 5. 记忆每个显示器鼠标位置（可选）
; 6. 自定义快捷键
; 7. 开机启动
; 8. 屏幕方向感知
; 9. 显示器识别
; =========================================================

; =========================================================
; 配置文件
; =========================================================

global SettingsFile := A_ScriptDir . "\MouseMonitorSwitcher.ini"

; =========================================================
; 默认配置
; =========================================================

if !FileExist(SettingsFile)
{
    IniWrite("^!", SettingsFile, "General", "HotkeyModifiers")

    ; 默认关闭
    IniWrite("0", SettingsFile, "General", "RememberPosition")

    IniWrite("0", SettingsFile, "General", "RunAtStartup")

    IniWrite("0", SettingsFile, "General", "EnableMouseTrail")
	
	 ; 默认开启
    IniWrite("1", SettingsFile, "General", "EnablePowerToysAnimation")
}

; =========================================================
; 读取配置
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
            "0"
        ) = "1"
    )

; =========================================================
; 动画配置
; =========================================================

global AnimationSpeed := 6
global AnimationSteps := 40

; =========================================================
; DPI 感知
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
; 显示器编号
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
; 鼠标位置记忆
; =========================================================

global MonitorMousePositions := Map()

; =========================================================
; 注册热键
; =========================================================

RegisterHotkeys()

; =========================================================
; 托盘菜单
; =========================================================

BuildTrayMenu()

TraySetIcon("shell32.dll", 44)

A_IconTip :=
(
"鼠标跨显示器切换

快捷键：

" HotkeyModifiers "1~9
" HotkeyModifiers "a~z

0 = 主显示器"
)

return

; =========================================================
; 注册热键
; =========================================================

RegisterHotkeys()
{
    global HotkeyModifiers
    global OrigMonitorCount
    global MonitorIDs

    try Hotkey(HotkeyModifiers . "0", "Off")

    Loop OrigMonitorCount
    {
        try
        {
            key := HotkeyModifiers . MonitorIDs[A_Index]

            Hotkey(key, "Off")
        }
    }

    Hotkey(
        HotkeyModifiers . "0",
        MoveToPrimary
    )

    Loop OrigMonitorCount
    {
        key := HotkeyModifiers . MonitorIDs[A_Index]

        Hotkey(
            key,
            MoveToMonitor
        )
    }
}

; =========================================================
; 托盘菜单
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
        "重新加载",
        ReloadScript
    )

    A_TrayMenu.Add(
        "退出",
        ExitScript
    )
}

; =========================================================
; 热键处理
; =========================================================

MoveToMonitor(ThisHotkey)
{
    global HotkeyModifiers
    global MonitorNums

    id := SubStr(
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
; 动画移动
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

    ; 屏幕方向感知
    isPortrait := height > width

    ; =====================================================
    ; 目标位置
    ; =====================================================

    if (
        EnableRememberPosition
        && MonitorMousePositions.Has(mon)
    )
    {
        pos := MonitorMousePositions[mon]

        targetX := pos.x
        targetY := pos.y
    }
    else
    {
        ; 竖屏偏上
        if isPortrait
        {
            targetX := L + Floor(width / 2)

            targetY := T + Floor(height * 0.35)
        }
        else
        {
            ; 横屏居中
            targetX := L + Floor(width / 2)

            targetY := T + Floor(height / 2)
        }
    }

    ; =====================================================
    ; 保存当前屏幕位置
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
    ; PowerToys 风格动画
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
            startX + ((targetX - startX) * smooth)
        )

        y := Round(
            startY + ((targetY - startY) * smooth)
        )

        DllCall(
            "SetCursorPos",
            "int", x,
            "int", y
        )

        ; =================================================
        ; 鼠标轨迹特效
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
; 清除轨迹 Tooltip
; =========================================================

RemoveTrailTooltip()
{
    ToolTip()
}

; =========================================================
; 获取当前显示器
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
; 记忆位置开关
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
; 鼠标轨迹开关
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
; PowerToys 动画开关
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
; 快捷键设置 GUI
; =========================================================

ConfigureHotkeys(*)
{
    global HotkeyModifiers

    guiObj := Gui()

    guiObj.SetFont("s10", "Segoe UI")

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

    guiObj.Show("AutoSize Center")
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

    guiObj.Destroy()

    MsgBox(
        "快捷键已更新为：`n`n"
        HotkeyModifiers
    )
}

; =========================================================
; 开机启动
; =========================================================

ToggleStartup(*)
{
    link := A_Startup . "\MouseMonitorSwitcher.lnk"

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
    link := A_Startup . "\MouseMonitorSwitcher.lnk"

    return FileExist(link)
}

; =========================================================
; 识别显示器
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

        cx := L + Floor((R - L) / 2)
        cy := T + Floor((B - T) / 2)

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
; 显示器信息
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
; 检查显示器变化
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