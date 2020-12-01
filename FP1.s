; GPIO Test program - Dave Duguid, 2011
; Modified Trevor Douglas 2014


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Author: Shrey Shah
;;  SID: 200377176
;;  Date: November 27th 2020
;;  Class: ENSE 352 Fall 2020
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
        
DELAYTIME	EQU		300000	; TIMER
PDTIME	EQU		600000	; TIMER
PDTIME2	EQU		500000	; TIMER
REACT_TIME EQU	550000	; GameWaitTime
; Vector Table Mapped to Address 0 at Reset
            AREA    RESET, Data, READONLY
            EXPORT  __Vectors

__Vectors	DCD		INITIAL_MSP			; stack pointer value when stack is empty
        	DCD		Reset_Handler		; reset vector
			
            AREA    MYCODE, CODE, READONLY
			EXPORT	Reset_Handler
			ENTRY

Reset_Handler		PROC


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
;;until a button is pushed
;; UC2 - Waiting for Player Loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;


IDLE PROC
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
	BL oneSecondDelay
	
	

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
		
		
oneSecondDelay PROC
	SUB R8,R8,#0x1;
	CMP R8, #0;
	BLE endDelay
	BGT oneSecondDelay 
	ALIGN
	ENDP
endDelay
	BX LR;




GameWait PROC
	SUB R6, R6, #0x1;
	CBZ R6, TimerDone
	B GameWait
TimerDone
	BX LR;
	ENDP
		
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
		
GameStart    PROC
	PUSH {LR};
	LDR R2, = 0x0;

continuePlay
	LDR R1,= 0x4444444;
;; Rand Generator
    LDR R7, =GPIOA_CRH;
	STR R1, [R7];
	LDR R8, = PDTIME2;
	BL oneSecondDelay;

	LDR R10, = 0x0;
	
loopmain;

	
	BL Rand;

	
	CMP R4, #0x0;
	BEQ LED1;
	CMP R4, #0xC0000000;
	BEQ LED2;
	CMP R4, #0x80000000;
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

	LDR R1,= 50051;
	LDR R10, = 50051;
	MUL R12,R1;
	ADD R12, R10;
	AND R4, R12, #0xC0000000;

	BX LR
	ALIGN
	ENDP

WinState  PROC
	LDR R3,= 0x16;
	LDR R7,= GPIOA_CRH;
WinCycleLoop
	LDR R1,= 0x3030;
	STR R1, [R7];
	LDR R8,= DELAYTIME
	BL oneSecondDelay;
	SUB R3, R3, #1;
	LSL R1, R1, #4;
	STR R1, [R7];
	LDR R8,= DELAYTIME
	BL oneSecondDelay;
	SUB R3, R3, #1;
	CBZ R3, resetBackToIDLE
	B WinCycleLoop
resetBackToIDLE
	B IDLE
	ENDP
    ALIGN

PreLimWait PROC
	LDR R6, = PDTIME2;
   	ADD R10, R10, #0x1;
	CMP R10, R6;
 	BNE PreLimWait
	BX LR;
	ALIGN
	ENDP


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
	SUB R6, R6, #1;
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
	SUB R6, R6, #1;
	CBZ R6, FailState
	B TimerLoop2
	ALIGN
	ENDP
		
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
	SUB R6, R6, #1;
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
	SUB R6, R6, #1;
	CBZ R6, FailState
	B TimerLoop4
	ALIGN
	ENDP
FailState PROC

	LDR R7,= GPIOA_CRH;
	LDR R0,= 0x3;
	LDR R1,= 0x33330;
	STR R1, [R7];
	LDR R8,= DELAYTIME
	BL oneSecondDelay;
Failloop
	LDR R1,= 0x0;
	STR R1, [R7];
	LDR R8,= DELAYTIME
	BL oneSecondDelay;
	SUB R0, R0, #1;
	CBZ R0, leave
	B Failloop
leave
	B IDLE
	ALIGN
	ENDP
TurnOff1  PROC
	LDR R1, =  0x0;
	STR R1, [R7];
	LDR R10,= 0x500
	
	LDR R6, = 0x20001000;
	LDR R1, [R6];
	ADD R2, R2, #1;
	MUL R10, R10, R2;
	SUB R1, R1, R10;
	STR R1, [R6];
	
	CMP R2, #15;
	BEQ JumpWin
	B continuePlay;
	ALIGN
	ENDP



Finish
	
	END
