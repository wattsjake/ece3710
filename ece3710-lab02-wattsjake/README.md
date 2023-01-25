Basic Input and Output 
=======================

Objective: Write, assemble, download and test a 
simple program that manipulates the I/O ports on a microcontroller. 
-------------------------------------------------------------------

 
### Parts: 
    1-C8051FX20-TB Evaluation Board & USB Debug Adapter 
    Project Board 
    1 96-pin edge card connector 
    3 32-pin connectors 
    1 10-LED bar graph 
    2 6-pin Bussed Resistor Networks (220) 
    1 8-position DIP switch 
    2 pushbutton switches 
    jumper wire 
 
### Software: 
    Silicon Laboratories IDE version 3.50.00 or greater 
 
### Preparation:

Starting with this laboratory exercise, students are required to do 
preparatory work before coming to lab. This way, time with the 
instructor can be spent troubleshooting hardware and debugging 
code instead of assembling hardware and composing code. In this 
and all future labs, 5 points are awarded if, at the beginning of lab 
period (and before the instructor has signed off the other students 
seeking preparation points), (a) the student has a lab book 
conforming to the guidelines containing a title and a short 
description of the lab, (b) all hardware is assembled if necessary 
and (c) the team has made a good-faith effort to compose the 
program code. 
 
No preparation points will be given if the student lacks (a) or (b). If 
(in the opinion of the instructor) the code is incomplete or 
haphazard, up to 3 preparation points may be deducted. 
 
During the lab period, once the instructor has awarded preparation 
points to all students who request them, he/she will announce “last 
call” for preparation points. Students who do not request 
preparation points at that time will not receive them for that lab 
exercise. No late credit is given for preparation points. 
 
Design a circuit that connects the 10-LED bar graph to ports of the 
C8051F020.  You are free to choose any ports you like, but avoid 
port 0 (bits 0 and 1 will be used for the serial port) and avoid ports 
4, 6 and 7 (these will be used for bus expansion later). Make the 
LEDs turn on when the corresponding port lines are low. 
 
Add additional circuitry that connects the two pushbutton switches 
and the eight DIP switches to other ports on the C8051F020. 
 
Be sure to include all design work including schematics in your lab 
book. (The schematics will be part of your grade.) 
 
Solder on the 96-pin connector, the three 32-pin connectors, the 
bar graph, resistors, pushbuttons and DIP switch. BE CAREFUL to 
put connectors and other components on the side of the board with 
the white legend. The side without the legend should be for 
soldering only. 
 
__IMPORTANT:__ The resistor networks must be installed in the right 
orientation. Failure to do so will result in the unpleasant chore of 
desoldering. Make sure the pin with the “dot” on the resistor pack is 
connected to the square pad on the circuit board. 
 
__IMPORTANT:__ If you solder the bar graph in backwards, do not try 
to desolder it. This problem can be handled in software. 
 
Use jumper wire to implement the circuits you designed in your lab 
book. Note that one pin of each DIP switch is already connected to 
ground on the circuit board so you need not wire those pins. 
 
Write an 8051 assembly program (lab2.asm) that continually reads 
the pushbutton and DIP switches and reflects the state of the 
pushbuttons on two of the LEDs and the state of the DIP switches 
on the other 8 LEDs. 
 
Note. In order for the C8051F020 to behave as a normal 8051, you 
must execute the following instructions when your program starts: 
 
 mov wdtcn,#0DEh ; disable watchdog 
 mov wdtcn,#0ADh 
 mov xbr2,#40h ; enable port output 
 
 Remember to include (c8051f020.inc) 
 
Create a project using the IDE and build your code as you did in 
Lab 1 (but of course, in a different folder). Find and correct syntax 
errors, if any. Bring your lab book, completed circuit and assembly 
code to your laboratory period. 