;********************************************************
;Program Name:  "counter.asm"
;Description:   Simple assembly code for testing each
;               segment of the 7-segment display. Use
;               the dip switches to increment through
;               0-9 on the display
;
;Author:        Jacob Watts
;Organization:  NA
;Revision History
;Date[YYYYMMDD] Author          Description
;----           ------          -----------
;20230207       Jacob W.        initial commit
;20230224       Jacob W.        completed test code 
;20230224       Jacob W.        copied and pasted code
;                               from seg-test.asm 
;20230224       Jacob W.        added counter code    
;********************************************************                
$include (c8051f020.inc)
;------------------------ TODO --------------------------
;fix count to skip A-F and inc second display


;--------------------- Registery ------------------------
;R0 - clr RAM (can used after clear RAM?)
;R1 - 
;R2 - 
;R3 - 1000 ms delay
;R4 - 1000 ms delay
;R5 - 1000 ms delay
;R6 - 
;R7 - 
;------------------------ DSEG --------------------------
        DSEG AT 30H
count: 	        ds 1

;------------------------ CSEG --------------------------       
        CSEG
        mov wdtcn,#0DEh ; disable watchdog 
        mov wdtcn,#0ADh 
        mov xbr2,#40h ; enable port output

        ;clear all internal ram 
        mov     r0,#255 
clrall: mov     @r0,#0
        djnz    r0,clrall
;---------------PLACE CODE BELOW THIS LINE---------------

;---------------- Initialization Code -------------------
        cseg 
init:   mov A, P2 ;DIP switches 
        cpl A       ;complement dip switches to invert in
        mov P4, A
        mov count, A

;------------------------ Main ---------------------------
main:   call count_inc
        call delay_1000ms
        mov A, count
        mov P4, A
        jmp main

;----------------- Counter Subroutine --------------------
count_inc:  mov A, count
            inc A 
            mov count, A  
            ret 
            


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

        END
;------------------------ END ---------------------------
        