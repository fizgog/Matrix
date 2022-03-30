\ ******************************************************************
\ *	Matrix: Gridrunner 2 - Snitch code
\ ******************************************************************

; 00 - Running right frame 1    %00000000
; 01 - Running right frame 2    %00000001
; 40 - Running left frame 1     %01000000
; 41 - Running left frame 2     %01000001
; 80 - Waving frame 1           %10000000
; 81 - Waving frame 2           %10000001

.snitchSpeedForLevel
    EQUB $00,$00,$08,$08,$07
    EQUB $07,$07,$07,$06,$06
    EQUB $06,$06,$06,$06,$06
    EQUB $04,$04,$04,$04,$04

.AnimateSnitch
{
    LDA snitchFrameRate
    BEQ snitchExit1
    
    DEC snitchFrameRate
    BEQ start
.snitchExit1  
    RTS 

.start    

    LDA snitchFrameRateLevel
    STA snitchFrameRate

    LDA snitchYPosition
    STA YOrd

    LDA snitchControl
    EOR #$01
    STA snitchControl
    AND #$80
    BEQ snitchRunning
    JMP DrawSnitchWaving

.snitchRunning

    ; Removing old snitch
    LDA snitchXPosition
    STA XOrd

    LDA snitchYPosition
    STA YOrd

    LDA #SPACE
    STA currentCharacter
    JSR PlotSprite

    LDA snitchControl
    AND #$40
    BNE snitchMovingLeft

    INC snitchXPosition
    LDA snitchXPosition
    STA XOrd
    
    LDA snitchControl
    AND #$01
    CLC
    ADC #SNITCH_RIGHT1
    STA currentCharacter
    JSR PlotSprite

    LDA snitchXPosition
    LSR A
    LSR A
    ;STA temp2

    JMP checkSnitchShip

.snitchMovingLeft
    
    DEC snitchXPosition
    LDA snitchXPosition
    STA XOrd

    LDA snitchControl
    AND #$01
    CLC
    ADC #SNITCH_LEFT1
    STA currentCharacter
    JSR PlotSprite

    LDA #0
    STA temp2
    LDA snitchXPosition
    LSR A
    ROL temp2
    LSR A
    ADC temp2
    ;STA temp2

.checkSnitchShip
    ; A contain snitch x pos in characters
    CMP shipXPosition
    BNE snitchExit2         ; snitch should run left

    LDA #$80                ; make snitch wave
    STA snitchControl

.snitchExit
    RTS

.snitchExit2
    BMI snitchExit3
    LDA snitchControl
    AND #$40
    BNE snitchExit
    LDA #$41
    STA snitchControl
    RTS

.snitchExit3
    LDA snitchControl
    AND #$40
    BEQ snitchExit
    LDA #$01
    STA snitchControl
    RTS


.DrawSnitchWaving
    LDA snitchControl
    AND #$01
    CLC
    ADC #SNITCH_WAVE1
    STA currentCharacter
    LDA snitchXPosition
    STA XOrd
    
    JSR PlotSprite
    
    LDA snitchXPosition
    LSR A
    LSR A
    CMP shipXPosition
    BNE snitchControlReset
    RTS

.snitchControlReset
    LDA #$00
    STA snitchControl
    JMP checkSnitchShip
}
;-------------------------------------------------------------------------
