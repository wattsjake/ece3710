$include (c8051f020.inc) 

        mov wdtcn,#0DEh ; disable watchdog 
        mov wdtcn,#0ADh 
        mov xbr2,#40h ; enable port output

				DSEG AT 30H
last_button: ds 1
game_state: ds 1


				CSEG




;; TODO
;; - Add routine for controlling state



Main:          CALL Initilize
start:         MOV R4, #10
               CALL Delay
							 MOV A, game_state
							 CALL LED_driver
               CALL check_buttons
							 CJNE A, #01, check_btn2
               INC game_state
							 jmp start
check_btn2:    CJNE A, #02,  start
               DEC game_state
							 JMP start




check_buttons: MOV A, P1
							 CPL A
							 XCH A, last_button
							 XRL A, last_button
							 ANL A, last_button
							 RET

P1_table:      DB 0FCh, 0F9h, 0F3h, 0E7h, 0CFh, 09Fh, 03Fh, 07Fh, 0FFh ; 0 1 2 3 4 5 6 7
P2_table:      DB 0FEh, 0FCh ; 8 9


LED_driver:    CJNE A, #07h, NEXT1
							 MOV R4, #07fh
							 MOV P5, R4
							 JMP NEXT

NEXT1:
               CJNE A, #08h, LED_helper


NEXT:					 SUBB A, #7
               CALL Turn_off
							 MOV dptr, #P2_table
							 MOVC A, @A+dptr
							 MOV P3, A
							 RET
               
							 
LED_helper:		 MOV  dptr, #P1_table
               MOVC A, @A+dptr
							 MOV  P5, A
							 MOV R4, #0FFh
							 MOV P3, R4
							 RET

Turn_off:      JZ Fast_forward
               MOV R4, #0FFh
               MOV P5, R4
Fast_forward:  
							 RET


							 

							 RET
               
							 

Delay:         
delay_loop_out:MOV R3, #250
delay_loop_in: NOP
               NOP
							 DJNZ R3, delay_loop_in
							 DJNZ R4, delay_loop_out   
							 RET  

Initilize:     MOV game_state, #4
               MOV A, game_state
               MOV R4, #55h
				       MOV P5, R4

							 MOV R4, #100
							 CALL Delay

							 CALL LED_driver

							 MOV C, 1B
							 MOV P3.1, C
							 MOV C, 1B
							 MOV P3.0, C
							 RET





               jmp start ; Need a flag here for win state

							 END   