Hi! Here is the code for the ENSE 352 Fall 2020 Final Project. 

My name's Shrey and today I'll be explaining to you the code I've written.

I have the older board from last year, so the variant is STM32F100RB. If you create a project to test this code,
It MUST be initalized with that specific variant, otherwise it won't work.

Since I have the older discovery board I also have the discovery board layout with the Pushbuttons and LED's.

These are mapped to:
ENEL 384 Pushbuttons: SW2(Red): PB8, SW3(Black): PB9, SW4(Blue): PC12 *****NEW for 2015**** SW5(Green): PA5
ENEL 384 board LEDs: D1 - PA9, D2 - PA10, D3 - PA11, D4 - PA12



The code is for a game called Whac-A-Mole, a popular arcade/fair game played on a box with moles.
In order to be animal friendly, we have represented it as a game with LED's and PushButtons.

Currently, upon intialization of the board, the lights will flash from left to right until a new user appears and presses a button.


The LED's and PushButtons (4 of each) are arranged in parallel and in a line, so the user should try to press the button with respect to the light.

If the correct button is pressed the games goes to the "next level" where the reaction time is lowered, and a new mole will "pop up" (A new LED will turn on)
If the user correctly pressess all the lights in a sequence of 16 levels, then the user "wins" and the games shows a little celebration animation with the LED's 
before returning to idle.

If the user takes too long to press a button, or an incorrect button is pressed, than the mole disappears and the game is lost. 
If the user has reached a higher level, the game will showcase a flashing sequence of the current highest level reached so far.
Before exiting back to the IDLE loop.


Now we've got that out of the way, lets get on to the code part!



/////////////////////////////////////////////////////
//  IF you want to modify the React Time, WinSignalTime, FailSignalTime and Number of Cycles.
//  Modify the following block of code within the FP1.s file
//
//  REACT_TIME EQU	350000	; GameWaitTime
//      
//      
//  DELAYTIME	EQU		200000	; TIMER
//      
//  NumberofCycles EQU 16;  <-- Maximum acceptable value is 16, Since any higher and we wont be able to display it in binary on the LED's (Only 4 consecutive bits total)
//      
//  WinningSignalTime EQU 	200000;; Wining Signal Time;
//      
//  FailingSignalTime EQU   350000; Fail Sequence Light Time
/////////////////////////////////////////////////////



Part 1)

UC1 and UC2 are symbiotic and occur almost every reset press. UC1 turns on all the GPIO clocks and proceeds to UC2 or the IDLE State referenced in the code.
This IDLE states loops continously until any of the four buttons is pressed. The idle state always flashing a sequence of LED's from left to right.

Part 2) 

The Idle and Game State
UC2 proceeds to the Game State upon a button press (UC3).

The game state will start with a short pause in the lights, indicating the game is in play, before generating a random number and populating one of the four lights.
This process is observed random so no two total sequences (All 16 levels) will be the same.

Upon a correct button press, the REACT_TIMER is decremented with the current level value, so each level in sequence is "harder"

Part 3) 

Ending States 
if the user presses an incorrect button with respect to the light, then the game will know instantly and proceed to the fail state UC5;
This is also achieved by not pressing any buttons and the timer expiring. 

In the fail state, we convert the highest level reached into a bit value used to turn on the LED's to show a binary value of the level.

That is:

            1. if the highest level reached is 0, then no lights flash and it proceeds directly to the UC2 or IDLE state awaiting the next user.


            2. If the highest level reached is 15, then ALL lights will flash since that is indicating binary value of 15, (1111)


If the user finishes all 16 levels, then it proceeds to the WIN State (UC4)
This will display a short animation of LED's for around 10 seconds. Flashing back and forth.

Before reseting automatically to the IDLE UC2 State.
