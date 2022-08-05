;-------------------------------------------------------------------------
; Matrix: Gridrunner2 - highscore code
;-------------------------------------------------------------------------

;-------------------------------------------------------------------------
; CheckHighScore
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A and X are undefined
;-------------------------------------------------------------------------
.CheckHighScore
{
    LDA #$00
    STA temp4

    LDA score4          
    CMP high_score + 3      ; Score four check
    BCC score_lower
    BNE score_higher
    ; score 4 is same
    LDA score3          
    CMP high_score + 2      ; score three check
    BCC score_lower
    BNE score_higher
    ; score 3 is the same
    LDA score2          
    CMP high_score + 1      ; score two check
    BCC score_lower
    BNE score_higher
    ; score 2 is the same
    LDA score1          
    CMP high_score          ; score one check
    BCC score_lower
    BEQ score_lower         ; score the same

.score_higher
    LDA score4
    STA high_score + 3,X
    LDA score3
    STA high_score + 2,X
    LDA score2
    STA high_score + 1,X
    LDA score1
    STA high_score,X

    LDA #$01
    STA temp4

.score_lower
    RTS
}

;-------------------------------------------------------------------------
