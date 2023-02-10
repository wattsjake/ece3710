$include (c8051f020.inc) 

        mov wdtcn,#0DEh ; disable watchdog 
        mov wdtcn,#0ADh 
        mov xbr2,#40h ; enable port output

        ;clear all internal ram 
        mov     r0,#255 
clrall: mov     @r0,#0
        djnz    r0,clrall 

	cseg

loop:   mov A, #03Ch
        mov R1, #096h

        cjne R1, #100, foo
        jmp loop

foo:    mov R2, #0F8h
        jmp loop

        END



			


