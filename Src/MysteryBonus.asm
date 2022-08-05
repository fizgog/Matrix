\ ******************************************************************
\ *	Matrix: Gridrunner 2 - Mystery Bonus code
\ ******************************************************************

;Mystery Bonus 2 (2000 points)
; ORA 0x02
;On a level with cameloids, if you allow any cameloid to exit the bottom of the grid without shooting it, you will be 
;eligible for Mystery Bonus 2.
 
;Mystery Bonus 3 (3000 points)
; ORA 0x04
;If your ship does not enter the 3 columns at the left or right sides of the grid (ie. columns 1, 2, 3, 18, 19 or 20), 
;you will be eligible for Mystery Bonus 3.
 
;Mystery Bonus 4 (4000 points)
; ORA 0x08
;The short explanation of Mystery Bonus 4 is that you will never receive it.
;The less short explanation is that every time a zapper fires, if there are no pods on-screen you will be (provisionally) 
;awarded MB4, but if there are pods on-screen, MB4 will be cancelled. In other words, if you are clear of pods when the final 
;zapper of the level goes off, you will be eligible for Mystery Bonus 4. Unfortunately, the zapper itself creates a new pod every 
;time it fires, and eligibility for this bonus is assessed immediately after the zapper has done this, so it is actually impossible 
;to score MB4, as you have no opportunity to remove the new pod from the screen before the game tests for pods :D
;Just for fun, I have created a version of VIC-20 Matrix where the zapper code is hacked around so that the MB4 test takes place 
;immediately before the pod creation instead of after it (the code is the same as the original, just a handful of instructions are 
;in a different order). You can download it here. To see the altered code in action, try starting a game on level 4, and destroy 
;every pod as soon as it is created - you should be awarded Mystery Bonus 4 at the end of the level.
 
;Mystery Bonus 5 (5000 points)
; ORA 0x10
;This is left as an exercise for the reader.
 
;Mystery Bonus 6 (6000 points)
; ORA 0x20
;On a level with deflexors, there are always 4 centre deflexors which form an X shape at the beginning of the level. 
;If you manipulate these 4 deflexors to form a diamond shape before completing the level, you will be eligible for Mystery Bonus 6.
 
;Mystery Bonus 7 (7000 points)
; ORA 0x40
;The short explanation is that if you complete a level which has both droids and cameloids (eg. level 6), you will always be 
;eligible for Mystery Bonus 7.
 
;Mystery Bonus 8 (8000 points)
; ORA 0x80
;On a level with deflexors, if you shoot a droid with a 'deflected' bullet (ie. a bullet that has hit one or more deflexors
;and is travelling left-, right- or downwards when it hits the droid), then you will be eligible for Mystery Bonus 8. 
;A bullet which has been deflected multiple times but which is ultimately travelling upwards when it hits a droid will not count, 
;as the game has no memory of a bullet's path, only knowledge of its direction of motion at the point of collision.

; Diamond Shape
.MysteryBonusShape
    EQUS $0F,$1F,$1F,$0F

.MysteryBonusText
EQUS " MYSTERY BONUS  0 ",$FF

.MysteryScore
EQUB $00,$10,$20,$30,$40,$50,$60,$70,$80

;---------------------------------------------------------------------------------
; CalculateMysteryBonus
;---------------------------------------------------------------------------------
.CalculateMysteryBonus
{
    LDA deflexorIndexForLevel
    BEQ invald_shape                    ; No deflectors on this stage

    LDX #$04
.shape_loop
    LDA currentDeflexorStatusArray,X
    CMP MysteryBonusShape,X
    BNE invald_shape
    DEX 
    BNE shape_loop

    ; Mystery Bonus 6
    LDA bonusBits
    ORA #$20
    STA bonusBits

.invald_shape   
    LDA #$08
    STA mysteryBonusEarned

.bonus_loop   
    LDA bonusBits
    CLC 
    ROL A
    STA bonusBits
    BCS bonus_exit
    DEC mysteryBonusEarned
    BNE bonus_loop

.bonus_exit

    LDX mysteryBonusEarned
    LDA MysteryScore,X
    JSR AddScore100

    JMP PrintScore
    ; Return
}    

;-------------------------------------------------------------------------
; DisplayMysteryBonus
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DisplayMysteryBonus
{
    LDA #5
    STA backColour
    LDA #0
    STA foreColour

    JSR DrawMysteryBonus

    LDA #YELLOW
    STA chrFontColour

    LDX #$01
    LDY #$12
    LDA #MysteryBonusText MOD 256: STA text_addr
    LDA #MysteryBonusText DIV 256: STA text_addr+1
    JSR PrintString

    LDA #CYAN
    STA chrFontColour
    LDX #$11
    LDY #$12
    JSR setTextPos

    LDA mysteryBonusEarned
    JSR BCDtoScreenOneChar
   
    ; Mystery animation
    LDA #$04
    STA gridFrameRate
    STA gridFrameRateMax

    LDA #$0F
    STA delay_counter2
.loop
    LDA #$00
    STA temp3

.mystery_loop
    JSR AnimateGrid

    LDA temp3
    STA GenericSoundPitch1
    STA GenericSoundPitch2
    STA GenericSoundPitch3
    
    LDX #GenericSound1 MOD 256 
    LDY #GenericSound1 DIV 256 
    JSR PlaySound
    LDX #GenericSound2 MOD 256 
    LDY #GenericSound2 DIV 256 
    JSR PlaySound
    LDX #GenericSound3 MOD 256 
    LDY #GenericSound3 DIV 256 
    JSR PlaySound

    LDA #$01
    JSR vsync_delay

    LDA temp3
    ADC #$04
    STA temp3
    
    CMP #$20
    BCC mystery_loop

    DEC delay_counter2
    BNE loop

    RTS
}

;-------------------------------------------------------------------------
; DrawGridOverEnterZone
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DrawMysteryBonus
{
    LDA #MYSTERY
    STA currentCharacter

    LDY #$11
.draw_vertical_line_loop2    
    STY currentYPosition
    LDX #$00
.draw_horizontal_line_loop2
    STX currentXPosition
    JSR PlotCharSprite
    INX
    CPX #$14
    BNE draw_horizontal_line_loop2
    INY
    CPY #$14
    BNE draw_vertical_line_loop2
    RTS
}

;-------------------------------------------------------------------------
