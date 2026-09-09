#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================
; CH57x Symbol Layer
;
; F13 = layer key
;
; F13 + Y -> {
; F13 + U -> "
; F13 + I -> `
; F13 + O -> }
;
; F13 + H -> [
; F13 + J -> :
; F13 + K -> ;
; F13 + L -> ]
;
; F13 + N -> (
; F13 + M -> /
; F13 + , -> )
; F13 + . -> @
; ==========================================

; Layer 1: F13
#HotIf GetKeyState("F13", "P") && !GetKeyState("F14", "P")

u::Send "{Backspace}"
i::SendText ";"
o::SendText ":"
p::SendText ","

h::Send "{Enter}"
j::SendText "``"
k::SendText '"'
l::SendText "."

n::Send "{Space}"
m::SendText "'"

#HotIf


; Layer 2: F14
#HotIf GetKeyState("F14", "P") && !GetKeyState("F13", "P")

u::SendText "["
i::SendText "]"
o::SendText "{"
p::SendText "}"

h::SendText "("
j::SendText ")"
k::SendText "-"
l::SendText "+"

n::SendText "|"
m::SendText "?"

#HotIf


; Layer 3: F13 + F14
#HotIf GetKeyState("F13", "P") && GetKeyState("F14", "P")

u::SendText "<"
i::SendText ">"
o::SendText "/"
p::SendText "\"

h::SendText "="
j::SendText "*"
k::SendText "!"
l::SendText "~"

#HotIf
