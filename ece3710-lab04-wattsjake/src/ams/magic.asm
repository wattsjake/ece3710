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
;R3 - 
;R4 - 
;R5 - 
;R6 -
;R7 - 
;------------------------ DSEG --------------------------
        DSEG AT 30H
last_button:    ds 1
led_position:   ds 1

;------------------------ CSEG --------------------------       
        CSEG
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
        RI1 bit 0C0h ;turn on flag for serial send

;--------------------- Main Code ------------------------
main:
        call delay_10ms
        call check_buttons
        mov A, last_button
        cjne A, #001h, serial_check ;if button pressed jmp
            jmp tx_sub

serial_check:
        jbc RI1, tx_sub

        
        


;---------------------- LED Display ---------------------
update_disp:
        mov A, led_position
        mov dptr, #init_table
        movc A, @A+dptr
        mov P5, A
;------------------------- tx ---------------------------
tx_sub:
        setb TR1
        mov DPTR, #msg_test
fn:     clr A
        movc A, @A+DPTR
        jz main
        call sendcom
        inc DPTR
        sjmp fn
sendcom:
        mov sbuf0,a
here1:  jnb TI, here1
        clr TI
        ret                

;-------------------- message table ----------------------
msg_test: DB "Hello World",0Dh,0Ah, 0 ;termination is zero (0)
  
;message_table1: DB "It is certain", "You may rely on it", "Without a doubt", "Yes", "Most likely", "Reply hazy, try again", "Concentrate and ask again"  
;message_table2: DB "Don't count on it", "Very doubtful", "My reply is no" 

;--------------------- LED table -------------------------
led_table: DB 0FEh, 0FDh, 0FBh, 0F7h, 0EFh, 0DFh, 0BFh, 07Fh

;------------- Randoom Delay Subroutine ------------------
;TODO

;------------------- Check Buttons ----------------------
check_buttons: 	MOV A, P1
                CPL A
                XCH A, last_button
                XRL A, last_button
                ANL A, last_button
                MOV last_button, A
                RET

;--------------------- 10ms Delay ------------------------
delay_10ms: 
here:       mov TL0, #000h ;-9216 for 5ms
            mov TH0, #0DCh
            setb TR0 ;start timer
again:      jnb TF0, again
            clr TR0
            clr TF0
            ret

        END