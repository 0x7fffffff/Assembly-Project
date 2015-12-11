                           .include <atxmega256a3budef.inc>
                           .CSEG

                           .ORG    0x00
                           JMP        start
                           .ORG    PORTF_INT0_VECT
                           JMP        Port_F_Pin_1_INT_VECT
                        .ORG    PORTF_INT1_VECT
                        JMP        Port_F_Pin_2_INT_VECT
                           .ORG    0xF6

start:                    LDI    R16, 0b00000010            ; interrupt 0 assigned to pin 1 on port F
                        STS    PORTF_INT0MASK, R16        ; *

                           LDI    R16, 0b00000100            ; interrupt 1 assigned to pin 2 on port F
                           STS    PORTF_INT1MASK, R16        ; *

                        LDI    R16, 0b00001010            ; Medium priority interrups 0 and 1 on port F
                           STS    PORTF_INTCTRL, R16        ; *

                           LDI    R16, 0b00000010            ; Enable medium priority interrupts
                           STS    PMIC_CTRL, R16            ; *

                        LDI    R16, 0b00000010            ; Sense falling edge, totem pole on pin 1 of port F
                        STS    PORTF_PIN1CTRL, R16        ; *

                        LDI    R16, 0b00000010            ; Sense falling edge, totem pole on pin 2 of port F
                        STS    PORTF_PIN2CTRL, R16        ; *

                        SEI                            ; set enable interrupts

                        LDI    R16, 0x0b00000011        ; enable output for both yellow LEDs (pins 0 and 1 on port R)
                        STS    PORTR_DIR, R16            ; *

                        LDI    R16, 0b00100000            ; enable output for the green power LED (pin 5 on port D)
                        STS    PORTD_DIR, R16            ; *

                        LDS    R16, PORTR_IN            ; turn off both yellow LEDs (pins 0 and 1 on port R)
                        ORI    R16, 0b00000011            ; *
                        STS    PORTR_OUT, R16            ; *

                        LDS    R16, PORTD_IN            ; turn off the green power LED (pin 5 on port D)
                        ANDI R16, 0b11011111        ; *
                        STS    PORTD_OUT, R16            ; *

loop:                    JMP    loop                    ; A whole lot of nothing

XOR:                    LDS    R16, PORTR_IN            ; Load the current state of port R (the yellow LEDs)

                        MOV    R17, R16                ; Copy R16 into R17 and isolate pin 0
                        ANDI R17, 0b00000001        ; *

                        MOV    R18, R16                ; Copy R16 into R17 and isolate pin 1
                        ANDI R18, 0b00000010        ; *
                        LSR    R18                        ; Shift pin 1's value into bit 0

                        LDS    R16, PORTD_IN            ; Read the current state of the power LED into R16
                        EOR    R17, R18                ; XOR on the bits cooresponding to the yellow LEDs on/off states.

                        CPI     R17, 1                    ; If the result produces 1, turn on the power LED, otherwise, turn it off.
                        BREQ    setOn                       ; *
                        ANDI    R16, 0b11011111             ; *
                        JMP     Continue                    ; *
setON:                  ORI     R16, 0b00100000             ; *
Continue:               STS     PORTD_OUT, R16              ; *
                        RETI                                ; Return from the interrupt that jumped to the XOR label.

Port_F_Pin_2_INT_VECT:  LDI    R16, 0b00000001              ; Clear the request
                        STS    PORTF_INTFLAGS, R16          ; *
                        
                        LDS    R16, PORTR_IN                ; load the current state of port R
                        LDI    R17, 0b00000010              ; *
                        EOR     R16, R17                    ; toggle bit 1 

                        STS    PORTR_OUT, R16               ; store new LED state information
                        JMP    XOR                          ; jump to XOR to set the new state of the green LED
    
Port_F_Pin_1_INT_VECT:  LDI     R16, 0b00000001             ; Clear the request
                        STS     PORTF_INTFLAGS, R16         ; *
                        
                        LDS     R16, PORTR_IN               ; load the current state of port R
                        LDI     R17, 0b00000001             ; *
                        EOR     R16, R17                    ; toggle bit 0

                        STS    PORTR_OUT, R16               ; store new LED state information
                        JMP    XOR                          ; jump to XOR to set the new state of the green LED
