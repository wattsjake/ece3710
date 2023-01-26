$include (c8051f020.inc) 

        mov wdtcn,#0DEh ; disable watchdog 
        mov wdtcn,#0ADh 
        mov xbr2,#40h ; enable port output

				cseg
loop1:	;mov A, #10101010B
				;mov P5, A

				;mov A, #00000001B
				;mov P3, A

				CLR C
				;SETB C
				mov P3.1, C

				;mov P5,P2 ; P2 - dip switch, P5 LED lights
				;mov C, P1.0
				;mov P3.0, C
				;mov C, P1.1
				;mov P3.1, C

				jmp	loop1

				END



        