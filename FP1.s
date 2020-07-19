; GPIO Test program - Dave Duguid, 2011
; Modified Trevor Douglas 2014

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
GAMETIME EQU	750000	; GameWaitTime
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




;;;;;;;;Subroutines ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ALIGN
IDLE  PROC
	
	LDR R1, =0x44440;
	LDR R4, = 0xDFF3;
	
	LDR R7, =GPIOA_CRH
	STR R1, [R7]
	LDR R8, = GPIOB_IDR;
	LDR R3, = 0x0;
	BL WinState




	
loopst1
	
	LDR R10, = 0x0;
	LDR R1, = 0x00003;
	STR R1, [R7];
	
	B GameStart
	LDR R2, = 0x0;
countloop
	
	
 	LDR R10, = 0x0;

 	LSL R1, R1, #4;
	STR R1, [R7];
	
	BL Delay1;
	LDR R11, = 0x0;
	LDR R11, [R8];
	CMP R11, R4;
	BNE CHECKSW;
	
	LDR R5, = 0x0;
	ADD R2, #0x1;
    CMP R2, #0x4;
	LDR R11, = 0xDFF3;
	BNE countloop;
	
	LDR R2, = 0x0;

countdown
	LDR R10, = 0x0;
	LSR R1, R1, #4;
	STR R1, [R7];
	BL Delay1;
	ADD R2, #0x1;
    CMP R2, #0x3;
	BNE countdown;

	ADD R3, #0x1;
	CMP R3, #0x5;
	BNE loopst1
	
	BL Rand;

	B IDLE;
	ENDP;

	ALIGN
CHECKSW PROC
	; ENEL 384 Pushbuttons: SW2(Red): PB8, SW3(Black): PB9, SW4(Blue): PC12 *****NEW for 2015**** SW5(Green): PA5
	LDR R1, = 0x0;
	LDR R7, = GPIOA_CRH;
	LDR R8, = GPIOB_IDR;
	
	LDR R1, [R8];
	AND R1, R1, #0x300;
	CMP R1, #0x100;
	BEQ Light2;
	
	LSR R1, R1, #4;
	

	
loopx
	STR R5, [R7];
	LDR R6, = PDTIME;

	
   	ADD R10, R10, #0x1;
	CMP R10, R6;
	BNE loopx
	CMP R5, #0x200;
	BEQ GameStart;
	LDR R11, = 0xDFF3;
	STR R11, [R7];
	
	BX LR
	ENDP
	
	ALIGN
Light2 PROC
	LDR R5, = 0x300;
	STR R5, [R7];
loopx1
	
	LDR R6, = PDTIME;

	
   	ADD R10, R10, #0x1;
	CMP R10, R6;
	BNE loopx1
	CMP R5, #0x200;
;; Game Start;
	LDR R11, = 0xDFF3;
	STR R11, [R7];
	BX LR
	ENDP
	ALIGN

Delay1 PROC
	LDR R6, = DELAYTIME;

	
   	ADD R10, R10, #0x1;
	CMP R10, R6;
 	BNE Delay1
		
	BX LR;
	ENDP
	ALIGN
PreLimWait PROC
	LDR R6, = PDTIME2;

	
   	ADD R10, R10, #0x1;
	CMP R10, R6;
 	BNE PreLimWait
	
	
	
	BX LR;
	ENDP
	ALIGN

GameWait PROC
			LDR R6, = GAMETIME;

	
			ADD R10, R10, #0x1;
			CMP R10, R6;
			BNE GameWait
	
	
	
		 BX LR;
		 ENDP
;This routine will enable the clock for the Ports that you need	
	ALIGN 
	; Students to write.  Registers   .. RCC_APB2ENR
	; ENEL 384 Pushbuttons: SW2(Red): PB8, SW3(Black): PB9, SW4(Blue): PC12 *****NEW for 2015**** SW5(Green): PA5
	; ENEL 384 board LEDs: D1 - PA9, D2 - PA10, D3 - PA11, D4 - PA12
GPIO_ClockInit PROC
	LDR R6, =RCC_APB2ENR
	ORR R0, #0x1C
	STR R0, [R6]
	LDR R12, = 0x1;
	
	
	BX LR
	ENDP
		
	
	
;This routine enables the GPIO for the LED's.  By default the I/O lines are input so we only need to configure for ouptut.
	ALIGN
GPIO_init  PROC
		; ENEL 384 board LEDs: D1 - PA9, D2 - PA10, D3 - PA11, D4 - PA12
	LDR R7, =GPIOA_CRH

	LDR R1, =0x33330;
	STR R1, [R7]
	
	
   




	BX LR
	ENDP
	ALIGN
		
TurnOff1  PROC
	LDR R1, =  0x0;
	STR R1, [R7];
	LDR R10, = 0x0;
	BL PreLimWait;

	BL GameStart;
	
	ENDP
	ALIGN

LED1  PROC
	
	LDR R3, = 0x30;
	STR R3, [R7];
	LDR R3, = 0x0;
	BL GameWait;
	LDR R8, = GPIOB_IDR
	LDR R3, [R8];
	AND R3, R3, #0x300;
	CMP R3, #0x200;
	BEQ TurnOff1;
	B GameStart
	ENDP
	

	ALIGN
LED2  PROC
	LDR R3, = 0x300;
	STR R3, [R7];
	BL GameWait;
	LDR R8, = GPIOB_IDR
	LDR R3, [R8];
	AND R3, R3, #0x300;
	CMP R3, #0x100;
	BEQ TurnOff1;
	B GameStart
	ENDP
		
	

	ALIGN
LED3  PROC
	LDR R3, = 0x3000;
	STR R3, [R7];
	BL GameWait
	LDR R8, = GPIOC_IDR
	LDR R3, [R8];
	AND R3, R3, #0x3000;
	CMP R3, #0x2000;
	BEQ TurnOff1;
	B GameStart
	ENDP
		
	
	
	ALIGN
LED4  PROC
	LDR R3, = 0x30000;
	STR R3, [R7];
	BL GameWait;
	LDR R8, = GPIOA_IDR
	LDR R3, [R8];
	AND R3, R3, #0xD8;
	CMP R3, #0xD8;
	BEQ TurnOff1;
	B GameStart
	ENDP
		
	ALIGN

GameStart  PROC
;; Rand Generator
    LDR R7, =GPIOA_CRH;
	LDR R2, = 0x0;
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
	ADD R2, R2, #1;
	
	CMP R2, #15;
	BNE loopmain
	CMP R2, #15;
	BEQ WinState;
	
	B IDLE;
	
	
	ENDP
	ALIGN
WinState  PROC
;; Rand Generator
loop1ws
	LDR R1, = 3030;
	STR R1, [R7];
	BL Delay1;
	LSL R1, R1, #4;
	STR R1, [R7];
	BL Delay1;
	b loop1ws


	BX LR
	ENDP
    ALIGN
Rand  PROC
;; Rand Generator

	LDR R1,= 50051;
	LDR R10, = 50051;
	MUL R12,R1;
	ADD R12, R10;
	AND R4, R12, #0xC0000000;

	


	BX LR
	ENDP




	ALIGN
	END