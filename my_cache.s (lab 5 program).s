; Samuel Godwin
; K1630575
;
; my_cache.s : uses bit operators to decode a memory address for my computer architecture (01101001101110011110000) into its separate cache address components.
; decode subroutine: finds the Tag, Block, and Word Offset bits for a supplied memory address and displays them on the LEDs as bytes
; Writes out each, in sequence, to PORTB / PORTD (LEDs for 8 bits).
; 128K = 2^7*2^10 = 2^17 ; 2^17/2^8 = 2^9 blocks in cache, so 9 bits are needed for the Block field.
; 8 bits are needed for the Word Offset field, leaving 6 for the Tag field.
;
; Tag field contains 6 bits: 011010
; Block field contains 9 bits: 011011100
; Word Offset field contains 8 bits: 11110000
;
; Desired outputs: 00011010, 11011100 & 00000000, 11110000.
;
; Register r20 will contain: 11110000 (oooooooo, where o = 'offset' bit )
; Register r21 will contain: 11011100 (bbbbbbbb, where b = 'block' bit  )
; Register r22 will contain: 00110100 (0ttttttb, where t = 'tag' bit and b = 'block' bit)


; specify  equivalent  symbols
.equ SREG , 0x3F	; Status  register.  See  data  sheet , p.11
.equ PORTB, 0x05
.equ PORTD, 0x0B
.equ DDRB, 0x04
.equ DDRD, 0x0A

; specify  the  start  address
.org 0
; reset  system  status
main:	ldi r16,0		; set  register  r16 to zero
	out SREG ,r16		; copy  contents  of r16 to SREG , i.e. , clear  SREG.

; set  bits  0-3  on DDRB (for bits 0-3 on PORTB to  be  in output mode)
ldi r16,0x0F
out DDRB,r16

; set  bits  4-7  on DDRD (for bits 4-7 on PORTD to  be  in output mode)
ldi r16,0xF0
out DDRD,r16

; load 01101001101110011110000 into as many registers necessary to store the entire memory address (separate bytes stored in registers r20, r21 & r22).

; 11110000 (0xF0) in r20
ldi r20, 0xF0
; 11011100 (0xDC) in r21
ldi r21, 0xDC
; 00110100 (0x34) in r22
ldi r22, 0x34

call decode 	; Call decode subroutine

mainloop: rjmp  mainloop	; jump  back to  mainloop  address

			; decode subroutine: finds the Tag, Block, and Word Offset bits for a supplied memory address and displays them on the LEDs as bytes
			; (DESCRIPTION OF DECODE SUBROUTINE)
			
decode:			; first, display  the Tag  bits for  the  memory  address  on  the  LEDs 
			; Display the byte 0x1A on the LEDs for 0.5 seconds for the Tag Field.             thought: ...;fill in other bits with binary 0s - use 'and'?
			
			call tag	; Call tag subroutine
                                                                                                                       ;  result 0x1A = 00011010)?? <- SHIFT r22 ONE TO THE RIGHT
			call halfsec 	; Call 0.5s subroutine

			; Turn off the LEDs for 1 second.
			call offsec	; Call off for 1s subroutine

			call block	; Call block subroutine
			call halfsec	; Call 0.5s subroutine

			; Turn off the LEDs for 1 second.
			call offsec	; Call off for 1s subroutine

			call offset	; Call offset subroutine
			call halfsec	; Call 0.5s subroutine
			
			; Turn off the LEDs 1 second and then return from the sub-routine.
			call offsec	; Call off for 1s subroutine
ret                  	; Return from subroutine

			; tag subroutine: display  the Tag  bits for  the  memory  address  on  the  LEDs 
			; Display the byte 0x1A on the LEDs for 0.5 seconds for the Tag Field.
tag:			ldi r23, 0x00	; load 00000000 into r23
			or r23, r22	; 'or' of r23 and r22: since r23 contains 0x00, this simply copies exact contents of r22 into r23 (for use with lsr, etc).
			; now r23 contains the same contents as r22, I will manipulate the contents of r23 for display.

			lsr r23 ; divide r23 by 2

			out PORTB, r23	; output r23 result 
			out PORTD, r23	; output r23 result 
ret                  	; Return from subroutine

			; block subroutine: display Block field in little endian form since my block field (011011100) is 9 bits long
			; Display the byte 0xDC (11011100) on the LEDs for 0.5 seconds for the first byte of the Block field.
			; Display the byte 0x00 (00000000) on the LEDs for 0.5 seconds for the second byte of the Block field.
			; as my block field contains 9 bits, 011011100, I am required to display it in endian form where 0xDC is my first display, and 0x00 is my second.
			; r21 already contains 0xDC.
block:			out PORTB, r21	; output r21, which already contains 0xDC 
			out PORTD, r21	; output r21, which already contains 0xDC 

			call halfsec	; Call 0.5s subroutine

			ldi r23,0x01	; load 00000001 into r23, for use in bit mask.
			and r23, r22	; 'and' to achieve bit mask result (isolates the very lowest bit of r22 - which is a vital part of my Block field).
					; This needs to be displayed second, when showing little endian form of my Block field

			out PORTB, r23	; output r23, which contains the result of my bit mask & isolates just the lowest bit of r22 (which belongs in my Block field).
			out PORTD, r23	; output r23, which contains the result of my bit mask & isolates just the lowest bit of r22 (which belongs in my Block field).
ret                  	; Return from subroutine

			; offset subroutine: display Word offset field
			; Display the byte 0xF0 on the LEDs for 0.5 seconds for Word offset field.
			; r20 already contains the Word offset field which is 8 bits long. Therefore, just display the contents of register r20 across PORTB and PORTD for Word offset field display.
offset:			out PORTB, r20	; output r20, which already contains 0xF0 
			out PORTD, r20	; output r20, which already contains 0xF0 
ret                  	; Return from subroutine

			; delay subroutine: delay for 10ms (36,000 iterations of a 31.25 microseconds loop): 
			; maximum number of iterations we can have the loop perform is 255.
			; 255 * 142 (36,210. 142 is 141.176471 rounded up).
delay: 			ldi r17, 255
			ldi r18, 142
	loop1:  	nop
			dec r17
			cpi r17, 0
			brne  loop1
			ldi r17, 255
			dec r18
			cpi r18, 0
			brne loop1
			ldi r18, 142
ret                  	; Return from subroutine

			; offsec subroutine: delays off for 1000ms (1s)
offsec:			ldi r16, 0x00
			out PORTB, r16
			out PORTD, r16
			; delay = 10ms subroutine
			; uses  r19  as  the  number  of  10ms  delays  the  sub-routine  will iterate over
			ldi r19, 100
	loop2:		call delay		; Call subroutine
			nop			; Continue (do nothing)
			dec r19
			cpi r19, 0
			brne loop2
ret                  	; Return from subroutine

			; halfsec subroutine: delays on for 500ms (0.5s)
			; delay = 10ms subroutine
			; uses  r19  as  the  number  of  10ms  delays  the  sub-routine  will iterate over
halfsec:		ldi r19, 50
	loop3:		call delay		; Call subroutine
			nop			; Continue (do nothing)
			dec r19
			cpi r19, 0
			brne loop3
ret                  	; Return from subroutine
