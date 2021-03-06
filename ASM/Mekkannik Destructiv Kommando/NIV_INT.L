
  TABLEAU DES NIVEAUX D'INTERRUPTIONS DU 68000 ET DU 68901 PAR METAL68


                 Niveau         Adresse       Description
             +~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
             |      7             $7C           NMI (Reset)                                          |
             |      6             $78           MFP 68901                                            |
             |      5             $74                                                                |
             |      4             $70           VBL, retour d'image                                  |
             |      3             $6C                                                                |
             |      2             $68           HBL, retour de ligne                                 |
             |      1             $64                                                                |
             |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
             | Niveau 6 : MFP 68901                                                                  |
             |                                                                                       |
             |     15            $13C           Detection de moniteur monochrome                     |
             |     14            $138           Indicateur de sonnerie RS232                         |
             |     13            $134           Timer A (disponible)                                 |
             |     12            $130           Tampon de reception RS232 plein                      |
             |     11            $12C           Erreur de reception RS232                            |
             |     10            $128           Tampon d'emission RS232 plein                        |
             |      9            $124           Erreur d'emission RS232                              |
             |      8            $120           Timer B,Compteur d'interruptions horizontales        |
             |      7            $11C           Controleur de disque et de DMA                       |
             |      6            $118           ACIA 6850  ( MIDI et Clavier )                       |
             |      5            $114           Timer C ( Horloge systeme a 200 Hz )                 |
             |      4            $110           Timer D ( Horloge de cadencement RS232)              |
             |      3            $10C           Controleur video ( fin d'operation )                 |
             |      2            $108           CTS de l'E/S serie                                   |
             |      1            $104           DCD de l'E/S serie                                   |
             |      0            $100           Ligne BUSY de l'interface parallele                  |
             |                                                                                       |
             +~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
 COMPLEMENT SUR LE MFP 68901
 ---------------------------

Registres 4 et 5 ( Interrupt Enable Register )

 le MFP a 16 sources d'interruption, ces 16 sources peuvent etre autorisees ou non . Pour cela il faut 2 registres IERA et IERB
Si un bit est a 1 l'interruption est autorise, s'il est a 0 elle n'est pas autorisee ; c'est a dire que si une interruption
survient alors que le bit est a 0 cette interruption est ignoree.

 IERA ( adresse $FFFA07 )
--------------------------
bit 7: bit 7 du port E/S           Priorite la plus grande
bit 6: bit 6 du port E/S
bit 5: Timer A
bit 4: tampon de reception plein
bit 3: erreur de reception
bit 2: tampon d'emission vide
bit 1: erreur d'emission
bit 0: Timer B


 IERB ( adresse $FFFA09 )
--------------------------
bit 7: bit 5 du port E/S
bit 6: bit 4 du port E/S
bit 5: Timer C
bit 4: Timer D
bit 3: bit 3 du port E/S
bit 2: bit 2 du port E/S
bit 1: bit 1 du port E/S
bit 0: bit 0 du port E/S           Priorite la plus faible


 Registre 8 et 9 ( Interrupt In-Service Register )
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 ISRA ( $FFFA0F ) et ISRB ( $FFFA11 )
--------------------------------------
Le ST travaille en mode ~ Software End of Interrupt ~ c'est a dire :
     - Lorsqu'une interruption est demandee par le MFP, le bit ISR correspondant a cette interruption est mis a 1 ; ainsi
       durant le traitement de l'interruption , aucune autre interruption de meme niveau et de niveau inferieur ne sera traitee
       tant que ce bit est a 1 . C'est pourquoi a la fin du traitement de l'interruption il faut remettre ce bit a 0 .

 la disposition de ces bits est identique aux registres IER

 