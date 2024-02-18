; Toggle HDR on or off for a monitor
Run "ms-settings:display"
SetTitleMatchMode  2
Sleep 500
WinActivate "Settings"
Send "{tab}{space}"
Sleep 200
; My HDR moitor is monitor 1 so I just go to the top of the list
; If your HDR monitor is not #1 you can go to top, then count down (included #2 example below)
; Monitor 1
Send "{tab}{tab}{Up}{Up}{Up}{Tab}{Space}"
; Monitor 2 example
; Send "{tab}{tab}{Up}{Up}{Up}{Down}{Tab}{Space}"
Sleep 1000
Send "!{f4}"
