;********************************************************
;Program Name:  "magic.asm"
;Description:  
;
;Author:        Jacob Watts & Jack Fernald
;Organization:  Weber State University ECE 3710
;Revision History
;Date[YYYYMMDD] Author          Description
;----           ------          -----------
;20230221       Jacob W.        initial commit           
;********************************************************                
$include (c8051f020.inc)
;------------------------ TODO --------------------------

;--------------------- Registery ------------------------
;R0 - clr RAM
;R1 -
;R2 - 
;R3 - delay
;R4 - delay
;R5 - delay
;R6 -
;R7 - rand delay
;------------------------ DSEG --------------------------
        DSEG AT 30H

;------------------------ CSEG --------------------------       
        CSEG
        mov wdtcn,#0DEh ; disable watchdog 
        mov wdtcn,#0ADh 
        mov xbr2,#40h ; enable port output

        ;clear all internal ram 
        mov     r0,#255 
clrall: mov     @r0,#0
        djnz    r0,clrall
;---------------PLACE CODE BELOW THIS LINE---------------


;---------------- Initialization Code -------------------
init:   
	mov 	wdtcn,#0DEh 	; disable watchdog
	mov	wdtcn,#0ADh
	mov	xbr2,#40h	; enable port output
	mov	xbr0,#04h	; enable uart 0
	mov	oscxcn,#67H	; turn on external crystal
	mov	tmod,#20H	; wait 1ms using T1 mode 2
	mov	th1,#256-167	; 2MHz clock, 167 counts = 1ms
	setb	tr1

;----------------------- wait1 -------------------------
wait1:
	jnb	tf1,wait1
	clr	tr1		; 1ms has elapsed, stop timer
	clr	tf1

;----------------------- wait2 -------------------------
wait2:
	mov	a,oscxcn	; now wait for crystal to stabilize
	jnb	acc.7,wait2
	mov	oscicn,#8	; engage! Now using 22.1184MHz

	mov	scon0,#50H	; 8-bit, variable baud, receive enable
	mov	th1,#-6		; 9600 baud
	setb	tr1		; start baud clock

;----------------------- cycle -------------------------
cycle:
	jnb	ri,cycle	; wait for data to arrive
	clr	ri		; and clear flag for next time
	mov	a,sbuf0		; get the incoming data...
	mov	sbuf0,a		; ...and send it back
	jmp	cycle

;-------------------- message table ----------------------  
message_table1: DB "It is certain", "You may rely on it", "Without a doubt", "Yes", "Most likely", "Reply hazy, try again", "Concentrate and ask again"  
message_table2: DB "Don’t count on it", "Very doubtful", "My reply is no" 

;------------- Randoom Delay Subroutine ------------------
delay:
        djnz R7,carry_on 
        mov R7,#50 
carry_on:
        MOV R4, #50 ;about 17.20 ms
here1:	MOV R3, #250			
here2:	DJNZ R3, here2
        DJNZ R4, here1
        RET

;-------------------- 1000ms Delay -----------------------
delay_1000ms:
        mov R5, #20 ; about 1000ms
here5:  djnz R5, delay_50ms
        RET

delay_50ms:
        mov R4, #150 ;about 51.60 ms
here3:  mov R3, #250
here4:  djnz R3, here4
        djnz R4, here3
        jmp here5

        END