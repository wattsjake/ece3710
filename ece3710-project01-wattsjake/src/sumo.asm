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
;********************************************************
$include (c8051f020.inc) 

        DSEG AT 30H
sumo1: 	        ds 1
sumo2: 	        ds 1
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

init:   mov A, P2 ;DIP switches 
        anl A, #7 ;use only the first three (3) switches
        mov sumo1, A 
        inc A
        mov sumo2, A

start:  call delay
        call check_buttons 
        cjne A, #01, check_btn2
        mov R4, #0FFh
        mov P5, R4
        jmp start

check_btn2:    CJNE A, #02, init
               jmp start

check_buttons: MOV A, P1
               CPL A
               XCH A, last_button
               XRL A, last_button
               ANL A, last_button
               RET
;-----DELAY
delay:		MOV R4, #50 ;about 17.20ms
here1:		MOV R3, #250			
here2:		DJNZ R3, here2
			DJNZ R4, here1
			RET



loop1:  jmp loop1
        END



