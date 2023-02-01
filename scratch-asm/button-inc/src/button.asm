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

start_state      equ   04h              ; make led_state #04h

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
last_button:	ds 1
led_state:	ds 1

			CSEG
			;JMP clear_ram ;running this breaks something
main:		CALL init

			CALL pin
			
			JMP loop_end

loop_end:		SJMP loop_end; wait forever

               



;-----INITIALIZE PROGRAM
init:		MOV led_state, #0FFh
			MOV R4, #00h
			MOV P5, R4
			MOV P3, R4
			RET

;-----CHECK BUTTONS
check_buttons:	MOV A, P1
			CPL A
			XCH A, last_button
			XRL A, last_button
			ANL A, last_button
			RET

;-----DELAY
delay:		MOV R4, #100 ;about 34.40ms
here1:		MOV R3, #250			
here2:		DJNZ R3, here2
			DJNZ R4, here1
			RET

;-----LED OFF
led_off:		MOV R5, #0FFh
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
			JMP init		

;-----------------------------------------------------------------------------
; End of file.

END


