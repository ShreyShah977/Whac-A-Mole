; GPIO Test program - Dave Duguid, 2011
; Modified Trevor Douglas 2014


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Author: Shrey Shah
;;  SID: 200377176
;;  Date: November 27th 2020
;;  Class: ENSE 352 Fall 2020
;;
;;  This file contains all the code for the Whac-A-Mole arcade game. Each State is documented in detail with reference to the PDF Handout.
;;  
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; Directives
            PRESERVE8
            THUMB       

        		 
;;; Equates

INITIAL_MSP	EQU		0x20001000	; Initial Main Stack Pointer Value


;PORT A GPIO - Base Addr: 0x40010800
GPIOA_CRL	EQU		0x40010800	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOA_CRH	EQU		0x40010804	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOA_IDR	EQU		0x40010808	; (0x08) Port Input Data Register
GPIOA_ODR	EQU		0x4001080C	; (0x0C) Port Output Data Register
GPIOA_BSRR	EQU		0x40010810	; (0x10) Port Bit Set/Reset Register
GPIOA_BRR	EQU		0x40010814	; (0x14) Port Bit Reset Register
GPIOA_LCKR	EQU		0x40010818	; (0x18) Port Configuration Lock Register

;PORT B GPIO - Base Addr: 0x40010C00
GPIOB_CRL	EQU		0x40010C00	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOB_CRH	EQU		0x40010C04	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOB_IDR	EQU		0x40010C08	; (0x08) Port Input Data Register
GPIOB_ODR	EQU		0x40010C0C	; (0x0C) Port Output Data Register
GPIOB_BSRR	EQU		0x40010C10	; (0x10) Port Bit Set/Reset Register
GPIOB_BRR	EQU		0x40010C14	; (0x14) Port Bit Reset Register
GPIOB_LCKR	EQU		0x40010C18	; (0x18) Port Configuration Lock Register

;The onboard LEDS are on port C bits 8 and 9
;PORT C GPIO - Base Addr: 0x40011000
GPIOC_CRL	EQU		0x40011000	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOC_CRH	EQU		0x40011004	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOC_IDR	EQU		0x40011008	; (0x08) Port Input Data Register
GPIOC_ODR	EQU		0x4001100C	; (0x0C) Port Output Data Register
GPIOC_BSRR	EQU		0x40011010	; (0x10) Port Bit Set/Reset Register
GPIOC_BRR	EQU		0x40011014	; (0x14) Port Bit Reset Register
GPIOC_LCKR	EQU		0x40011018	; (0x18) Port Configuration Lock Register

;Registers for configuring and enabling the clocks
;RCC Registers - Base Addr: 0x40021000
RCC_CR		EQU		0x40021000	; Clock Control Register
RCC_CFGR	EQU		0x40021004	; Clock Configuration Register
RCC_CIR		EQU		0x40021008	; Clock Interrupt Register
RCC_APB2RSTR	EQU	0x4002100C	; APB2 Peripheral Reset Register
RCC_APB1RSTR	EQU	0x40021010	; APB1 Peripheral Reset Register
RCC_AHBENR	EQU		0x40021014	; AHB Peripheral Clock Enable Register

RCC_APB2ENR	EQU		0x40021018	; APB2 Peripheral Clock Enable Register  -- Used

RCC_APB1ENR	EQU		0x4002101C	; APB1 Peripheral Clock Enable Register
RCC_BDCR	EQU		0x40021020	; Backup Domain Control Register
RCC_CSR		EQU		0x40021024	; Control/Status Register
RCC_CFGR2	EQU		0x4002102C	; Clock Configuration Register 2

; Times for delay routines
        
DELAYTIME	EQU		200000	; TIMER
PDTIME	EQU		600000	; TIMER
PDTIME2	EQU		500000	; TIMER
REACT_TIME EQU	350000	; GameWaitTime
FAIL_TIME   EQU  350000 ; Fail Sequence Light Time
; Vector Table Mapped to Address 0 at Reset
            AREA    RESET, Data, READONLY
            EXPORT  __Vectors

__Vectors	DCD		INITIAL_MSP			; stack pointer value when stack is empty
        	DCD		Reset_Handler		; reset vector
			
            AREA    MYCODE, CODE, READONLY
			EXPORT	Reset_Handler
			ENTRY

Reset_Handler		PROC

;;;;;;;;;;;;;;;;;;
;; UC1 is in this block.
;; Just turns on all the neccesary GPIO Clocks 
;;;;;;;;;;;;;;;;;;
		BL GPIO_ClockInit
		BL GPIO_init
 		BL IDLE
		

		ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;
;; Turn on clocks
;;
;;
;;;;;;;;;;;;;;;;;;;;;;
GPIO_ClockInit PROC
	LDR R6, =RCC_APB2ENR
	LDR R0, [R6];
	ORR R0, #0x3C
	STR R0, [R6]
	LDR R12, = 0x1;
	
	
	BX LR
	ALIGN
	ENDP
GPIO_init PROC
	LDR R2,= 0x44444444
	LDR R7,=GPIOA_CRH
	LDR R1, [R7];
	STR R2, [R7]
	LDR R7,= GPIOB_CRH;
	LDR R1, [R7];

	
	BX LR
	ALIGN
	ENDP
		
;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Idle State - UC1 and UC2;
;;; 
;;;
;;;
; ENEL 384 Pushbuttons: SW2(Red): PB8, SW3(Black): PB9, SW4(Blue): PC12 *****NEW for 2015**** SW5(Green): PA5
; ENEL 384 board LEDs: D1 - PA9, D2 - PA10, D3 - PA11, D4 - PA12
;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This IDLE State will constantly flash 
;; a pattern of lights from 
;; left to right in sequence 
;; until a button is pushed
;; 
;; UC2 ---- UC2 ---- UC2
;; Waiting for Player Loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;


IDLE PROC
	;;;;;;;;;;;;;;;;;;;;;
	;;; This little tidbit actually stores the value of the REACT_TIME into a memory location.
	;;; Where we can modify and reuse it continously.
	;;; This is modified when a user has pressed the correct button, the timer will be loaded, decremented and stored back for future use.
	;;;;;;;;;;;;;;;;;;;;;
	LDR R8,= 0x20001000;
	LDR R0,= REACT_TIME;
	STR R0, [R8];
	PUSH {LR}
	LDR R0,= 0x0;
	LDR R8,= 0x0;

	LDR R1,= 0x30;
GameWaitPattern
	
	LDR R0,= GPIOA_CRH;
	STR R1, [R0];
	LDR R8,= DELAYTIME
	BL R8SecondsDelay
	
	

    BL CheckforUser
	CMP R1, #0x30000; ;; Since we turn on the light in sequence, we must reset back to the first light at the end.
	MOVEQ R1, #0x3;  ;; This does exactly that by taking in the location of which light we're at. then resets it.
	LSL R1, R1, #0x4;;
	
	POP {LR};
	B GameWaitPattern
	ALIGN
	ENDP
CheckforUser PROC
	LDR R2,= GPIOB_IDR; Loading in the input for the PushButtons assigned at Port B;
	LDR R2, [R2]; 
	LSR R2, R2, #8; ;; We isolate the bits corresponding to a button press from either Red or Black.
	CMP R2, #0xDF;
	BLT GameStart
	LDR R2,= 0x0;
	LDR R2,= GPIOC_IDR; ;; Check Blue Button at PC12
	LDR R2, [R2];
	LSR R2, R2, #12;
	CMP R2, #0xE;
	BEQ GameStart
	LDR R2,= 0x0;
	LDR R2,= GPIOA_IDR ;; Check Green Button at PA5
	LDR R2, [R2];
	LSR R2, R2, #5;
	AND R2, R2, #0x1;
	CBZ R2, GameStart;
	
	
	BX LR;
	ALIGN;
	ENDP;
		
;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Here is our generic timer or delay function
;; It takes in the value passed into R8 and returns when 
;; The variable is 0.
;;;;;;;;;;;;;;;;;;;;;;;;;;


R8SecondsDelay PROC
	SUB R8,R8,#0x1;
	CMP R8, #0;
	BLE endDelay
	BGT R8SecondsDelay 
	ALIGN
	ENDP
endDelay
	BX LR;

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This is a generic CheckButtons Function
;; It checks for any input in all four buttons
;; i.e ENEL 384 Pushbuttons: SW2(Red): PB8, SW3(Black): PB9, SW4(Blue): PC12 SW5(Green): PA5
;; And then shifts, ORR's and operates so that it forms a binary number.
;; For example, if the left most button is pressed (Red - PB8)
;; Then the resulting binary number generated is 0001.
;; For the Blue - PC12, the Resulting binary number is 0100;
;; This is what's used to determine the pass/fail logic.
;;;;;;;;;;;;;;;;;;;;;;;;;;



CheckButtons PROC
	LDR R5,= 0x0;
	LDR R8,= GPIOB_IDR
	LDR R5, [R8];
	LSR R5, R5, #8;
	AND R5, R5, #0xF;
	EOR R5, R5, #0xF;
	LDR R8,= GPIOC_IDR
	LDR R4, [R8];
	LSR R4, R4, #12;
	CMP R4, #0xE;
	ORREQ R5, #0x4;
	LDR R8,= GPIOA_IDR;
	LDR R4, [R8];
	LSR R4, R4, #5;
	AND R4, R4, #1;
	CMP R4, #0x0; 
	ORREQ R5, R5, #0x8;	
	BX LR
	ALIGN
	ENDP






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UC3 ---- UC3 ---- UC3
;; GameStart is the actual game function, this is initiated once the user has moved on from IDLE or wait state.
;;
;; It contains a PreLimWaitFunction on line 280. Loaded with the PDTIME2, a different timer value used for PrelimWait
;;
;; Since we have an easy to use abstract timer function, we just use that.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameStart    PROC
	PUSH {LR}; ;; We push the LR here so that we can make calls to other functions within this one.
	LDR R2, = 0x0;

continuePlay
	LDR R1,= 0x4444444;

    LDR R7, =GPIOA_CRH; 
	STR R1, [R7];
	LDR R8, = PDTIME2;
	BL R8SecondsDelay;
	
	;;;;;;
	;; The above sequence is used to indicate to the user that the game has started. 
	;; That is, turning off all lights for a brief stint
	;;;;;;

	LDR R10, = 0x0;
	;; Here we dive into the main game loop.
loopmain;

	;; Our Random number generator is called here. Jump to Line 314
	BL Rand;

	;; Since we know that the Random number is stored in R4, we simply compare it to the possible values that it can be.
	;; We turn on the corresponding LED based on the random number.
	CMP R4, #0x0;
	BEQ LED1;
	CMP R4, #0x80000000;
	BEQ LED2;
	CMP R4, #0xC0000000;
	BEQ LED3;
	CMP R4, #0x40000000;
	BEQ LED4;	
	
	LDR R10, = 0x0;
	BNE loopmain


FinishedWinAnim
	POP {LR}
	B IDLE;
	ALIGN
	ENDP

Rand  PROC
;; Rand Generator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Our random number generator is a very simple concept.
;; Take two large prime numbers. Add some relatively small number to one and multiply the same small number to the other
;; Then And them with some number. This will produce bits in the very left most row.
;; The combinations are generally some sequence of 0, 4, 8 or C in the left most hex digit.
;; The sequence of these combinations are random since the small number is dependant on the current game level. 
;; Further adding randomization to the process
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR R1,= 5000077;
	LDR R10, = 5000077;
	MUL R12,R1;
	ADD R12, R10;
	AND R4, R12, #0xC0000000;

	BX LR
	ALIGN
	ENDP
		
		
		
		
		
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   UC4 ---- UC4 ---- UC4
;;; Here is out Win State, i.e when the user has sucessfully got the correct button pressed 16 times in sequence.
;;; It displays a short animation of the lights back and forth a couple of times.
;;; Then exits to IDLE state, awaiting the next user.
;;;
;;; It displays this animation of lights for a certain period of time, around 10s.
;;;
;;;
;;;
;;; The user's proficiency is displayed just by reaching to this state. Since there are only 16 total levels, 
;;; upon passing the 16th leads to this function
;;; 
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WinState  PROC
	LDR R3,= 0x32;
	LDR R7,= GPIOA_CRH;
WinCycleLoop
	LDR R1,= 0x3030;
	STR R1, [R7];
	LDR R8,= DELAYTIME
	BL R8SecondsDelay;
	SUB R3, R3, #1;
	LSL R1, R1, #4;
	STR R1, [R7];
	LDR R8,= DELAYTIME
	BL R8SecondsDelay;
	SUB R3, R3, #1;
	CBZ R3, resetBackToIDLE
	B WinCycleLoop
resetBackToIDLE
	B IDLE
	ENDP
    ALIGN




;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LEDX contains the code to turn on an LED, where X is (#1-#4).
;;
;; Then it also loads a value from the memory address of the timer.
;; Which is decremented each cycle of the TimerLoopX where X is the LED number
;; 
;; We call CheckButtons each time on this cycle to ensure that we always record if a button has been pressed.
;;
;; If the incorrect button has been pressed we will know instantly since the binary number outputed from CheckButtons 
;; will be different than the one we expect
;;
;; As such there are two ways to reach FailState from here, that is:
;; 1. Exit to Fail state when the incorrect button has been pressed.
;; 2. Exit to fail state when the timer has been expired
;; These are both two different events.
;;
;;
;; Lastly, if the correct button has been pressed we will proceed to the TurnOffState
;; Where the corresponding light turns off. And the level is incremented by one.
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




LED1  PROC
	LDR R3, = 0x30;
	STR R3, [R7];
	LDR R3, = 0x0;
	LDR R6, = 0x20001000;
	LDR R6, [R6];
TimerLoop1
	PUSH {LR}
	BL CheckButtons
	POP {LR}
	CMP R5, #0x1;
	BEQ TurnOff1;
	BGT FailState
	SUB R6, R6, #2;
	CBZ R6, FailState
	B TimerLoop1
	ALIGN
	ENDP
	


LED2  PROC
	LDR R3, = 0x300;
	STR R3, [R7];
	LDR R6, = 0x20001000;
	LDR R6, [R6];
TimerLoop2
	PUSH {LR}
	BL CheckButtons
	POP {LR}
	CMP R5, #0x2;                                                                                                                                                                                           
	BEQ TurnOff1;
	CMP R5, #0x1;
	BGE FailState
	SUB R6, R6, #2;
	CBZ R6, FailState
	B TimerLoop2
	ALIGN
	ENDP
		
;;;;
;; Assembly code doesn't like being spaced apart, this acts as a springboard to let us get back to our original state.
;; (used in the Turn Off Function)
;;;;
JumpWin PROC
	B WinState
	ALIGN
	ENDP
		
		
LED3  PROC
	LDR R3, = 0x3000;
	STR R3, [R7];
	LDR R6, = 0x20001000;
	LDR R6, [R6];
TimerLoop3
	PUSH {LR}
	BL CheckButtons
	POP {LR}
	CMP R5, #0x4;      
	BEQ TurnOff1;
	CMP R5, #0x1;
	BGE FailState
	SUB R6, R6, #2;
	CBZ R6, FailState
	B TimerLoop3
	ALIGN
	ENDP
		

	ALIGN
LED4  PROC
	LDR R3, = 0x30000;
	STR R3, [R7];
	LDR R6, = 0x20001000;
	LDR R6, [R6];
TimerLoop4
	PUSH {LR}
	BL CheckButtons
	POP {LR}
	CMP R5, #0x8;
	BEQ TurnOff1;
	CMP R5, #0x1;
	BGE FailState;
	CBZ R3, TurnOff1;
	SUB R6, R6, #2;
	CBZ R6, FailState
	B TimerLoop4
	ALIGN
	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  UC5 ---- UC5 ---- UC5
;; Here is our fail state. Where the user has either expired the timer or pressed the wrong button in the current level.
;; It displays all lights briefly to let the user know the game has ended.
;; Then it flashes the lights to show the binary number of the highest level completed.
;; Lastly exiting to the IDLE loop (UC2) awaiting the next user. 
;;
;;
;; All numbers from 1 - 15 are represented. 
;; So that if the user fails on the very last level, then all lights will flash to indicate 15 in binary
;;  
;; If the user fails on the very first level (techincally level 0), then no lights flash and it goes straight to the IDLE loop (UC2);
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
FailState PROC
	LDR R7,= GPIOA_CRH;
	LDR R0,= 0x5;
	LDR R1,= 0x33330;
	STR R1, [R7];
	LDR R8,= DELAYTIME
	BL R8SecondsDelay;
	CBZ R2, leave;
	BL GetBitCount
	
Failloop
	STR R1, [R7];
	LDR R8,= FAIL_TIME
	BL R8SecondsDelay;
	LDR R2,= 0x0;
	STR R2, [R7];
	LDR R8,= FAIL_TIME;
	BL R8SecondsDelay
	SUB R0, R0, #1;
	CBZ R0, leave
	B Failloop
leave
	POP {R1,R2,R3,R4,R5,R6}
	LDR R8,= DELAYTIME;
	BL R8SecondsDelay
	B IDLE
	ALIGN
	ENDP
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Here is the Turn Off State.
;; We arrive here everytime the correct button corresponding to the light has been pressed.
;;
;; There are several things happening here. 
;; Most notably, we turn off the light.
;; Then, we load in the old timer value for REACT_TIME
;; And decrement it by the value of the level and a small number 0x400.
;; This way, each subsequent level is "harder" since the user has less time to react to.
;; 
;; Because we always store the value of time in memory we just plug it back into 0x20001000
;;
;; If and only if the value of R2 is 16. (We have achieved 16 button presses) then we "Win" the game and proceed to the WinState
;;
;; Otherwise, we just proceed to the game loop and continue to the next level.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
TurnOff1  PROC
	LDR R1, =  0x0;
	STR R1, [R7];
	LDR R10,= 0x400
	
	LDR R6, = 0x20001000;
	LDR R1, [R6];
	ADD R2, R2, #1;
	MUL R10, R10, R2;
	MOV R12, R10;
	SUB R1, R1, R10;
	STR R1, [R6];
	
	CMP R2, #16;
	BEQ JumpWin
	B continuePlay;
	ALIGN
	ENDP
GetBitCount PROC
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Obtain the level number and represent 
	;; it as a sequence of lights in binary
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Here we modify the level number so that it corresponds to a binary number within our LED's.
	;; i.e Lets say we reach level 5, 5 in binary is 0101. And so we turn on the 2nd and 4th LEDS from the left.
	;; It's interesting to note that we have to keep in mind that although the LED's go left to right, each one is turned on by an increasing value of 0x30.
	;; We've made our loop so that this happens efficently. It returns the correct hex number to turn on the lights in R1.
	LDR R4,= 0x0;
	LDR R5,= 0x8;
	LDR R8,= 0x30;
GetDigits
	CBZ R5, Done;
	
	AND R1, R2, R5;
	CMP R1, R5;
	ORREQ R4, R8;
	LSL R8, R8, #4;
	LSR R5, R5, #1;
	 B GetDigits	
Done
	LDR R1,= 0;
	MOV R1, R4;
	LDR R4,= 0;
	LDR R8,= 0;
	
	BX LR
	ALIGN
	ENDP
		
Finish
	
	END
