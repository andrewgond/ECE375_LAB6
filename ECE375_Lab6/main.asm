;***********************************************************
;*
;*	This is the skeleton file for Lab 6 of ECE 375
;*
;*	 Author: Andrew Gondoputro
;*			 Harrison Gregory
;*	   Date: 2-20-2025
;*
;*	Dscrp: This program utilized the buttons:
;*			d7 to increase power level of driven motor
;*			d6 set power level of driven motor to max
;*			d4 to decrease power level of driven motor
;*		
;*		There are 16 power levels, 0-15:
;*
;*		 - CurrPowLevel is represented as a 
;*		 binary value on LEDs D1 - D4 (D1 is msb)
;*
;*		- CurrMotorPower is represented as the total 
;*		brightness of LEDs D5 - D8 and corresponds to 
;*		CurrPowLevel
;*
;*
;***********************************************************

.include "m32U4def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register
.def	speedReg = r24		; User Defined Power Level of motor
.def	waitcnt = r17				; Wait Loop Counter
.def	ilcnt = r18				; Inner Loop Counter
.def	olcnt = r19				; Outer Loop Counter


.equ	maxSpeed = 15		; maximum power output level
.equ	minSpeed = 0		;
.equ	EngEnR = 5				; right Engine Enable Bit
.equ	EngEnL = 6				; left Engine Enable Bit
.equ	EngDirR = 4				; right Engine Direction Bit
.equ	EngDirL = 7				; left Engine Direction Bit

.equ	Right = 4				; Right Whisker Input Bit
.equ	Left = 5				; Left Whisker Input Bit

.equ	WTime = 50				; Time to wait in wait loop
.equ	BTime = 50				; Time to backup?

.equ	step = 17





;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000
		rjmp	INIT			; reset interrupt
.org	$0002				;
		nop					;
		reti				;
.org	$0004				;
		nop					;
		reti				;
.org	$008				;
		nop					;
		reti				;


		; place instructions in interrupt vectors here, if needed

.org	$0056					; end of interrupt vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:
		; Initialize the Stack Pointer
		ldi		mpr, low(RAMEND)  ; Load low byte of RAMEND into 'mpr'
		out		SPL, mpr  ; Store low byte of RAMEND into SPL (stack pointer low byte)
		ldi		mpr, high(RAMEND)  ; Load high byte of RAMEND into 'mpr'
		out		SPH, mpr  ; Store high byte of RAMEND into SPH (stack pointer high byte)

		; Configure I/O ports
		ldi		mpr, $FF		; Set Port B Data Direction Register
		out		DDRB, mpr		; for output
		ldi		mpr, $00		; Initialize Port B Data Register
		out		PORTB, mpr		; so all Port B outputs are low

		; Initialize Port D for input
		ldi		mpr, $00		; Set Port D Data Direction Register
		out		DDRD, mpr		; for input
		ldi		mpr, $FF		; Initialize Port D Data Register
		out		PORTD, mpr		; so all Port D inputs are Tri-State

		; Configure 16-bit Timer/Counter 1A and 1B
		; Fast PWM, 8-bit mode, no prescaling
		ldi mpr, 0b11_11_00_01
		sts TCCR1A, mpr

		ldi mpr, 0b000_01_001
		sts TCCR1B, mpr 
		ldi waitcnt, WTime		;
		; Set TekBot to Move Forward (1<<EngDirR|1<<EngDirL) on Port B
		ldi mpr, (1<<EngDirR) | (1<<EngDirL) | (1 << EngEnR) | (1 << EngEnL)
		out portB, mpr


		; Set initial speed, display on Port B pins 3:0
		ldi speedReg, 0

		; Enable global interrupts (if any are used)


;***********************************************************
;*	Main Program
;***********************************************************
MAIN:
		in		mpr, PIND		; Get Button input from Port D
		sbrs	mpr, right		; If Right button is high skip next
		rcall	SPEED_UP		; increment speed and do operation
		sbrs	mpr, left		; If left button is high skip next
		rcall	SPEED_DOWN		; Decrement speed and change stuff
		sbrs	mpr, 6			; Check if Third button is pressed and skip
		rcall	max_speed		; Turn speed to max



	rjmp	MAIN			; return to top of MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func:	Template function header
; Desc:	Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
FUNC:	; Begin a function with a label

		; If needed, save variables by pushing to the stack

		; Execute the function here

		; Restore any saved variables by popping from stack

		ret						; End a function with RET



;-----------------------------------------------------------
; Func:	Template function header
; Desc:	Cut and paste this and fill in the info at the
;		beginning of your functions
;----------------------------------------------------------
SPEED_UP:
	push mpr	

	ldi mpr, 15	; Use as temp
	cp speedREg,MPR	; Check if given speed is the same as 
	breq UP_SKIP	; If it is skip changing anything
	
	inc speedREg	; If not add to speed reg
	ldi mpr, 0b10010000	; For turning on mov fwd
	or mpr, speedREg	; Add the current speed level LED
	out portB, mpr	; Set LEDs to output
	rcall update_clock	; Set duty cycle based of speed level

UP_SKIP:
	rcall WAIT
	pop	mpr
	ret

;-----------------------------------------------------------
; Func:	Template function header
; Desc:	Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
SPEED_DOWN:
	push mpr		
	ldi mpr, 0		; Check edge case
	cp speedREG, mpr	; check edge case
	breq DOWN_SKIP	; skip if edge 

	dec speedREg	; decrement speed reg
	ldi mpr, 0b10010000 ; turn mov fwd leds
	or mpr, speedREg	; turn speed LEDs
	rcall Update_Clock	; update clock

	out portB, mpr 


DOWN_SKIP:
	rcall WAIT
	pop mpr
	ret

;-----------------------------------------------------------
; Func:	Template function header
; Desc:	Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
MAX_SPEED:

	push mpr
	ldi speedREg, 15 ; set max speed
	ldi mpr, 0b10010000	;mv fwd
	or mpr, speedREg	; update leds
	out portB, mpr ;display leds

	rcall Update_Clock	;update clk

	rcall WAIT;
	pop mpr
	ret

;-----------------------------------------------------------
; Func:	Update_clock
; Desc: Update clock params to change duty cycle and such
;-----------------------------------------------------------
Update_Clock:
	push mpr
	
	ldi mpr, 17	;Step by 17
	mul SpeedReg, mpr	; Multiply speed level by 17

	sts OCR1AH, r1	; Set the compare value for A
	sts OCR1AL, r0	; set compare value for A

	sts OCR1BH, r1	; set compare value for B
	sts OCR1BL, r0	; Set compare value for B

	pop mpr
	ret

;----------------------------------------------------------------
; Sub:	Wait
; Desc:	A wait loop that is 16 + 159975*waitcnt cycles or roughly
;		waitcnt*10ms.  Just initialize wait for the specific amount
;		of time in 10ms intervals. Here is the general eqaution
;		for the number of clock cycles in the wait loop:
;			(((((3*ilcnt)-1+4)*olcnt)-1+4)*waitcnt)-1+16
;----------------------------------------------------------------
Wait:
		push	waitcnt			; Save wait register
		push	ilcnt			; Save ilcnt register
		push	olcnt			; Save olcnt register

Loop:	ldi		olcnt, 224		; load olcnt register
OLoop:	ldi		ilcnt, 237		; load ilcnt register
ILoop:	dec		ilcnt			; decrement ilcnt
		brne	ILoop			; Continue Inner Loop
		dec		olcnt		; decrement olcnt
		brne	OLoop			; Continue Outer Loop
		dec		waitcnt		; Decrement wait
		brne	Loop			; Continue Wait loop

		pop		olcnt		; Restore olcnt register
		pop		ilcnt		; Restore ilcnt register
		pop		waitcnt		; Restore wait register
		ret				; Return from subroutine

;***********************************************************
;*	Stored Program Data
;***********************************************************
		; Enter any stored data you might need here

;***********************************************************
;*	Additional Program Includes
;***********************************************************
		; There are no additional file includes for this program
