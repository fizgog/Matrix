;-------------------------------------------------------------------------
; Matrix: Gridrunner 2 - Ship code
;-------------------------------------------------------------------------

; Ship explodes into 8 pieces
; \ | /
; - o -
; / | \

; 00 - X or Y stays the same
; 01 - X or Y Increments
; 80 - X or Y Decrements
; Array index
;  7 - $80 $80 : top left
;  6 - $00 $80 : centre left
;  5 - $01 $80 : bottom left
;  4 - $00 $01 : centre bottom
;  3 - $01 $01 : bottom right 
;  2 - $01 $00 : centre right
;  1 - $80 $01 : top right
;  0 - $80 $00 : centre top

; Ship Explosion Arrays
;.explosionXPosArrayControl
;EQUB    $80,$80,$01,$01,$00,$01,$00,$80

;.explosionYPosArrayControl
;EQUB    $00,$01,$00,$01,$01,$80,$80,$80

;.shipExplosionAnimation 
;EQUB EXPLOSION1,EXPLOSION2,EXPLOSION3,$FF

;-------------------------------------------------------------------------
; MaterializeShip
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.MaterializeShip
{
    LDA #SHIP_MAX_Y
    STA shipYPosition
    
    LDA #SHIP_START_X
    STA shipXPosition
    
    LDA #$08
    STA temp3

.ShipMaterializationLoop

    LDA gridCharacter
    STA currentCharacter
  
    LDA shipYPosition
    SEC
    SBC temp3
    STA currentYPosition
    
    LDA shipXPosition
    SEC
    SBC temp3
    STA currentXPosition
    JSR PlotCharSprite

    LDA shipXPosition
    CLC
    ADC temp3
    STA currentXPosition
    JSR PlotCharSprite

    INC currentYPosition
    DEC currentXPosition
    LDA #HALF_RIGHT
    STA currentCharacter
    JSR PlotCharSpriteNoBlack

    LDA shipXPosition
    SEC
    SBC temp3
    STA currentXPosition
    INC currentXPosition
    LDA #HALF_LEFT
    STA currentCharacter
    JSR PlotCharSpriteNoBlack

    LDA #$04
    JSR vsync_delay

    DEC temp3
    BNE ShipMaterializationLoop

    LDA #SHIP
    STA currentCharacter
    JSR PlotCharSprite

    LDX #ShipExplosionSound MOD 256 
    LDY #ShipExplosionSound DIV 256 
    JSR PlaySound

    LDA #$03
    STA temp4

.loop
    LDA #0
    STA backColour
    LDA #3
    STA foreColour
    
    LDX #4
    LDY #3
    JSR DefineColour
    JSR AnimateGrid
    JSR AnimateGrid

    LDA #$02
    JSR vsync_delay

    LDA #0
    STA backColour
    LDA #4
    STA foreColour
    
    LDX #4
    LDY #4
    JSR DefineColour
    JSR AnimateGrid
    JSR AnimateGrid
    
    LDA #$02
    JSR vsync_delay

    DEC temp4
    LDA temp4
    BNE loop
    RTS
    ; Return
}

;-------------------------------------------------------------------------
; UpdateShip
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.UpdateShip
{
    DEC shipAnimationFrameRate  
    BEQ start   
    RTS 
.start    
    LDA #SHIP_FRAME_RATE        
    STA shipAnimationFrameRate

    LDA shipXPosition
    STA currentXPosition
    LDA shipYPosition
    STA currentYPosition

    BIT joystickFlag
    BPL over
    JMP ShipKeyboard
    ; Return
.over
    JMP ShipJoystick
    ; Return    
}

;-------------------------------------------------------------------------
; ShipKeyboard
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.ShipKeyboard
{
.ship_left      

    LDX #keyCodeZ
    JSR isKeyPressed
	BNE ship_right

    LDA currentXPosition
    CMP #GRID_MIN_X;#$01
    BEQ ship_exit
    
    JSR EraseShip

    DEC currentXPosition
    JMP ship_fire

.ship_right
    LDX #keyCodeX
    JSR isKeyPressed
	BNE ship_up

    LDA currentXPosition
    CMP #GRID_MAX_X
    BEQ ship_exit

    JSR EraseShip

    INC currentXPosition
    JMP ship_fire

.ship_up
    LDX #keyCodeColon
    JSR isKeyPressed
	BNE ship_down

    LDA currentYPosition
    CMP #SHIP_MIN_Y
    BEQ ship_exit
    JSR EraseShip

    DEC currentYPosition
    JMP ship_fire

.ship_down
    LDX #keyCodeForwardSlash
    JSR isKeyPressed
	BNE ship_fire

    LDA currentYPosition
    CMP #SHIP_MAX_Y;#GRID_MAX_Y
    BEQ ship_exit

    JSR EraseShip

    INC currentYPosition
    ; Fall through

.ship_fire
    LDX #keyCodeRETURN
    JSR isKeyPressed
    BNE ship_pod_check

    ; one bullet at a time
    LDA bulletType
    BNE ship_update
    JSR FireBullet

.ship_pod_check
    JSR getChar
    CMP gridCharacter ; #GRID
    BEQ ship_update

    LDA shipXPosition
    STA currentXPosition
    LDA shipYPosition
    STA currentYPosition

.ship_update
    
    LDA #SHIP
    STA currentCharacter
    JSR PlotCharSpriteNoBlack

    LDA currentXPosition
    STA shipXPosition
    LDA currentYPosition
    STA shipYPosition
    
.ship_exit
    JMP CheckShipBonus
    ; Return
}

;-------------------------------------------------------------------------
; ShipJoystick - Bit of a hack, really need to combine with keyboard code
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.ShipJoystick
{
.ship_right    
    LDX #1
    JSR isJoystickMoved1
    BCS ship_left

    LDA currentXPosition
    CMP #GRID_MAX_X
    BEQ ship_exit
    JSR EraseShip
    INC currentXPosition
    JMP ship_fire

.ship_left
    LDX #1
    JSR isJoystickMoved2
    BCC ship_down

    LDA currentXPosition
    CMP #$01
    BEQ ship_exit
    JSR EraseShip
    DEC currentXPosition
    JMP ship_fire

.ship_down    
    LDX #2
    JSR isJoystickMoved1
    BCS ship_up

    LDA currentYPosition
    CMP #SHIP_MAX_Y
    BEQ ship_exit
    JSR EraseShip
    INC currentYPosition
    JMP ship_fire

.ship_up
    LDX #2
    JSR isJoystickMoved2
    BCC ship_fire
    
    LDA currentYPosition
    CMP #SHIP_MIN_Y
    BEQ ship_exit
    JSR EraseShip
    DEC currentYPosition
    ; Fall through

.ship_fire
    JSR isJoystickPressed
    BCC ship_pod_check

    ; one bullet at a time
    LDA bulletType
    BNE ship_update
    JSR FireBullet

.ship_pod_check
    JSR getChar
    CMP gridCharacter ; #GRID
    BEQ ship_update

    LDA shipXPosition
    STA currentXPosition
    LDA shipYPosition
    STA currentYPosition

.ship_update
    
    LDA #SHIP
    STA currentCharacter
    JSR PlotCharSpriteNoBlack

    LDA currentXPosition
    STA shipXPosition
    LDA currentYPosition
    STA shipYPosition    

.ship_exit
    JMP CheckShipBonus
    ; Return
}

.CheckShipBonus
{
    ; Mystery Bonus 3
    LDA shipXPosition
    CMP #$03
    BEQ no_mystery_bonus_3
    CMP #$11
    BPL no_mystery_bonus_3
    
    RTS

    ; Clear most of the bonus bits, as punishment for moving to the
    ; extreme left of the grid.
.no_mystery_bonus_3   
    LDA bonusBits
    AND #$FB
    STA bonusBits

.exit
    RTS
}


;-------------------------------------------------------------------------
; FireBullet
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.FireBullet
{
    LDA #$01
    STA bulletType

    LDA currentXPosition
    STA bulletXPosition

    LDA currentYPosition
    STA bulletYPosition
    DEC bulletYPosition

    ; Bullet Sound
    LDX #FireBulletSound1 MOD 256
    LDY #FireBulletSound1 DIV 256
    JSR PlaySound
    LDX #FireBulletSound2 MOD 256
    LDY #FireBulletSound2 DIV 256
    JSR PlaySound

    LDA #BULLET_UP
    STA bulletCharacter

    RTS
}

;-------------------------------------------------------------------------
; EraseShip
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.EraseShip
{
    LDA gridCharacter ; #GRID
    STA currentCharacter
    JSR PlotCharSprite
    RTS
}

;-------------------------------------------------------------------------
; FindShip
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.FindShip
{
    LDA currentXPosition
    CMP shipXPosition
    BNE not_ship
    LDA currentYPosition
    CMP shipYPosition
    BNE not_ship
    LDA #SHIP
    RTS
.not_ship
    LDA gridCharacter ; #GRID
    RTS    
}

;-------------------------------------------------------------------------
; UpdateBullet
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.UpdateBullet
{
    ; Fire as fast as we can
    ;DEC bulletAndLaserFrameRate
    ;BEQ start
    ;RTS
.start   
    ;LDA #BULLET_FRAME_RATE
    ;STA bulletAndLaserFrameRate
    
    ; One bullet on screen at a time
    LDA bulletType                  ; > 0 = In Play
    BEQ bullet_exit

    LDA bulletXPosition
    STA currentXPosition
    LDA bulletYPosition
    STA currentYPosition
    
    LDA gridCharacter ; #GRID
    STA currentCharacter
    JSR PlotCharSprite  ; Erase bullet

    LDA bulletType                  ; > 0 = In Play
    AND #$F0                            ; %11110000        
    BEQ standard_bullet
  
    ;LDA bulletType
    ;JSR Debug1

    JMP DrawDeflectedBullet

.standard_bullet

    DEC bulletYPosition
    DEC currentYPosition
    LDA currentYPosition   

    CMP #GRID_MIN_Y-1
    BNE not_top

    LDA #$00
    STA bulletType
    RTS

.not_top
    LDA #BULLET_UP
    STA currentCharacter
    ; Check Enemy 
    JSR CheckEnemyCollision

.draw_bullet
  
    JMP PlotCharSpriteNoBlack

.bullet_exit
    RTS
}

;-------------------------------------------------------------------------
; CheckEnemyCollision
;-------------------------------------------------------------------------
; Has the bullet collided with something?
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.CheckEnemyCollision
{
    ; A = M  then Z = 1          BEQ
    ; M <= A then C = 1 (A > M)  BCS
    ; M > A  then C = 0 (A <= M) BCC

    JSR getChar
    CMP gridCharacter
    BEQ found_grid

    STA currentCharacter

    CMP #DEFLECTOR1
    BCC not_deflexor            ; < #DEFLEXOR1
    CMP #DEFLECTOR3+1
    BCS not_deflexor            ; >= DEFLEXOR+1
    
    JMP DeflexorCollision      
    ; Return
    
.not_deflexor

    CMP #CAMELOID_RIGHT
    BCC not_cameloid
    CMP #CAMELOID_LEFT+1
    BCS not_cameloid
   
    JSR CameloidCollision
  
    LDA #$00
    STA bulletType
    RTS

.not_cameloid

    CMP #LEADER1
    BCC not_droid
    CMP #DROID+1
    BCS not_droid
   
    JSR DroidCollision
  
    LDA #$00
    STA bulletType
    RTS

.not_droid  ; must be a pod then
    JSR CheckPodCollision
   
    LDA #$00
    STA bulletType
    RTS

.found_grid    
    RTS    
}

;-------------------------------------------------------------------------
; CheckPodCollision
;-------------------------------------------------------------------------
; On entry  : A contains CheckCharacter
; On exit   : 
;-------------------------------------------------------------------------
.CheckPodCollision
{
    LDY #$06 ; Start on 6th sequence
.loop    
    CMP PodDecaySequence,Y
    BEQ found_pod
    DEY
    BNE loop
    RTS

.found_pod
    ; Locate pod inside array
    JSR FindPod
    ; X contains location of array

    LDA PodDecaySequence,Y
    CMP #POD1
    BEQ remove_pod
    DEY
    
    LDA PodDecaySequence,Y
    STA currentCharacter
    STA podArrayChar,X

    JMP PlotCharSprite

.remove_pod
    LDA #$FF
    STA podArrayChar,X
    STA podArrayXPos,X
    STA podArrayYPos,X
    
    LDA gridCharacter ; #GRID
    STA currentCharacter
    JSR PlotCharSprite

    ;JSR PlayExplosion
    LDX #ExplosionSound MOD 256
    LDY #ExplosionSound DIV 256
    JSR PlaySound

    ; Increase score by 10
    LDA #$10
    JSR AddScore10

    JSR PrintScore
    RTS
}

;-------------------------------------------------------------------------
; ExplodeShip
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.ExplodeShip
{
    ; Reset Red colour
    LDX #1
    LDY #1
    JSR DefineColour
    
    LDX #ShipExplosionSound MOD 256
    LDY #ShipExplosionSound DIV 256
    JSR PlaySound

    LDA #$05
    STA temp4

.loop
    LDX #0
    LDY #4
    JSR DefineColour
 
    LDA #$02
    JSR vsync_delay

    LDX #0
    LDY #0
    JSR DefineColour
    
    LDA #$02
    JSR vsync_delay

    DEC temp4
    LDA temp4
    BNE loop

    JSR AnimateShipExplosion

    DEC shipLives
    BEQ finish

    JMP GotYou
    
.finish
    JMP GameOver
    RTS  
}

;-------------------------------------------------------------------------
; AnimateShipExplosion
;-------------------------------------------------------------------------
; This will animate 1 cycle of 8 explosion
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.AnimateShipExplosion
{
    LDA #$0F
    STA temp4

.b956A
    LDA #$0F
    SEC
    SBC temp4 
    STA temp3

    LDA #$07
    STA temp2

    LDA #$04
    JSR vsync_delay

.b957F   
    JSR DrawCharacterInShipExplosion

    LDA temp3
    BEQ b959F
    DEC temp3
    BEQ b958E
    LDA temp2
    BNE b957F

.b958E
    LDA gridCharacter
    STA currentCharacter
    JSR DrawEightExplosion
    
.b959F   
    DEC temp4
    BNE b956A   
    RTS
}

.DrawCharacterInShipExplosion
{
    LDA temp2                   
    AND #$07
    TAY
    LDA ColourEffects,Y
    STA chrFontColour

    LDA #49
    STA currentCharacter

    DEC temp2
    ; Falls through
}

.DrawEightExplosion
{
    LDA shipXPosition
    SEC
    SBC temp3
    STA currentXPosition
    LDA shipYPosition
    STA currentYPosition

    JSR DrawSingleExplosion           ; centre left explosion

    LDA shipYPosition
    CLC
    ADC temp3
    STA currentYPosition
    JSR DrawSingleExplosion           ; bottom left explosion

    LDA shipYPosition
    SEC
    SBC temp3
    STA currentYPosition
    JSR DrawSingleExplosion           ; top left explosion

    LDA shipXPosition
    STA currentXPosition
    JSR DrawSingleExplosion           ; centre top explosion

    LDA shipXPosition
    CLC
    ADC temp3
    STA currentXPosition
    JSR DrawSingleExplosion           ; top right explosion

    LDA shipYPosition
    STA currentYPosition
    JSR DrawSingleExplosion           ; centre right explosion

    LDA shipYPosition
    CLC
    ADC temp3
    STA currentYPosition
    JSR DrawSingleExplosion           ; bottom right explosion

    LDA shipXPosition
    STA currentXPosition
    ; Fall through

}

.DrawSingleExplosion
{  
    LDA currentXPosition
    CMP #GRID_MIN_X;#$01
    BMI exit
    CMP #MAX_X;#$14 ; 21
    BPL exit

    LDA currentYPosition
    CMP #GRID_MIN_Y;#$03
    BMI exit
    CMP #GRID_MAX_Y;#$1D ; 31
    BPL exit

    LDA currentCharacter
    CMP #49
    BEQ use_font

    JMP PlotCharSprite

.use_font
    JSR PlotFont
    LDA #49                 
    STA currentCharacter    ; Restore currentCharacter
.exit
    RTS
}

;-------------------------------------------------------------------------
