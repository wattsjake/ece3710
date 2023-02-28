;********************************************************
;Program Name:  "stopwtch.asm"
;Description: BCD stopwatch using interrupts
;
;Author:        Jacob Watts & Jack Fernald
;Organization:  Weber State University ECE 3710
;Revision History
;Date[YYYYMMDD] Author          Description
;----           ------          -----------
;20230208       Jacob W.        initial commit     
;********************************************************                
$include (c8051f020.inc)
;------------------------ TODO --------------------------

;--------------------- Registery ------------------------
;R0 - clr RAM but only in the beginning
;R1 - 
;R2 - 
;R3 - 
;R4 - 
;R5 - 
;R6 -
;R7 - 
;------------------------ CSEG --------------------------       
        CSEG
;------------------ 22.1184Mhz Set-UP -------------------     
        mov wdtcn,#0DEh ; disable watchdog 
        mov wdtcn,#0ADh 
        mov xbr2,#40h ; enable port output
        mov	xbr0,#04h	; enable uart 0
        mov	oscxcn,#67H	; turn on external crystal
    	mov	tmod,#21H	; wait 1ms using T1 mode 2
    	mov	th1,#256-167	; 2MHz clock, 167 counts = 1ms
    	setb	tr1
wait1:
    	jnb	tf1,wait1
    	clr	tr1		; 1ms has elapsed, stop timer
    	clr	tf1
wait2:
    	mov	a,oscxcn	; now wait for crystal to stabilize
    	jnb	acc.7,wait2
    	mov	oscicn,#8	; engage! Now using 22.1184MHz

        mov	scon0,#50H	; 8-bit, variable baud, receive enable
	    mov	th1,#-6		; 9600 baud
	    setb tr1		; start baud clock

        ;clear all internal ram
        mov     r0,#255 
clrall: mov     @r0,#0
        djnz    r0,clrall
;---------------PLACE CODE BELOW THIS LINE---------------

;--------------------- ORG 0 ---------------------------
        org 0
        jmp main

        org 000Bh
        cpl P0.1
        reti

        org 23h
        jmp serial
        org 30h 

;--------------------- Main Code ------------------------
main:
        ;set up a timer for counting to 0.0-9.9
        mov tmod, #20h
        mov th1, #0FDh
        mov scon, #50h
        mov IE, #10010000B
        setb tr1

t_loop:;timer loop
        sjmp t_loop
        

;------------------ Serial Port ISR ---------------------
        org 100h
serial: jb TI, trans
        mov a, sbuf0
        mov R4, A
        clr RI1 
        cjne R4, #'r', next1 ;ASCII "R"
            ;put the timer into run mode
next1:  cjne R4, #'s', next2
            ;stop the timer
            jmp back
next2:  cjne R4, #'c', next3
            ;clear the counter
            jmp back
next3:  cjne R4, #'t', back
            ;print to serial current count value                             
            jmp back
back:
        reti

trans:  clr TI
        reti 
        END 

