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
.explosionXPosArrayControl
EQUB    $80,$80,$01,$01,$00,$01,$00,$80

.explosionYPosArrayControl
EQUB    $00,$01,$00,$01,$01,$80,$80,$80

.shipExplosionAnimation 
EQUB EXPLOSION1,EXPLOSION2,EXPLOSION3,$FF

;-------------------------------------------------------------------------
; MaterializeShip
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.MaterializeShip
{
    ; TODO? C64 implodes ship on start, but VIC 20 doesn't

    LDA #SHIP
    STA currentCharacter
    LDA #SHIP_MAX_Y
    STA currentYPosition
    STA shipYPosition
    
    LDA #SHIP_START_X
    STA currentXPosition
    STA shipXPosition
    JSR PlotCharSprite
    RTS
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
.over
    JMP ShipJoystick
    RTS
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
    LDA bulletType;bulletYPosition
    ;CMP #$FF
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
    JSR PlotCharSprite

    LDA currentXPosition
    STA shipXPosition
    LDA currentYPosition
    STA shipYPosition
    
.ship_exit
    RTS
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
    CMP #GRID_MAX_Y
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
    LDA bulletType;bulletYPosition
    ;CMP #$FF
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
    JSR PlotCharSprite

    LDA currentXPosition
    STA shipXPosition
    LDA currentYPosition
    STA shipYPosition    

.ship_exit
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
    LDX #FireBulletSound MOD 256
    LDY #FireBulletSound DIV 256
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
  
    JMP DrawDeflectedBullet

.standard_bullet

    DEC bulletYPosition
    DEC currentYPosition
    LDA currentYPosition   

    ; First row of grid so remove bullet as you cannot hit anything ?
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
  
    JMP PlotCharSprite

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
    CMP #DEFLECTOR3
    BCS not_deflexor            ; >= DEFLEXOR+1
    
    JMP DeflexorCollision      
    ; Return
    
.not_deflexor

    CMP #CAMELOID_RIGHT
    BCC not_cameloid
    CMP #CAMELOID_LEFT+1
    BCS not_cameloid
   
    ;JSR CameloidCollision
  
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
; CheckPodCollision
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.ExplodeShip
{
    ;LDA shipXPosition
    ;STA currentXPosition
    ;LDA shipYPosition
    ;STA currentYPosition

    ;AND #$3                     ; %00000011
    ;TAX
    ;LDA shipExplosionAnimation,X
    ;STA currentCharacter
    ;LDA currentYPosition
    ;AND #$07
    ;STA chrFontColour;???


    ; Initiliase explosion array
    ;JSR InitExplosionArray

    ;LDX #ShipExplosionSound MOD 256
    ;LDY #ShipExplosionSound DIV 256
    ;JSR PlaySound

    ; Animation effect is different for Matrix
    ; Loop 20 times for animation effect
    ;LDY #$14
;.loop    
;    JSR AnimateShipExplosion

;    STY saveY
;    LDA #$05
;    JSR vsync_delay
;    LDY saveY

;    DEY
;    BPL loop

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
    INC currentExplosionCharacter
    LDA currentExplosionCharacter
    CMP #EXPLOSION3 + 1
    BNE next_animation

    ; Reset animation
    LDA #EXPLOSION1
    STA currentExplosionCharacter

.next_animation

    LDX #$07
 .loop_eight_explosion

    LDA explosionXPosArray,X
    STA currentXPosition
    LDA explosionYPosArray,X
    STA currentYPosition
    LDA gridCharacter ; #GRID
    STA currentCharacter
    JSR PlotCharSprite

    LDA explosionXPosArrayControl,X
    BEQ over2   ; X stays the same  
    
    CMP #$80    ; %10000000
    BEQ over3   ; Decrements x position

    INC explosionXPosArray,X

.over2
    INC explosionXPosArray,X    

.over3
    JSR UpdateExplosionXPosArray

    LDA explosionYPosArrayControl,X
    BEQ over4   ; Y stays the same

    CMP #$80    ; %10000000
    BEQ over5   ; Decrement y position

    INC explosionYPosArray,X

.over4    
    INC explosionYPosArray,X

.over5
    JSR UpdateExplosionYPosArray

    LDA explosionXPosArray,X
    STA currentXPosition
    LDA explosionYPosArray,X
    STA currentYPosition
    LDA currentExplosionCharacter
    STA currentCharacter
    JSR PlotCharSprite
    
    DEX
    BPL loop_eight_explosion
    RTS
}

;-------------------------------------------------------------------------
; InitExplosionArray
;-------------------------------------------------------------------------
; Put ships current x and y coords into each explosion x and y array
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.InitExplosionArray
{
    LDX #$07
.loop
    LDA shipXPosition
    STA explosionXPosArray,X
    LDA shipYPosition
    STA explosionYPosArray,X
    DEX
    BPL loop

    LDA shipXPosition
    STA currentXPosition
    LDA shipYPosition
    STA currentYPosition
    
    LDA #EXPLOSION1
    STA currentExplosionCharacter
    STA currentCharacter
        
    JSR PlotCharSprite
    RTS
}

;-------------------------------------------------------------------------
; UpdateExplosionXPosArray
;-------------------------------------------------------------------------
; On entry  : X contains postion into Explosion XPOS array
; On exit   : 
;-------------------------------------------------------------------------
.UpdateExplosionXPosArray
{
    DEC explosionXPosArray,X
    LDA explosionXPosArray,X
    BEQ over    ; xpos 0
    AND #$1F    ; %00011111
    CMP #$14    ; xpos 20
    BPL over

    STA explosionXPosArray,X
    RTS
.over
    LDA shipXPosition
    STA explosionXPosArray,X
    RTS
}

;-------------------------------------------------------------------------
; UpdateExplosionYPosArray
;-------------------------------------------------------------------------
; On entry  : X contains postion into Explosion YPOS array
; On exit   : 
;-------------------------------------------------------------------------
.UpdateExplosionYPosArray
{
    DEC explosionYPosArray,X
    LDA explosionYPosArray,X
    AND #$1F    ; %00111111
    CMP #$02    ; ypos 2
    BEQ over
    CMP #$1D    ; ypos 29   
    BPL over

    STA explosionYPosArray,X
    RTS
.over
    LDA shipYPosition
    STA explosionYPosArray,X
    RTS
}

;-------------------------------------------------------------------------
