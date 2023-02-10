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
;********************************************************
$include (c8051f020.inc) 

        mov wdtcn,#0DEh ; disable watchdog 
        mov wdtcn,#0ADh 
        mov xbr2,#40h ; enable port output

;clear all internal ram 
        mov     r0,#255 
clrall: mov     @r0,#0
        djnz    r0,clrall

        cseg
        mov A, P2
        anl A, #7
        mov R3, A


loop:   jmp loop
        END



