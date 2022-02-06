# STM8-UNIPOLAR-STEPPER-MOTOR-EXAMPLE
28BYJ-48  unipolar stepper motor example in assembly
This is a crude example in assembler to run a stepper motor for 2 revolutions in both directions. The delay between each step is 10ms
The stm8 pins PC7,PC6,PC5,PC4 as outputs that will activate the stepper motor controller pins 4,3,2,1 respectievely. The motor driver
used was bought from aliexpress (ULN2003 version). 
The  blue wire is controlled by portC bit 4, PC4
The  pink wire is controlled by portC bit 5, PC5
The  yellow wire is controlled by portC bit 6, PC6
The  orange wire is controlled by portC bit 7, PC7
The redwire of the motor is common positive
The motor diver board and the stm 8 grounds must be tied together
changing the step on time changes how speed the motor steps
