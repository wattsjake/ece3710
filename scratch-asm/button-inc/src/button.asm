$include (c8051f020.inc)

start_state      equ   4

			mov wdtcn,#0DEh ; disable watchdog 
			mov wdtcn,#0ADh 
			mov xbr2,#40h ; enable port output

			DSEG AT 30H
last_button:ds 1
led_state:	ds 1

			CSEG
main:		CALL initialize

run:		CALL display_p5
            CALL display_p3
			CALL delay
			CALL check_press
			CJNE A, #01, check_btn2 ;if not changed jump to check_btn2
			INC led_state
            MOV A, led_state
            
            CJNE A, #0Ah, check_state
            JMP initialize
			
;-----P5_table
p5_table: db 0FEh, 0FDh, 0FBh, 0F7h, 0EFh, 0DFh, 0BFh, 07Fh
;-----p3_table
p3_table: db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FEh, 0FDh

check_state:CJNE A, #00, run
			JMP initialize

;-----DISPLAY
display_p5:	clr A 
			mov a, led_state
			mov dptr, #p5_table
			movc a, @a+dptr
			mov p5, a
			ret

display_p3: clr A
            mov a, led_state
            mov dptr, #p3_table
            movc a, @a+dptr
            mov p3, a
            ret

;-----INITIALIZE PROGRAM
initialize:	MOV led_state, #04h
			mov A, #000h
			mov P5, A
			CALL delay
			CALL delay
			CALL delay
			CALL delay
			CALL delay
			CALL delay
			CALL delay
			CALL delay
			RET

;-----CHECK BUTTONS
check_press:	MOV A, P1
				CPL A
				XCH A, last_button
				XRL A, last_button
				ANL A, last_button
            	RET

;-----CHECK SECOND BUTTON
check_btn2:		CJNE A, #02, run ;if not changed jump to run
				DEC led_state
				JMP run

;-----DELAY
delay:		MOV R4, #100 ;about 34.40ms
here1:		MOV R3, #250			
here2:		DJNZ R3, here2
			DJNZ R4, here1
			RET
			
;-----------------------------------------------------------------------------
; End of file.
END


