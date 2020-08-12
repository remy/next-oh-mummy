PLUS3DOS �y   %y %y                                                                                                         � 
\ ; Oh Mummy (clone) and to avoid any problem with the name, called Oh Remmmy! (or Go Mummy!) 4 ; By Remy Sharp 2020 / @rem / https://remysharp.com = ; Full source code at https://github.com/remy/next-oh-mummy/  ;  ��3    :�@ 28Mhz  ;  ; ******** TODO ********* 7 ; - [x] (bug) at random times, you can't unlock tomb 4 ) ; - [x] (feat) show when you have amulet : ; - [x] (bug) baddie can go off screen and crash the game ' ; - [x] too fast until you lose a life , ; - [x] bottom row - stuck if pointing down  ; $ ; ******** VARIABLE INDEX *********  ; 1 ; %A[] = baddie array (allows for > 64 elements)  ; %b = baddie index  ; %c = baddie count # ; %C[] = palette colours for tombs ) ; %d = player sprite flags (mirror, etc) ( ; H() = high scores (actually just one) K ; %n = delta time counter (only used during dev, but needs to be reserved)  z ; %P() = 0=lives, 1=score, 2=score multiple, 3=has scroll, 4=player last corner, used for tomb calc - initilised to $FFFF !H ; %P = player last position, used for tread marks - initilised to $FFFF "T ; %q = player last direction (whilst movement is engaged) - used for movement hacks #5 ; %r = (flag) player has scroll and can kill a mummy $ ; %s = player sprite %7 ; %R() = used to pick random selection of hidden items & ; %S(...) = speed option array 'y ; %T(21) = tomb array 0-19 with index 20 used for temp rendering, with 8bit flags (14 items contain data in the low bit) (% ; %t = items to find - defaults to 2 ) ; %x = player x * ; %y = player y +* ; %z = speed (for both baddie and player) , ; --- non int vars --- -0 ; DIFFICULTY(3) = how many lives you start with . ; LEVEL(1) = current level /& ; SPEED(3) = how fast the baddies are 0@ ; PLAYING = bool like - whether we're in game or not (in menus) 1 ; 2 ; TMP VARIABLES 3� ; i, j, k (but often shared) - then - a, e, f, g, h, l, o, u, v, w (used for score math) (unless documented, are disposable between DEFPROCS) 4 ; 5 ; BANK INDEX 6 ; 7" ; 19: tiles (copied from BANK 23) 8 ; 20: music (music.ndr) 9' ; 21: game over (music) (gameover.ndr) :2 ; 22: main player and NPC sprites (m-sprites.spr) ;/ ; 23: tile map (used with BANK 19) (mummy.map) <( ; 24: tile data (sprites) (m-tiles.spr) =% ; 25: hi score (music) (hiscore.ndr) > ; 26: game over/pause tiles ?> ; 27: tomb tiles - extra graphics arranged in a useful layout @J ; 28: palette - let's me change level colours without additional graphics A  ; 29: sound effects (mummy.afb) BF ; 30: temp holding space for 1/3rd of layer 2 screen (used for pause) C ; 31-33: screen cover image D ; E
 ; SCORING F ; GL ; A number of actions have base score values and depending on the speed and H= ; difficulty the player has selected, a multiple is applied. I ; J' ; The multiple logic is: x => (d-1)+s: KM ; This works out so that (s)peed = 1 and (d)iffulty = 1 has a multiple of 1, L6 ; and speed = 3 and diffulty = 3 has a multiple of 5. M ; N ; Action values: O ; - level up: 50 P ; - reveal empty tomb: 1 Q ; - reveal archaeologist: 25 R ; - reveal key: 25 S ; - reveal gold: 5 T ; - kill nasty: 10 U ; V% ; ********************************** W ; X ;PROC dT() Y ;PROC splash() Z DEBUG=0      [ SPRITEON=1     \ BOOT=0      ] ��DEBUGː��exit() ^ �initOnce() _ �initNewGame() ` �mainLoop() a= ; game loop - includes: render loop, lives check & game over b �mainLoop() c � d � eQ ;IF DEBUG THEN IF INKEY$ ="s" THEN SPRITEON= NOT SPRITEON: SPRITE PRINT SPRITEON fR ;IF DEBUG THEN PRINT AT %1,%0;"mem=";%65536- USR 7962;" ": ; memory available.... gE ;IF DEBUG THEN IF INKEY$ ="t" THEN %t=0: ; FIXME remove TESTING ONLY hH ;IF DEBUG THEN IF INKEY$ ="d" THEN %P(0)=0: ; FIXME remove TESTING ONLY iM ;IF DEBUG THEN IF INKEY$ ="w" THEN LEVEL=5:%t=0: ; FIXME remove TESTING ONLY j ;IF DEBUG THEN BORDER 0 k( �updateLoop():; update logic and render l ;IF DEBUG THEN BORDER 2 m# ��%P(0)=0�(t=0):; until zero lives n< �%t=0˓nextLevel(LEVEL+1    ):��gameOver():�initNewGame() o ��0     :; repeat forever p � q ; rI ; start main game loop - we do only one thing at a time in the main loop s �updateLoop() t �updatePlayer(%8) u �%b=1    :; baddie loop v � w* %i=%b*6:; 6 props (easy to mess this up!) x �%��b<2˓updateBaddie() y	 �%b=%b+1 z ��%b=(c+1) { ��="h"˓pauseGame() |G �Ѻ :;without INT itseems TO RUN atinybitsmoother ON tombintersections }E �%m�-1˕49  1  ,2    ,%m:%m=%-1:; play the activated sound effect ~J ;PROC dT() TO %f: PRINT AT 0,0;%c;"@";%f;" ": ; f big = bad, small = good  � � ; � ; %z = speed of player � �updatePlayer(%z) �I �treadMark():; put treadmarks on the place we're about to move away from �1 �%j=�31    :; check the joystick and then keys �V ; help the player when turning corners - but only with the joystick, not the keyboard �? �%j��%y�40�(y>$ff)��%(j&@0011)=j�%j=%j+q:; add the y direction �7 �%j��%x�48��%(j&@1100)=j�%j=%j+q:; add the x direction �L ; NOTE: these shifts aren't always needed, but it makes the code consistent �" �%(�$fbfe�0&1^1)��%j=%j+@1000:; Q �" �%(�$fdfe�0&1^1)��%j=%j+@0100:; A �" �%(�$dffe�1&1^1)��%j=%j+@0010:; O �" �%(�$dffe�0&1^1)��%j=%j+@0001:; P �i ; NOTE I no longer do an early exit - this keeps the game speed constant, otherwise the baddies speed up �L ; IF %j&$0f=0 THEN LET %P=%$ffff: ENDPROC : ; play isn't moving, early exit �B ; the last direction is stored in the up/down/left/right routines �* ; If I can't move on the x plane, check y �7 �%x�48�:�:�%j&@0100˓down(%z):��%y>0�(j&@1000)˓up(%z) �0 �checkTomb():; %P = $ffff if they haven't moved �< �%y�40�(y>$ff)�:�:�%j&@0010˓left(%z):��%j&@0001˓right(%z) �Q ; note that %x > $ff means the integer has gone from 0, to -1, but it's unsigned �L ; so it'll be up in the 65K range, so this check against 255 is good enough �- �%x>$ff�:�%x=0     :��%x>240�:�%x=240  �   �Y �%t=1��%j&@1000�(y=0)�(x=96)˓up(%z):%t=0     :%m=2    :�64  @  ,%x+32,%y+48,%s,%d:� �D �%y=$FFF0�(y=$FFF8)�:�:�%y>$ff�:�%y=0     :��%y>160�:�%y=160  �   �	 ; render � �64  @  ,%x+32,%y+48,%s,%d �K ; check the 2nd tomb _after_ sprite render to help smooth out the movement � �checkTomb() �' ; check if we're bumping into a baddie � %i=%��(64,1�c) � �%i=0˒ � �%i,,,,0      � %i=%i*6 �6 �%A[i+4]=0˒:; ignore hidden zombies/inactive baddies � %A[i+4]=0      � %A[i+5]=0      �` �%P(3)=0�%m=5    :�takeLife(%1):�%P(3)=0     :�takeLife(%0):�printScore(10  
  ):%m=6     � � � ; � �checkTomb() �X ; IIRC the PAUSE 1 is to attempt to match the timing if the player _had_ openned a tomb �1 �%(x�48)�(y�40)��1    :�:; only run on corners �K �%i=%(6*(y/40))+(x/48):; x/y as aisle index (6 aisles for 5 rows of tombs) �: %e=%P(4):; shorthand help - saves looking up all the time �< �%i=e��1    :�:; we were just there (%e is last position) � �%e=$ffff�%P(4)=%i:�1    :� �) %f=%i-e:; f is forward +1 or backward -1 �9 %k=%��{f}=1    :; k tracks the axis, +1 for X, 0 for Y �I ; important: %g is assigned here and used within getXTombs and getYTombs � �%�{f<0}�%g=%e:�%g=%i �+ �%k˓getXTombs()�%g,%h:��getYTombs()�%g,%h �F ; note that index 20 is out of bounds and assigns to the junk element �% ;PRINT AT 21,0;"g:";%g;",h:";%h;"  " �= �%g<20˓crackEdge(%k,%g,%T(g),1    ,%@11011111,%@10111111) �= �%h<20˓crackEdge(%k,%h,%T(h),0     ,%@01111111,%@11101111) �C %P(4)=%f+e:; save the last position (reverting from %f we lost %i) � � � ; �1 ; getXTombs: get tombs above and below of player � �getXTombs() � ; %g from checkTomb � %h=%1+(g/6) � %i=%g-h �
 �=%i-5,%i � ; �7 ; getYTombs: get tombs on the left and right of player � �getYTombs() � ;%g is from checkTomb �C ; this uses special logic for the left and right edge of the grid, �@ ; otherwise when you complete tomb 4 (x:4, y:0) then it wrongly �B ; applies a completed edge to 5 (x:0, y:1). The logic below fixes �? ; that - and returns '21' for a non existant/out of scope tomb � %v=%(g+1)�6 �+ �%v>1�%i=%g-6-(g/6):�=%i,%i+1:; inner grid �> �%v=1�%i=%g-6-(g/6):�=21    ,%i+1:; completed on right edge �8 �=%g-6-(g/6),21    :; case 0 = completed on left edge � ; � �crackEdge(%k,%i,%j,%o,%a,%b) �L ; cache the curent value, and if it doesn't change, nothing to do / endproc �
 �%j&8=8˒ �6 %u=%2+((i�5)*6):; map X to the x coord in tile offset � %v=%4+((i/5)*5):; same with Y �V ; bitwise op below is $current wall & (0xF0 + wall, 1 top, 2 right, 4 bottom, 8 left) �c ; importantly this leaves the first 4 bits untouched (Least Significant Nibble) meaning: @00001111 �! �%k�%T(i)=%T(i)&a:�%T(i)=%T(i)&b � �%T(i)=j˒ � ; print the cracked tile �V �%k˛4    ,1    �0     ,%24+o�%u,%v+(o*2):��1    ,3    �%0+o,%21�%u+(o*3),%v �	 %j=%T(i) �* ; only continue if the tomb is fully open � �%j&$f8�0˒ �, ; open tomb (ie. slightly different colour) �' �4    ,3    �0     ,3    �%u,%v �? �%m=4�:�:�%j=0�(j=4)�%m=0     :��%j>2�%m=1    :�%m=4    : �( �4    ,3    �0     ,%(3*j)+3�%u,%v �A ; if we revealed a baddie, bring them to life, and kick them off � �%j=4˓revealBaddie() �@ ; archaeologist(1), key(2), amulet(3), baddie(4) or treasure(5) �5 %w=1    :; 1 point for unlocking a tomb either way �e �%j=1�%t=%t-1:%w=25    :��%j=2�%w=25    :%t=%t-1:��%j=3�%P(3)=%1:�takeLife(%0):��%j=5�%w=5     �2 %T(i)=%j+8:; prevent the tomb from being reopened � �printScore(%w) � � � ; �Q ; should only ever be called from crackEdge - a separate routine for ledgability � �revealBaddie() � %A[6+4]=%$ff � %A[6+3]=3     � �1    ,,,%A[6+5]-4,1     �S ��1    ,�,%A[7]�%A[7]+16�1    �,%A[6+5]-4�%A[6+5]-1,�10    ,1    ,20     � � � ; � ; � ; leave tread marks �) �treadMark():;down=0,up=2,left=4,right=6 � �%P=$ffff˒:; didn't move �8 �%P>3�%i=%(x�3)�2:�%i=%(y�3)�2:; if left +1, right = -1 � ; � %v=%(y�3)+2 �> �%v>8000�%v=%v�8192:; handle when player is in start position �1 ; IF %P=0 THEN TILE 2,1 AT 0,%26+i TO %x >> 3,%v �3 ; IF %P=2 THEN TILE 2,1 AT 2,%26+i TO %x >> 3,%v+1 �3 ; IF %P=4 THEN TILE 1,2 AT %0+i,28 TO %x >> 3+1,%v �1 ; IF %P=6 THEN TILE 1,2 AT %2+i,28 TO %x >> 3,%v �B ; The four above lines can be refactored into a single line below �^ �%P<3˛2    ,1    �%P,%26+i�%x�3,%v+(P�1):��1    ,2    �%P-4+i,28    �%x�3+(P�3),%v �! %P=%$ffff:; now we're not moving  � ; ; handle baddies ; �updateBaddie()$ ; if this baddie is dead, fast exit �%A[i+4]=0˒ %f=%��(b,0):; x %g=%��(b,1):; y	O ; select a random direction 0-3 is valid, but if we have a random value higher
O ; then decide whether the baddie should chase the goodie, or keep going in the ; current direction %j=%�12 �%j>3�%j=%A[i+3]= ; if they're on the edge of the map, don't let them walk off �%g=208��%j=0�%j=1     �%g=48��%j=1�%j=0      �%f=272��%j=2�%j=3     �%f=32��%j=3�%j=2     ; save their direction %A[i+3]=%j ; FIXME what does this do? %A[(i*j)+2]=0     M ; this handles an edge case whereby the baddie is being revealed from hiding] ; and they're not on the right Y plane, so the distance to the next intersection is adjusted %v=%48` ;   IF %(f-32) MOD 48=0 THEN : ELSE %v=%32: IF %j < 2 THEN %j=%j+2: ELSE : PRINT AT 21,0;"done"$ �%(f-32)�48�0˓updateBaddieAdjust()k ; Note: I don't make use of the sprite mirror flag, instead I'm storing all the permutations of the spritef ; because I have room, and it means that I don't need an IF and subsequent SPRITE statement, i.e. the ; fastest code is no code. %e=%A[i+5] G �%j=0˞�%b,�,%g�%g+40�%z�,%e-4�%e-3,�10    ,0     ,0     :�:; down!I �%j=1˞�%b,�,%g-40�%g�%�{-z}�,%e-2�%e-1,�10    ,0     ,0     :�:; up"E �%j=2˞�%b,%f�%f+v�%z�,�,%e�%e+1,�10    ,0     ,0     :�:; right#J �%j=3˞�%b,%f-v�%f�%�{-z}�,�,%e+2�%e+3,�10    ,0     ,0     :�:; left$ �% ;& �updateBaddieAdjust()' %v=%32( �%j<2�%j=%j+2)? ; if the baddie on the far right edge, the force them to go 16* �%f=256��%j=2�%v=16    + �, ;- ; modifies: j, i, k. �takeLife(%a)/ �%i:�%j:�%k0 �%a��6    1 %j=%P(0)-a2, �%j=0�%m=3    :; REALLY dead sound effect3	 %P(0)=%j4 ; print hearts5 �%i=1    �%j6' �%40+i,%16,%32+(i*14),54  6  ,1    7 �%i8 ; now print empty9 %k=%7-(�{DIFFICULTY}*2): �%i=%j+1�%k;' �%40+i,%16,%32+(i*14),55  7  ,1    < �%i=/ ; note that %i increments beyond the max value># �%46,%14,%36+(i*14),56  8  ,%P(3)? �%a��0     @ �A ;B �up(%z):; move upC %q=8    DK %P=2    :; I'm fairly certain that q and P do pretty much the same thingE %y=%y-zF %d=%d^@1000G %s=50  2  H �I ;J �down(%z):; move downK �%y<160�:��%y�$FFF0�:��L %q=4    M %P=0     N %y=%y+zO %d=%d^@1000P %s=51  3  Q �R ;S �left(%z):; move leftT %q=2    U %P=4    V %x=%x-zW
 %d=%@1001X %s=%s+1:�%s>49�%s=48  0  Y �Z ;[ �right(%z):; move right\ %q=1    ] %P=6    ^ %x=%x+z_
 %d=%@0001` %s=%s+1:�%s>49�%s=48  0  a �b ;c ; %w = score numberd	 �pad(%w)e �%w<10˒="000"f �%w<100˒="00"g �%w<1000˒="0"h �=""i ;j ; %i = value to *add* to scorek �printScore(%i)l %P(1)=%P(1)+(i*P(2))m	 %w=%P(1)n9 �%w>�{H(1    )}�H(1    )=%w:��0     ,2    ,%$1c5:o w$=""p �%w<1001˓pad(%w)�w$q ��0     ,6    ;w$;%wr ��0     ,27    ;H(1    )s �t ;u ; init functionsv ;w �initSprites()x( ��:�2    ,1    :��1    :��1    y �19    �z$ �23    ��19    :; reset the map{^ ��19    ,0     ,32     ,8    :; using tile bank 19, offset 0, tile 32 wide, tile size 8|A �32     ,24    :; print tile for 14 tile cols by 12 tile rows}? ��27    ,0     ,4    ,8    :; swap to our tomb tile set~A ��:; switch to batching (though pretty sure this isn't required) �� ;� ; %n = 512 colour index� �setBorder(%n)� �1    ,0     :��9  	  �L �28    �%(512+32),%((n&1)�8)+(n�1):; poke 16bit little endian next colour�	 �0     � ��0     �28    ,512    �0 �2    ,1    :; re-select our original layer�: �0     :�2    :; note that ink 2 is changed on the fly� �� ;� �pauseGame()�T ; note that this tiles with a black with priority set, so it will sit above sprites� �2    ,1    � ; backup the screen� �10  
  ��30    � ; stop the music� �50  2  ,4    � ; paint it black�$ ��26    ,0     ,16    ,8    �2 �16    ,3    �0     ,2    �8    ,8    �3 �16    ,3    �0     ,2    �8    ,11    � %i=13    �5 �1    ,1    �10  
  ,0     �%i+0,10  
  :;  P�4 �1    ,1    �11    ,0     �%i+1,10  
  :; A�4 �1    ,1    �12    ,0     �%i+2,10  
  :; U�4 �1    ,1    �13    ,0     �%i+3,10  
  :; S�4 �1    ,1    �14    ,0     �%i+4,10  
  :; E�4 �1    ,1    �15    ,0     �%i+5,10  
  :; D� �pressAnyKey()� ; resume music if it wass on�+ �MUSIC˕50  2  ,2    :�50  2  ,3    � ; restore the screen� �30    ��10  
  � ; put original tiles back�# ��27    ,0     ,4    ,8    � �� ;� �gameOver()� �0     :�255  �  �T ; note that this tiles with a black with priority set, so it will sit above sprites� �2    ,1    �$ ��26    ,0     ,16    ,8    �2 �16    ,3    �0     ,2    �8    ,9  	  �3 �16    ,3    �0     ,2    �8    ,12    �3 �16    ,3    �0     ,2    �8    ,15    � �%j=%P(1)=�{H(1    )}�V ��MUSIC�:��%j� �50  2  ,1    ,0     ,25    :��50  2  ,1    ,0     ,21    �+ �MUSIC˕50  2  ,2    :�50  2  ,3    � �%i=%0�%20:�1    :�%i�O �1    ,1    �0     ,0     �8    ,12    :�%i=%0�%20:�1    :�%i:;  G�O �1    ,1    �1    ,0     �10  
  ,12    :�%i=%0�%20:�1    :�%i:; A�O �1    ,1    �2    ,0     �12    ,12    :�%i=%0�%20:�1    :�%i:; M�O �1    ,1    �3    ,0     �14    ,12    :�%i=%0�%20:�1    :�%i:; E�O �1    ,1    �4    ,0     �17    ,12    :�%i=%0�%20:�1    :�%i:; O�O �1    ,1    �5    ,0     �19    ,12    :�%i=%0�%20:�1    :�%i:; V�O �1    ,1    �6    ,0     �21    ,12    :�%i=%0�%20:�1    :�%i:; E�O �1    ,1    �7    ,0     �23    ,12    :�%i=%0�%20:�1    :�%i:; R�� �%j˛9  	  ,1    �7    ,1    �11    ,14    :��7    ,1    �0     ,1    �12    ,14    :; "you ded" / "hi score"� �%i=%0�%20:�1    :�%i�	 �:���=""� �:����""�(�31    =16    )�[ �freeze():; not quite ideal, but it'll hopefully make the transition to main screen better� �saveHighScore()�	 �:���=""� ��� �� ;� �resetMusic()�= �50  2  ,1    ,0     ,20    :; reset to the main music� �50  2  ,2    � �MUSIC˕50  2  ,3    � �� ;� �saveHighScore()� %i=�H(1    )�3 �%P(1)>i�H(1    )=%P(1):�"assets/scores.bin"�H()� �� ;ς ; initBaddies: %A=Array[[x,y,spr,angle(0: x, 1: y),direction(0: backward, 1: forward),alive]] (allowing for more than 10 baddies)�& ; note: i*j = j properties per baddie� �initBaddies()� �%j=6    :;n props� �%i=1    �%c� �%A[i*j]=%(�6)*48:; 0 = x�C �%A[(i*j)+1]=%40+(�4*40):; 1 = y - baddies start on bottom 3 rungs�5 �%A[(i*j)+2]=0     :; 2 = delay (used to be SPRITE)�% �%A[(i*j)+3]=%�4:;3 = qaop/direction�[ ; if we're on the last baddie, then we'll set them to dead, but they'll come to life later�t �%i=1�%A[(i*j)+4]=%$0:�%A[(i*j)+4]=%$ff:; 4 = alive (note to self: I changed this to 1 and baddie walked backwards)�A �%A[(i*j)+5]=%44-(8*(c-i)):; 5 = sprite offset (for baddie type)�8 �%i,%A[i*j]+32,%A[(i*j)+1]+48,%A[(i*j)+5],%1&A[(i*j)+4]� �%i� �� ;� �initTombs()�T �%i=0     �20    :; note that index 20 is used for dumping invalid/out of bounds�k �%T(i)=%$f0:; this is 11110000 - each edge is the high nibble and set as closed/waiting to be masked later� �%i� �pickRandom()�5 ;    %W(3)=%4: ; use to force hidden baddie position�M ; generates: scroll (0), archaeologist (1), key (2), hidden mummy/baddie (3)�
 �%i=%0�%3� %T(W(i))=%$f1+i� �%i�$ ;   PRINT AT 22,0;"Hidden @ ";%W(3)� ; hides the baddie in a tomb� %A[6]=%(W(3)�5)*48+32+32� %A[7]=%(W(3)/5)*40+24+48� �1    ,%A[6],%A[7],,,� ;� ; treasures x 5�
 �%i=%4�%8� %T(W(i))=%$f5� �%i� �� ;� �pickRandom()� �%n:�%t:�%v:�%i�. %v=20    :; select from 0-20 (excluding 20)� %i=0     � ; init the 0-N array� ��	 %R(i)=%i� %i=%i+1� ��%i=v�& ; then go back downwards for P values� �  %t=%�i4 %W(v-i)=%R(t):; W is our global (winning positions) %i=%i-1 %R(t)=%R(i) ��%i=(v-9)! ; pickings are in global array W � ; �loadAssets()	 ��
 �2    ,1     ��9  	  ,12    	 �0      �
 �freeze() �252  �  :�0     :�0     : ��8 ; allows for stop and start when music is running still ���:�50  2  ,4    :��( ���:.uninstall "assets/nextdaw.drv" :�� .install "assets/nextdaw.drv"% ���:.uninstall "assets/ayfx.drv" :�� .install "assets/ayfx.drv"M ; note: I'm being a bit lavish with my banks here, but I could pretty easilyM ; upgrade the .map files to exist in a single file and single bank, just use/ ; offsets (same goes with .pal, .adb and .bin) �"assets/music.ndr"�20      �"assets/gameover.ndr"�21     �"assets/hiscore.ndr"�25    , �"assets/m-sprites.spr"�22    :��22    Y �"assets/mummy.map"�23    :;load tile map created at https://zx.remysharp.com/sprites/G �"assets/m-tiles.spr"�24    :��24    :; load spritesheet for tiles   �"assets/gameover.map"�26    ! �"assets/tombs.map"�27    " �"assets/mummy.pal"�28    #- �"assets/mummy.afb"�29    :; sound effects$ �"assets/font.bin"�64000   � %* ; bank 30 is used for temp layer 2,1 data&= �"assets/banner1.bin"�31    :; header for non-game screens'= �"assets/banner2.bin"�32     :; header for non-game screens(= �"assets/banner3.bin"�33  !  :; header for non-game screens)E ; this isn't particularly required, but I've got the space in memory*J ; and it means there's no pause in the music when the screens are loading+ �"assets/story.bin"�34  "  ,  �"assets/controls.bin"�35  #  - �"assets/credits.bin"�36  $  .  �"assets/discover.bin"�37  %  / �"assets/scores.bin"�H()0 �1 ;2 �initOnce()3C �loadAssets():; separate load allows for future single tape loader4 %m=%-15 PLAYING=0     6 DIFFICULTY=2    7 SPEED=2    8	 %S(1)=%49	 %S(2)=%8:
 %S(3)=%12;	 %C(1)=%0<
 %C(2)=%16= %C(3)=%236>
 %C(4)=%82? %C(5)=%128@ MUSIC=�DEBUGA ; init the sound effectsB �49  1  ,1    ,29    C ; fontD% �23606  6\ ,63744   � :; 64000-256E �2    ,1    F* ��2    :; trigger the font to be loadedG5 ; reduce the font into 7x8 (bit more space to write)H( ;PRINT CHR$ 30; CHR$ 7; CHR$ 31; CHR$ 7I ; colour paletteJ
 ��9  	  K ��0     �28    ,0     L
 ��0     M; �23658  j\ ,0     :; turn off CAPS LOCK (for menu items)N �O ;P �initGameVars()Q �%x=%96R	 �%y=%-16S �%s=%51:; s=spriteT �%q=%0:; last directU �%d=%1:; direction & speedV# �%P=%0:; %P = last player positionW �%a=%$ffffX �%t=%3Y �Z ;[
 �youWin()\ LEVEL=1    ] �setBorder(%0)^ SPEED=3    :; GO FAST!_
 ��0     ` �252  �  :�0     :�0     a �"assets/youdidit.sl2"�b �%y=7    c �narrowFont()d, ��%y+2,1    ;"You saved all five of the "e3 ��%y+3,1    ;"archaeologists. They're safe back"f/ ��%y+4,1    ;"home drinking tea and dunking"g' ��%y+5,1    ;"biscuits. Great work!"h4 ��%y+8,1    ;"But...a hero's work is never done."i/ ��%y+9,1    ;"More archaeologists have gone"j4 ��%y+10,1    ;"walkies, and they need your help."k2 ��%y+12,1    ;"Will you survive the challenge?"l �resetFont()m �0     :�252  �  n& ��%y+14,13    ;"Onward adventurer!"o �252  �  :�0     p �pressAnyKey()q �r ;s
 �freeze()t$ ; point Layer 2 to the shadow layeru ��12    ,9  	  v �w ;x �defrost()y ��9  	  ,9  	  z �{ ;| �initNewGame()} �welcome()~
 �freeze() �initPlayerState()� ; define player and game state� %z=%S(�{SPEED}):; baddie speed� PLAYING=1    � �resetFont()� �nextLevel(1    )� �� ;� �initPlayerState()�# %P(0)=%7-(�{DIFFICULTY}*2):; lives� %P(1)=%0:; score� %i=%�{SPEED}� %j=%�{DIFFICULTY}�  %P(2)=%(j-1)+i:; score multiple� �� ;� �resetPlayerState()�( %P(3)=%0:; has scroll / can kill baddie�" %P(4)=%$ffff:; player last corner� �� ;� �nextLevel(l)�	 �0     � LEVEL=l� �LEVEL=6    ˓youWin()� %j=%�{LEVEL}�+ %c=%j+1:; baddies increase with each level� ; 0x150, 0x1f8, 0x1e8, 0x168� ; offset values:�F ; yellow (0), orange (16), purple (236), party pink (82), green (128)� �2    ,1    �* %i=%C(j):;%i=%82 : ; used to test colours� ��0     ,33  !  ,%$150-i� ��0     ,34  "  ,%$1f8-i� ��0     ,35  #  ,%$1e8-i� ��0     ,36  $  ,%$168-i�: �0     :�2    :; note that ink 2 is changed on the fly� �resetPlayerState()� �initSprites()�! �%P(1)=0˜�0     ,2    ,%$1ff� �initBaddies()� �initTombs()� �initGameVars()�* �treadMark():; depends on player position�" �takeLife(%0):; renders the lives�* �printScore(%�{(LEVEL-1    )*50  2  })�1 ; show how many archaeologist's are left to save� �%i=2    �LEVEL�( �%55+i,%290,%14+(i*18),52  4  ,1    � �%i� �%i=LEVEL+1    �6    �( �%55+i,%290,%14+(i*18),53  5  ,1    � �%i� ; wait for a key up�	 �:���=""� �setBorder(%$168-C(�{LEVEL}))� �defrost()� �� ;� �dT()� �%g=%�23672�	 �%f=%g-n� �%g<n��%f=%f+256� �%n=%g� �=%f� ;� �optionsScreen()� �header(0     )� �%y=9  	  � DIFFICULTY=0     � %z=0     �$ ��%y+1,5    ;"Speed of nasties ?"�* ��%y+3,5    ;"[1] I'm a kid, be gentle"�# ��%y+5,5    ;"[2] regular speed"�$ ��%y+7,5    ;"[3] BRING IT ON!!!"� �100  d  � �� �Ѻ� �%j=%�{��}-$30� �%j<4�%z=%j� ��%z�0�) ��%y+(z*2+1),5    ;�1    ;" ";%z;" "�+ �%z=1���%y+10,5    ;"Gentle it shall be"�/ �%z=2���%y+10,5    ;"Not feeling brave, eh?"�+ �%z=3���%y+10,5    ;"Nutter. You're on."�' SPEED=%z:; maps 1 to 5, 2 to 3, 3 to 1�	 %z=%S(z)�* �:���="":; wait until the key is up again� �%i=%0�%50:�Ѻ:�%i� �header(0     )�$ ��%y+1,5    ;"Difficulty level ?"�) ��%y+3,5    ;"[1] I need ALL the help"�& ��%y+5,5    ;"[2] I'll manage fine"� ��%y+7,5    ;"[3] DEATHWISH"� �� �Ѻ� �%j=%�{��}-$30�2 �%j<4�DIFFICULTY=%j:; maps 1 to 3, 2 to 2, 3 to 1� ��DIFFICULTY�0     � ;PRINT AT %y+1,30;DIFFICULTY�) ��%y+(j*2+1),5    ;�1    ;" ";%j;" "�$ �%j=1���%y+10,5    ;"You got it!"�2 �%j=2���%y+10,5    ;"The nasties beg to differ"�& �%j=3���%y+10,5    ;"RAAAAAAAAA!!!"�* �:���="":; wait until the key is up again� �%i=%0�%50:�Ѻ:�%i� �header(0     )� MUSIC=2    �$ ��%y+1,5    ;"Background music ?"�" ��%y+3,5    ;"[y] IT ROCKS \m/"�& ��%y+5,5    ;"[n] I prefer to work"�  ��%y+6,5    ;"    in silence"� �� �Ѻ� c$=��d �c$="y"�MUSIC=1    :��%y+3,5    ;�1    ;" y ":��%y+10,3    ;"It's pretty banging isn't it?"�Z �c$="n"�MUSIC=0     :��%y+5,5    ;�1    ;" n ":��%y+10,5    ;"Okay, shusshing now"� ��MUSIC<2    �F �MUSIC=0     ˕50  2  ,4    :��50  2  ,2    :�50  2  ,3    �* �:���="":; wait until the key is up again� �%i=%0�%50:�Ѻ:�%i� �� ;� �narrowFont()�8 ��0     ,0     ;�30    ;�7    ;�31    ;�7    � �� ;� �resetFont()�8 ��0     ,0     ;�30    ;�8    ;�31    ;�8      � ; �creditScreen() �header(36  $  ) �%y=9  	  ( ��%y+1,3    ;"Written by Remy Sharp";. ��%y+2,3    ;"https://remysharp.com / @rem"( ��%y+4,3    ;"Sprites by Remy's kids"+ ��%y+6,3    ;"Music by Richard Faulkner"	Y ; font: https://spectrumcomputing.co.uk/entry/25364/ZX-Spectrum/The_8bit_Font_Collection
+ ��%y+8,3    ;"Font by Paul van der Laan" �0     :�252  �   ��%y+11,24    ;"Continue..." �252  �  :�0      �pressAnyKey() � ; �helpScreen() �header(34  "  ) �%y=9  	  @ ; 123456789012345678901234567890123456 (total column count: 36)( ��%y,2    ;"Rescue the original 1984"0 ��%y+1,2    ;"archaeologist party from their", ��%y+2,2    ;"failed pyramid plundering."3 ��%y+5,2    ;"Navigate five catacombs, avoiding"- ��%y+6,2    ;"the guardians, rescue those"- ��%y+7,2    ;"muppets and bring them back" ��%y+8,2    ;"to Blighty." �0     :�252  �   ��%y+11,24    ;"Continue..." �252  �  :�0     @ ;PAUSE 50: REPEAT : SPRITE MOVE INT : REPEAT UNTIL INKEY$ <> ""  �pressAnyKey()! �%y=8    " �header(37  %  )# ; the tokens from tombs.map$$ ��27    ,24    ,4    ,8    %- �4    ,3    � 0     ,0     �2    ,%y&/ �4    ,3    �12    ,0     �2    ,%y+3'/ �4    ,3    �24    ,0     �2    ,%y+6(/ �4    ,3    �48  0  ,0     �2    ,%y+9)" ��%y+1,6    ;"Rescue this dude"*, ��%y+4,6    ;"Key to escape the catacomb"+% ��%y+7,6    ;"Vanquish a guardian",' ��%y+10,6    ;"Gems means hi-scores"- �0     :�252  �  . ��%y+12,24    ;"Continue..."/ �252  �  :�0     0 �pressAnyKey()1 �"assets/baddies.sl2"�2 %y=8    3 �252  �  :�0     4 ��%y+1,7    ;"Lampshade"5 ��%y+5,7    ;"Spatula"6 ��%y+9,7    ;"Crazihare"7 ��%y+1,21    ;"Baddiebear"8 ��%y+5,21    ;"Springzoid"9 ��%y+9,21    ;"Tentackly": �0     :�252  �  ; ��%y+12,24    ;"Continue..."< �252  �  :�0     = �pressAnyKey()> �header(35  #  )? �%y=5    @0 ��%y+4,3    ;"Kempton joystick and keyboard";A ��%y+6,3    ;"Q= up"B ��%y+7,3    ;"A= down"C ��%y+6,18    ;"O= left"D ��%y+7,18    ;"P= right"E! ��%y+9,3    ;"H= halt / pause"F0 ��%y+11,3    ;"Surround a tomb to reveal the"G/ ��%y+12,3    ;"contents. Don't get chomped!"H �0     :�252  �  I ��%y+15,24    ;"Continue..."J �252  �  :�0     K@ ;PAUSE 50: REPEAT : SPRITE MOVE INT : REPEAT UNTIL INKEY$ <> ""L �pressAnyKey()M �creditScreen()N �O ;P ; %i = BANK_IDQ �header(%i)R �252  �  :�0     :�0     SM ; basically loading an SL2 file without the layer bit (and thus no file i/o)T �%i=0�%i=31    U �%i��9  	  V) �32     ��10  
  :; landing screen 2/3W) �33  !  ��11    :; landing screen 3/3X �Y ;Z �playScreen()[ �header(0     )\ �%y=9  	  ] ; make the font massive :)^ ��29    ;�1    _) ��%y,6    ;"Rescue the archaeologists"`# ��%y+2,8    ;"    Save the day!"a$ ��%y+4,8    ;"   Don't get eaten"b% ��0     ,0     ;�29    ;�0     c3 �11    �%$2400,%$1c00,0     :; last 4k is blackdI ��%21,0     ;�0     ;�252  �  ;"I-Instructions   O-Options    P-Play"e �f ;g �welcome()h �DEBUG˒:; FIXME removei �setBorder(%0)j PLAYING=0     k ��l
 ��0     m ��22    n ��24    oA ��:; switch to batching (though pretty sure this isn't required)p
 ��1    q �%x=304  0 :�%y=208  �  r  �64  @  ,%x,%y,48  0  ,%@1001s! �63  ?  ,%x,%y,46  .  ,1    tU ��64  @  ,0     �%x�-8    �,�,48  0  �49  1  ,�0001000    ,3    ,200  �  uU ��63  ?  ,0     �%x�-8    �,�,46  .  �47  /  ,�0001000    ,3    ,225  �  v �w �narrowFont()x �playScreen()y �defrost()z* ; start the music when the screen appears{ �resetMusic()| �} c$=�~$ �c$="i"˓helpScreen():�playScreen()' �c$="o"˓optionsScreen():�playScreen()� �Ѻ� c$=�� ��c$="p"ſ31    =16    � ��� �� ;� �pressAnyKey()� �:�Ѻ:���=""�" �:�Ѻ:����""�(�31    =16    )� �:�Ѻ:���=""� �� ;� �reportErr()� ��err,lin,st� e$=�err� ���:�50  2  ,4    :���( ���:.uninstall "assets/nextdaw.drv" :���% ���:.uninstall "assets/ayfx.drv" :��� �2    ,1    � ��� ��� ��� �� �7    :�0     :�7    � ��0     :; turn off sprites� ��30    ,�- �"Error:";e$;", line:";lin;", statement:";st� �waitForKeyClear()� �� ;� �exit()� ; use break to exit mid-game�& �PLAYING˓initNewGame():�mainLoop():�� �9999  ' � �� ;') �:��:��:��0     :�"mummy.bas"�0     :�' �2    ,1    :; soft reset