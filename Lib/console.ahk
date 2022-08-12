/*
	Title: console
			Input and Output to console
	Console code refractored from https://www.autohotkey.com/boards/viewtopic.php?t=56877
*/

/*
	Console foreground colouriser
		Usage:
			console.name.col.("string")
		After console_enable_fm_namespace():
			name["col"]("string")
			fb.r.() . "This text is" . "bright red"
			fd.g.("This text is dark green") . "this is not"

	Console background colouriser
		Usage:
			console.name.col.("string")
		After console_enable_fm_namespace():
			name["col"]("string")
			bb.b.() . "The background of this text is bright blue"
			bd.w.("The background here is dark grey") . "No colour"

		k = black
		r = red
		g = green
		y = yellow
		b = blue
		m = magenta
		c = cyan
		w = white

	Console text formatter
		Usage:
			fm.number.("string")
		After console_enable_fm_namespace():
			fm[int]("string")

		0 = reset
		1 = bold
		2 = darken
		3 = italic
		4 = underlined
		5 = blinking
		6 = un-inverse colour
		7 = inverse colour
		8 = hide
		9 = crossthrough
*/

class console {
	static __SciTE := console._check_SciTE_exists() && console._check_SciTE()
	static __col := false
	static __console := false
	static __prev_str := ""
	static __prev_inl := false
	static inline := false

	static sep := " "
	static pre := "yyyy-MM-dd HH:mm:ss [{: -8}] "
	static post := ""

	__New() {
		; Does not return new object, only the class.
		return this
	}

	out(output:="", end:="`n") {
		; Output to console, opens a new console window if there isn't one already
		; CONOUT$ is a special file windows uses to expose attached console output

		if this.__prev_inl != this.inline
			output := "`n" . output

		; Inline override if default
		output .= (this.inline and end === "`n")?"":end

		if (this.__SciTE) {
			FileAppend, %output%, *
		} else {
			if (!this.__console) {
				DllCall("AttachConsole", "int", -1) || DllCall("AllocConsole")
				this.__console:= true
			}
			FileAppend, %output%, % "CONOUT$"
		}

		this.__prev_inl := this.inline
	}

	in(prompt:="", end:="") {
		; Output to console & wait for input & return input
		this.out(prompt, end)
		value := ""
		FileReadLine, value, CONIN$, 1
		return value
	}

	close() {
		; Close terminal window
		DllCall("FreeConsole")

		static function := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "kernel32.dll", "ptr"), "astr", "Process32Next" (A_IsUnicode ? "W" : ""), "ptr")
		if !(h := DllCall("CreateToolhelp32Snapshot", "uint", 2, "uint", 0))
			return
		VarSetCapacity(pEntry, sz := (A_PtrSize == 8 ? 48 : 36)+(A_IsUnicode ? 520 : 260))
		Numput(sz, pEntry, 0, "uint")
		DllCall("Process32First" (A_IsUnicode ? "W" : ""), "ptr", h, "ptr", &pEntry)
		loop
		{
			if (DllCall("GetCurrentProcessId") == NumGet(pEntry, 8, "uint") || !DllCall(function, "ptr", h, "ptr", &pEntry))
				break
		}
		; DllCall("CloseHandle", "ptr", h)
		parent_process := Numget(pEntry, 16+2*A_PtrSize, "uint")

		; static function := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "kernel32.dll", "ptr"), "astr", "Process32Next" (A_IsUnicode ? "W" : ""), "ptr")
		; if !(h := DllCall("CreateToolhelp32Snapshot", "uint", 2, "uint", 0))
		; 	return
		VarSetCapacity(pEntry, sz := (A_PtrSize == 8 ? 48 : 36)+260*(A_IsUnicode ? 2 : 1))
		; Numput(sz, pEntry, 0, "uint")

		DllCall("Process32First" (A_IsUnicode ? "W" : ""), "ptr", h, "ptr", &pEntry)
		; loop
		; {
		; 	if (parent_process == NumGet(pEntry, 8, "uint") || !DllCall(function, "ptr", h, "ptr", &pEntry))
		; 		break
		; }
		DllCall("CloseHandle", "ptr", h)

		if StrGet(&pEntry+28+2*A_PtrSize, A_IsUnicode ? "utf-16" : "utf-8") == "cmd.exe"		;couldn't get this: 'DllCall("GenerateConsoleCtrlEvent", CTRL_C_EVENT, 0)' to work so...
			ControlSend, , {Enter}, % "ahk_pid " . parent_process

		this.__console := false
	}

	run(commands*) {
		; Runs and returns the result of shell commands
		; https://www.autohotkey.com/boards/viewtopic.php?t=55301
	    shell := ComObjCreate("WScript.Shell")
	    ; Open cmd.exe with echoing of commands disabled
	    exec := shell.Exec(ComSpec " /Q /K echo off")
	    ; Send the commands to execute, separated by newline
	    command := ""
	    for i in commands {
	    	command .= "`n" . commands[i]
	    }
	    exec.StdIn.WriteLine(command . "`nexit")  ; Always exit at the end!
	    ; Read and return the output of all commands
	    return exec.StdOut.ReadAll()
	}

	__log(level, params*) {
		; Full log method, formats level into prefix, cout message and then suffix
		if this.__prev_inl != this.inline
			this.out("`n","")

		FormatTime, time,, % this.pre
		time := Format(time, level)
		this.out(time, "")

		for index, param in params
			this.out(param, this.sep)

		this.out(this.post, "`n")
		this.__prev_inl := false
	}

	log(params*) {
		this.__log("INFO", params*)
	}

	warning(params*) {
		this.__log(this.fb.y.("WARNING"), params*)
	}

	error(params*) {
		this.__log(this.fb.r.("ERROR"), params*)
	}

	critical(params*) {
		this.__log(this.bd.r.("CRITICAL"), params*)
	}

	debug(string:="") {
		; Opens AHK window, replaces ListVars output with specified string
		static
		string := string ? string . "`r`n" . this.__prev_str : "", this.__prev_str := string
		if (!WinActive("ahk_class AutoHotkey")) {
			ListVars
			; WinWait ahk_id %A_ScriptHwnd%
		} else if (!string) {
			return this.debug_close()
		}
		ControlSetText Edit1, %string%, ahk_id %A_ScriptHwnd%
	}

	debug_close() {
		; Closes the AHK window
		WinGetTitle, title, ahk_id %A_ScriptHwnd%
		PostMessage, 0x112, 0xF060,,, %title% ; 0x112 == WM_SYSCOMMAND, 0xF060 == SC_CLOSE
	}

	__check_SciTE_exists(){
		Process, Exist, SciTE.exe
		Return ErrorLevel
	}

	__check_SciTE() {
		static function := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "kernel32.dll", "ptr"), "astr", "Process32Next" (A_IsUnicode ? "W" : ""), "ptr")
		if !(h := DllCall("CreateToolhelp32Snapshot", "uint", 2, "uint", 0))
			return
		VarSetCapacity(pEntry, sz := (A_PtrSize == 8 ? 48 : 36)+(A_IsUnicode ? 520 : 260))
		Numput(sz, pEntry, 0, "uint")
		DllCall("Process32First" (A_IsUnicode ? "W" : ""), "ptr", h, "ptr", &pEntry)
		loop
		{
			if (DllCall("GetCurrentProcessId") == NumGet(pEntry, 8, "uint") || !DllCall(function, "ptr", h, "ptr", &pEntry))
				break
		}
		parent_process := Numget(pEntry, 16+2*A_PtrSize, "uint")
		VarSetCapacity(pEntry, sz := (A_PtrSize == 8 ? 48 : 36)+260*(A_IsUnicode ? 2 : 1))
		DllCall("Process32First" (A_IsUnicode ? "W" : ""), "ptr", h, "ptr", &pEntry)
		DllCall("CloseHandle", "ptr", h)
		return StrGet(&pEntry+28+2*A_PtrSize, A_IsUnicode ? "utf-16" : "utf-8") == "SciTE.exe"
	}

	class ColourFormat {
		; Documentation above
		class Colour {
			__New(id) {
				this.__id := id
				return this
			}
			__Call(method, string:="", after:="") {
				if console.__col {
					return string?Format("[{}m{}{}[0m", this.__id, string, after):("[" . this.__id . "m")
				} else {
					return string . after
				}
			}
		}
		__New(offset, custom:=0) {
			if custom {
				for k, v in custom {
					this[k] := new this.Colour(v)
				}
			} else {
				lower = krgybmcw
				loop, parse, lower
				{
					this[A_LoopField] := new this.Colour(A_Index + offset)
				}
			}
		}
	}
}

; Aliases
cin(prompt:="", end:="") {
	return console.in(prompt, end)
}

cout(output:="", end:="`n") {
	return console.out(output, end)
}

console.fd := new console.ColourFormat(30)
console.fb := new console.ColourFormat(90)
console.bd := new console.ColourFormat(40)
console.bb := new console.ColourFormat(100)
console.fm := new console.ColourFormat(0, {0: 0, 1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9, "c": 0, "u": 4, "i": 8})

console_enable_fm_namespace() {
	; Enable using shorthand to access these variables
	global fd, fb, bd, bb, fm
	fd := console.fd
	fb := console.fb
	bd := console.bd
	bb := console.bb
	fm := console.fm
}

console.debug_close()
