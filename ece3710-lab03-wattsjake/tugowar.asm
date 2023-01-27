$include (c8051f020.inc) 

       		mov wdtcn,#0DEh ; disable watchdog 
        	mov wdtcn,#0ADh

					mov xbr2,#40h ; enable port output

p1_table: db 0FFh, 0FEh, 0FCh, 0F9h, 0F3h, 0E7h, 0CFh, 09Fh, 03Fh, 07Fh, 0Ffh

					dseg at 30h
last_btn:	ds 			1 ;reserve 1 bit

					cseg
loop1:  	mov P5,P2 ; P2 - dip switch, P5 LED lights
					mov C, P1.0
					mov P3.0, C
					mov C, P1.1
					mov P3.1, C
					jmp loop1

					END



