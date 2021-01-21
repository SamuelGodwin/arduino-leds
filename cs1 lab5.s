; Samuel Godwin
; K1630575
;
; my_k_num.s : switches on external LEDs connected to my Arduino.
; Writes out each digit of my King's k-number separately, in sequence, to PORTB (LEDs).
; Left-most numerical digit first.


; 128K = 2^7*2^10 = 2^17 ; 2^17/2^8 = 2^9 blocks in cache, so 9 bits are needed for the block field.
; 8 bits are needed for the word field, leaving 6 for the tag.
;
;    tag            block           offset
;  (6 bits)        (9 bits)        (8 bits)
;
;|_ _ _ _ _ _|_ _ _ _ _ _ _ _ _|_ _ _ _ _ _ _ _|					DOUBLE CHECK THIS
;
;   011010        011011100         11110000
;
;   nttttttb bbbbbbbb oooooooo



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



ldi r16,0xDB
out PORTB, r16
out PORTD, r16


; write out each digit of my King's k-number separately, in sequence, to PORTB (LEDs)
;ldi r16,0x01
;out PORTB,r16

;ldi r16,0x06
;out PORTB,r16

;ldi r16,0x03
;out PORTB,r16

;ldi r16,0x00
;out PORTB,r16

;ldi r16,0x05
;out PORTB,r16

;ldi r16,0x07
;out PORTB,r16

;ldi r16,0x05
;out PORTB,r16


; load 01101001101110011110000 into as many registers necessary to store the entire memory address (separate bytes stored in registers).

; 00110100 = 0x34	 11011100 = 0xDC	11110000 = 0xF0
;		r22					r21				r20

ldi r20, 0xF0
ldi r21, 0xDC
ldi r22, 0x34

mainloop: rjmp  mainloop	; jump  back to  mainloop  address

			; decode subroutine
			; (DESCRIPTION OF DECODE SUBROUTINE)
			
decode:		; first, display  the Tag  bits for  the  memory  address  on  the  LEDs 
			; Display the byte 0x1A on the LEDs for 0.5 seconds for the Tag Field.     ...;fill in other bits with binary 0s - use 'and'?
			result 0x1A = 00011010)?? <- SHIFT r22 ONE TO THE RIGHT
			
			; Turn off the LEDs for 1 second.
			
			; Display the byte 0xDC (11011100) on the LEDs for 0.5 seconds for the first byte of the Block field.  ....;little endian - use lsl, lsr//(involve or to display both? no)
			Display r21 as normal (or perhaps ORed with 00000000/ANDed with identical clone to make clear no change OR MAYBE LOTS OF SHIFTS WOULD MAKE MORE SENSE?)?
			; Display the byte 0x00 (00000000) on the LEDs for 0.5 seconds for the second byte of the Block field
			Display r21, ANDed for a bit mask 00000000 (OR MAYBE LOTS OF SHIFTS ---'SWAP VALUE' WOULD MAKE MORE SENSE?) -i.e could i do 0000000011011100 shifted 8 left then right..?
																															or something similar?
			
			; Turn off the LEDs for 1 second.
			
			; Display the byte 0xF0 on the LEDs for 0.5 seconds for Word offset field.
			r20 already in correct form so either 'or' with all 0s, or AND with identical...?
			
			; Turn off the LEDs 1 second and then return from the sub-routine.
			
			
ret                  	; Return from subroutine