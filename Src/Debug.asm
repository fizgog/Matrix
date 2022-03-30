

.Debug1
{
    STA debugA    
    STX debugX
    STY debugY

    LDA currentCharacter
    STA debugChar
    LDA currentXPosition
    STA debugXPos
    LDA currentYPosition
    STA debugYPos

    LDX #0
    LDY #30
    JSR setTextPos
    LDA debugA
    JSR BCDtoScreen
    
    ;LDX #3
    ;LDY #30
    ;JSR setTextPos
    ;LDA debugX
    ;JSR BCDtoScreen

    ;LDX #6
    ;LDY #30
    ;JSR setTextPos
    ;LDA debugY
    ;JSR BCDtoScreen

    ;LDX #0
    ;LDY #31
    ;JSR setTextPos
    ;LDA debugChar
    ;JSR BCDtoScreen
    
    ;LDX #3
    ;LDY #31
    ;JSR setTextPos
    ;LDA debugXPos
    ;JSR BCDtoScreen

    ;LDX #6
    ;LDY #31
    ;JSR setTextPos
    ;LDA debugYPos
    ;JSR BCDtoScreen

    LDX #12
    LDY #31
    JSR setTextPos
    LDA bulletType
    JSR BCDtoScreen

    LDA #$40
    JSR vsync_delay

    LDA debugChar
    STA currentCharacter
    LDA debugXPos
    STA currentXPosition
    LDA debugYPos
    STA currentYPosition

    LDA debugA
    LDX debugX
    LDY debugY
    RTS
}
