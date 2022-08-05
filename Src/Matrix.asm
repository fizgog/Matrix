;-------------------------------------------------------------------------
; Matrix: Gridrunner 2
;-------------------------------------------------------------------------
; BBC Conversion Shaun Lindsley
; Thanks to Jef Minter for producing an excellent game for the VIC20 / C64
; Special thanks to the following: -
; Rich-Talbot-Watkins, Tricky and Coeus - Coding advice
; Rob Hawk - Testing
; Stardot Community - https://stardot.org.uk

; Use following for vsync debugging
; LDA #&00: STA &FE21 ;white
; LDA #&01: STA &FE21 ;cyan
; LDA #&02: STA &FE21 ;magenta 
; LDA #&03: STA &FE21 ;blue 
; LDA #&04: STA &FE21 ;yellow
; LDA #&05: STA &FE21 ;green
; LDA #&06: STA &FE21 ;red
; LDA #&07: STA &FE21 ;black

\\ Define addresses

NATIVE_ADDR		= &0E00		; address at which code will run
RELOAD_ADDR		= &1100		; address at which code will load

OFFSET			= RELOAD_ADDR - NATIVE_ADDR

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

MAPCHAR '*',49          ; Ship Explosion

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

MIN_X               = 0  
MIN_Y               = 0
MAX_X               = 19
MAX_Y               = 31

GRID_MIN_X          = MIN_X+1
GRID_MAX_X          = MAX_X-1
GRID_MIN_Y          = MIN_Y+3
GRID_MAX_Y          = MAX_Y-2

SHIP_MIN_Y          = GRID_MIN_Y+5      ; How far ship can travel up the grid
SHIP_MAX_Y          = GRID_MAX_Y-1
SHIP_START_X        = (MAX_X) / 2       ; Used for Ship start x position

ZAPPER_LEFT_X       = MIN_X             ; Static
ZAPPER_LEFT_MIN_X   = MIN_X             ; Left zapper min x pos
ZAPPER_LEFT_MIN_Y   = GRID_MIN_Y
ZAPPER_LEFT_MAX_Y   = GRID_MAX_Y

ZAPPER_BOTM_Y       = GRID_MAX_Y        ; Static
ZAPPER_BOTM_MIN_X   = GRID_MIN_X
ZAPPER_BOTM_MAX_X   = GRID_MAX_X+1

LASER_MAX_X         = GRID_MAX_X
LASER_MAX_Y         = GRID_MAX_Y
LASER_FIRE_Y        = ZAPPER_BOTM_Y-1

BOMB_MAX_Y          = GRID_MAX_Y        ; How far down can the bomb go

DROID_MIN_X         = GRID_MIN_X-1
DROID_MIN_Y         = GRID_MIN_Y
DROID_MAX_X         = GRID_MAX_X+1      
DROID_MAX_Y         = GRID_MAX_Y-1      ; How far down can the droid go

CAMELOID_MIN_X      = GRID_MIN_X-1
CAMELOID_MIN_Y      = GRID_MIN_Y
CAMELOID_MAX_X      = GRID_MAX_X+1      
CAMELOID_MAX_Y      = GRID_MAX_Y-1      

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
LEADER1             = 21    ; 15
LEADER2             = 22    ; 16
LEADER3             = 23    ; 17
LEADER4             = 24    ; 18
DROID               = 25    ; 19
SNITCH_RIGHT1       = 26    ; 1A
SNITCH_RIGHT2       = 27    ; 1B
SNITCH_LEFT1        = 28    ; 1C
SNITCH_LEFT2        = 29    ; 1E
SNITCH_WAVE1        = 30    ; 1F
SNITCH_WAVE2        = 31    ; 20
CAMELOID_RIGHT      = 32    ; 21
CAMELOID_LEFT       = 33    ; 22
DEFLECTOR1          = 34    ; 23
DEFLECTOR2          = 35    ; 24
DEFLECTOR3          = 36    ; 25
BONUS1              = 37    ; 26
BONUS2              = 38    ; 27

HALF_LEFT           = 39    ; 28
HALF_RIGHT          = 40    ; 29
MYSTERY             = 41    ; 2A

SOUND_ON            = 42    ; 2B
SOUND_OFF           = 43    ; 2C
PAUSE_ICON          = 44    ; 2D
JOYSTICK_ICON       = 45    ; 2E

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

.chrFontColourIndex             SKIP 1
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
.foreColour                     SKIP 1
.backColour                     SKIP 1 

.snitchFrameRate                SKIP 1
.snitchFrameRateLevel           SKIP 1
.snitchXPosition                SKIP 1
.snitchYPosition                SKIP 1
.snitchControl                  SKIP 1 
                        
.temp                           SKIP 1
.temp2                          SKIP 1
.temp3                          SKIP 1
.temp4                          SKIP 1

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

.InitialCameloidsRefreshRate    SKIP 1
.CurrentCameloidsRefreshRate    SKIP 1
.InitialDroidsInSquad           SKIP 1
.CurrentCameloidsOnScreen       SKIP 1
.CameloidsLeftToKill            SKIP 1
.InitialCameloidsOnScreen       SKIP 1
.currentCameloidsLeft           SKIP 1
.currentCameloidsIndex          SKIP 1

.mysteryBonusEarned             SKIP 1
.bonusBits                      SKIP 1

.random                         SKIP 1

; Remove following once live
;.debugA                         SKIP 1
;.debugX                         SKIP 1
;.debugY                         SKIP 1
;.debugXPos                      SKIP 1
;.debugYPos                      SKIP 1
;.debugChar                      SKIP 1
;.debugTemp                      SKIP 1

.end_of_ZP

; Paged aligned arrays
ORG &0400

; Pods / bombs Max &28 - 40 decimals
.podArrayXPos               SKIP &3A    ; 0400-042A
.podArrayYPos               SKIP &3A
.podArrayChar               SKIP &3A

; Deflexor array &28 -  40 decimal
.currentDeflexorXPosArray   SKIP &1A    ; 0480-049F
.currentDeflexorYPosArray   SKIP &1A    ; 04A8-04CF
.currentDeflexorStatusArray SKIP &1A    ; 04C0-04F7

ORG &0500
; Max Droid &55 - 86 decimal
.droidXPositionArray        SKIP &55    ; 0500-0554
.droidYPositionArray        SKIP &55    ; 0555-05A9
.droidStatusArray           SKIP &55    ; 05AA-05FF

ORG &0600 
; Max Cameloids &55 - 86 decimal
.cameloidXPositionArray     SKIP &55    ; 0600-0654
.cameloidYPositionArray     SKIP &55    ; 0680-06A9
.cameloidStatusArray        SKIP &55    ; 06AA-06FF

ORG NATIVE_ADDR

.START

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
    ; Reset Red colour
    LDX #1
    LDY #1
    JSR DefineColour

    ; Reset level
    LDA #1
    STA selectedLevel
    STA random 

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

    LDA #$80                ; %10000000 - set bit 7 to 1
    STA joystickFlag        ; Use BPL if bit 7 is 0                         

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
    CMP #$06
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
    BEQ start_game

    JSR isJoystickPressed
    BCC title_screen_loop

    ;LDA joystickFlag
    ;EOR #$80
    LDA #$00
    STA joystickFlag

.start_game
    ; Reset Score
    LDA #0
    STA score1
    STA score2
    STA score3
    STA score4
    JSR PrintScore

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

    JSR InitialiseLevel
 
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
    JSR DrawLaser
    JSR UpdateBombs
    JSR UpdatePods
    
    JSR AnimateCameloid
    JSR DrawDroids
    JSR DrawDeflexor
    
    LDA #1
    JSR vsync_delay
    JSR CheckLevelComplete

    LDX #keyCodeESCAPE
    JSR isKeyPressed
    BNE MainLoop
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

    ;; Set colour red back to red
    ;LDX #1
    ;LDY #1
    ;JSR DefineColour

    LDA #CYAN
    STA chrFontColour
 
    LDX #2
    LDY #5
    LDA #DesignText MOD 256:STA text_addr
    LDA #DesignText DIV 256:STA text_addr+1
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
    
    LDA CameloidsLeftToKill
    BNE not_complete
    LDA currentCameloidsLeft
    BNE not_complete

    ;JSR FindPod
    ;CMP #gridCharacter
    ;BEQ no_mystery_bonus_4

    ; Mystery Bonus 4
    ; Award a bonus bit for clearing all pods.
    ;LDA bonusBits
    ;ORA #$08
    ;STA bonusBits

.no_mystery_bonus_4    
 
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
    ; Return

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
    STA ZoneClearedSound1Pitch
    STA ZoneClearedSound2Pitch
    STA ZoneClearedSound3Pitch

    LDX #ZoneClearedSound1 MOD 256 
    LDY #ZoneClearedSound1 DIV 256 
    JSR PlaySound
    LDX #ZoneClearedSound2 MOD 256 
    LDY #ZoneClearedSound2 DIV 256 
    JSR PlaySound
    LDX #ZoneClearedSound3 MOD 256 
    LDY #ZoneClearedSound3 DIV 256 
    JSR PlaySound

    LDA temp2
    AND #$C0                    ; %11000000
    CMP #$C0
    BNE zone_colour_loop

    ; Mystery Bonus
    JSR CalculateMysteryBonus

    LDA mysteryBonusEarned
    BEQ zone_exit
    JSR DisplayMysteryBonus

.zone_exit
    JSR ClearScreen
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

    LDA #$0F
    STA temp2

.loop1    
    
    LDA #$00
    STA temp3

.loop2
    
    LDA temp3
    ADC #$08
    STA temp3
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

    LDA #$01;80
    JSR vsync_delay

    INC temp3
    LDA temp3
    CMP #$32
    BCC loop2

    DEC temp2
    LDA temp2
    BNE loop1

    ;LDA #$80
    ;JSR vsync_delay

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

    LDX #06
    LDY #10
    LDA #GameOverText MOD 256:STA text_addr
    LDA #GameOverText DIV 256:STA text_addr+1
    JSR PrintString 

    JSR CheckHighScore
 
    LDA #$00
    STA chrFontColourIndex
   
    LDA #$0F
    STA temp2

.loop1
    LDA #$00
    STA temp3

    LDA temp4
    BEQ not_highscore

    JSR AnimatedHighScore

.not_highscore

.loop2
    LDA temp3
    STA GenericSoundPitch1
    ADC #$10
    STA GenericSoundPitch2
    ADC #$10
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
    ADC #$08
    STA temp3
    LDA temp3
    CMP #$40
    BCC loop2

    DEC temp2
    BNE loop1 

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

    ; Cascade Sound
    LDX #CascadeSound1 MOD 256
    LDY #CascadeSound1 DIV 256
    JSR PlaySound
    ; Cascade Sound
    LDX #CascadeSound2 MOD 256
    LDY #CascadeSound2 DIV 256
    JSR PlaySound
    ; Cascade Sound
    LDX #CascadeSound3 MOD 256
    LDY #CascadeSound3 DIV 256
    JSR PlaySound
      
.cascade_loop
    ; Wait for horizontal blank
    LDA #19     
    JSR OSBYTE

    LDA #8                      ; 8 rows to a column
    STA temp2

    LDA #27 
    SEC
    SBC currentYPosition        ; 25-24 = 1, then 25-23 = 2... etc
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
 
    LDX #9      ;#18 ; number of columns
    
.pixel_loop
    LDA chrFontColour

    LDY #0  :STA (write_addr),Y
    LDY #8  :STA (write_addr),Y
    LDY #16 :STA (write_addr),Y
    LDY #24 :STA (write_addr),Y
    LDY #32 :STA (write_addr),Y
    LDY #40 :STA (write_addr),Y
    LDY #48 :STA (write_addr),Y
    LDY #56 :STA (write_addr),Y
    
	LDA	write_addr
	ADC	#64
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

    LDX #2
    LDY #14
    LDA #EnterZoneBlank MOD 256: STA text_addr
    LDA #EnterZoneBlank DIV 256: STA text_addr+1
    JSR PrintString

    LDX #2
    LDY #15
    LDA #EnterZoneText MOD 256: STA text_addr
    LDA #EnterZoneText DIV 256: STA text_addr+1
    JSR PrintString

    LDX #15
    LDY #15
    JSR setTextPos

    LDA selectedLevel
    JSR BCDtoScreen

    LDX #2
    LDY #16
    LDA #EnterZoneBlank MOD 256: STA text_addr
    LDA #EnterZoneBlank DIV 256: STA text_addr+1
    JSR PrintString

    LDA #0
    STA temp2

    LDA #80;#$FF
    STA delay_counter2

.gridloop
    JSR AnimateGrid

    LDA temp2
    STA EnterZoneSound1Pitch
    STA EnterZoneSound2Pitch
    STA EnterZoneSound3Pitch
    LDX #EnterZoneSound1 MOD 256 
    LDY #EnterZoneSound1 DIV 256 
    JSR PlaySound
    LDX #EnterZoneSound2 MOD 256 
    LDY #EnterZoneSound2 DIV 256 
    JSR PlaySound
    LDX #EnterZoneSound3 MOD 256 
    LDY #EnterZoneSound3 DIV 256 
    JSR PlaySound
    INC temp2

    LDA #$01
    JSR vsync_delay

    DEC delay_counter2
    BNE gridloop

    ; Remove Enter zone
    JSR DrawGridOverEnterZone

    ; Slow down grid animation
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
    LDA selectedLevel
    JSR DecimalToHex
    TAX
    DEX

    ; Init Grid Character
    LDA GridLevel,X
    STA gridCharacter

    ; Init Droids
    LDA noOfDroidSquadsForLevel,X
    STA droidsLeftToKill
    STA InitialDroidsInSquad

    LDA sizeOfDroidSquadsForLevels,X
    STA sizeOfDroidSquadForLevel

    ; Init Lasers
    LDA laserFrameRateForLevel,X
    STA laserFrameRate

    ; Init Snitch
    LDA snitchSpeedForLevel,X
    STA snitchFrameRate
    STA snitchFrameRateLevel

    ; Init Deflexors
    LDA deflexorIndexArrayForLevel,X
    STA deflexorIndexForLevel

    ; Init Cameloids
    LDA CameloidsLevelArray,X
    STA CameloidsLeftToKill

    LDA CameloidsOnScreenArray,X
    STA InitialCameloidsOnScreen
    STA CurrentCameloidsOnScreen 

    LDA CameloidsRefreshRateArray,X
    STA InitialCameloidsRefreshRate   
    STA CurrentCameloidsRefreshRate    
    
    ; Init Ship
    LDA #SHIP_FRAME_RATE
    STA shipAnimationFrameRate

    LDA #DROID_FRAME_RATE
    STA droidFrameRate

    LDA #BULLET_FRAME_RATE
    STA bulletAndLaserFrameRate  
    
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
    STA currentCameloidsLeft
    STA mysteryBonusEarned
    
    LDA #LEADER1
    STA currentDroidCharacter
    
    LDA #$01
    STA gridFrameRate
    STA gridFrameRateMax
    STA droidTimer

    ; Mystery Bonus 3
    LDA #$04
    STA bonusBits

    LDA #0
    STA backColour
    LDA #4
    STA foreColour
    JSR AnimateGrid

    JSR ClearPodArray
    JSR ClearDroidArray
    JSR InitDeflexorArray

    RTS
}

;-------------------------------------------------------------------------
; DrawGrid
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DrawGrid
{
    LDA gridCharacter 
    STA currentCharacter

    LDY #GRID_MIN_Y

.draw_vertical_line_loop2    
    STY currentYPosition
    LDX #GRID_MIN_X

.draw_horizontal_line_loop2
    STX currentXPosition
    JSR PlotCharSprite
    INX
    CPX #GRID_MAX_X+1
    BNE draw_horizontal_line_loop2
    INY
    CPY #GRID_MAX_Y
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
    LDX #2
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
; On entry  : X = background colour, Y = foreground colour
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
    LDY backColour
    JSR DefineColour

    LDX gridNewColour
    JSR Incdelay_counter1
    STX gridNewColour
    LDY foreColour                 
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
include "mysterybonus.asm"
;include "debug.asm"

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
; ConvertCharToPixel
;-------------------------------------------------------------------------
; Convert character based position to pixel based position
;-------------------------------------------------------------------------
; On entry  : currentXPosition = 0-19, currentYPosition = 0-31
; On exit   : XOrd = 0-79, YOrd = 0-255
;           : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------
.ConvertCharToPixel
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
    RTS
}

;-------------------------------------------------------------------------
; CalcXYCharAddress
;-------------------------------------------------------------------------
; 8x8 Character based address calculation only
;-------------------------------------------------------------------------
; On entry  : currentXPosition = 0-19, currentYPosition = 0-31
; On exit   : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------
.CalcXYCharAddress
{
    JSR ConvertCharToPixel
    JMP GetScreenAddress
}

;-------------------------------------------------------------------------
; GetScreenAddress
;-------------------------------------------------------------------------
; 8x8 Character based address calculation only
;-------------------------------------------------------------------------
; On entry  : XOrd = 0-79, YOrd = 0-255
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
; On entry  : currentXPosition = 0-19, currentYPosition = 0-31
; On exit   : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------
.PlotCharSprite
{
    JSR ConvertCharToPixel
    JMP PlotSprite
}

;-------------------------------------------------------------------------
; PlotSprite
;-------------------------------------------------------------------------
; This plots an 8x8 sprite at screen coords XOrd,YOrd
;-------------------------------------------------------------------------
; On entry  : XOrd and YOrd contain the screen coords
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
 
.sprite_write    
    STA $FFFF,X

    DEX
    BPL sprite_read

    PLA
    TAX
    RTS
}


;-------------------------------------------------------------------------
; PlotCharSpriteNoBlack
;-------------------------------------------------------------------------
; This plots an 8x8 sprite at character position X,Y
;-------------------------------------------------------------------------
; On entry  : currentXPosition = 0-19, currentYPosition = 0-31
; On exit   : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------
.PlotCharSpriteNoBlack
{
    JSR ConvertCharToPixel
    JMP PlotSpriteNoBlack
}

;-------------------------------------------------------------------------
; PlotSpriteNoBlack
;-------------------------------------------------------------------------
; This plots an 8x8 sprite at screen coords XOrd,YOrd
;-------------------------------------------------------------------------
; On entry  : XOrd and YOrd contain the screen coords
; On exit   : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------
.PlotSpriteNoBlack
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
    BEQ ignore_black
.sprite_write    
    STA $FFFF,X
.ignore_black
    DEX
    BPL sprite_read

    PLA
    TAX
    RTS
}
;-------------------------------------------------------------------------
; GetChar
;-------------------------------------------------------------------------
; LDA #$87 : JSR OSBYTE - Too slow - don't ever use
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A contains sprite character index
;           : X may contain index into pod, droid or deflexor array
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

    JSR FindCameloid
    CMP gridCharacter
    BNE found

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
    TAX
    JMP PrintChar
}

;-------------------------------------------------------------------------
; DecimalToHex
;-------------------------------------------------------------------------
; On entry  : A contains decimal value
; On exit   : A contains hex value
;           : X and Y are preserved
;-------------------------------------------------------------------------
.DecimalToHex
{
    PHA
	AND	#$F0	; Isolate the tens digit.
	STA	temp
	PLA
	AND	#$0F	; isolate the units digit.
	LSR	temp	; tens digit is now x8
	CLC
	ADC	temp	; Add it in to the binary total.
	LSR	temp	; tens digit is now x4
	LSR	temp	; tens digit is now x2
	CLC
	ADC	temp	; Result is now in A.
	RTS
}

;-------------------------------------------------------------------------
; RandomNumber
;-------------------------------------------------------------------------
; On entry  : variable random is the seed
; On exit   : A contains random number
;           : X and Y are preserved
;-------------------------------------------------------------------------
.RandomNumber 
{
	LDA random 
	ASL A         
	ASL A         
	CLC           
	ADC random
	CLC           
	ADC #&45      
	STA random 
	RTS
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
; PlotFont
;-------------------------------------------------------------------------
; On entry  : currentXPos, currentYPos, currentCharacter
; On exit   : X is preserved
;-------------------------------------------------------------------------

.PlotFont
{
    TXA
    PHA
    
    JSR CalcXYCharAddress
    
    LDX currentCharacter
    JSR PrintChar

    PLA
    TAX
    RTS
}


;-------------------------------------------------------------------------
; AnimatedHighScore
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : 
;-------------------------------------------------------------------------
.AnimatedHighScore
{
    LDA #WHITE
    STA chrFontColour
    LDX #06
    LDY #16
    LDA #WellDoneText MOD 256:sta text_addr
    LDA #WellDoneText DIV 256:sta text_addr+1
    JSR PrintString

    LDX #4
    LDY #18
    LDA #NewHighscoreText MOD 256:sta text_addr
    LDA #NewHighscoreText DIV 256:sta text_addr+1

    STX currentXPosition
    STY currentYPosition

    JSR CalcXYCharAddress   ; Screen address is stored in write_addr

    LDY #0
.loop

    LDA chrFontColourIndex
    AND #$07
    TAX
    STX chrFontColourIndex
    LDA CascadeEffects, X
    STA chrFontColour
    
    LDA (text_addr),Y
    BMI finished
    TAX
    JSR PrintChar
    INC chrFontColourIndex
    INY
    BNE loop
.finished  
    
    RTS   
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
    INC write_addr + 1

.finish1
    
    LDY saveY
    RTS
}

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
EQUS "                ",$FF

.EnterZoneText
EQUS " ENTER ZONE     ",$FF

.GotYouText
EQUS "GOT YOU!", $FF

.ZoneClearedText
EQUS "ZONE CLEARED", $FF

.GameOverText
EQUS "GAME OVER", $FF

.WellDoneText
EQUS "WELL DONE",$FF

.NewHighscoreText
EQUS "NEW HIGHSCORE ",$FF

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

; Used for cascading line (reverse order)
.CascadeEffects
EQUB RED, MAGENTA, GREEN, CYAN, YELLOW, WHITE, BLUE, BLACK

; 00 blank, 01 grid, 02 dots
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

.FireBulletSound1
EQUW &11
EQUW 1
EQUW 0
EQUW 10

; SOUND &10,-15,7,10
.FireBulletSound2
EQUW &10
EQUW &FFF1
EQUW 7
EQUW 10

.ExplosionSound
EQUW 0
EQUW 3
EQUW 5
EQUW 10

.ShipExplosionSound
EQUW &10
EQUW 3
EQUW 6
EQUW 40

.FireLaserSound
EQUW &12
EQUW 4
EQUW 100
EQUW 2

.LevelSelectSound
EQUW &11
EQUW 4
EQUW 25
EQUW 50

.CascadeSound1
EQUW &11
EQUW 5
EQUW 0
EQUW 50

.CascadeSound2
EQUW &12
EQUW 5
EQUW 1
EQUW 50

.CascadeSound3
EQUW &13
EQUW 5
EQUW 2
EQUW 50

.EnterZoneSound1
EQUW &11
EQUW 7
.EnterZoneSound1Pitch
EQUW 0
EQUW 1

.EnterZoneSound2
EQUW &12
EQUW 7
.EnterZoneSound2Pitch
EQUW 0
EQUW 2

.EnterZoneSound3
EQUW &13
EQUW 7
.EnterZoneSound3Pitch
EQUW 0
EQUW 1

.ZoneClearedSound1
EQUW &201
EQUW 7
.ZoneClearedSound1Pitch
EQUW 0
EQUW 1

.ZoneClearedSound2
EQUW &202
EQUW 7
.ZoneClearedSound2Pitch
EQUW 0
EQUW 1

.ZoneClearedSound3
EQUW &203
EQUW 7
.ZoneClearedSound3Pitch
EQUW 0
EQUW 1

.GenericSound1
EQUW &11
EQUW &FFF1
.GenericSoundPitch1
EQUW 0
EQUW 1

.GenericSound2
EQUW &12
EQUW &FFF1
.GenericSoundPitch2
EQUW 0
EQUW 1

.GenericSound3
EQUW &13
EQUW &FFF1
.GenericSoundPitch3
EQUW 0
EQUW 1

.font_data
INCLUDE "Fonts.asm"

.end_of_Fontdata

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
EQUW sprite_data + $2A0     ; Leader1
EQUW sprite_data + $2C0     ; Leader1
EQUW sprite_data + $2E0     ; Leader2
EQUW sprite_data + $300     ; Leader4
EQUW sprite_data + $320     ; Droid Segment
EQUW sprite_data + $340     ; Snitch_Right1
EQUW sprite_data + $360     ; Snitch_Right2
EQUW sprite_data + $380     ; Snitch_Left1
EQUW sprite_data + $3A0     ; Snitch_Left2
EQUW sprite_data + $3C0     ; Snitch_Wave1
EQUW sprite_data + $3E0     ; Snitch_Wave2
EQUW sprite_data + $400     ; Camel_Right
EQUW sprite_data + $420     ; Camel_Left
EQUW sprite_data + $440     ; Deflector1
EQUW sprite_data + $460     ; Deflector2
EQUW sprite_data + $480     ; Deflector3
EQUW sprite_data + $4A0     ; Bonus1
EQUW sprite_data + $4C0     ; Bonus2
EQUW sprite_data + $4E0     ; Half_Left
EQUW sprite_data + $500     ; Half_Right
EQUW sprite_data + $520     ; Mystery

EQUW sprite_data + $540     ; SoundOn
EQUW sprite_data + $560     ; SoundOff
EQUW sprite_data + $580     ; Pause
EQUW sprite_data + $5A0     ; Joystick

.end_of_Spritedata

.END

ALIGN &100
.RELOC_START
{
    LDA #$8C
    LDX #$00
    LDY #$00
    JSR OSBYTE      ; Select cassette file system and set speed

    LDX #HI(RELOC_START-START)
	LDY #0

.relocloop
	LDA RELOAD_ADDR,Y
	STA NATIVE_ADDR,Y
	INY
	BNE relocloop
	INC relocloop+OFFSET+2		; PATCHED ADDRESS
	INC relocloop+OFFSET+5		; PATCHED ADDRESS
	DEX
	BNE relocloop
	
	JMP START
}

\ ******************************************************************
\ *	End address to be saved
\ ******************************************************************
.RELOC_END

\ ******************************************************************
\ *	Save the code
\ ******************************************************************
PRINT
PRINT "--------------------------------------------------"
PRINT "End of ZP", ~end_of_ZP, ", Font Size", ~(end_of_Fontdata-font_data), ", Sprite Size", ~(end_of_Spritedata-sprite_data) 
PRINT "Bytes Used", ~(RELOC_END-START)
PRINT "--------------------------------------------------"
PRINT
SAVE "MATRIX", START, RELOC_END, RELOC_START+OFFSET, RELOAD_ADDR
puttext "BOOT", "!BOOT",&FFFF
putbasic "Matrix.bas", "LOADER"


\\ run command line with this
\\ beebasm -v -i Matrix.asm -do Matrix.ssd -opt 3


