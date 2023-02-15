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
;Date[YYYYMMDD] Author      Description
;----           ------      -----------
;20230207       Jacob W.    initial commit
;20230209       Jacob W.    added clear RAM
;20230209       Jacob W.    add Jack F. to author
;20230209       Jacob W.    added sumo1 & 2
;************************************************************
$include (c8051f020.inc) 

        DSEG AT 30H
sumo1: 	        ds 1
sumo2: 	        ds 1
player1:        ds 1
player2:        ds 1
last_button:    ds 1
        
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

        ;and player1, player2
        mov A, player1
        anl A, player2
        mov P5, A

			  jmp init

;-------------- Main Game Code --------------------------   
main:   call delay
        call check_buttons 
        cjne A, #01, check_btn2
        mov R3, sumo1
        mov P5, R4
        jmp main
        
;-------------- Check Buttons Subroutine ----------------
check_buttons:  MOV A, P1
                CPL A
                XCH A, last_button
                XRL A, last_button
                ANL A, last_button
                RET

check_btn2:     CJNE A, #02, main
                mov R4, sumo2
                mov P5, R4
                jmp main
;------------- Update LEDs Subroutine -------------------


;------------- Randoom Delay Subroutine -----------------

;------------- Look Up Table ----------------------------
; The follow table consists of: 11111110, 11111101, 11111011, 11110111, 11101111, 11011111, 10111111, 01111111
init_table: DB 0FEh, 0FDh, 0FBh, 0F7h, 0EFh, 0DFh, 0BFh, 07Fh

;--------------------- Delay ----------------------------
delay:		MOV R4, #50 ;about 17.20ms
here1:		MOV R3, #250			
here2:		DJNZ R3, here2
                DJNZ R4, here1
                RET



loop1:  jmp loop1
        END



