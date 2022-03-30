;-------------------------------------------------------------------------
; Matrix: Gridrunner 2
;-------------------------------------------------------------------------
; BBC Conversion Shaun Lindsley
; Thanks to Jef Minter for producing an excellent game for the VIC20

\ Memory space
\ &0000-&008F Language workspace            - Can be used
\ &008F-&00FF - ????
\ &0100-&01FF 6502 Stack                    - *** Don't use ***
\ &0200-&02FF OS Workspace                  - *** Don't use ***
\ &0300-&03FF OS Workspace                  - *** Don't use ***

\ &0400-&04FF Basic workspace               - Can be used
\ &0500-&05FF Basic workspace               - Can be used
\ &0600-&06FF String buffer                 - Can be used
\ &0700-&07FF Line input buffer             - Can be used

\ &0800-&08FF Sound workspace               - *** don't use as sound is required, if I can work out vic and c64 sound ***
\ &0900-&09BF Envelopes 5-16                - Can be used if we only used enveloped below 5

\ &09C0-&09FF Speech buffer                 - Can be used
\ &0A00-&0AFF RS423 or Cassette buffer      - Can be used
\ &0B00-&0BFF SoftKey (Function Keys)       - Can be used

\ &0C00-&0CFF Chacter Defination 128-159    - Can be used
\ &0D00-&0DFF OS Workspace                  - *** Don't use ***
\ &0E00-&0EFF 
\ &0F00-&0FFF
\ &1000-&10FF

; Use following for vsync debugging
; LDA #&00: STA &FE21 ;white
; LDA #&01: STA &FE21 ;cyan
; LDA #&02: STA &FE21 ;magenta 
; LDA #&03: STA &FE21 ;blue 
; LDA #&04: STA &FE21 ;yellow
; LDA #&05: STA &FE21 ;green
; LDA #&06: STA &FE21 ;red
; LDA #&07: STA &FE21 ;black

; Defines
MAPCHAR '0','9',0
MAPCHAR 'A','Z',10
MAPCHAR ' ',36
MAPCHAR '.',37          ; fullstop
MAPCHAR ',',38          ; comma
MAPCHAR '!',39          ; Exclamation Mark
MAPCHAR '@',40          ; Copyright
MAPCHAR '^',41          ; Ship

MAPCHAR 'm',42
MAPCHAR 'a',43
MAPCHAR 't',44
MAPCHAR 'r',45
MAPCHAR 'i',46
MAPCHAR 'x',47

MAPCHAR '_',48          ; Matrix Title Line

MAPCHAR '/',49          ; Explosion 1 ?
MAPCHAR '\',50          ; Explosion 2 ?
MAPCHAR '(',51          ; Explosion 3 ?

OSRDCH = &FFE0
OSASCI = &FFE3
OSWRCH = &FFEE
OSWORD = &FFF1
OSBYTE = &FFF4
OSCLI  = &FFF7

; Font Colours
BLACK       = $00
RED         = $03
GREEN       = $0C
YELLOW      = $0F
BLUE        = $30
MAGENTA     = $33
CYAN        = $3C
WHITE       = $3F

; Frame rates
SHIP_FRAME_RATE             = $02
BULLET_FRAME_RATE           = $01
DROID_FRAME_RATE            = $03
ZAPPER_FRAME_RATE           = $0A
LASER_AND_POD_FRAME_RATE    = $0B
DROID_TIMER                 = $20
BOMB_FRAME_RATE             = $01

MIN_X               = 0;1    
MIN_Y               = 0;2
MAX_X               = 19;20
MAX_Y               = 31;29

GRID_MIN_X          = MIN_X+1
GRID_MAX_X          = MAX_X;-1
GRID_MIN_Y          = MIN_Y+3;+1
GRID_MAX_Y          = MAX_Y-2;-1

SHIP_MIN_Y          = GRID_MIN_Y+5;MIN_Y+7       ; How far ship can travel up the grid
SHIP_MAX_Y          = GRID_MAX_Y-1;MAX_Y-1
SHIP_START_X        = (MAX_X+1) / 2     ; Used for Ship start x position

ZAPPER_LEFT_X       = MIN_X             ; Static
ZAPPER_LEFT_MIN_X   = MIN_X         ; Left zapper min x pos
ZAPPER_LEFT_MIN_Y   = GRID_MIN_Y
ZAPPER_LEFT_MAX_Y   = GRID_MAX_Y;MAX_Y-1

ZAPPER_BOTM_Y       = GRID_MAX_Y;GRID_MAX_Y+1;MAX_Y         ; Static
ZAPPER_BOTM_MIN_X   = GRID_MIN_X;MIN_X
ZAPPER_BOTM_MAX_X   = GRID_MAX_X+1;MAX_X

LASER_MAX_X         = GRID_MAX_X;MAX_X
LASER_MAX_Y         = GRID_MAX_Y;MAX_Y
LASER_FIRE_Y        = ZAPPER_BOTM_Y-1

BOMB_MAX_Y          = GRID_MAX_Y ;MAX_Y         ; How far down can the bomb go

DROID_MIN_X         = GRID_MIN_X-1
DROID_MIN_Y         = GRID_MIN_Y
DROID_MAX_X         = GRID_MAX_X+1        ; Currently not used ??
DROID_MAX_Y         = GRID_MAX_Y-1         ; How far down can the droid go
;DROIDYR             = MAX_Y-11      ; Droid row restart after getting to end of grid

; Key codes
keyCodeESCAPE       = &8F           ; Escape
keyCodeRETURN       = &B6           ; Fire
keyCodeZ            = &9E           ; Left
keyCodeX            = &BD           ; Right
keyCodeColon        = &B7           ; Up
keyCodeForwardSlash = &97           ; Down
keyCodeP            = &C8           ; Pause Key
keyCodeS            = &AE           ; Sound Key
keyCodeJ            = &BA           ; Joystick Key

; Sprite index
SPACE               = 0     ; 00
GRID                = 1     ; 01
DOTS                = 2     ; 02
LEFT_ZAPPER         = 3     ; 03
BOTTOM_ZAPPER       = 4     ; 04
HORIZ_LASER1        = 5     ; 05
HORIZ_LASER2        = 6     ; 06
VERTICAL_LASER1     = 7     ; 07
VERTICAL_LASER2     = 8     ; 08
SHIP                = 9     ; 09
BULLET_UP           = 10    ; 0A
BULLET_DOWN         = 11    ; 0B
BULLET_LEFT         = 12    ; 0C
BULLET_RIGHT        = 13    ; 0D
POD1                = 14    ; 0E
POD2                = 15    ; 0F
POD3                = 16    ; 10
POD4                = 17    ; 11
POD5                = 18    ; 12
POD6                = 19    ; 13
BOMB_DOWN           = 20    ; 14

EXPLOSION1          = 21 ; 15
EXPLOSION2          = 22 ; 16
EXPLOSION3          = 23 ; 17

LEADER1             = 24 ; 18
LEADER2             = 25 ; 19
LEADER3             = 26 ; 1A
LEADER4             = 27 ; 1B
DROID               = 28 ; 1C

SNITCH_RIGHT1       = 29 ; 1D
SNITCH_RIGHT2       = 30 ; 1E
SNITCH_LEFT1        = 31 ; 1F
SNITCH_LEFT2        = 32 ; 20
SNITCH_WAVE1        = 33 ; 21
SNITCH_WAVE2        = 34 ; 22

SOUND_ON            = 35 ; 23
SOUND_OFF           = 36 ; 24
PAUSE_ICON          = 37 ; 25
JOYSTICK_ICON       = 38 ; 26
CAMELOID_RIGHT      = 39 ; 27
CAMELOID_LEFT       = 40 ; 28
DEFLECTOR1          = 41 ; 29
DEFLECTOR2          = 42 ; 2A
DEFLECTOR3          = 43 ;
BONUS1              = 44 ;
BONUS2              = 45 ;

; Define some zp locations
ORG 0

.currentCharacter               SKIP 1   
.currentXPosition               SKIP 1
.currentYPosition               SKIP 1
.shipLives                      SKIP 1
                            
.XOrd                           SKIP 1     
.YOrd                           SKIP 1    
                            
.currentExplosionCharacter      SKIP 1  
.materializeShipOffset          SKIP 1

.shipXPosition                  SKIP 1
.shipYPosition                  SKIP 1
.shipAnimationFrameRate         SKIP 1
                            
.bulletAndLaserFrameRate        SKIP 1
.bulletXPosition                SKIP 1
.bulletYPosition                SKIP 1
.bulletCharacter                SKIP 1
.bulletType                     SKIP 1                          

.zapperFrameRate                SKIP 1
.leftZapperYPosition            SKIP 1
.bottomZapperXPosition          SKIP 1
.laserAndPodInterval            SKIP 1
.laserShootInterval             SKIP 1
.laserCurrentCharacter          SKIP 1
.leftLaserXPosition             SKIP 1
.leftLaserYPosition             SKIP 1
.bottomLaserXPosition           SKIP 1
.bottomLaserYPosition           SKIP 1
.laserFrameRate                 SKIP 1

.PodInterval                    SKIP 1

.currentDroidCharacter          SKIP 1
.noOfDroidSquadsCurrentLevel    SKIP 1
.currentDroidIndex              SKIP 1
.droidsLeftToKill               SKIP 1
.droidFrameRate                 SKIP 1
.droidTimer                     SKIP 1
.droidParts                     SKIP 1
.sizeOfDroidSquadForLevel       SKIP 1

.selectedLevel                  SKIP 1

.chrFontColour                  SKIP 1
.chrFontAddr                    SKIP 2 ; (&FFFF)
.text_addr                      SKIP 2 ; (&FFFF)
                                                 
.pauseFlag                      SKIP 1
.soundFlag                      SKIP 1  
.joystickFlag                   SKIP 1 
.specialdelay_counter1          SKIP 1

; Score 0000000 - 4 bytes for the BCD score
.score1                         SKIP 1  ; 00
.score2                         SKIP 1  ; 00
.score3                         SKIP 1  ; 00
.score4                         SKIP 1  ; 0                  
.high_score                     SKIP 4 ; Hiscore 0000000
                                                         
.gridCharacter                  SKIP 1
.gridOldColour                  SKIP 1
.gridNewColour                  SKIP 1          
.gridFrameRate                  SKIP 1
.gridFrameRateMax               SKIP 1   

.snitchFrameRate                SKIP 1
.snitchFrameRateLevel           SKIP 1
.snitchXPosition                SKIP 1
.snitchYPosition                SKIP 1
.snitchControl                  SKIP 1 
                        
.temp                           SKIP 1
.temp2                          SKIP 1
.temp3                          SKIP 1
                             
.delay_counter1                 SKIP 1
.delay_counter2                 SKIP 1
                            
.saveX                          SKIP 1 ; instead of stack
.saveY                          SKIP 1 ; instead of stack
.saveA                          SKIP 1 ; instead of stack
.write_addr                     SKIP 2 ; (&FFFF)

.source_addr                    SKIP 2 ; (&FFFF)
.dest_addr                      SKIP 2 ; (&FFFF)
.blocks_to_copy                 SKIP 1
.scrolltext_offset              SKIP 1
                            

.deflexorFrameRate              SKIP 1
.deflexorIndexForLevel          SKIP 1
.currentDeflexorIndex           SKIP 1
.animateRedColour               SKIP 1

.cameloidAnimationInteveralForLevel SKIP 1
.currentCameloidAnimationInterval   SKIP 1
.originalNoOfDronesInDroidSquadInCurrentLevel SKIP 1
.cameloidsTimer                 SKIP 1
.cameloidsLeft                  SKIP 1
.cameloidsTimerReset            SKIP 1
.currentCameloidsLeft           SKIP 1

.bonusBits                      SKIP 1

; Remove one live
.debugA                         SKIP 1
.debugX                         SKIP 1
.debugY                         SKIP 1
.debugXPos                      SKIP 1
.debugYPos                      SKIP 1
.debugChar                      SKIP 1

.end_of_ZP

ORG &0400

; Max 40 pods and/or bombs at each x,y coords use podArray to store
podArrayXPos = &0400            ; 0400-0427
podArrayYPos = &0428            ; 0428-0449
podArrayChar = &0450            ; 0450-0477

; Delfexor array &28
currentDeflexorXPosArray    = &0480     ; 0480-049F
currentDeflexorYPosArray    = &04A8     ; 04A0-04BF
currentDeflexorStatusArray  = &04D0     ; 04C0-04DF

; max droids is 13 * 3 = 39 = &27
ORG &0500
; Droid array 255 bytes $FF could use &55 and fit into 1 page?
droidXPositionArray         = &0500     ; 0500-05FF
droidYPositionArray         = &0600     ; 0600-06FF
droidStatusArray            = &0700     ; 0700-07FF

ORG &0A00 
cameloidsCurrentXPosArray   = &0A00     ; 0A00-0A7F
cameloidsCurrentYPosArray   = &0A80     ; 0A80-0AFF
cameloidsColorArray         = &0B00     ; 0B00-0B80

; Ship explosion array 8 bytes for each x and y coords
explosionXPosArray          = &B800     ; 04E0-04E7
explosionYPosArray          = &B810     ; 04F0-04F7


ORG &1100
GUARD &3000

.start

;-------------------------------------------------------------------------
; Initialise
;-------------------------------------------------------------------------
.Initialise

    ; wipe zero page
    LDA #0
    LDX #$FF
.zp_loop
    STA 0,X
    DEX
    BNE zp_loop

    ; switch to mode 2 and initialise
    LDX #0   
.init_loop
    LDA setup_screen,X
    JSR OSWRCH
    INX
    CPX #60
    BNE init_loop

    ; Turn off Auto Repeat vsync_delay ?
    LDX #0
    LDA #$0B
    JSR OSBYTE
    
    LDA #$80                ; %10000000 - set bit 7 to 1
    STA pauseFlag           ; NB
    STA soundFlag           ; Use BMI if bit 7 is 1
    STA joystickFlag        ; Use BPL if bit 7 is 0

    LDA #15                 ; Countdown timer for pressing special keys
    STA specialdelay_counter1

    LDA #8
    STA gridOldColour
    LDA #10
    STA gridNewColour

;-------------------------------------------------------------------------
; TitleScreen
;-------------------------------------------------------------------------
.TitleScreen
{
    ; Reset level
    LDA #1
    STA selectedLevel 

    ; Reset ship lives
    LDA #5
    STA shipLives

    JSR DisplayHUD
    JSR DisplayTitleScreen
    JSR UpdateLevelSelector

.restart_scrolltext
 
    LDA #ScrollingText MOD 256 : STA text_addr
    LDA #ScrollingText DIV 256 : STA text_addr+1

    LDY #0                                          
    STY scrolltext_offset                           

.title_screen_loop

    LDX #19
    LDY #20
    JSR setTextPos

    LDA #WHITE
    STA chrFontColour
    
    LDY scrolltext_offset
    LDA (text_addr),Y
    BMI restart_scrolltext
    TAX
    JSR PrintChar

    JSR AnimateScrollingText
    JSR AnimateScrollingText
    JSR AnimateScrollingText    
    JSR AnimateScrollingText

    INC scrolltext_offset

.Check_key_up
    LDX #keyCodeColon
    JSR isKeyPressed
    BNE Check_key_down
    LDA selectedLevel
    CMP #$20
    BEQ title_screen_loop
    SED
    ADC #1
    STA selectedLevel
    CLD
    JSR UpdateLevelSelector

.Check_key_down
    LDX #keyCodeForwardSlash
    JSR isKeyPressed
    BNE Check_fire
    LDA selectedLevel
    CMP #$01
    BEQ title_screen_loop
    SED
    SBC #1
    STA selectedLevel
    CLD
    JSR UpdateLevelSelector

.Check_fire    
    LDX #keyCodeRETURN
    JSR isKeyPressed
    BNE title_screen_loop

    ; Reset Score
    LDA #0
    STA score1
    STA score2
    STA score3
    STA score4

    JSR Cascade
    JSR ResetLevel
    JMP TitleScreen
}

.ScrollingText
EQUS "IN THE TEN YEARS AFTER THE GRID WARS, INTERGALACTIC TENSION INCREASED"
EQUS " UNTIL THE FEARS OF MANKIND WHERE REALISED AND THE DROIDS RETURNED WITH"
EQUS " SUPERIOR WEAPONRY TO ATTACK THE GRID.... CAN YOU FREE ALL TWENTY GRID"
EQUS " SECTORS OR BE BLASTERED TO ALIEN HELL......", $FF

;-------------------------------------------------------------------------
; UpdateLevelSelector
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.UpdateLevelSelector
{
    LDA #MAGENTA
    STA chrFontColour
  
    LDX #16
    LDY #16
    JSR setTextPos
    LDA selectedLevel
    JMP BCDtoScreen
}

;-------------------------------------------------------------------------
; ResetLevel
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.ResetLevel    

    DEC selectedLevel
    JSR InitialiseLevel
    INC selectedLevel

    LDA #CYAN
    STA chrFontColour
 
    LDX #19
    LDY #0
    JSR setTextPos
    LDA shipLives
    JSR BCDtoScreenOneChar

    JSR DisplayEnterZone

    JSR DrawDeflexor

    ; Drop through to game loop

;-------------------------------------------------------------------------
; MainLoop - Game
;-------------------------------------------------------------------------
.MainLoop
    JSR CheckSpecialKeys

    JSR AnimateGrid
    JSR AnimateRedColour

    JSR UpdateShip
    JSR UpdateBullet
    JSR UpdateZappers
    JSR AnimateSnitch
    ;JSR DrawLaser
    ;JSR UpdateBombs
    ;JSR UpdatePods
    
    ;JSR AnimateCameloid
    JSR DrawDroids
    JSR DrawDeflexor
    
    LDA #1
    JSR vsync_delay
    JSR CheckLevelComplete

    ; Keys function?
    ; Quit pressed
    BIT joystickFlag
    BPL joystick_in_use

    LDX #keyCodeESCAPE
    JSR isKeyPressed
    BNE MainLoop
    RTS

.joystick_in_use
    JSR isJoystickPressed
    BCC MainLoop
    RTS

;-------------------------------------------------------------------------
; DisplayHUD
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DisplayHUD
{   
    LDA #CYAN
    STA chrFontColour

    LDX #0
    LDY #0
    LDA #MatrixLogo MOD 256:STA text_addr
    LDA #MatrixLogo DIV 256:STA text_addr+1
    JSR PrintString 

    LDX #19
    LDY #0
    JSR setTextPos
    LDA shipLives
    JSR BCDtoScreenOneChar
    
    LDA #GREEN
    STA chrFontColour
  
    LDX #17
    LDY #0
    LDA #MatrixShip MOD 256:STA text_addr
    LDA #MatrixShip DIV 256:STA text_addr+1
    JSR PrintString

    JSR AnimateMatrixTitle

    JMP PrintScore
    ; Return 
}

;-------------------------------------------------------------------------
; AnimateMatrixTitle
;-------------------------------------------------------------------------
.AnimateMatrixTitle
{
    CLC
    LDA matrix_title_line + $0001
    ROL A
    ADC #$00
    STA matrix_title_line + $0001

    LDA #MAGENTA
    STA chrFontColour
    LDX #0
    LDY #1
    LDA #MatrixLogoAnimate MOD 256:STA text_addr
    LDA #MatrixLogoAnimate DIV 256:STA text_addr+1
    JMP PrintString 
}

;-------------------------------------------------------------------------
; DisplayTitle
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DisplayTitleScreen
{
    JSR ClearScreen

    ; Set colour red back to red
    LDX #1
    LDY #1
    JSR DefineColour

    LDA #CYAN
    STA chrFontColour
 
    LDX #2
    LDY #5
    LDA #DesignText MOD 256:STA text_addr
    LDA #DesignerText DIV 256:STA text_addr+1
    JSR PrintString

    LDX #3
    LDY #9
    LDA #ConversionText MOD 256:STA text_addr
    LDA #ConversionText DIV 256:STA text_addr+1
    JSR PrintString

    LDX #0
    LDY #14
    LDA #PressFireText MOD 256:STA text_addr
    LDA #PressFireText DIV 256:STA text_addr+1
    JSR PrintString

    LDA #MAGENTA
    STA chrFontColour

    LDX #2
    LDY #16
    LDA #SelectLevelText MOD 256:STA text_addr
    LDA #SelectLevelText DIV 256:STA text_addr+1
    JSR PrintString

    LDX #1
    LDY #24
    LDA #HighScoreText MOD 256:STA text_addr
    LDA #HighScoreText DIV 256:STA text_addr+1
    JSR PrintString

    LDA #YELLOW
    STA chrFontColour
    
    LDX #4
    LDY #7
    LDA #DesignerText MOD 256:STA text_addr
    LDA #DesignerText DIV 256:STA text_addr+1
    JSR PrintString

    LDX #3
    LDY #11
    LDA #CodingText MOD 256:STA text_addr
    LDA #CodingText DIV 256:STA text_addr+1
    JSR PrintString

    JMP PrintHighScore
    ; Return
}

;-------------------------------------------------------------------------
; CheckLevelComplete
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.CheckLevelComplete
{
    LDA droidsLeftToKill
    BNE not_complete
    LDA noOfDroidSquadsCurrentLevel
    BNE not_complete
    
    LDA cameloidsLeft
    BNE not_complete
    LDA currentCameloidsLeft
    BNE not_complete

    INC selectedLevel

    LDA selectedLevel
    CMP #20                     ; 20 levels only - (selected level is zero based)
    BNE skip_level_update 
    DEC selectedLevel

.skip_level_update

    INC shipLives

    LDA shipLives
    CMP #10                     ; 9 lives only
    BNE skip_lives_update 
    DEC selectedLevel

.skip_lives_update

    ; Reset Red colour
    LDX #1
    LDY #1
    JSR DefineColour

    JSR ZoneCleared
    
    JMP ResetLevel

.not_complete
    RTS
}

;-------------------------------------------------------------------------
; ZoneCleared
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------

.ZoneCleared
{
    JSR ClearScreen

    LDA #0
    STA temp2                   ; Colour number
    
.zone_colour_loop

    LDA #$04
    STA currentYPosition

.zone_loop
    
    LDA temp2                   
    AND #$07
    TAY
    LDA ColourEffects,Y
    STA chrFontColour

    LDX #04
    LDY currentYPosition
    LDA #ZoneClearedText MOD 256 : STA text_addr
    LDA #ZoneClearedText DIV 256 : STA text_addr+1
    JSR PrintString 

    INC temp2
    INC currentYPosition
    LDA currentYPosition
    CMP #$0B
    BNE zone_loop

    LDA temp2
    AND #$C0                    ; %11000000
    CMP #$C0
    BNE zone_colour_loop
    RTS
}

;-------------------------------------------------------------------------
; GotYou
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.GotYou
{
    JSR ClearScreen

    LDA #CYAN
    STA chrFontColour

    LDX #06
    LDY #10
    LDA #GotYouText MOD 256 : STA text_addr
    LDA #GotYouText DIV 256 : STA text_addr+1
    JSR PrintString 

    LDA #$80
    JSR vsync_delay

    JMP ResetLevel
    ; Return
}    

;-------------------------------------------------------------------------
; GameOver
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.GameOver
{
    JSR ClearScreen

    LDA #YELLOW
    STA chrFontColour

    LDX #05
    LDY #10
    LDA #GameOverText MOD 256:STA text_addr
    LDA #GameOverText DIV 256:STA text_addr+1
    JSR PrintString 

    JSR CheckHighScore
    
    LDA #$80
    JSR vsync_delay

    JMP TitleScreen
    ; Return
}

;-------------------------------------------------------------------------
; Cascade
;-------------------------------------------------------------------------
; Only appears when the game is started and not every level
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.Cascade
{
    JSR ClearScreen

    ; These never change
    LDA #4  : STA XOrd          ; Character Pos 1
 
    LDA #26        
    STA currentYPosition
      
.cascade_loop
    ; Wait for horizontal blank
    LDA #19     
    JSR OSBYTE

    LDA #8                          ; 8 rows to a column
    STA temp2

    LDA #27 
    SEC
    SBC currentYPosition                 ; 25-24 = 1, then 25-23 = 2... etc
    STA temp3

.animate
    
    JSR GridLines

    DEC temp2
    BNE animate
    DEC currentYPosition
    BNE cascade_loop

    RTS
}

;-------------------------------------------------------------------------
; GridLines
;-------------------------------------------------------------------------
.GridLines
{
    LDY temp3
    LDX #6                          ; Start colour blue

.line_loop

    TYA
    ASL A
    ASL A
    ASL A                           ; Convert to YOrd format 0-255
    ADC #24                         ; Start on on row 4
    
    SBC temp2
    STA YOrd
   
    LDA CascadeEffects, X
    STA chrFontColour

    ; X an Y get destroyed on DrawHorizontalLine
    STX saveX
    STY saveY

    JSR DrawHorizontalLine

    ; Erase line behind it
    DEC YOrd
    LDA #BLACK : STA chrFontColour
    JSR DrawHorizontalLine
    LDX saveX
    LDY saveY

    DEX
    BPL next_colour
    ; Reset colour to blue
    LDX #6

.next_colour
   
    DEY
    BNE line_loop
    RTS
}

;-------------------------------------------------------------------------
; DrawHorizontalLine
;-------------------------------------------------------------------------
; On entry  : XOrd = 0-79, yOrd = 0-255
; On exit   : A, X and Y are underfined
;-------------------------------------------------------------------------
.DrawHorizontalLine 
{   
    JSR GetScreenAddress
 
    LDX #19 ; number of columns
    
.pixel_loop
    LDA chrFontColour

    LDY #0  :STA (write_addr),Y
    LDY #8  :STA (write_addr),Y
    LDY #16 :STA (write_addr),Y
    LDY #24 :STA (write_addr),Y
    
	LDA	write_addr
	ADC	#32
	STA	write_addr
	BCC	samehiaddr
	INC	write_addr + 1
	CLC

.samehiaddr
    DEX             
    BNE pixel_loop

    RTS
}


;-------------------------------------------------------------------------
; DisplayEnterZone
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DisplayEnterZone
{
    JSR DrawGrid

    LDA #WHITE
    STA chrFontColour

    LDX #3
    LDY #14
    LDA #EnterZoneBlank MOD 256: STA text_addr
    LDA #EnterZoneBlank DIV 256: STA text_addr+1
    JSR PrintString

    LDX #3
    LDY #15
    LDA #EnterZoneText MOD 256: STA text_addr
    LDA #EnterZoneText DIV 256: STA text_addr+1
    JSR PrintString

    LDX #15
    LDY #15
    JSR setTextPos

    LDA selectedLevel
    JSR BCDtoScreen

    LDX #3
    LDY #16
    LDA #EnterZoneBlank MOD 256: STA text_addr
    LDA #EnterZoneBlank DIV 256: STA text_addr+1
    JSR PrintString

    ; Fast grid animation
    LDA #$01
    STA gridFrameRate
    STA gridFrameRateMax

    LDA #$FF
    STA delay_counter2

.gridloop
    JSR AnimateGrid
    LDA #$01
    JSR vsync_delay
    DEC delay_counter2
    BNE gridloop

    ; Remove Enter zone
    JSR DrawGridOverEnterZone

    LDA #$02
    STA gridFrameRate
    STA gridFrameRateMax

    JMP MaterializeShip
    ; Return
}

;-------------------------------------------------------------------------
; InitialiseLevel
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.InitialiseLevel
{
    LDX selectedLevel

    LDA GridLevel,X
    STA gridCharacter

    LDA noOfDroidSquadsForLevel,X
    STA droidsLeftToKill

    LDA sizeOfDroidSquadsForLevels,X
    STA sizeOfDroidSquadForLevel

    LDA laserFrameRateForLevel,X
    STA laserFrameRate

    LDA noOfCameloidsForLevel,X
    STA cameloidsLeft

    LDA noOfCameloidsTimerLevel,X
    STA cameloidsTimerReset
    STA cameloidsTimer

    LDA deflexorIndexArrayForLevel,X
    STA deflexorIndexForLevel

    LDA cameloidSpeedForLevel,X
    STA currentCameloidAnimationInterval
    STA cameloidAnimationInteveralForLevel    

; Init Ship
    LDA #SHIP_FRAME_RATE
    STA shipAnimationFrameRate

    LDA #DROID_FRAME_RATE
    STA droidFrameRate

    LDA #BULLET_FRAME_RATE
    STA bulletAndLaserFrameRate

    ; Init Snitch
    
    LDA snitchSpeedForLevel,X
    STA snitchFrameRate
    STA snitchFrameRateLevel
    
    LDA #4
    STA snitchXPosition
    LDA #16
    STA snitchYPosition

    ; Init Zappers
    LDA #ZAPPER_FRAME_RATE
    STA zapperFrameRate

    LDA #ZAPPER_BOTM_MIN_X
    STA bottomZapperXPosition
    LDA #ZAPPER_LEFT_MIN_Y
    STA leftZapperYPosition

    LDA #LASER_AND_POD_FRAME_RATE
    STA laserAndPodInterval
    STA laserShootInterval

    LDA #$00
    STA snitchControl
    STA droidParts
    STA noOfDroidSquadsCurrentLevel
    
    LDA #LEADER1
    STA currentDroidCharacter
    
    LDA #$01
    STA gridFrameRateMax
    STA droidTimer

    ;LDA sizeOfDroidSquadForLevel
    ;STA sizeOfDroidSquadForLevel
    
    ;LDA droidsLeftToKill 
    ;STA droidsLeftToKill

    
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
    
    JSR ClearPodArray
    JSR ClearDroidArray

    RTS
}

;-------------------------------------------------------------------------
; DrawNewLevel
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DrawNewLevelScreen
{
    JSR ClearScreen
    JSR DrawGrid

    LDX #3
    LDY #14
    LDA #EnterZoneBlank MOD 256: STA text_addr
    LDA #EnterZoneBlank DIV 256: STA text_addr+1
    JSR PrintString

    LDX #3
    LDY #15
    LDA #EnterZoneText MOD 256: STA text_addr
    LDA #EnterZoneText DIV 256: STA text_addr+1
    JSR PrintString

    LDX #15
    LDY #15
    LDA selectedLevel
    JSR BCDtoScreen

    LDX #3
    LDY #16
    LDA #EnterZoneBlank MOD 256: STA text_addr
    LDA #EnterZoneBlank DIV 256: STA text_addr+1
    JSR PrintString

    JMP MaterializeShip
    ; Return
    ;RTS
}

;-------------------------------------------------------------------------
; DrawGrid
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DrawGrid
{
    ; Draw Grid section
    LDA gridCharacter 
    STA currentCharacter

    LDY #GRID_MIN_Y
.draw_vertical_line_loop2    
    STY currentYPosition
    LDX #GRID_MIN_X;#1
.draw_horizontal_line_loop2
    STX currentXPosition
    JSR PlotCharSprite
    INX
    CPX #GRID_MAX_X+1;#MAX_X
    BNE draw_horizontal_line_loop2
    INY
    CPY #GRID_MAX_Y;#MAX_Y
    BNE draw_vertical_line_loop2
    RTS
}

;-------------------------------------------------------------------------
; DrawGridOverEnterZone
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DrawGridOverEnterZone
{
    ; Draw Grid section
    LDA gridCharacter 
    STA currentCharacter

    LDY #14
.draw_vertical_line_loop2    
    STY currentYPosition
    LDX #3
.draw_horizontal_line_loop2
    STX currentXPosition
    JSR PlotCharSprite
    INX
    CPX #18
    BNE draw_horizontal_line_loop2
    INY
    CPY #17
    BNE draw_vertical_line_loop2
    RTS
}

;-------------------------------------------------------------------------
; AnimateGrid
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.AnimateGrid
{
    DEC gridFrameRate
    BNE AnimateGridExit
 
    LDA gridFrameRateMax
    STA gridFrameRate

    LDX gridOldColour
    JSR Incdelay_counter1
    STX gridOldColour
    LDY #0
    JSR DefineColour

    LDX gridNewColour
    JSR Incdelay_counter1
    STX gridNewColour
    LDY #4
    JSR DefineColour

.AnimateGridExit
    RTS
}

;-------------------------------------------------------------------------
; AnimateRedColour
;-------------------------------------------------------------------------
; Colour 1 (Red) is used to cycle through the colour palete for the 
; deflexors and the bonus 106
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : 
;-------------------------------------------------------------------------
.AnimateRedColour
{
    INC animateRedColour
    LDA animateRedColour
    AND #$07
    TAY
    LDX #1
    JMP DefineColour
}


;-------------------------------------------------------------------------
; Incdelay_counter1
;-------------------------------------------------------------------------
.Incdelay_counter1
{
    INX
    CPX #16
    BNE Incdelay_counter1Exit
    LDX #8
    
.Incdelay_counter1Exit   
    RTS
}


include "ship.asm"
include "zappers.asm"
include "snitch.asm"
include "pods.asm"
include "bombs.asm"
include "droids.asm"
include "deflexors.asm"
include "cameloids.asm"
include "highscore.asm"
include "debug.asm"

;-------------------------------------------------------------------------
; AddScore100's
;-------------------------------------------------------------------------
; On entry  : A contains value
; On exit   : 
;-------------------------------------------------------------------------
.AddScore100
{
    SED
    CLC
    ADC score2
    JMP AddScore100s    ; Jump into AddScore10 instead to save on code
}

;-------------------------------------------------------------------------
; AddScore10's
;-------------------------------------------------------------------------
; On entry  : A contains value
; On exit   : 
;-------------------------------------------------------------------------
.AddScore10
{
    SED
    CLC
    ADC score1
    STA score1

    LDA score2
    ADC #$00
.^AddScore100s      ; Global label - called from AddScore100    
    STA score2

    LDA score3
    ADC #$00
    STA score3

    LDA score4
    ADC #$00
    STA score4
    CLD
    RTS
}

;-------------------------------------------------------------------------
; ClearScreen
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A and X are underfined
;-------------------------------------------------------------------------
.ClearScreen
{
    LDX #6
.loop
    LDA mode2_clear_grid,X
    JSR OSWRCH
    DEX
    BPL loop
    RTS
}

;-------------------------------------------------------------------------
; CalcXYCharAddress
;-------------------------------------------------------------------------
; 8x8 Character based address calculation only
;-------------------------------------------------------------------------
; On entry  : currentXPos = 0-20, currentYPos = 0-31
; On exit   : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------
.CalcXYCharAddress
{
    LDA currentXPosition
    ASL A
    ASL A
    STA XOrd

    LDA currentYPosition
    ASL A
    ASL A
    ASL A
    STA YOrd
    
    JMP GetScreenAddress
}

;-------------------------------------------------------------------------
; GetScreenAddress
;-------------------------------------------------------------------------
; 8x8 Character based address calculation only
;-------------------------------------------------------------------------
; On entry  : XOrd = 0-79, yOrd = 0-255
; On exit   : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------

.GetScreenAddress
{
    TYA
    PHA

    LDA YOrd
    AND #248
    LSR A
    LSR A
    TAY

    LDA LookUp640,  Y   : STA write_addr
    LDA LookUp640 + 1,Y : STA write_addr + 1

    LDA YOrd
    AND #7
    ADC write_addr
    STA write_addr

    LDA #$30                    ; Mode 2 Base screen location MSB
    ADC write_addr + 1
    STA write_addr + 1

    LDA #0
    STA temp
    LDA XOrd
    ASL A                       ; A = A * 2     
    ASL A                       ; A = A * 4     
    ROL temp                    ; Save carry
    ASL A                       ; A = A * 16    
    ROL temp                    ; Save carry
   
    ADC write_addr
    STA write_addr
    LDA temp
    ADC write_addr + 1
    STA write_addr + 1

    PLA
    TAY
    RTS
}

;-------------------------------------------------------------------------
; PlotCharSprite
;-------------------------------------------------------------------------
; This plots an 8x8 sprite at character position X,Y
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------
.PlotCharSprite
{
    LDA currentXPosition
    ASL A
    ASL A
    STA XOrd

    LDA currentYPosition
    ASL A
    ASL A
    ASL A
    STA YOrd

    JMP PlotSprite
}


;-------------------------------------------------------------------------
; PlotSprite
;-------------------------------------------------------------------------
; This plots an 8x8 sprite at screen coords X,Y
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------
.PlotSprite
{
    TXA
    PHA

    JSR GetScreenAddress                   ; Screen address is stored in write_addr

    LDA write_addr:STA sprite_write+1
    LDA write_addr+1:STA sprite_write+2

    LDA currentCharacter
    ASL A                                   ; A = A * 2 (2 bytes for address)
    
    TAX
    LDA sprlist,X: STA sprite_read+1
    LDA sprlist+1,X: STA sprite_read+2

    LDX #31                                 ; game sprites are always 8x8 (Mode 2 are 4 bits * 8 bits => 0-31)
.sprite_read    
    LDA $FFFF,X
    ;BEQ ignore_black

.sprite_write    
    STA $FFFF,X

;.ignore_black    
    DEX
    BPL sprite_read
    PLA
    TAX
    RTS
}

;-------------------------------------------------------------------------
; PlotSpriteEOR
;-------------------------------------------------------------------------
; This plots an 8x8 sprite at screen coords X,Y
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------
;.PlotSpriteEOR
;{
;    STX saveX
;    STY saveY
   
;    LDA width
;    LSR A
;    STA width

;    LDA currentCharacter
;    ASL A   ; A = A * 2 (2 bytes for address)
;    TAX
;    LDA sprlist,X: STA sprite_read+1
;    LDA sprlist+1,X: STA sprite_read+2

;    LDA currentXPosition
;    sta XOrd
  
;    LDA currentYPosition
;    sec
;    sbc #1
;    clc
;    adc height  ; but only to nearest character row start
;    sta YOrd
;    and #7     ; put low order bits in X  for index addressing
;    tax     
;    sta XStartOffset ; preserve this for use later
;    lda YOrd      ; then store the other bits 3-7 in YOrd to get screen address of nearest character start row
;    and #248
;    sta YOrd
;    ;jsr ScreenStartAddress  
;    JSR GetScreenAddress ;CalcXYAddress               
;    ; now we've got the screen start address, and address of alien, lets plot it
;    lda write_addr ; put address in code below
;    sta sprite_write+1     
;    ;STA sprite_eor+1 
;    lda write_addr+1        
;    sta sprite_write+2
;    ;STA sprite_eor+2     
;    clc
   
;.PlotXLoop
;     ldy height 
;     dey  
;.PlotLoop   
;.sprite_read
;    lda $FFFF,Y     ;dummy address, will be filled in by code
;;.sprite_eor
;;    EOR $FFFF,X     ; dummy address, will be filled in by code
;.sprite_write
;    sta $FFFF,X     ; dummy address, will be filled in by code
;    ; are we at a boundary
;    dex                  
;    bpl NotAtRowBoundary   ;   no, so carry on
;    ;yes we moved to another character row, so we really want this to be the start of next screen row
;    sec                     ; we do this by adding &279 to value to get to next row
;    lda sprite_write+1
;    sbc #$80                   ; Offset is $01C0 for 28 character mode
;    ;SBC #LO(charRow)
;    sta sprite_write+1  
;    ;STA sprite_eor+1
;    lda sprite_write+2
;    sbc #2
;    ;SBC #HI(charRow)
;    sta sprite_write+2
;    ;STA sprite_eor+2   
;    ldx #7 ; reset X to 7 (bottom of this character row)

;.NotAtRowBoundary
;    dey
;    bpl PlotLoop    ; have we finished a full column, go to plot loop if not
;    dec width
;    beq EndPlotSprite   ; no more to plot, exit routine
;    ; move to next column
;    clc
;    lda sprite_read+1
;    adc height
;    sta sprite_read+1
;    lda sprite_read+2
;    adc #0  
;    sta sprite_read+2      
;    lda write_addr
;    clc
;    adc #8
;    sta write_addr
;    sta sprite_write+1  
;    ;STA sprite_eor+1
;    lda write_addr+1
;    adc #0                     
;    sta write_addr+1
;    sta sprite_write+2
;    ;STA sprite_eor+2 
;    ldx XStartOffset  
;    jmp PlotXLoop ;never zero so always branches

;.EndPlotSprite
 
;    LDY saveY
;    LDX saveX
;    rts
; }

;-------------------------------------------------------------------------
; GetChar
;-------------------------------------------------------------------------
; LDA #$87 : JSR OSBYTE - Too slow - don't ever use
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A contains sprite character index
;           : X may contain index into pod array
;-------------------------------------------------------------------------
.getChar 
{
    JSR FindShip
    CMP #SHIP
    BEQ found

    JSR FindDroid
    CMP gridCharacter 
    BNE found           ; Found droid

    JSR FindPod
    CMP gridCharacter 
    BNE found           ; Find Pod

    JSR FindDeflexor
    CMP gridCharacter
    BNE found           ; Found Deflexor

    ; A contains gridCharacter

.found
    RTS    
}   

;-------------------------------------------------------------------------
; PrintScore
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : X and Y are preserved
;-------------------------------------------------------------------------
.PrintScore
{
    TXA
    PHA
   
    LDA #YELLOW
    STA chrFontColour

    LDX #8
    LDY #0
    JSR setTextPos
 
    LDA score4
    JSR BCDtoScreenOneChar
    LDA score3
    JSR BCDtoScreen
    LDA score2
    JSR BCDtoScreen
    LDA score1
    JSR BCDtoScreen
    
    PLA
    TAX
    RTS
}

;-------------------------------------------------------------------------
; PrintHighScore
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : X and Y are preserved
;-------------------------------------------------------------------------
.PrintHighScore
{
    TXA
    PHA
  
    LDA #CYAN
    STA chrFontColour

    LDX #12
    LDY #24
    JSR setTextPos

    LDA high_score + 3
    JSR BCDtoScreenOneChar
    LDA high_score + 2
    JSR BCDtoScreen
    LDA high_score + 1
    JSR BCDtoScreen
    LDA high_score
    JSR BCDtoScreen
    
    PLA
    TAX
    RTS
}

;-------------------------------------------------------------------------
; BCDtoScreen
;-------------------------------------------------------------------------
; Used for displaying scores
;-------------------------------------------------------------------------
; On entry  : A contains value
; On exit   : A and X are underfined
;           : Y is preserved
;-------------------------------------------------------------------------
.BCDtoScreen
{
    PHA
    LSR A:LSR A:LSR A:LSR A
    JSR onedigit
    PLA
.*BCDtoScreenOneChar    ; Global label    
    AND #$0F
.onedigit    
    ;ORA #48
    ;JMP OSWRCH
    TAX
    JMP PrintChar
}

\\ returns rand in A C=? X=X Y=Y \\ period 256 seed any, this is what I currently use.
.Rand 
{
	lda selectedLevel ; 3
	asl a         ; 2
	asl a         ; 2
	clc           ; 2
	adc selectedLevel ; 3
	clc           ; 2
	adc #&45      ; 2
	sta selectedLevel ; 3
;	EOR &FE44
	rts           ; [b]19c 12b[/b] + rts
}

;-------------------------------------------------------------------------
; CheckSpecialKeys
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : 
;-------------------------------------------------------------------------
.CheckSpecialKeys
{
    LDA specialdelay_counter1
    DEC specialdelay_counter1
    BEQ start
    BNE exit
    
.start
    LDA #15
    STA specialdelay_counter1

    ; Sound On / Off
    LDX #keyCodeS
    JSR isKeyPressed
    BNE not_sound
    LDA soundFlag
    EOR #$80
    STA soundFlag

.not_sound
    ; Pause On / Off
    LDX #keyCodeP
    JSR isKeyPressed
    BNE not_pause
    LDA pauseFlag
    EOR #$80
    STA pauseFlag

.not_pause
    ; Keyboard / Joystick
    LDX #keyCodeJ
    JSR isKeyPressed
    BNE not_keyboard_joystick
    LDA joystickFlag
    EOR #$80
    STA joystickFlag

.not_keyboard_joystick
  
.exit
    JSR ShowSpecials

    ; if pause then loop back
    BIT pauseFlag
    BMI special_exit
    LDA #1
    JSR vsync_delay
    
    BIT pauseFlag
    BPL CheckSpecialKeys
    
.special_exit
    RTS
}

;-------------------------------------------------------------------------
; AnimateScrollingText
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : 
;-------------------------------------------------------------------------
.AnimateScrollingText
{
    LDA #03                                     ;
    JSR vsync_delay                             ;

    LDX #$61                                    ;
    STX dest_addr+1                             ;
    STX source_addr+1                         
    LDY #$F0                                    ; Target: $61F0 = $6100 - $10
    STY dest_addr                          
    LDA #$F8                                    ; Source: $61F8 = $6108 - $10
    STA source_addr                          
    LDY #$10                                    ;
    LDA #3                                      ; 3 blocks of $84
    STA blocks_to_copy                          ;
    LDX #$84                                    ;                

.scrolling_loop
    LDA (source_addr),Y                         ;
    STA (dest_addr),Y                           ;
    INY                                         ;
    BNE scroll_skip                             ;
    INC dest_addr+1                             ;
    INC source_addr+1                           ;

.scroll_skip
    DEX                                         ;
    BNE scrolling_loop                          ;
    DEC blocks_to_copy                          ;
    BNE scrolling_loop                          ;
    RTS                                
}

;-------------------------------------------------------------------------
; ShowSpecial
;-------------------------------------------------------------------------
; Display icons along the bottom right
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : 
;-------------------------------------------------------------------------
.ShowSpecials
{
    LDY #30
    STY currentYPosition

    ; Pause icon
    LDX #19
    STX currentXPosition
    LDA #PAUSE_ICON
    STA currentCharacter
    BIT pauseFlag
    BPL shows_pause_on

    LDA #SPACE
    STA currentCharacter

.shows_pause_on    
    JSR PlotCharSprite

    ; Sound icon
    LDX #18
    STX currentXPosition
    
    LDA #SOUND_ON
    STA currentCharacter

    BIT soundFlag
    BMI show_sound_on

    LDA #SOUND_OFF
    STA currentCharacter

.show_sound_on    
    JSR PlotCharSprite

    ; Joystick icon
    LDX #17
    STX currentXPosition
    LDA #JOYSTICK_ICON
    STA currentCharacter

    BIT joystickFlag
    BPL show_joysatick_on
    
    LDA #SPACE
    STA currentCharacter

.show_joysatick_on
    JSR PlotCharSprite

    RTS
}

;-------------------------------------------------------------------------
; IsKeyPressed
;-------------------------------------------------------------------------
; On entry  : X contains inkey value
; On exit   : A is preserved
;           : X contains key value
;           : Y is underfined
;-------------------------------------------------------------------------
.isKeyPressed
{
    LDA #$81
    LDY #$FF
    JSR OSBYTE
    CPX #$FF
    RTS
}

;-------------------------------------------------------------------------
; IsJoystickPressed
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : 
;-------------------------------------------------------------------------
.isJoystickPressed
{
    LDX #$00
    LDA #&80
    JSR OSBYTE
    TXA
    LSR A
    RTS
}

;-------------------------------------------------------------------------
; IsJoystickMoved1
;-------------------------------------------------------------------------
; On entry  : X contains
; On exit   : 
;-------------------------------------------------------------------------
.isJoystickMoved1
{
    LDA #&80
    JSR OSBYTE
    CPY #$25
    RTS
}

;-------------------------------------------------------------------------
; IsJoystickMoved2
;-------------------------------------------------------------------------
; On entry  : X contains 
; On exit   : 
;-------------------------------------------------------------------------
.isJoystickMoved2
{
    LDA #&80
    JSR OSBYTE
    CPY #$DB
    RTS
}

;-------------------------------------------------------------------------
; AnimateGrid
;-------------------------------------------------------------------------
; On entry  : X contains logical colour 
;           : Y contains primary colour
; On exit   : A is undefined
;           : X and y are preserved
;-------------------------------------------------------------------------

.DefineColour
{
    LDA #19
    JSR OSWRCH
    TXA
    JSR OSWRCH
    TYA
    JSR OSWRCH
    LDA #0
    JSR OSWRCH
    LDA #0
    JSR OSWRCH
    LDA #0
    JMP OSWRCH
}

;-------------------------------------------------------------------------
; SetTextPos
;-------------------------------------------------------------------------
; On entry  : X contains horizontal character position
;           : Y contains vertical character position
; On exit   : A is undefined
;           : X and y are preserved
;-------------------------------------------------------------------------
.setTextPos
{
    STX currentXPosition
    STY currentYPosition
    JMP CalcXYCharAddress 
}

;-------------------------------------------------------------------------
; PrintString
;-------------------------------------------------------------------------
; On entry  : X and Y contain character position
; On exit   : A,X and Y are undefined  
;-------------------------------------------------------------------------
.PrintString
{
    STX currentXPosition
    STY currentYPosition

    JSR CalcXYCharAddress   ; Screen address is stored in write_addr

    LDY #0
.loop
    LDA (text_addr),Y
    BMI finished
    TAX
    JSR PrintChar
    INY
    BNE loop
.finished    
    RTS   
}

;-------------------------------------------------------------------------
; PrintChar
;-------------------------------------------------------------------------
; On entry  : X contains font character
; On exit   : A and X are undefined
;           : Y is preserved
;-------------------------------------------------------------------------
.PrintChar
{
    STY saveY
    
    LDA #0
    STA temp            ; clear temp

    TXA                 ; Get font character
    CLC                 ; clear carry
    ASL A               ; *2
    ASL A               ; *4
    ASL A               ; *8
    ROL temp            ; Store carry in temp 
    STA chrFontAddr     ; 
    
    ADC #LO(font_data)  ;
    STA chrFontAddr     ; Calculate and store font offset low byte

    LDA #0
    ADC temp            ; Add temp
    ADC #HI(font_data)
    STA chrFontAddr+1   ; Calculate and store font offset high byte
    
    LDY #$07
    BNE displaychar

.nextPatternByte 
    TYA                                                 
    SBC #$21                                            
    BMI finish                                         
    TAY   

.displaychar
    LDA (chrFontAddr),Y     ; Point to font data
    STA currentCharacter    
    SEC

.iLoop
    LDA #0                                              
    ROL currentCharacter                              
    BEQ nextPatternByte                             
    ROL A                                             
    ASL currentCharacter                               
    ROL A                                              
    TAX                                               
    LDA ColourMask,X            
    AND chrFontColour 
    STA (write_addr),Y          
    CLC                                              
    TYA                                               
    ADC #8                                                                                           
    TAY                                               
    BCC iLoop 
    
.finish    
    ; Advance to next character position
    CLC
    LDA write_addr
    ADC #32
    STA write_addr
    BCC finish1
    ; Advance to next line position
    INC write_addr+1

.finish1
    
    LDY saveY
    RTS
}

;-------------------------------------------------------------------------
; PlotFont
;-------------------------------------------------------------------------
; On entry  : currentXPos, currentYPos, currentCharacter
; On exit   : X is preserved
;-------------------------------------------------------------------------

;.PlotFont
;{
;    TXA
;    PHA
    
;    JSR CalcXYCharAddress
    
;    LDX currentCharacter
;    JSR PrintChar

;    PLA
;    TAX
;    RTS
;}

;-------------------------------------------------------------------------
; PlaySound
;-------------------------------------------------------------------------
; On entry  : X and Y point to sound address
; On exit   : A contains 7
;-------------------------------------------------------------------------
.PlaySound
{
    BIT soundFlag
    BPL sound_exit
    LDA #$07
    JMP OSWORD

.sound_exit
    RTS
}

;-------------------------------------------------------------------------
; vsync_delay
;-------------------------------------------------------------------------
; On entry  : A contains duration
; On exit   : A contains 19   
;           : X and Y are underfined
;-------------------------------------------------------------------------
.vsync_delay
{
    STA delay_counter1
.vsync_delay_loop    
    LDA #19
    JSR OSBYTE

    DEC delay_counter1
    BNE vsync_delay_loop
    CLI
    RTS
}
;-------------------------------------------------------------------------

; Mode 2
.setup_screen
EQUB 22,2
EQUB 23,1,0,0,0,0,0,0,0,0
EQUB 19,8,4,0,0,0
EQUB 19,9,4,0,0,0
EQUB 19,10,0,0,0,0
EQUB 19,11,0,0,0,0
EQUB 19,12,0,0,0,0
EQUB 19,13,0,0,0,0
EQUB 19,14,0,0,0,0
EQUB 19,15,0,0,0,0

.mode2_clear_grid 
EQUB 26,12,2,19,30,0,28    ; VDU28,0,30,19,2:CLS:VDU26  NB:Reversed for speed

.MatrixLogo
EQUS "matrix",$FF

.MatrixLogoAnimate
EQUS "______", $FF

.MatrixShip
EQUS "^",$FF

.DesignText
EQUS "ORIGINAL  DESIGN", $FF

.DesignerText
EQUS "JEFF  MINTER",$FF

.ConversionText
EQUS "BBC CONVERSION",$FF

.CodingText
EQUS "SHAUN LINDSLEY",$FF

.PressFireText
EQUS "PRESS FIRE FOR START",$FF

.SelectLevelText
EQUS "SELECT LEVEL",$FF

.HighScoreText
EQUS "HIGHSCORE", $FF

.EnterZoneBlank
EQUS "               ",$FF

.EnterZoneText
EQUS " ENTER ZONE    ",$FF

.GotYouText
EQUS "GOT YOU!", $FF

.ZoneClearedText
EQUS "ZONE CLEARED", $FF

.GameOverText
EQUS "GAME  OVER", $FF

; Standard Mode 2 (20x32) character lookup table
.LookUp640
EQUB $00,$00,$80,$02,$00,$05,$80,$07,$00,$0A,$80,$0C,$00,$0F,$80,$11
EQUB $00,$14,$80,$16,$00,$19,$80,$1B,$00,$1E,$80,$20,$00,$23,$80,$25
EQUB $00,$28,$80,$2A,$00,$2D,$80,$2F,$00,$32,$80,$34,$00,$37,$80,$39
EQUB $00,$3C,$80,$3E,$00,$41,$80,$43,$00,$46,$80,$48,$00,$4B,$80,$4D

; Mode 2 Colour mask
.ColourMask
EQUB $00, $55, $AA, $FF

; Used for ship explosion, zone cleared etc.
.ColourEffects
EQUB BLACK, BLUE, RED, MAGENTA, GREEN, CYAN, YELLOW, WHITE

.CascadeEffects
EQUB RED, MAGENTA, GREEN, CYAN, YELLOW, WHITE, BLUE

.GridLevel
EQUB $01,$01,$01,$00,$01
EQUB $01,$02,$00,$00,$01
EQUB $00,$02,$01,$00,$02
EQUB $02,$01,$00,$02,$02

; Sound Info
;-----------------
; chan     2 bytes
; vol      2 bytes
; pitch    2 bytes
; duration 2 bytes

.FireBulletSound
EQUW &11
EQUW 1
EQUW 150
EQUW 5
EQUW 2

.ExplosionSound
EQUW 0
EQUW 3
EQUW 5
EQUW 10

.ShipExplosionSound
EQUW 0
EQUW 3
EQUW 6
EQUW 40

.FireLaserSound
EQUW &12
EQUW 4
EQUW 100
EQUS 2

.LevelSelectSound
EQUW &11
EQUW 4
EQUW 25
EQUW 50

.font_data
INCLUDE "Fonts.asm"

.sprite_data
INCBIN "SpriteData.bin"

.sprlist
EQUW sprite_data            ; Space
EQUW sprite_data + $20      ; Grid
EQUW sprite_data + $40      ; Dots
EQUW sprite_data + $60      ; Left Zapper
EQUW sprite_data + $80      ; Bottom Zapper
EQUW sprite_data + $A0      ; Horiz Laser1
EQUW sprite_data + $C0      ; Horiz Laser2
EQUW sprite_data + $E0      ; Vertical Laser1
EQUW sprite_data + $100     ; Vertical Laser2
EQUW sprite_data + $120     ; Ship
EQUW sprite_data + $140     ; Bullet Up
EQUW sprite_data + $160     ; Bullet Down
EQUW sprite_data + $180     ; Bullet Left
EQUW sprite_data + $1A0     ; Bullet Right
EQUW sprite_data + $1C0     ; Pod1
EQUW sprite_data + $1E0     ; Pod2
EQUW sprite_data + $200     ; Pod3
EQUW sprite_data + $220     ; Pod4
EQUW sprite_data + $240     ; Pod5
EQUW sprite_data + $260     ; Pod6
EQUW sprite_data + $280     ; Bomb Down
EQUW sprite_data + $2A0     ; Explosion1
EQUW sprite_data + $2C0     ; Explosion2
EQUW sprite_data + $2E0     ; Explosion3
EQUW sprite_data + $300     ; Leader1
EQUW sprite_data + $320     ; Leader2
EQUW sprite_data + $340     ; Leader3
EQUW sprite_data + $360     ; Leader4

EQUW sprite_data + $380     ; Droid
EQUW sprite_data + $3A0     ; Snitch_Right1
EQUW sprite_data + $3C0     ; Snitch_Right2
EQUW sprite_data + $3E0     ; Snitch_Left1
EQUW sprite_data + $400     ; Snitch_Left2
EQUW sprite_data + $420     ; Snitch_Wave1
EQUW sprite_data + $440     ; Snitch_Wave2

EQUW sprite_data + $460     ; SoundON
EQUW sprite_data + $480     ; SoundOff
EQUW sprite_data + $4A0     ; Pause
EQUW sprite_data + $4C0     ; Joystick

EQUW sprite_data + $4E0     ; Camel_Right
EQUW sprite_data + $500     ; Camel_left
EQUW sprite_data + $520     ; Deflector1
EQUW sprite_data + $540     ; Deflector2
EQUW sprite_data + $560     ; Deflector3
EQUW sprite_data + $580     ; Bonus1
EQUW sprite_data + $5A0     ; Bonus2

\ ******************************************************************
\ *	End address to be saved
\ ******************************************************************
.end

\ ******************************************************************
\ *	Save the code
\ ******************************************************************

PRINT "End of ZP", ~end_of_ZP, "Bytes Used", ~(end-start), "Bytes Left", ~(&3000-end)

SAVE "MATRIX", start, end
puttext "BOOT", "!BOOT",&FFFF
putbasic "Matrix.bas", "LOADER"

\\ run command line with this
\\ beebasm -v -i Matrix.asm -do Matrix.ssd -opt 3


