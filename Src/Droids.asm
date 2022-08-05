;-------------------------------------------------------------------------
; Matrix: GridRunner 2 - Droid code
;-------------------------------------------------------------------------

; Droid segment info
; 00 - Middle segment    00000000
; 01 - Going left mask   00000001
; 02 - Going right mask  00000010
; 03 -                   00000011
; 40 - Head segment      01000000
; 41 - head going right  01000001
; 42 - head going left   01000010
; 80 - tail segment      10000000  
; FD -                   11111101 


; 04 - going up / down
; 08 - zigzag on / off 


DROID_SIZE = $55 
DROID_EMPTY_SLOT = $FF

; Max 20 levels 
.noOfDroidSquadsForLevel
EQUB    $01,$02,$03,$00,$02
EQUB    $02,$02,$02,$00,$03
EQUB    $03,$03,$02,$03,$03
EQUB    $00,$03,$03,$03,$03

.sizeOfDroidSquadsForLevels
EQUB    $06,$06,$04,$00,$07
EQUB    $08,$08,$07,$00,$08
EQUB    $08,$08,$09,$0A,$0B
EQUB    $00,$0B,$0B,$0C,$0D

;-------------------------------------------------------------------------
; ClearDroidArray
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A contains $FF
;           : X is underfined
;-------------------------------------------------------------------------
.ClearDroidArray
{
    LDA #DROID_EMPTY_SLOT
    LDX #DROID_SIZE
.loop  
    STA droidStatusArray,X          ; Fill data with FF
    STA droidXPositionArray,X
    STA droidYPositionArray,X
    DEX 
    BNE loop
    RTS 
}
;-------------------------------------------------------------------------
; DrawDroids
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A and X are undefined
;-------------------------------------------------------------------------
.DrawDroids
{
    DEC droidFrameRate
    BEQ start

.droid_exit    
    RTS
 
.start
    LDA #DROID_FRAME_RATE
    STA droidFrameRate

    JSR CreateDroid
    LDA noOfDroidSquadsCurrentLevel
    BEQ droid_exit

    TAX
    INC currentDroidCharacter
    LDA currentDroidCharacter
    CMP #LEADER4+1
    BNE droid_head_reset_bypass

    LDA #LEADER1
    STA currentDroidCharacter

.droid_head_reset_bypass
    STX currentDroidIndex
    
    ; Draw grid over
    LDA droidXPositionArray,X
    STA currentXPosition
    LDA droidYPositionArray,X
    STA currentYPosition

    LDA gridCharacter 
    STA currentCharacter
    JSR DrawDroidSegment

    LDX currentDroidIndex
    LDA droidStatusArray,X
    AND #$40                    ;  Head segment (left or right)
    BNE DroidMovingDown
    
    ; Draw segment
    LDA droidXPositionArray - $01,X
    STA droidXPositionArray,X
    STA currentXPosition
    LDA droidYPositionArray - $01,X
    STA droidYPositionArray,X
    STA currentYPosition

    LDA #DROID
    STA currentCharacter
    JSR PlotCharSprite

.resume_drawing_droids
    LDX currentDroidIndex
    DEX
    BNE droid_head_reset_bypass
    RTS
    ; Return


.DroidMovingDown
    LDA droidStatusArray,X
    AND #$08                        ; %00001000 Zig Zagging?
    BEQ DroidMovingRight            ; No

    LDA droidStatusArray,X
    AND #$04                        ; %000000100 Going Down ?
    BNE DroidMovingUp               ; No

    INC currentYPosition
    INC currentYPosition

.DroidMovingUp
    DEC currentYPosition

    ; Check Y up down
    LDA currentYPosition
    CMP #DROID_MIN_Y;#GRID_MIN_Y
    BEQ DroidHitY

    CMP #DROID_MAX_Y;#GRID_MAX_Y
    BEQ DroidHitY

.DroidMovingRight
    LDA droidStatusArray,X
    AND #$02                        ; %00000010 Moving Right?
    BNE DroidMovingLeft             ; No
    
    INC currentXPosition
    INC currentXPosition

.DroidMovingLeft
    DEC currentXPosition

    LDA currentXPosition
    CMP #DROID_MAX_X;#MAX_X
    BEQ over

    CMP #DROID_MIN_X;#$00 ; minx-1 = 0
    BEQ over
    
    JSR getChar
    CMP gridCharacter 
    BEQ add_droid 

    CMP #SHIP
    BNE over
    JMP ExplodeShip
    ; Return
   
 .over   
    LDX currentDroidIndex
    LDA droidXPositionArray,X
    ;;JSR CheckShipCollision
    STA currentXPosition
   
    LDA droidStatusArray,X 
    AND #$08                        ; %00001000
    BEQ DroidFirstPass              ; Only zig zag when droid has reached the bottom
    JMP not_reached_bottom
    ; Return

.DroidHitY
    LDA droidStatusArray,X
    EOR #$04                        ; %000000100
    STA droidStatusArray,X
    JMP add_segment
    ; Return

.DroidFirstPass

    INC currentYPosition
    LDA currentYPosition
    
    CMP #DROID_MAX_Y
    BNE not_reached_bottom

    ; Reached bottom
    LDA droidStatusArray,X
    ORA #$09                    ; %00001001     Turn on zigzag
    EOR #$04                    ; %00000100     Going up
    AND #$FD                    ; %11111101    ?????
    
    STA droidStatusArray,X
    
    JMP add_segment
    ; Return

.not_reached_bottom
    LDA droidStatusArray,X
    EOR #$03                    ; %00000011
    STA droidStatusArray,X

    ; Draw the droid segment
.add_segment    
    LDA currentXPosition
    STA droidXPositionArray,X
    LDA currentYPosition
    STA droidYPositionArray,X

    LDA currentDroidCharacter
    STA currentCharacter
    JSR PlotCharSprite

    LDX currentDroidIndex
    JMP resume_drawing_droids
    ; Return

.add_droid
    LDX currentDroidIndex
    JMP add_segment  
    ; Return          
}

;-------------------------------------------------------------------------
; CheckShipCollision
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : 
;-------------------------------------------------------------------------
;.CheckShipCollision
;{
    ;CMP #SHIP
    ;BEQ over
;    LDA droidXPositionArray,X
;.over    
;    RTS
;}

;-------------------------------------------------------------------------
; DrawDroidSegment
;-------------------------------------------------------------------------
; On entry  : X contains droid index
; On exit   : A is underfined
;           : X is preserved
;-------------------------------------------------------------------------
.DrawDroidSegment
{
    LDA droidStatusArray,X
    AND #$80                    ; %10000000 - Tail segment
    BEQ segment_exit
    JMP PlotCharSprite
    ; Return

.segment_exit
    RTS    
}

;-------------------------------------------------------------------------
; CreateDroid
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A and X are underfined
;-------------------------------------------------------------------------
.CreateDroid
{
    LDA droidParts
    BNE create_droid_segment
    DEC droidTimer
    BEQ start
    RTS 
    ; Return

.create_droid_segment
    INC noOfDroidSquadsCurrentLevel
    LDX noOfDroidSquadsCurrentLevel
    LDA #$0A
    STA droidXPositionArray,X
    LDA #DROID_MIN_Y
    STA droidYPositionArray,X
    LDA #$00                            ; %00000000   
    ;JSR RandomNumber
    ;AND #$01                         
    STA droidStatusArray,X
    DEC droidParts
    LDA droidParts
    CMP #$01                            ; %00000001
    BEQ create_droid_tail
    RTS 
    ; Return

.create_droid_tail 
    DEC droidParts
    DEC droidsLeftToKill
    LDA #$80                        ; %10000000 - Tail segment
    STA droidStatusArray,X
    RTS    
    ; Return

.start
    LDA droidsLeftToKill
    BNE init_leader_droid
    RTS 
    ; Return

.init_leader_droid
    LDA #DROID_TIMER
    STA droidTimer
    LDA sizeOfDroidSquadForLevel
    STA droidParts
    INC noOfDroidSquadsCurrentLevel
    LDX noOfDroidSquadsCurrentLevel
    LDA #$0A
    STA droidXPositionArray,X
    LDA #DROID_MIN_Y
    STA droidYPositionArray,X
    JSR RandomNumber                    ; Randomise the droid start movement
    AND #$03
    ADC #$40                            ; Make sure it's the head piece
    STA droidStatusArray,X
    RTS   
}

;-------------------------------------------------------------------------
; UpdateDroidStatus
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.UpdateDroidStatus
{
    STX currentDroidIndex
.droid_loop
    DEX
    LDA droidStatusArray,X
    AND #$40                        ; Head segment (left or right)
    BEQ droid_loop
    LDA droidStatusArray,X
    NOP
    NOP
    LDX currentDroidIndex
    JSR toggle_droid_control_state
    LDA droidStatusArray - $01,X
    ORA #$80                        ; %10000000 - Tail segment
    STA droidStatusArray - $01,X
    RTS
    ; Return

.toggle_droid_control_state
    ORA droidStatusArray + $01,X
    STA droidStatusArray + $01,X
    RTS        
}

;-------------------------------------------------------------------------
; DroidCollision
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DroidCollision
{
    STA saveA

    ;JSR PlayExplosion
    LDX #ExplosionSound MOD 256
    LDY #ExplosionSound DIV 256
    JSR PlaySound

    ;LDX #0
    ;LDY #31
    ;JSR setTextPos
    ;LDA saveA
    ;JSR BCDtoScreen
    LDA saveA

    CMP #DROID
    BEQ droid_segment_hit
    ; Otherwise Lead droid hit
    ; Increase score by 300 (Head is worth 400)
    LDA #$03
    JSR AddScore100
    
.droid_segment_hit
    ; Increase score by 100 (segment is worth 100)
    LDA #$01
    JSR AddScore100

    ; This destroys current x and y
    LDA currentXPosition
    STA temp2
    LDA currentYPosition
    STA temp3

    JSR PrintScore

    LDA temp2
    STA currentXPosition
    LDA temp3
    STA currentYPosition

    LDA bulletType
    AND #$30
    BEQ no_mystery_bonus_8

    ; Mystery Bonus 8
    ; Get a bonus bit for hitting something with a deflected
    ; bullet.
    LDA bonusBits
    ORA #$80
    STA bonusBits

.no_mystery_bonus_8    
    ; Remove bullet
   
    LDA #$00
    STA bulletType

    LDX noOfDroidSquadsCurrentLevel
.droid_hit_position
    LDA droidXPositionArray,X
    CMP currentXPosition                ; ???
    BEQ droid_has_been_hit ; found
.droid_hit_wrong_position  
    DEX    
    BNE droid_hit_position
    RTS
    ; Return

.droid_has_been_hit
    LDA droidYPositionArray,X
    CMP currentYPosition
    BNE droid_hit_wrong_position
    LDA droidStatusArray,X
    AND #$C0
    BNE droid_control_character
    JSR UpdateDroidStatus

    ;Update droid arrays
.droid_loop    
    LDA droidYPositionArray + $01,X
    STA droidYPositionArray,X
    LDA droidXPositionArray + $01,X
    STA droidXPositionArray,X
    LDA droidStatusArray + $01,X
    STA droidStatusArray,X
    CPX noOfDroidSquadsCurrentLevel
    BEQ droid_segment_destroyed
    INX
    JMP droid_loop
    ; Return

.droid_segment_destroyed  
    DEC noOfDroidSquadsCurrentLevel

    ; Drop pod
    JMP CreatePodArrayEntry
    ; Return

.droid_control_character
    CMP #$C0                        ; %11000000
    BEQ droid_loop
    CMP #$40                        ; %01000000 - Head segment (left or right)
    BEQ droid_head
    LDA droidStatusArray - $01,X
    ORA #$80                        ; %10000000 - Tail segment
    STA droidStatusArray - $01,X
    JMP droid_loop
    ; Return

.droid_head
    LDA droidStatusArray + $01,X
    ORA droidStatusArray,X
    STA droidStatusArray + $01,X
    JMP droid_loop
    ; Return
}

;-------------------------------------------------------------------------
; FindDroid
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A contains either gridCharacter , #DROID or #LEADER1
;           : X contains index into array
;-------------------------------------------------------------------------
.FindDroid
{
    LDX #DROID_SIZE
.loop
    LDA droidXPositionArray,X
    CMP currentXPosition
    BNE skip
    LDA droidYPositionArray,X
    CMP currentYPosition
    BNE skip

    ; Droid found - but which part of it
    LDA droidStatusArray,X
    AND #$40                    ; %01000000 - Head segment (left or right)
    BEQ segment_found           ; Result == 0 then Z = 1, so branch if not head
    
    LDA #LEADER1
    RTS
    ; Return

.segment_found
    LDA #DROID
    ;JSR BCDtoScreen
    RTS
    ; Return

.skip
    DEX
    BNE loop
    LDA gridCharacter  ; Default to Grid        
    RTS
}

;-------------------------------------------------------------------------


