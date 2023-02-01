;-----------------------------------------------------------------------------
;  
;  
;  FILE NAME   :  F02x_BLINKY.ASM 
;  TARGET MCU  :  C8051F020 
;  DESCRIPTION :  
;
; 	NOTES: 
;
;-----------------------------------------------------------------------------

$include (c8051f020.inc)               ; Include register definition file.

;-----------------------------------------------------------------------------
; EQUATES
;-----------------------------------------------------------------------------

start_state      equ   4              ; make led_state #04h

;-----------------------------------------------------------------------------
; RESET and INTERRUPT VECTORS
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
			mov wdtcn,#0DEh ; disable watchdog 
			mov wdtcn,#0ADh 
			mov xbr2,#40h ; enable port output
			MOV R0, #0FFh

			DSEG AT 30H
last_button:ds 1
led_state:	ds 1

			CSEG
			;JMP clear_ram ;running this breaks something
main:		CALL initialize

run:		CALL delay
			CALL check_press
			JMP check_btn1 ;these three lines break the program
			JMP check_btn2
			;CJNE A, #01, check_btn2 ;if not changed jump to check_btn2
			;INC led_state
			CALL find_value

			JMP run

;-----loop_end
loop_end:	SJMP loop_end; wait forever

;-----P5_table
; convert these values to hex and put them in p5_table: 11111110, 11111101, 11111011, 11110111, 11101111, 11011111, 10111111, 01111111
p5_table: db 0FEh, 0FDh, 0FBh, 0F7h, 0EFh, 0DFh, 0BFh, 07Fh

;-----find value in p5_table
find_value:	CLR A
			MOV A, led_state
			MOV dptr, #p5_table
			MOVC A, @A+dptr
			MOV P5, A
			RET

;-----INITIALIZE PROGRAM
initialize:	MOV led_state, #4
			MOV R4, #0FFh
			MOV P5, R4
			MOV P3, R4
			RET

;-----CHECK BUTTONS
check_press:	MOV A, P1
				CPL A
				XCH A, last_button
				XRL A, last_button
				ANL A, last_button
            	RET

;-----CHECK FIRST BUTTON
check_btn1:		CJNE A, #01, check_btn2 ;if not changed jump to check_btn2
				INC led_state
				JMP run

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

;-----LED OFF
led_off:	MOV R5, #0FFh
			MOV P5, R5
			MOV P3, R5
			RET
;-----LED ON
led_on:		MOV R5, #000h
			MOV P5, R5
			MOV P3, R5
			RET
;-----P3.2 B9 ON/OFF
pin: 		CLR C
			MOV P3.2, C
			CALL delay
			SETB C
			MOV P3.2, C
			RET



;-----CLEAR ALL INTERNAL RAM
clear_ram:	MOV @R0, #0
			DJNZ R0, clear_ram
			JMP initialize		

;-----------------------------------------------------------------------------
; End of file.
END


