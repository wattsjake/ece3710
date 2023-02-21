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
;20230218       Jacob W.        fixed split on edges 
;20230220       Jacob W.        added winner check               
;********************************************************                
$include (c8051f020.inc)
;------------------------ TODO --------------------------
;call random delay

;--------------------- Registery ------------------------
;R0 - clr RAM
;R1 -
;R2 - 
;R3 - delay
;R4 - delay
;R5 - delay
;R6 -
;R7 - rand delay
;------------------------ DSEG --------------------------
        DSEG AT 30H
sumo1: 	        ds 1
sumo2: 	        ds 1
player1:        ds 1
player2:        ds 1
player1_temp:   ds 1
player2_temp:   ds 1
last_button:    ds 1;used inside checkbuttons
current_button: ds 1
button_store:   ds 1
led_position:   ds 1
rand_int:       ds 1
position_count: ds 1
split_state:    ds 1
dual_press:     ds 1
game_state:     ds 1;tell when game ends

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

        mov A, #000h; set game state false (0)
        mov game_state, A

rand_delay:;enter random delay 

        call delay_1000ms;1s delay for start of game

        call split

        call disp_upt

;-------------- Main Game Code --------------------------   
main:       call delay
            jmp check_buttons
disp_call:  call disp_upt
                  
;Check if game is in a winning state
            mov last_button, button_store;use with check_btn
            call check_position
            mov A, game_state
            cjne A, #000h, init ;check for game state
            mov A, split_state ;if split state is 1 jmp delay
            cjne A, #000h, rand_delay
            jmp main

   
;-------------- Check Buttons Subroutine ----------------
check_buttons:  MOV A, P1
                cpl A
                anl A, #03h
                mov button_store, A; if 2 roll p2; if 1 roll p1
                xrl A, last_button

                ;there's a bug when last_button is #03h
                cjne A, #03h, cp0 ;used to see if dual press
                    mov A, #001h
                    mov dual_press, A ;set dual_press to true
                    mov A, #000h
                    mov last_button, A
                    jmp main
              
cp0:            cjne A, #00h, cp1
                jmp main

cp1:            cjne A, #01h, cp2
                call roll_p1 ;player 1 is the right one
                jmp disp_call

cp2:            cjne A, #02h, cp3
                call roll_p2 ;player 2 is the left one
                jmp disp_call

cp3:            mov  A, last_button  
                cjne A, #03h, scp1
                jmp main
                
scp1:           cjne A, #02h, scp2
                call roll_p2
                jmp disp_call

scp2:           cjne A, #01h, scp3
                call roll_p1
                jmp disp_call

scp3:           call roll_p1               
                call roll_p2
                jmp disp_call

                RET
;------------- Roll P1 Sub ------------------------------
roll_p1: 
            mov A, player1
            clr C ;this allows the rlc to work properly
            cjne A, #0FFh, roll_cont1
                mov A, #0FFh 
                mov P3, A; turn off P3 led
                mov A, #0FFh ;reset A to 
roll_cont1: rlc A;needs to be rlc to work correctly
            mov player1, A
            clr A;just for saftey
            clr C;just for saftey
            ret

;------------- Roll P2 Sub ------------------------------
roll_p2:
            mov A, player2
            cjne A, #0FFh, roll_cont2
                mov A, #0FFh 
                mov P3, A; turn off P3 led
                mov A, #0FEh ;reset A to 
roll_cont2: rr A
            mov player2, A
            ret

;------------- Check LED Position Subroutine ------------
check_position: 
                mov A, #00h
                mov position_count, A ;zero the count
                mov A, led_position
                cpl A
                mov led_position, A
                mov A, led_position
winner2:        cjne A, #01h, winner1;check to see winner  pl2
                    mov A, #001h ;game state true (1)
                    mov game_state, A
                    call delay_1000ms
                    mov A, #0FFh
                    mov P3, A;turn off far right LED
                    ret
winner1:        cjne A, #080h, loop1
                    mov A, #001h ;game state true (1)
                    mov game_state, A
                    call delay_1000ms
                    mov A, #0FFh
                    mov P3, A; turn off far left LED
                    ret                
loop1:          mov A, led_position
                cjne A, #03h, loop2
                    mov A, #01h
                    mov split_state, A ;mov true into state
                    clr A ; clear accumulator 
                    ret
                
loop2:          rr A
                mov led_position, A
                inc position_count
                mov A, position_count
                cjne A, #07h, loop1
                    mov A, #00h
                    mov position_count, A ;zero the count
                    mov A, #00h
                    mov split_state, A ;clear split state
                    clr A
                    ret

;-------------- Split LED Subroutine --------------------
;Destroys: acc, carry
split:  mov A, player1;split the players apart
        cpl A ;inverse so that carry works
        clr C
        rrc A ;rotate right carry
        cpl A
        mov player1_temp, A
        jb psw.7, update_led1
cont1:  mov player1, player1_temp
        mov A, player2
        cpl A
        clr C ;clear carry so rlc work correctly
        rlc A ;rotate left carry
        cpl A
        mov player2_temp, A
        jb psw.7, update_led2
cont2:  mov player2, player2_temp
        clr C ;clear carry after leaving
        clr A ;clear carry for saftey 
        ret 

update_led1:
        mov A, #01h
        mov P3, A;turn on right led
        jmp cont1

update_led2:
        mov A, #02h
        mov P3, A ;turn on left led
        jmp cont2

;------------- Update LEDs Subroutine -------------------
disp_upt:     
        mov A, player1
        anl A, player2
        mov P5, A
        mov led_position, A ;for used with position 
        ret

;------------- Look Up Table ----------------------------
;The follow table consists of: 11111110, 11111101, 11111011, 11110111, 11101111, 11011111, 10111111, 01111111
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

        END