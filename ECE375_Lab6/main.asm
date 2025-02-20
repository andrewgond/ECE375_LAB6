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
.def	CurrPowLevel = r24		; User Defined Power Level of motor
.def	maxPowLevel = 15		; maximum power output level
.equ	EngEnR = 5				; right Engine Enable Bit
.equ	EngEnL = 6				; left Engine Enable Bit
.equ	EngDirR = 4				; right Engine Direction Bit
.equ	EngDirL = 7				; left Engine Direction Bit




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

		; Configure External Interrupts, if needed
		ldi mpr, 0b1000_1010		;
		sts EICRA, mpr				;
		ldi mpr, 0b0000_1011		;
		out EIMSK, mpr				; set the mask
		sei

		; Configure 16-bit Timer/Counter 1A and 1B
		

		; Fast PWM, 8-bit mode, no prescaling

		; Set TekBot to Move Forward (1<<EngDirR|1<<EngDirL) on Port B

		; Set initial speed, display on Port B pins 3:0

		; Enable global interrupts (if any are used)

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:

	; If Power Level Changed: (1 if inc, 2 if dec, 2 if max)
	; inc CurrPowLevel
	; dec CurrPowLevel
	; lti CurrPowLevel, maxPowLevel
	; FIXME need to implement above ^
	

		rcall UPDATE_DUTY_SPEED	;Update the indicator LEDs and power driven
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
; Func:	UPDATE_DUTY_SPEED
;		
; Desc:	This function takes integer from register  
;		CurrPowLevel in order to:
;
;		1) set LED speed indication of LEDs D1 - D4 to 
;		binary value between 0-15 to represent the current
;		power level of the motor.
;
;		2) update the duty cycle to output the correct power 
;		based on speed level from 0 - 15 to the motors. 
;		This power output is represented by total LED 
;		brightness of LEDs D5 - D8).
;-----------------------------------------------------------
UPDATE_DUTY_SPEED:

		; If needed, save variables by pushing to the stack

		; Execute the function here
		rcall UPDATE_LEVEL_IND	; Updates LEDs representing power level (0 - 15)
		rcall UPDATE_POWER_IND	; Updates LEDs brightness respresenting power amount
		; FIXME need to define these functions

		; Restore any saved variables by popping from stack

		ret						; End a function with RET

;***********************************************************
;*	Stored Program Data
;***********************************************************
		; Enter any stored data you might need here

;***********************************************************
;*	Additional Program Includes
;***********************************************************
		; There are no additional file includes for this program
