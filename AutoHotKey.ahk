;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sound Control
;;;;;;;;;;;;;;;;;;;;;;;;;;;
^PgUp::
	Send { Volume_Up 1 }
	NotifyVolume()
	return

^PgDn::
	Send { Volume_Down 1 }
	NotifyVolume()
	return

; Mute volume
^End::
	Send { Volume_Mute }
	SoundGet, master_mute, , mute
	TrayTip, Mute, Mute %master_mute%
	SetTimer, RemoveTrayTip, 500
	return

; Set volume to 5%
^Home::
	SoundSet, 5
	NotifyVolume()
	return


;Run ElectricSheep with Ctrl+F9
^F9::
	Sleep, 300
	Run C:\WINDOWS\es.exe -R
	Return

;Reload the AHK script with Ctrl+F11
^F11::
	Sleep, 300 ; give it time to save the script
	Reload
	Return

; Popup notification with current volume
NotifyVolume() {
	Run sndvol32.exe -t	
	SoundGet, master_volume
	master_volume := Floor(master_volume)
	Progress, Off
	Progress, %master_volume%, , Volume at %master_volume%`%, Volume
	SetTimer, RemoveTrayTip, 500
	return
}

; Global helper function for removing tray tips
RemoveTrayTip:
	SetTimer, RemoveTrayTip, Off
	WinHide ahk_class Tray Volume
	;TrayTip
	Progress, Off
	return


F1::toggleWindow("Console_2_Main", "console", true)
F2::toggleWindow("KiTTY", "C:\cygwin\bin\kitty_portable.exe -load cygwin", true)
F4::toggleWindow("PX_WINDOW_CLASS", "C:\Program Files\Sublime Text 2\sublime_text.exe", false, true)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Toggle a window by ahk_class
; If the window does not exist, then run CMD 
; @param cls The window ahk_class
; @param cmd The command to run if ahk_class does not exist 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
toggleWindow(cls, cmd, onTop = false, minimizeInsteadOfHiding = false)
{
	SplashImage off
	DetectHiddenWindows, on
	IfWinExist ahk_class %cls%
	{
		IfWinActive ahk_class %cls%
		  {
		  		if ( minimizeInsteadOfHiding = false ) {
					WinHide ahk_class %cls%
					; need to move the focus somewhere else.
					;WinActivate ahk_class Shell_TrayWnd
					Send, {ALTDOWN}{TAB}{ALTUP}
				} else {
					WinMinimize ahk_class %cls%
				}
				; Send ALT+TAB to move focus to the last window


			}
		else
		  {
		    WinShow ahk_class %cls%
		    WinActivate ahk_class %cls%
		    if ( onTop = true)
				WinSet, AlwaysOnTop, toggle, ahk_class %cls%
			WinSet, Transparent, Off, ahk_class %cls%

		  }
	}
	else
		;SplashImage, x50 y50,, run
		Run %cmd%
		if ( onTop = true ) 
			WinSet, AlwaysOnTop, toggle, ahk_class %cls%
		
	; the above assumes a shortcut in the c:\windows folder to console.exe.
	; also assumes console is using the default console.xml file, or
	; that the desired config file is set in the shortcut.

	DetectHiddenWindows, off
	Return
}
