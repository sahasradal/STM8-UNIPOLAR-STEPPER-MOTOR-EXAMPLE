stm8/

	#include "mapping.inc"
	#include "stm8s103f.inc"

	
pointerX MACRO first
	ldw X,first
	MEND
pointerY MACRO first
	ldw Y,first
	MEND
millis MACRO first
	pushw Y
	ldw Y,first
	call delayYx1mS
	popw Y
	MEND
	
micros MACRO first
	pushw Y
	ldw Y,first
	call usdelay
	popw Y
	MEND
	
	
	  segment byte at 100 'ram1'
buffer1  ds.b
buffer2  ds.b
buffer3  ds.b
nibble1  ds.b
temp	 ds.b


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	segment 'rom'
main.l
	; initialize SP
	ldw X,#stack_end
	ldw SP,X

	#ifdef RAM0	
	; clear RAM0
ram0_start.b EQU $ram0_segment_start
ram0_end.b EQU $ram0_segment_end
	ldw X,#ram0_start
clear_ram0.l
	clr (X)
	incw X
	cpw X,#ram0_end	
	jrule clear_ram0
	#endif

	#ifdef RAM1
	; clear RAM1
ram1_start.w EQU $ram1_segment_start
ram1_end.w EQU $ram1_segment_end	
	ldw X,#ram1_start
clear_ram1.l
	clr (X)
	incw X
	cpw X,#ram1_end	
	jrule clear_ram1
	#endif

	; clear stack
stack_start.w EQU $stack_segment_start
stack_end.w EQU $stack_segment_end
	ldw X,#stack_start
clear_stack.l
	clr (X)
	incw X
	cpw X,#stack_end	
	jrule clear_stack
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
infinite_loop.l

fclk.l 		equ 16000000
	
	mov CLK_CKDIVR,#$00	; cpu clock no divisor = 16mhz
	mov PC_DDR,#$f0		; enable PC7,PC6,PC5,PC4 as outputs
	mov PC_CR1,#$f0		; enable output as push pull 

test:
	mov buffer3,#$ff	; mov #255 into buffer3 (255 steps)
	call clock			; call subroutine to perform 8 half step in clockwise
	mov buffer3,#$ff	; mov #255 into buffer3 (255 steps)
	call clock			; call subroutine to perform 8 half step in clockwise
	mov buffer3,#$ff	; mov #255 into buffer3 (255 steps)
	call clock			; call subroutine to perform 8 half step in clockwise
	mov buffer3,#$ff	; mov #255 into buffer3 (255 steps)
	call clock			; call subroutine to perform 8 half step in clockwise
	mov buffer3,#$ff	; mov #255 into buffer3 (255 steps)
	call anticlock		; call subroutine to perform 8 half step in anticlockwise
	mov buffer3,#$ff	; mov #255 into buffer3 (255 steps)
	call anticlock		; call subroutine to perform 8 half step in anticlockwise
	mov buffer3,#$ff	; mov #255 into buffer3 (255 steps)	
	call anticlock		; call subroutine to perform 8 half step in anticlockwise
	mov buffer3,#$ff	; mov #255 into buffer3 (255 steps)
	call anticlock		; call subroutine to perform 8 half step in anticlockwise
	jp test 

clock:
	pointerX #CW		; call pointerX macro and point ot array holding clockwise steps
	mov buffer2,#8		; total half steps to becounted is 8
loop0:
	ld a,(X)			; load a value in address pointed by pointerX
	incw X				; increase pointer by 1
	ld PC_ODR,a			; load value in a to port C
	call ms10			; 10ms delay is called so the shaft stays in ew position for 10ms
	dec buffer2			; decrease step count
	jrne loop0			; loop to loop0 if buffer2 is not empty
	dec buffer3			; decrease totoal half step count by 1
	jrne clock			; if not equal to 0 loop back to clock label to step through the 8 steps
	ret					; return tocaller

anticlock:
	pointerX #CCW
	mov buffer2,#8
loop1:
	ld a,(X)
	incw X
	ld PC_ODR,a
	call ms10
	dec buffer2
	jrne loop1
	dec buffer3
	jrne anticlock
	ret


	; 28BYJ-48 unipolar stepper motor
	; blue1=4,pink2=5,yellow3=6,orange4=7
CW: dc.b $80,$C0,$40,$60,$20,$30,$10,$90
CCW: dc.b $90,$10,$30,$20,$60,$40,$C0,$80

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;DELAY routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	
delayYx1mS:
	call delay1mS
	decw Y
	jrne delayYx1mS
	ret
delay1mS:
	pushw Y
	ldw Y,#{{fclk/1000}/12}
delay1mS_01:
	decw Y
	jrne delay1mS_01
	popw Y
	ret


usdelay:
	decw Y
	pushw Y
	popw Y
	pushw Y
	popw Y
	jrne usdelay
	ret

ms2000:
	millis #2000
	ret
ms500:
	millis #500
	ret
ms250:
	millis #250
	ret
ms50:
	millis #50
ms30:
	millis #30
	ret
ms10:
	millis #10
	ret	


















	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

	segment 'vectit'
	dc.l {$82000000+main}									; reset
	dc.l {$82000000+NonHandledInterrupt}	; trap
	dc.l {$82000000+NonHandledInterrupt}	; irq0
	dc.l {$82000000+NonHandledInterrupt}	; irq1
	dc.l {$82000000+NonHandledInterrupt}	; irq2
	dc.l {$82000000+NonHandledInterrupt}	; irq3
	dc.l {$82000000+NonHandledInterrupt}	; irq4
	dc.l {$82000000+NonHandledInterrupt}	; irq5
	dc.l {$82000000+NonHandledInterrupt}	; irq6
	dc.l {$82000000+NonHandledInterrupt}	; irq7
	dc.l {$82000000+NonHandledInterrupt}	; irq8
	dc.l {$82000000+NonHandledInterrupt}	; irq9
	dc.l {$82000000+NonHandledInterrupt}	; irq10
	dc.l {$82000000+NonHandledInterrupt}	; irq11
	dc.l {$82000000+NonHandledInterrupt}	; irq12
	dc.l {$82000000+NonHandledInterrupt}	; irq13
	dc.l {$82000000+NonHandledInterrupt}	; irq14
	dc.l {$82000000+NonHandledInterrupt}	; irq15
	dc.l {$82000000+NonHandledInterrupt}	; irq16
	dc.l {$82000000+NonHandledInterrupt}	; irq17
	dc.l {$82000000+NonHandledInterrupt}	; irq18
	dc.l {$82000000+NonHandledInterrupt}	; irq19
	dc.l {$82000000+NonHandledInterrupt}	; irq20
	dc.l {$82000000+NonHandledInterrupt}	; irq21
	dc.l {$82000000+NonHandledInterrupt}	; irq22
	dc.l {$82000000+NonHandledInterrupt}	; irq23
	dc.l {$82000000+NonHandledInterrupt}	; irq24
	dc.l {$82000000+NonHandledInterrupt}	; irq25
	dc.l {$82000000+NonHandledInterrupt}	; irq26
	dc.l {$82000000+NonHandledInterrupt}	; irq27
	dc.l {$82000000+NonHandledInterrupt}	; irq28
	dc.l {$82000000+NonHandledInterrupt}	; irq29

	end
