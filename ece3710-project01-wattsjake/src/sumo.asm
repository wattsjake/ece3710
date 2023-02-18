;********************************************************
;Program Name:  "sumo.asm"
;Description:   A two-player game using the bar graph and 
;               two push buttons. Each player will 
;               control one of two sumo wrestlers and
;               each will try to push the 
;               other out of the ring.
;
;Author:        Jacob Watts & Jack Fernald
;Organization:  Weber State University ECE 3710
;Revision History
;Date[YYYYMMDD] Author          Description
;----           ------          -----------
;20230207       Jacob W.        initial commit
;20230209       Jacob W.        added clear RAM
;20230209       Jacob W.        add Jack F. to author
;20230209       Jacob W.        added sumo1 & 2
;20230214       Jacob W.        added 1000ms delay                
;********************************************************                
$include (c8051f020.inc) 

        DSEG AT 30H
sumo1: 	        ds 1
sumo2: 	        ds 1
player1:        ds 1
player2:        ds 1
last_button:    ds 1;used inside checkbuttons
current_button: ds 1
button_rls:     ds 1;used to check button release
rand_int:       ds 1

        
        CSEG
        mov wdtcn,#0DEh ; disable watchdog 
        mov wdtcn,#0ADh 
        mov xbr2,#40h ; enable port output

        ;clear all internal ram 
        mov     r0,#255 
clrall: mov     @r0,#0
        djnz    r0,clrall
;---------------PLACE CODE BELOW THIS LINE---------------


;-------------- Initialization Code ---------------------
        cseg 
init:   mov A, P2 ;DIP switches 
        anl A, #7 ;use only the first three (3) switches
        mov sumo1, A 
        inc A
        mov sumo2, A

        mov A, sumo1
        mov dptr, #init_table
        movc A, @A+dptr
        mov player1, A
        
        mov A, sumo2
        mov dptr, #init_table
        movc A, @A+dptr
        mov player2, A

        mov A, player1
        anl A, player2
        mov P5, A

        call delay_1000ms;1s delay for start of game

        mov A, player1;split the players apart
        rr A ;rotate right 
        mov player1, A
        mov A, player2
        rl A ;rotate left
        mov player2, A

        mov A, player1
        anl A, player2
        mov P5, A

;-------------- Main Game Code --------------------------   
main:   call delay
        call check_buttons
        
        mov A, current_button
roll_p1:cjne A, #01h, roll_p2 
        mov A, player1
        rl A
        mov player1, A
        jmp disp_upt

roll_p2:cjne A, #02h, main
        mov A, player2
        rr A
        mov player2, A
        jmp disp_upt

        



disp_upt:;should we change this to update display?     
        mov A, player1
        anl A, player2
        mov P5, A 
       
; Check if game is in a winning state
        jmp main

   
;-------------- Check Buttons Subroutine ----------------
check_buttons:  MOV A, P1
                CPL A
                ANL A, #03h
                mov current_button, A
                ret

;------------- Update LEDs Subroutine -------------------
; Reference Main

;------------- Look Up Table ----------------------------
; The follow table consists of: 11111110, 11111101, 11111011, 11110111, 11101111, 11011111, 10111111, 01111111
init_table: DB 0FEh, 0FDh, 0FBh, 0F7h, 0EFh, 0DFh, 0BFh, 07Fh

ext_table: DB 0FFh

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


loop1:  jmp loop1
        END



