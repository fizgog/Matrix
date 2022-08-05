\ ******************************************************************
\ *	Matrix: Gridrunner 2 - Deflexors code
\ ******************************************************************

;DEFLEXOR_SIZE           = $20
;DEFLEXOR_EMPTY_SLOT     = $FF ; ??? $00

; Bullet Type
; 00 %0000000 - Nothing
; 01 %0000001 - Fire bullet up
; 02 %0000010 - Bullet Animation - not used
; 10 %0001000 - DrawDeflexor Bullet Bullet Right
; 20 %0010000 - Bullet Down
; 30 %0011000 - Bullet Left
; F0 %1111000 - Mask (positive then its a deflexor bullet)

; 20 levels - how many deflexors to draw
.deflexorIndexArrayForLevel
EQUB $00,$00,$00,$00,$03
EQUB $00,$00,$09,$00,$00
EQUB $0D,$00,$00,$11,$00
EQUB $00,$00,$19,$00,$19

; Max 26 Deflexors on screen at once 0 - 25
; 0F = / , 1F = \ , 2F = -
.deflexorStatusArray
EQUB $1F,$0F,$0F,$1F,$1F,$0F
EQUB $1F,$0F,$1F,$0F,$2F,$2F
EQUB $2F,$2F,$0F,$1F,$1F,$0F,$2F
EQUB $2F,$2F,$2F,$2F,$2F,$2F,$2F

.deflexorXPosArrays
EQUB $09,$0A,$09,$0A,$02,$04
EQUB $06,$11,$0F,$0D,$09,$0A
EQUB $06,$0D,$04,$04,$0F,$0F,$01
EQUB $03,$05,$07,$12,$10,$0E,$0C
        
.deflexorYPosArrays
EQUB $13,$13,$14,$14,$0A,$0A
EQUB $0A,$0A,$0A,$0A,$06,$06
EQUB $06,$06,$14,$1C,$14,$1C,$08
EQUB $08,$08,$08,$08,$08,$08,$08


;---------------------------------------------------------------------------------
; InitDeflexorArray
;---------------------------------------------------------------------------------
.InitDeflexorArray
{
    LDX deflexorIndexForLevel
    STX currentDeflexorIndex

.deflexor_loop   
    LDA deflexorXPosArrays,X
    STA currentDeflexorXPosArray,X
    LDA deflexorYPosArrays,X
    STA currentDeflexorYPosArray,X
    LDA deflexorStatusArray,X
    STA currentDeflexorStatusArray,X
    DEX 
    BPL deflexor_loop
    RTS
}

;---------------------------------------------------------------------------------
; DrawDeflexor 
;---------------------------------------------------------------------------------
.DrawDeflexor
{
    LDX currentDeflexorIndex
    BNE next_deflexor
    RTS 

.next_deflexor
    LDA currentDeflexorXPosArray,X
    STA currentXPosition
    LDA currentDeflexorYPosArray,X
    STA currentYPosition

    LDA currentDeflexorStatusArray,X
    AND #$30                            ; %00110000 MASK
    TAY

    LDA #DEFLECTOR3                     ; 2F = - straight deflexor
 
    CPY #$20                            ; %00100000 
    BEQ deflexor_found

    LDA #DEFLECTOR2                     ; 1F = \ left deflexor
 
    CPY #$10                            ; %00010000 ; 0F
    BEQ deflexor_found
    
    LDA #DEFLECTOR1                     ; 0F = / right deflexor
    
.deflexor_found   
    STA currentCharacter
    JSR PlotCharSpriteNoBlack
    DEX 
    BPL next_deflexor
    RTS 
}

;---------------------------------------------------------------------------------
; DrawDeflectedBullet   
;---------------------------------------------------------------------------------
.DrawDeflectedBullet
{   
    ;LDA bulletType
    ;JSR Debug1

    LDA bulletType
    AND #$30                    ; MASK %00110000

    CMP #$30                    ; %00100000 -
    BEQ deflexor_bullet_down

    CMP #$20                    ; %00010000 \
    BEQ deflexor_bullet_left

    ; \ = 11
    ; / = 21
    ; - = 31

.deflexor_bullet_right
    INC bulletXPosition
    INC currentXPosition
    LDA currentXPosition

    CMP #GRID_MAX_X+1
    BEQ bullet_destroyed

.not_hit_right
    LDA #BULLET_RIGHT
    JMP draw_bullet

.deflexor_bullet_left    
    DEC bulletXPosition
    DEC currentXPosition
    LDA currentXPosition

    CMP #GRID_MIN_X-1
    BEQ bullet_destroyed
  
.not_hit_left    
    LDA #BULLET_LEFT
    JMP draw_bullet 

.deflexor_bullet_down
    ;JSR Debug
    INC bulletYPosition
    INC currentYPosition
    LDA currentYPosition

    CMP #GRID_MAX_Y
    BEQ bullet_destroyed
  
.not_hit_bottom  
    LDA #BULLET_DOWN
         
  
.draw_bullet
    STA currentCharacter
  
    ; Check Enemy 
    JSR CheckEnemyCollision

    JMP PlotCharSprite

    ;JSR Debug1
.bullet_destroyed
    LDA #$00
    STA bulletType
    RTS
}

;-------------------------------------------------------------------------
; FindDeflexor
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A contains DEFLEX1-3 or gridCharater
;           : X contains index into array, Y is preserved
;-------------------------------------------------------------------------
.FindDeflexor
{
    LDX currentDeflexorIndex
    BEQ FindDeflexorExit

.loop
    LDA currentDeflexorXPosArray,X
    CMP currentXPosition
    BNE skip

    LDA currentDeflexorYPosArray,X
    CMP currentYPosition
    BNE skip

    LDA currentDeflexorStatusArray,X
    AND #$30                            ; %00110000 ; 30
    TAY

    LDA #DEFLECTOR3 
    CPY #$20                            ; %00100000 ; 2F
    BEQ deflexor_found

    LDA #DEFLECTOR2 
    CPY #$10                            ; %00010000 ; 1F
    BEQ deflexor_found
    
    LDA #DEFLECTOR1 

.deflexor_found
    ;JSR Debug1
    RTS

.skip
    DEX
    BNE loop  

.FindDeflexorExit    
    LDA gridCharacter
    RTS
}

;---------------------------------------------------------------------------------
; DeflexorCollision   
;---------------------------------------------------------------------------------
.DeflexorCollision
{
    ;JSR Debug1

    CMP #DEFLECTOR3
    BEQ change_bullet_down
    CMP #DEFLECTOR2
    BEQ change_bullet_left

.change_bullet_right
    ;JSR Debug1
    LDA bulletType
    EOR #$10
    ;STA bulletType
    ;RTS
    JMP swap_deflexor

.change_bullet_left
    ;JSR Debug1
    ;LDA #$10
    LDA bulletType
    EOR #$20
    ;STA bulletType
    ;RTS
    JMP swap_deflexor

.change_bullet_down
    ;JSR Debug1
    ;LDA #$20
    LDA bulletType
    EOR #$30
    ;STA bulletType
    ;RTS

.swap_deflexor
    STA bulletType
    
    ;JSR Debug1

    ; A bullet has hit the deflexor.
    LDA currentDeflexorStatusArray,X
    JSR UpdatecurrentDeflexorStatusArray
    STA currentDeflexorStatusArray,X
    RTS
        
}

;-------------------------------------------------------------------------
; UpdatecurrentDeflexorStatusArray
;-------------------------------------------------------------------------
.UpdatecurrentDeflexorStatusArray
    AND #$30
    CMP #$20
    BEQ b91DA
    CMP #$10
    BEQ b91D5
    LDA #$1F
    STA currentDeflexorStatusArray,X
    RTS 

.b91D5   
    LDA #$0F
    STA currentDeflexorStatusArray,X
.b91DA   
    LDA currentDeflexorStatusArray,X
    RTS 


;-------------------------------------------------------------------------
