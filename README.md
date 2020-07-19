# Whac-A-Mole
Whac-A-Mole Project

This project is my attempt at making a physical game utilizing ARM x86 Assembly.
Tested and runs on a STM32Fx Development Board with 4 LED's and 4 Push Buttons mapped to their respective states.

Built with IDE: Keil Uvision 5


### Whac-a-Mole is a retro style game with "moles" popping out of openings from the player side of a arcade machine. 
- The objective is to "smash" or press the button on the corresponding "mole" (LED light).
- The game gets significantly harder each time a pattern finishes. Lowering the time window to execute the button press.
- If the player misses a chance at smashing a mole, the game is over!
- If the player beats all patterns, then a win sequence is initalized via LED's. 
  Otherwise a failure sequence occurs in the LED's





