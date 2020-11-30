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
        
DELAYTIME	EQU		350000	; TIMER
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;


IDLE PROC
	PUSH {LR}

	LDR R1,= 0x30;
GameWaitPattern
	
	LDR R0,= GPIOA_CRH;
	STR R1, [R0];
	LDR R8,= DELAYTIME
	BL oneSecondDelay
	
	
return
	CMP R1, #0x30000; ;; Since we turn on the light in sequence, we must reset back to the first light at the end.
	MOVEQ R1, #0x3;  ;; This does exactly that by taking in the location of which light we're at. then resets it.
	LSL R1, R1, #0x4;
	LDR R2,= GPIOB_IDR; Loading in the input for the PushButtons assigned at Port B;
	LDR R2, [R2]; 
	LSR R2, R2, #8; ;; We isolate the bits corresponding to a button press from either Red or Black.
	CMP R2, 0xDF;
	BLT TurnOnLight
	LDR R2,= 0x0;
	LDR R2,= GPIOC_IDR; ;; Check Blue Button at PC12
	LDR R2, [R2];
	LSR R2, R2, #12;
	CMP R2, 0xE;
	BEQ TurnOnLight
	LDR R2,= 0x0;
	LDR R2,= GPIOA_IDR ;; Check Green Button at PA5
	LDR R2, [R2];
	LSR R2, R2, #5;
	AND R2, R2, 0x1;
	CBZ R2, TurnOnLight;
	POP {LR};
	B GameWaitPattern
	ALIGN
	ENDP
oneSecondDelay PROC
	SUB R8,R8,#0x1;
	CMP R8, #0;
	BLE endDelay
	BGT oneSecondDelay
	ALIGN
	ENDP
endDelay
	BX LR;


TurnOnLight    PROC
	PUSH {LR};
	LDR R1,= 0x33330;
	LDR R2,= GPIOA_CRH;
	STR R1, [R2];
	LDR R8,= 0x40000;
	BL oneSecondDelay;
	
	
	
	POP {LR}
	
	
	
	ALIGN
	ENDP




Finish
	
	END
