\ ******************************************************************
\ *	Matrix: Gridrunner 2 - Cameloids code
\ ******************************************************************

; 00 - %00000000 - Moving Left 
; 40 - %01000000 - Moving Right 
; 2F - %00101111 - Bullet Hit Camel so start bonus (every loop reduce by 1 until 0F)
; 0F - %00001111 - Bonus ended - replace with grid

; Reducing score by 10
; hit camiloid score 106

CAMELOID_SIZE = $55 
CAMELOID_EMPTY_SLOT = $00

.CameloidsLevelArray
    EQUB $00,$00,$00,$14,$00
    EQUB $08,$09,$00,$19,$0A
    EQUB $00,$0B,$0C,$00,$0F
    EQUB $1E,$00,$14,$14,$14

; thIS IS THE TIMER to bring another camel on screen
.CameloidsOnScreenArray
    EQUB $00,$00,$00,$06,$00
    EQUB $06,$06,$00,$04,$06
    EQUB $00,$04,$04,$00,$04
    EQUB $03,$00,$04,$03,$03

.CameloidsRefreshRateArray
    EQUB $00,$00,$00,$04,$00
    EQUB $07,$07,$00,$03,$06
    EQUB $00,$05,$05,$00,$04
    EQUB $03,$00,$03,$03,$03

;-------------------------------------------------------------------------
; AnimateCameloid
;-------------------------------------------------------------------------
.AnimateCameloid
{
        DEC CurrentCameloidsRefreshRate
        BEQ start
        RTS 

.start   
        LDA InitialCameloidsRefreshRate
        STA CurrentCameloidsRefreshRate
        LDA InitialDroidsInSquad
        BNE droidsOnline                        ; only camels on level then reduce score
        JSR ReduceScore                         ; droids == 0

.droidsOnline   
        LDA CurrentCameloidsOnScreen
        BNE b8CF0      
        RTS 

.b8CF0  
        LDA CameloidsLeftToKill                 ; 14
        BNE b8CF7
        JMP checkCameloid
        ; Return

.b8CF7  
        DEC CurrentCameloidsOnScreen
        BEQ newCameloid               ; CurrentCameloidsOnScreen == 0   
        JMP checkCameloid
        ; Return

.newCameloid                            ; Drop new Cameloid on screen  
        LDA InitialCameloidsOnScreen    ; 6
        STA CurrentCameloidsOnScreen

        INC currentCameloidsLeft

        LDX currentCameloidsLeft
        LDA #CAMELOID_MIN_Y             ; top row
        STA cameloidYPositionArray,X
        JSR RandomNumber
        AND #$0F
        CLC 
        ADC #$03
        STA cameloidXPositionArray,X

        JSR RandomNumber
        AND #$40
        STA cameloidStatusArray,X

        DEC CameloidsLeftToKill
  
.checkCameloid 
        LDX currentCameloidsLeft
        CPX #$00
        BNE CheckBonus
        RTS 

.^CheckBonus   
.cameloid_loop 
        LDA cameloidStatusArray,X
        AND #$20                            ; %00100000
        BEQ not_bonus

        JMP PlotBonus106

;.cameloid_loop
.not_bonus    
        LDA cameloidXPositionArray,X
        STA currentXPosition
        LDA cameloidYPositionArray,X
        STA currentYPosition

        LDA gridCharacter
        STA currentCharacter
        JSR PlotCharSprite

.CameloidMovingRight
        LDA cameloidStatusArray,X
        AND #$40                                ; %01000000 - Camel Right
        BNE CameloidMovingLeft

        INC currentXPosition
        INC currentXPosition

.CameloidMovingLeft
        DEC currentXPosition

        LDA currentXPosition
        CMP #CAMELOID_MIN_X                        ; Same as droid
        BEQ cameloidHitSides

        CMP #CAMELOID_MAX_X                        ; Same as droid
        BEQ cameloidHitSides
        
        STX saveX
        JSR getChar
        LDX saveX
        CMP gridCharacter 
        BEQ DrawCameloid

.cameloidHitSides

        LDA cameloidXPositionArray,X
        STA currentXPosition                        ; Reset x position

        LDA cameloidStatusArray,X
        EOR #$40                                    ; %01000000 - Swap direction
        STA cameloidStatusArray,X

        INC currentYPosition
        LDA currentYPosition                        ; Cameloid drop down
    
        CMP #CAMELOID_MAX_Y                         ; Same as droid
        BNE DrawCameloid

.no_bonus        
        JSR DestroyCameloid
        JMP next_cameloid
   
.DrawCameloid

        LDA currentXPosition
        STA cameloidXPositionArray,X

        LDA currentYPosition
        STA cameloidYPositionArray,X
       
        ; Default Cameloid left
        LDA #CAMELOID_LEFT
        STA currentCharacter

        LDA cameloidStatusArray,X
        AND #$40                                    ; %01000000
        BNE skip_cameloid_change

        LDA #CAMELOID_RIGHT
        STA currentCharacter

.skip_cameloid_change

        LDA currentCharacter
        JSR PlotCharSpriteNoBlack

.next_cameloid
        DEX
        BNE cameloid_loop

.cameloidExit
        RTS
}

;-------------------------------------------------------------------------
.PlotBonus106
{        
        LDA cameloidXPositionArray,X
        STA currentXPosition
        LDA cameloidYPositionArray,X
        STA currentYPosition
        LDA cameloidStatusArray,X
        AND #$0F                                    ; %00001111
        BEQ erase_bonus                             ; plot 2 grids when counter hits #$20 after starting on #$2F
        LDA cameloidStatusArray,X
        SEC                                         ; Clear carry
        SBC #$01                                    ; countdown bonus106 to $0F ?
        STA cameloidStatusArray,X

        ; Draw the cameloid bonus.
        LDA #BONUS1                                 ; bonus 106 (left)
        STA currentCharacter
        JSR PlotCharSprite                          ; Plot bonus 106 (left)
        INC currentCharacter                        ; bonus 106 (right)
        INC currentXPosition
        JSR PlotCharSprite                          ; Plot bonus 106 (right)
.j8F1E   
        DEX 
        BEQ bonus_exit
        JMP CheckBonus
        ; Return

.erase_bonus   
        JSR DestroyCameloid
        LDA gridCharacter
        STA currentCharacter
        JSR PlotCharSprite
        INC currentXPosition
        JSR PlotCharSprite
        JMP j8F1E
        ; Return

.bonus_exit
    RTS
}

;-------------------------------------------------------------------------
; DestroyCameloid
;-------------------------------------------------------------------------
.DestroyCameloid
{
        LDA droidsLeftToKill
        BNE no_mystery_bonus_2
        LDA noOfDroidSquadsCurrentLevel
        BNE no_mystery_bonus_2

        ; Mystery Bonus 2
        ; Get a low bonus bit for killing all droids before cameloids
        LDA bonusBits
        ORA #$02
        STA bonusBits

.no_mystery_bonus_2

        STX saveX
        
.cameloid_loop   
        ; Seems to copy data down ?
        LDA cameloidXPositionArray + $0001,X
        STA cameloidXPositionArray,X
        LDA cameloidYPositionArray + $0001,X
        STA cameloidYPositionArray,X
        LDA cameloidStatusArray + $0001,X
        STA cameloidStatusArray,X
        CPX currentCameloidsLeft
        BEQ cameloid_destroyed
        INX 
        JMP cameloid_loop

.cameloid_destroyed   
        DEC currentCameloidsLeft
        LDA InitialDroidsInSquad
        BEQ exit
        LDA CameloidsLeftToKill
        BNE exit

        ; Mystery Bonus 7
        ; Get a high bonus bit for clearing cameloids.
        LDA bonusBits
        ORA #$40
    STA bonusBits

.exit   
    LDX saveX
    RTS 
}

;-------------------------------------------------------------------------
; CameloidCollision
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.CameloidCollision
{
    STX saveX    
    LDX #ExplosionSound MOD 256
    LDY #ExplosionSound DIV 256
    JSR PlaySound

    LDA #$01
    JSR AddScore100
    LDA #$06
    JSR AddScore10

    JSR PrintScore

    LDX saveX

    LDA #$2F
    STA cameloidStatusArray,X

    RTS
}

;-------------------------------------------------------------------------
; ReduceScore
;-------------------------------------------------------------------------
.ReduceScore
{
    SED
    CLC
    LDA score1
    SBC #$10
    STA score1

    LDA score2
    SBC #$00
    STA score2

    LDA score3
    SBC #$00
    STA score3

    LDA score4
    SBC #$00
    STA score4
    CLD

    LDA score4
    BPL over

    LDA #$00
    STA score1
    STA score2
    STA score3
    STA score4
    
.over    
    JSR PrintScore
    RTS
}
      
;-------------------------------------------------------------------------
; FindCameloid
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A contains either gridCharacter , #CAMEL_LEFT or #CAMEL_RIGHT
;           : X contains index into array
;-------------------------------------------------------------------------
.FindCameloid
{
    LDX currentCameloidsLeft

.loop
    LDA cameloidXPositionArray,X
    CMP currentXPosition
    BNE skip
    LDA cameloidYPositionArray,X
    CMP currentYPosition
    BNE skip

    ; Cameloid found - but which part of it
    LDA cameloidStatusArray,X
    AND #$20                            ; Bonus 106 ?
    BEQ not_bonus
    LDA gridCharacter
    RTS

.not_bonus
    AND #$40                            ; %01000000 - CAMEL_RIGHT
    BEQ cameloid_right_found            ; Result == 0 then Z = 1, so branch if not head
    
    LDA #CAMELOID_LEFT
    RTS
    ; Return

.cameloid_right_found
    LDA #CAMELOID_RIGHT
    RTS
    ; Return

.skip
    DEX
    BNE loop
    LDA gridCharacter  ; Default to Grid        
    RTS
}

;-------------------------------------------------------------------------

  