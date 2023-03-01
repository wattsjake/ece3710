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
;na
;--------------------- Registery ------------------------
;R0 - clr RAM but only in the beginning
;R1 - 
;R2 - 
;R3 - 
;R4 - 
;R5 - 
;R6 -
;R7 - 
;----------------------- Timers -------------------------
;Timer1 - Serial 
;Timer2 - 100 Hz clock
;------------------------ BSEG --------------------------
        BSEG
sw_flag:    dbit 1
;------------------------ DSEG --------------------------
        DSEG AT 21H
current_button: ds 1
last_button:    ds 1
sw_time:        ds 1
count:          ds 1
select:         ds 1
;------------------------ CSEG --------------------------       
        CSEG
;----------------- 22.1184Mhz Crystal -------------------     
        mov wdtcn,#0DEh ; disable watchdog 
        mov wdtcn,#0ADh 
        mov xbr2,#40h ; enable port output
        mov	xbr0,#04h	; enable uart 0
        mov	oscxcn,#67H	; turn on external crystal
    	mov	tmod,#21H	; wait 1ms using T1 mode 2
    	mov	th1,#256-167	; 2MHz clock, 167 counts = 1ms
    	setb tr1

        jmp wait1

;----------------- ISR for Serial Com--------------------
        ORG 23h
        call serial_crap
        reti

        ORG 2Bh
        call timer_crap
        reti






serial_crap:
        jbc TI, cont_send 
        jbc RI, init_send

init_send:
        clr RI
        mov A, sbuf0

serial_R: 
        cjne A, #'r', serial_S  
        setb sw_flag
        jmp return_sub
serial_S:
        cjne A, #'s', serial_C  
        clr sw_flag
serial_C:
        cjne A, #'c', serial_T  
        mov sw_time, #00h
        mov A, sw_time
        cpl A
        mov P5, A
        jmp return_sub
serial_T:
        cjne A, #'t', return_sub

        mov A, sw_time
        anl A, #0F0h
        swap A
        add A, #'0'
        da a
        mov sbuf0, A
        mov select, #00h
        jmp return_sub

        

cont_send:
        inc select
        mov A, select
decimal:cjne A, #01h, tenths
        mov sbuf0, #'.'
        jmp return_sub
tenths: cjne A, #02h, line_feed
        mov A, sw_time
        anl A, #00Fh
        add A, #'0'
        da a
        mov sbuf0, A
        jmp return_sub
line_feed:
        cjne A, #03h, carriage
        mov sbuf0, #0Ah
        jmp return_sub
carriage:
        cjne A, #04h, return_sub
        mov sbuf0, #0Dh

return_sub:
        ret

;--------------------ISR for Timer 2---------------------
timer_crap:
        clr tf2
        call check_buttons
        mov A, current_button
        cjne A, #00h, next
        jmp toggle_time
next:   cjne A, last_button, toggle_time
          jmp return
toggle_time:
        cjne A, #001h, reset_time
            cpl sw_flag
reset_time:
        cjne A, #002h, sw_running
            clr A
            mov sw_time, A
sw_running:
        jnb sw_flag, return
 
        
update_timer:
        jnb sw_flag, return
        mov A, count
        djnz ACC, replace
          cjne A, #99h, inc1
          mov A, #0h
          jmp inc2
          ;Increment Timer 
inc1:     mov A, sw_time
          add A, #01
          da a
          mov sw_time, A
inc2:     
          cpl A
          mov P5, A
          ; Reset Counter
          mov count, #10
          jmp return         

replace:
        mov count, A

return:
        ret ;if both buttons pressed reti 
               
               
               
;--------- Initilize More stuff? ------------------------                             
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

;------------------ Timer 2 (100 Hz)---------------------
        mov RCAP2L, #LOW(-18432) ;set timer 2(100hz)
        mov RCAP2H, #HIGH(-18432)
        mov T2CON, #00000100B ;start timer 2

        ;clear all internal ram
        mov     r0,#255 
clrall: mov     @r0,#0
        djnz    r0,clrall
;---------------PLACE CODE BELOW THIS LINE---------------

;---------------- Initialization Code -------------------
init:
        mov IE, #10110000B
        mov count, #10
        mov sw_time, #0

;--------------------- Main Code ------------------------
main:   jmp main

;------------------- Check Buttons ----------------------
check_buttons:  MOV A, P1
                MOV last_button, current_button ; Memory for next loop
                CPL A ; Complement A
                ANL A, #00000011B ; Mask out other bits from P1, we only care about the single button bit. Anding it with 1 will keep the state of the button
                ; e.g. button = 1 and with 1 = 1, button = 0 and with 1 = 0. T
                MOV current_button, A ; Move this newly found button state into current_button
                clr A;for safety 
                RET
        
;------------------------ END ---------------------------
        END



        

