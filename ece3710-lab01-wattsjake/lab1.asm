$include (c8051f020.inc) 
 
        dseg at 30h 
str_d:  ds      10h             ; reserve 16 bytes 
 
        iseg at 80h 
str_i:  ds      10h             ; reserve 16 bytes 
stack:  ds      70h             ; reserve the rest for stack 
 
        xseg at 20h 	          ; print at mem location 20h
str_x:  ds      10h             ; reserve 16 bytes 
 
        bseg 
flag:   dbit    1               ; reserve 1 bit for flag 
 
        cseg 
        mov     wdtcn,#0DEh      ; Disable watchdog for hex values you need to have a zero infront
        mov     wdtcn,#0ADh      ; Disable watchdog
        mov     r0,#255 
clrall: mov     @r0,#0          ; clear all internal ram 
        djnz    r0,clrall 
        setb    flag            ; set flag bit 
        mov     sp,#stack-1     ; initialize stack 
        mov     dptr,#str_x     ; point dptr at str_x 
        mov     r0,#str_d       ; point r0 at str_d 
        mov     r1,#str_i       ; point r1 at str_i 
        mov     r6,#10h          ; copy all the bytes 
        mov     r7,#str_c-pc_rel; pc relative offset to str_c 
loop1:  mov     a,r7            ; offset to first (next) byte 
        movc    a,@a+pc         ; actually get the byte 
pc_rel: mov     @r0,a           ; store in str_d 
        mov     @r1,a           ; store in str_i 
        movx    @dptr,a         ; store in str_x 
        inc     r0 
				inc 		r1
        inc     dptr            ; increment pointers 
        inc     r7 
        djnz    r6,loop1        ; loop 16 times 
loop2:  sjmp    loop2           ; wait forever 
 
str_c:  db "Hello, Students", 0 
        end