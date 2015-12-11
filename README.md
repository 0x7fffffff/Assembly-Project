Assembly Project
----------------

This was my project for CDA 3104 Computer Organization and Assembly Language Programming. It is a small project written in AVR assembly for the ATxmega256A3BU. It creates two interrupt service routines for interrupt vectors 0 and 1 on port F to attach events to two of the buttons on the board. When these buttons are pressed, they toggle the on off state of their corresponding yellow LEDs. Every time one of the buttons is pressed and one of the yellow LEDs change, the green power LED turns on or off depending on whether or not the XOR of the on off states of the yellow LEDs produces a 0 or a 1.
