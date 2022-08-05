10REM Matrix Loader
20REM Original Design Jeff Minter
30REM BBC Conversion Shaun Lindsley
40REM (c) 2022
50MODE7:ON ERROR GOTO 720
60VDU23;8202;0;0;0;28,0,31,19,17

100REM Envelopes
110ENVELOPE 1,1,-3,-4,-5,10,10,-1,0,0,0,-126,126,0 : REM Bullet
120ENVELOPE 2,1,-127,8,-8,255,255,2,12,0,0,-1,126,126
130ENVELOPE 3,1,0,0,0,0,0,0,127,-1,-1,-1,126,30 : REM Ship Explosion
140ENVELOPE 4,0,-15,-15,-15,100,100,100,0,0,0,-2,120,120 : REM Zapper Laser
150ENVELOPE 5,1,0,0,0,0,0,0,1,0,0,-1,126,0 : REM Cascade
160ENVELOPE 6,8,2,20,16,16,0,0,126,0,0,-126,126,126
170ENVELOPE 7,1,6,6,6,2,2,1,126,0,0,-126,126,126: REM ZONE

200REM Matrix Title
230PRINTTAB(8,0);CHR$(150);"=p>5 :k 'k7%7�i �";CHR$(255);"�*t_>"
240PRINTTAB(8,1);CHR$(150);"5"" 5h�k4 j5 7+1  ";CHR$(255);"  zo0"
250PRINTTAB(8,2);CHR$(150);"%(*%% *% /% / *%,/,*%$/"
260PRINTTAB(19,3)CHR$133"GRIDRUNNER 2"
265PRINTTAB(6,5)CHR$131"Original Design Jeff Minter"
270PRINTTAB(5,6)CHR$134"BBC Conversion Shaun Lindsley"'

280PRINTTAB(5,23);CHR$133;CHR$(136);"Press SPACE BAR to continue"
290VDU28,0,22,39,8

300PRINTCHR$135"SCENARIO:"'
310PRINTCHR$130"It is 10 years after the infamous Grid"
320PRINTCHR$130"wars. You, one of the few survivors of"
330PRINTCHR$130"the Gridrunner squadrons, are sitting"
340PRINTCHR$130"watching TV when suddenly an"
350PRINTCHR$130"announcement breaks in:"'
360PRINTCHR$130"All pilots with Gridrunner experience"
370PRINTCHR$130"report to base immediately."'
380PRINTCHR$129"        This is an emergency!        "
390REMPRINTCHR$130"grid was found to be delivering less"
400REMPRINTCHR$130"power than predicted."
410REPEAT:UNTIL GET=32:CLS:*FX15

600PRINTCHR$135"SCORING:"'
610PRINTCHR$131"     POD destroyed..............10"
620PRINTCHR$131"     DROID segment.............100"
630PRINTCHR$131"     Cameloids.................106"
640PRINTCHR$131"     Leader DROID..............400"
650PRINTCHR$131"     Clearing zone......Extra ship"'

660PRINTCHR$135"MYSTERY BONUS:"'
670PRINTCHR$130"There are seven bonuses from 2000 to"
680PRINTCHR$130"8000 points. It is up to you to"
690PRINTCHR$130"discover how to score them!"'
700REPEAT:UNTIL GET=32:CLS:*FX15

720VDU28,0,24,39,8:CLS:*FX15
730PRINTTAB(13)CHR$133"Game Controls"'
740PRINTTAB(17)CHR$130"Z - Left"
750PRINTTAB(17)CHR$130"X - Right"
760PRINTTAB(17)CHR$130": - Up"
770PRINTTAB(17)CHR$130"/ - Down"'
780PRINTTAB(12)CHR$131"RETURN - Fire"'
790PRINTTAB(12)CHR$129"ESCAPE - Exit the game"'
800PRINTTAB(17)CHR$129"S - Sound on/off" 
810PRINTTAB(17)CHR$129"P - Pause on/off"     
820PRINTTAB(17)CHR$129"J - Joystick/Keyboard"
830PRINTTAB(7,15);CHR$133;"Press SPACE BAR to start"
840REPEAT:UNTIL GET=32:*FX15
860*RUN MATRIX


