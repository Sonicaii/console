#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory

#Include <console>

has_delay := true
delay(delay:=1000) {
	global has_delay
	if has_delay
		sleep, delay
}
in(output:="type anything to continue`n", end:="", use_cin:=true) {
	global has_delay
	if !has_delay
		return
	return use_cin?cin(output, end):console.in(output, end)
}

;https://www.autohotkey.com/board/topic/59612-simple-debug-console.output/

console.out("console.out:`tio.ahk library test`n" . (console.__SciTE?"Detected":"Did not detect" . " SciTE"))

; Goto, logging

cout("cout: this was printed using the cout alias")
inp := in("`ncin input: ")
cout("you typed: " . inp)
inp := in("console.in: ",, true)

cout("you typed: " . inp)
delay()

cout("`nempty cout() below")
delay(500)
cout()
cout("empty cout() above")
cout("`ninline, end param test", " - no ``n - ")
delay(500)
cout("same line, ", "")
delay(500)
cout("now testing inline attribute")
delay()

console.inline := true
cout("console.inline is now on, ")
cout("this should be inline")
cout("`ncustom end: ", "=end=")
cout("last line did not have ending newline, this should be on the same line")
console.inline := false
cout("console inline is now off")
delay()

inp := in("loop amount (integer): ")

Loop, %inp% {
	cout(A_index)
}

cout("Loop done`nnow looping inline")
delay()

Loop, %inp% {
	cout(A_index, " ")
}
cout()
Loop, %inp% {
	delay(20)
	cout(A_index, " ")
}
cout()
Loop, %inp% {
	delay(20)
	cout(A_index . "`t[" . StrReplace(format("`{:" A_index "`}", ""), " ", "=") . StrReplace(format("`{:" inp - A_index "`}", ""), " ", "-") . "]`t" . A_index, "`r")
}

cout("`nInline loop done`ntesting console open and close")
delay()
console.close()


cout("new console window")
if has_delay
	inp := console.in("type anything to continue: ")
console.close()
console.out(inp, " - ")
console.out("on delay to close")
delay()
console.close()


logging:
console.log("level:", "log/info")
console.warning("level:", "warning")
console.error("level:", "error")
console.critical("level:", "critical")
in()
console.close()


console.log("testing", console.run("echo console.run", "time /t"))
cout(console.run("color"))
in()
console.close()


cout("now testing colour")

console.inline := true
console.__col := true

console_enable_fm_namespace()

cout(console.fd.k.("k "))
cout(console.fd.r.("r "))
cout(console.fd.g.("g "))
cout(console.fd.y.("y "))
cout(console.fd.b.("b "))
cout(console.fd.m.("m "))
cout(console.fd.c.("c "))
cout(console.fd.w.("w "))
cout("`n")
cout(console.fb.k.("k "))
cout(console.fb.r.("r "))
cout(console.fb.g.("g "))
cout(console.fb.y.("y "))
cout(console.fb.b.("b "))
cout(console.fb.m.("m "))
cout(console.fb.c.("c "))
cout(console.fb.w.("w "))
cout("`n")
cout(console.bd.k.("k "))
cout(console.bd.r.("r "))
cout(console.bd.g.("g "))
cout(console.bd.y.("y "))
cout(console.bd.b.("b "))
cout(console.bd.m.("m "))
cout(console.bd.c.("c "))
cout(console.bd.w.("w "))
cout("`n")
cout(console.bb.k.("k "))
cout(console.bb.r.("r "))
cout(console.bb.g.("g "))
cout(console.bb.y.("y "))
cout(console.bb.b.("b "))
cout(console.bb.m.("m "))
cout(console.bb.c.("c "))
cout(console.bb.w.("w "))
cout("`n")
cout(fd.k.("k "))
cout(fd.r.("r "))
cout(fd.g.("g "))
cout(fd.y.("y "))
cout(fd.b.("b "))
cout(fd.m.("m "))
cout(fd.c.("c "))
cout(fd.w.("w "))
cout("`n")
cout(fb.k.("k "))
cout(fb.r.("r "))
cout(fb.g.("g "))
cout(fb.y.("y "))
cout(fb.b.("b "))
cout(fb.m.("m "))
cout(fb.c.("c "))
cout(fb.w.("w "))
cout("`n")
cout(bd.k.("k "))
cout(bd.r.("r "))
cout(bd.g.("g "))
cout(bd.y.("y "))
cout(bd.b.("b "))
cout(bd.m.("m "))
cout(bd.c.("c "))
cout(bd.w.("w "))
cout("`n")
cout(bb.k.("k "))
cout(bb.r.("r "))
cout(bb.g.("g "))
cout(bb.y.("y "))
cout(bb.b.("b "))
cout(bb.m.("m "))
cout(bb.c.("c "))
cout(bb.w.("w "))
cout("`n")
cout(fd["k"]("k "))
cout(fd["r"]("r "))
cout(fd["g"]("g "))
cout(fd["y"]("y "))
cout(fd["b"]("b "))
cout(fd["m"]("m "))
cout(fd["c"]("c "))
cout(fd["w"]("w "))
cout("`n")
cout(fb["k"]("k "))
cout(fb["r"]("r "))
cout(fb["g"]("g "))
cout(fb["y"]("y "))
cout(fb["b"]("b "))
cout(fb["m"]("m "))
cout(fb["c"]("c "))
cout(fb["w"]("w "))
cout("`n")
cout(bd["k"]("k "))
cout(bd["r"]("r "))
cout(bd["g"]("g "))
cout(bd["y"]("y "))
cout(bd["b"]("b "))
cout(bd["m"]("m "))
cout(bd["c"]("c "))
cout(bd["w"]("w "))
cout("`n")
cout(bb["k"]("k "))
cout(bb["r"]("r "))
cout(bb["g"]("g "))
cout(bb["y"]("y "))
cout(bb["b"]("b "))
cout(bb["m"]("m "))
cout(bb["c"]("c "))
cout(bb["w"]("w "))
cout("`n")
for _, fb in ["f", "b"] {
	for _, db in ["d", "b"] {
		loop, parse, % "krgybmcw"
		{
			var := fb . db
			cout(console[var][A_LoopField].(A_LoopField " "))
		}
		cout("`n")
	}
}

console.inline := false

cout(console.fd.r() . "r " . fd.g() . "g " . fd["y"]() . "y " . console["fd"]["b"].() . "b ")

in()

; console.debug("testing debug")
; delay()
; console.debug_close()

console.close()

in("=TEST END=`n")
