;********************************************************
;Program Name:  "magic.asm"
;Description:  
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
;------------------------ DSEG --------------------------
        DSEG AT 30H


;------------------------ CSEG --------------------------       
        CSEG
;------- Crystal Setup Code -----------------------------        
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
	    setb	tr1		; start baud clock

        ;clear all internal ram
        mov     r0,#255 
clrall: mov     @r0,#0
        djnz    r0,clrall
;---------------PLACE CODE BELOW THIS LINE---------------

;---------------- Initialization Code -------------------
init:   
        mov A, #0FFh 
        mov P3, A
        mov P5, A
        call reset
        RI1 bit 0C0h ;turn on flag for serial send
        mov R1, #10
        jmp tx_sub

;--------------------- Main Code ------------------------
main:
        
        
;--------------------- 10ms Delay ------------------------
delay_10ms:
            djnz R1,here
            mov R1,#10 
            
here:       mov TL0, #000h ;-9216 for 5ms
            mov TH0, #0DCh
            setb TR0 ;start timer
again:      jnb TF0, again
            clr TR0
            clr TF0

            mov A, R1
            mov rand_int, A
            clr A; for good measure
            clr C; for good measure
            ret

            END