;********************************************************
;Program Name:  "seg-test.asm"
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
;********************************************************                
$include (c8051f020.inc)
;------------------------ TODO --------------------------
;NA
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
sample: 	        ds 1

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
        ;anl A, #00Fh ;use only the first four(4) switches
        mov P4, A
        jmp init

        END
;------------------------ END ---------------------------
        