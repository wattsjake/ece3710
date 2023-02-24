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
;20230218       Jack F.         Got game in working cond-
;                               -ition but glitchy             
;********************************************************                
$include (c8051f020.inc) 

        DSEG AT 30H
sumo1: 	        ds 1
sumo2: 	        ds 1
player1:        ds 1
player2:        ds 1
last_button:    ds 1;used inside checkbuttons
current_button: ds 1
button_store:   ds 1
rand_int:       ds 1
temp1:          ds 1

p1_track_high:     ds 1
p1_track_low:     ds 1
p2_track_high:     ds 1
p2_track_low:     ds 1
p_total_track_high: ds 1  
p_total_track_low: ds 1  
led_track:    ds 1
led_edge_track: ds 1

        
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

        mov	oscxcn,#67H	; turn on external crystal
      	mov	tmod,#20H		; wait 1ms using T1 mode 2
      	mov	th1,#256-167	; 2MHz clock, 167 counts = 1ms
      	setb	tr1
wait1:
      	jnb	tf1,wait1
      	clr	tr1			; 1ms has elapsed, stop timer
      	clr	tf1
wait2:
      	mov	a,oscxcn		; now wait for crystal to stabilize
      	jnb	acc.7,wait2
      	mov	oscicn,#8		; engage! Now using 22.1184MHz


        mov p1_track_high, #00h
        mov p1_track_low, #00h
        mov p2_track_high, #00h
        mov p2_track_low, #00h
        mov p_total_track_high, #00h  
        mov p_total_track_low, #00h
        mov led_track, #00h
        mov led_edge_track, #00h
        mov last_button, #00h
        mov current_button, #00h
        mov button_store, #00h
        mov p1_track_high, #00h
        mov p2_track_high, #01h
        mov p2_track_low, #00h
        mov p1_track_low, #80h
  
        call disp_update

        call delay_1000ms;1s delay for start of game

        mov A, player1;split the players apart
        rr A ;rotate right 
        mov player1, A
        mov A, player2
        rl A ;rotate left
        mov player2, A

        


        

;-------------- Main Game Code --------------------------   
main:   
        
        
        call check_buttons
        call delay
        call move_players
        call split



        mov A, p_total_track_low
        cjne A, #18h, check_high
        jmp init
        
check_high:
        mov A, p_total_track_high
        cjne A, #18h, proceed
        jmp init

proceed:
        call disp_update 
       
; Check if game is in a winning state
        mov last_button, button_store
        jmp main

   
;-------------- Check Buttons Subroutine ----------------
; Check the state of the buttons and store it in the button_store variable
; Args: P1, A, button_store
; Returns: button_store
; Destroys: A, button_store
check_buttons:  MOV A, P1
                cpl A
                anl A, #03h
                mov button_store, A
                RET

move_players: 
                mov A, button_store
                xrl A, last_button
                
cp0:            cjne A, #00h, cp1
                ret

cp1:            cjne A, #01h, cp2
                call roll_p1
                call disp_update
                ret

cp2:            cjne A, #02h, cp3
                call roll_p2
                call disp_update
                ret

cp3:            mov  A, last_button  
                cjne A, #03h, scp1
                jmp main
                ret
                
scp1:           cjne A, #02h, scp2
                call roll_p2
                call disp_update
                ret

scp2:           cjne A, #01h, scp3
                call roll_p1
                call disp_update
                ret

scp3:           call roll_p1               
                call roll_p2
                call disp_update
                ret

                RET


;------------- Roll P1 Sub ------------------------------
; Rotate the 16-bit player 1 storage variable to the right 
; Args: A, B, p1_track_low, p1_track_high
; Returns: p1_track_low, p1_track_high
; Destroys: A, B
roll_p1:
        mov A, p1_track_low
        mov B, p1_track_high
        rlc A
        xch A, B
        rlc A
        xch A, B
        mov p1_track_low, A
        mov p1_track_high, B
        ret


;------------- Roll P2 Sub ------------------------------
; Rotate the 16-bit player 2 storage variable to the left 
; Args: A, B, p2_track_low, p2_track_high
; Returns: p2_track_low, p2_track_high
; Destroys: A, B
roll_p2:
        mov A, p2_track_high
        mov B, p2_track_low
        rrc A
        xch A, B
        rrc A
        xch A, B
        mov p2_track_high, A
        mov p2_track_low, B
        ret


;------------- Roll P1 Sub for Split ------------------------------
; Rotate the 16-bit player 1 storage variable to the left. This function
; is used explicitly for the split subroutine 
; Args: A, B, p1_track_low, p1_track_high
; Returns: p1_track_low, p1_track_high
; Destroys: A, B
roll_p1_split:
        mov A, p1_track_high
        mov B, p1_track_low
        rrc A
        xch A, B
        rrc A
        xch A, B
        mov p1_track_high, A
        mov p1_track_low, B
        ret


;------------- Roll P2 Sub for Split ------------------------------
; Rotate the 16-bit player 2 storage variable to the right. This function
; is used explicitly for the split subroutine 
; Args: A, B, p2_track_low, p2_track_high
; Returns: p2_track_low, p2_track_high
; Destroys: A, B
roll_p2_split:
        mov A, p2_track_low
        mov B, p2_track_high
        rlc A
        xch A, B
        rlc A
        xch A, B
        mov p2_track_low, A
        mov p2_track_high, B
        ret

;------------ 16 anding sub ------------------------------
; This routine ands the p1 and p2 16 bit tracker variables. 
; Args: A, B, p1_track_low, p1_track_high
; Returns: p1_track_low, p1_track_high
; Destroys: A
big_oring: 
        mov A, p1_track_high
        orl A, p2_track_high
        mov p_total_track_high, A
        mov A, p1_track_low
        orl A, p2_track_low
        mov p_total_track_low, A
        ret

;------------- Update LEDs Subroutine -------------------
; This routine masks the middle 8 bits of the now anded "p_total_track" 16 
; bit tracker variable with a 0Fh. It then masks out the 5 bits of the 
; upper and lower tracks for the end LEDs on the board. 
; Args: A, B, p_total_track_low, p_total_track_high, led_edge_track
; Returns: P5, P3
; Destroys: A
disp_update:
        call big_oring
; Middle 8-bits masking
        mov A, p_total_track_high
        anl A, #0Fh
        rl A
        rl A
        rl A
        rl A
        mov led_track, A
        mov A, p_total_track_low
        anl A, #11110000b
        rr A
        rr A
        rr A
        rr A
        orl A, led_track
        mov led_track, A

; Edge masking
        mov A, p_total_track_high
        anl A, #10h
        rr A
        rr A
        rr A
        mov led_edge_track, A
        mov A, p_total_track_low
        anl A, #08h
        rr A
        rr A
        rr A
        orl A, led_edge_track
        mov led_edge_track, A

        mov A, led_track
        cpl A
        mov P5, A
        mov A, led_edge_track
        cpl A
        mov P3, A
        
        ret

;------------- Look Up Table ----------------------------
; Look Up Table for LED position
; Args: na
; Returns: na
; Destroys: na
; The follow table consists of: 11111110, 11111101, 11111011, 11110111, 11101111, 11011111, 10111111, 01111111
init_table: DB 0FEh, 0FDh, 0FBh, 0F7h, 0EFh, 0DFh, 0BFh, 07Fh


;------------- Random Delay Subroutine -------------------
; Random Delay Subroutine between .5-1.0s
; Args: rand_int
; Returns: na
; Destroys: Acc, Carry, R2
delay_random:
            mov A, rand_int
            add A, #050 ;delay between .5-1 S
compare:    mov R2, A
            cjne A, #000h, call_delay
            clr A;just for saftey
            clr C;just for saftey 
            RET

call_delay: call delay
            dec R2
            mov A, R2
            jmp compare
        
;----------------- Delay Subroutine ----------------------
; Delay Subroutine about 17.20 ms
; Args: na
; Returns: na
; Destroys: R7, R4, R3
delay:
        djnz R7,carry_on 
        mov R7,#50 
carry_on:
        MOV R4, #50 ;about 17.20 ms
here1:	MOV R3, #250			
here2:	DJNZ R3, here2
        DJNZ R4, here1
        RET
        


;--------------- Split Routine ------------------
; Splits the two players apart
; Args: led_track, p_total_track_high, p_total_track_low
; Returns: na
; Destroys: Acc, R6
split:  

        mov A, led_track
        cjne A, #18h, start_check
        call split_actual
        ret

start_check:        
        mov R6, #00h
        mov A, p_total_track_high
css1:   cjne A, #03h, cs1
        jmp split_actual
cs1:
        cjne R6, #03h, cs11
        jmp part2
cs11:  inc R6     
        rr A
        jmp css1


part2:  mov R6, #00h
        mov A, p_total_track_low
css2:   cjne A, #03h, cs2
        jmp split_actual
cs2:
        cjne R6, #07h, cs22
        jmp not_next_to_each_return
cs22:  inc R6     
        rr A
        jmp css2


split_actual:

        mov A, button_store
        call check_buttons
        cjne A, #00, split_actual

        call roll_p1_split
        call delay_1000ms
        call roll_p2_split
        call delay_1000ms
        ret


not_next_to_each_return: ret


;-------------------- 1000ms Delay -----------------------
; Create a delay of 1000ms or 1s
; Args: na
; Returns: na
; Destroys: R5, R4, R3
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



