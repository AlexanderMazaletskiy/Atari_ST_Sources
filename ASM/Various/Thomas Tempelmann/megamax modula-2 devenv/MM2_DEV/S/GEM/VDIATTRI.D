DEFINITION MODULE VDIAttributes;


(*  Megamax Modula-2 GEM-Library :  Die VDI Attributfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  04.11.87
 *
 *  Version   2.2     V#0008
 *)
 
(*      Mit Hilfe der Routinen dieses Moduls wird festgelegt, auf welche
 *      Art und Weise die Ausgabeoperationen des Moduls 'VDIOutput' vor-
 *      genommen werden sollen. Die hierf�r notwendigen Aufz�hlungstypen
 *      m�ssen aus 'GEMGlobals' importiert werden. Au�erdem sind in 'Graf
 *      Base' die 16 Farben der Standardfarbpalette als Konstanten vor-
 *      definiert.
 *      Versucht man einen Wert zu setzen, der vom GEM nicht akzeptiert
 *      wird, so liefert 'GEMEnv.GemError' den Wert 'TRUE' und mit 'GEMEnv.
 *      ErrorNumber' kann die R�ckgabe des GEM erfragt werden. Diese R�ck-
 *      gabe stellt gleichzeitig den Wert dar, der vom GEM ersatzweise ge-
 *      setzt wurde (als Ordinalzahl).
 *)
 
 
FROM    SYSTEM     IMPORT WORD;

FROM    GrafBase   IMPORT WritingMode, BitBlk16x16;

FROM    GEMGlobals IMPORT LineType, LineEnding, MarkerType, TEffectSet,
                          TVertJust, THorJust, FillType;
 
FROM    GEMEnv     IMPORT DeviceHandle;


 
PROCEDURE SetWritingMode (handle: DeviceHandle; mode: WritingMode);

        (*  Mit Hilfe dieser Routine wird der aktuelle Zeichenmodus
         *  f�r alle VDI Ausgaberoutinen festgelegt.
         *)
        
PROCEDURE DefineColor (handle                 : DeviceHandle;
                       color, red, green, blue: CARDINAL);

        (*  Hiermit wird das Aussehen der Farbe bestimmt, die den Farb-
         *  index 'color' hat. 'red', 'green' und 'blue' geben den RGB-
         *  Wert der Farbe in Promille an (Wertebereich 0 - 1000).
         *)
         
         
                (*  Linien Attribute  *)
                (*  ================  *)

                         
PROCEDURE SetLineType (handle: DeviceHandle; type: LineType);

        (*  Der aktuelle Linientyp wird festgelegt, dabei gibt es
         *  folgende M�glichkeiten:
         *
         *  'solidLn'      -- Durchgezogene Linie ( **************** )
         *  'longDashLn'   -- Gestrichelte Linie  ( ************---- )
         *  'dottedLn'     -- Gepunktete Linie    ( ***-----**------ )
         *  'dashDotLn'    --                     ( ******---***---- )
         *  'dashedLn'     -- Kurz gestrichelt    ( ********-------- )
         *  'dashDotDotLn' --                     ( ****---**--**--- )
         *  'userLn'       -- Benutzerdefiniertes Linienmuster
         *)

PROCEDURE DefUserLine (handle: DeviceHandle; pattern: WORD);

        (*  Mit dieser Routine kann man das benutzerdefinierte Linien-
         *  muster festlegen. Das h�chstwertige Bit legt den linken
         *  Punkt des Musters fest.
         *)

PROCEDURE SetLineWidth (handle: DeviceHandle; width: CARDINAL);

        (*  Hiermit legt man die Linienst�rke in Pixel fest.
         *  Es sind nur ungerade Zahlen erlaubt.
         *)

PROCEDURE SetLineColor (handle: DeviceHandle; color: CARDINAL);

        (*  Es wird festgelegt welcher Farbnindex 'color' zum Zeichnen
         *  von Linien verwendet werden soll.
         *)


PROCEDURE SetLineEndings (handle    : DeviceHandle;
                          begin, end: LineEnding);

        (*  Das Aussehen der Linienenden wird bestimmt, es bedeutet:
         *
         *  'edgedLn'   -- Eckiges Ende (Standardwert)
         *  'arrowedLn' -- Pfeilartiges Ende
         *  'roundedLn' -- Abgerundetes Ende
         *)
         

                (*  Makierungs Attribute  *)
                (*  ====================  *)


PROCEDURE SetMarkerType (handle: DeviceHandle; type: MarkerType);

        (*  Damit bestimmt man das Aussehen von Markierungen,
         *  wobei man die folgenden Alternativen hat:
         *
         *  'pointMark'   -- Einzelner Punkt
         *  'plusMark'    -- Pluszeichen
         *  'starMark'    -- Stern ('*')
         *  'squareMark'  -- Quadrat
         *  'crossMark'   -- Kreuz ('X')
         *  'diamondMark' -- Raute
         *)

PROCEDURE SetMarkerHeight (handle: DeviceHandle; height: CARDINAL);

        (*  Die Gr��e einer einzelnen Markierung wird mit dieser Routine
         *  festgelegt.
         *
         *  Hinweis: Beim ATARI sind nur Vielfache von 11 erlaubt.
         *)

PROCEDURE SetMarkerColor (handle: DeviceHandle; color: CARDINAL);

        (*  Hiermit wird die Markierungsfarbe bestimmt.
         *)


                (*  Text Attribute  *)
                (*  ==============  *)

PROCEDURE SetAbsTHeight (    handle                    : DeviceHandle;
                             height                    : CARDINAL;
                         VAR charW, charH, cellW, cellH: CARDINAL);
                         
        (*  Diese Routine dient zum Einstellen der Texth�he.
         *
         *  'height'    -- Die H�he von der Grundlinie (baseline) bis
         *                 zum oberen Rand (topline).
         *  'handle'    -- bezeichnet das Ausgabeger�t.
         *
         *  Ausgabeparameter
         *  ----------------
         *  die neuen Werte f�r
         *  'charW'     -- Zeichenbreite
         *  'charH'     -- Zeichenh�he
         *  'cellW'     -- Zellenbreite
         *  'cellH'     -- Zellenh�he
         *
         *  Bei einem proportionalen Zeichensatz wird die Breite des
         *  breitesten Zeichens zur�ckgegeben.
         *)

PROCEDURE SetPtsTHeight (    handle                    : DeviceHandle;
                             height                    : CARDINAL;
                         VAR charW, charH, cellW, cellH: CARDINAL);
                         
        (*  Entspricht im wesentlichen 'SetAbsTHeight', nur wird hier
         *  die H�he der gesamten Zeichenzelle angegeben.
         *
         *  'height'    -- H�he der Zelle in Punkt, wobei ein Punkt
         *                 1/72 Inch entspricht
         *
         *  Die VAR-Parameter entsprechen denen von 'SetAbsTHeight'.
         *)

PROCEDURE SetTBaseLine (handle: DeviceHandle; angle: CARDINAL);

        (*  Die Ausrichtung der Grundlinie (base line) wird in 1/10 Grad
         *  angegeben.
         *
         *  'angle'     -- Die gesamte Ausgabe wird um 1/10 * angle
         *                 Grad entgegen dem Uhrzeigersinn gedreht.
         *                 Leider sind hierf�r nur die Werte 0, 900,
         *                 1800, 2700 erlaubt.
         *)
         
PROCEDURE SetTextFace (handle: DeviceHandle; font: CARDINAL);

        (*  Hiermit kann man den Zeichensatz bestimmen, der forthin bei
         *  Textausgaben benutzt werden soll.
         *  Die Font-Nummer wird bei VDIInquires.GetFaceName ermittelt.
         *)

PROCEDURE SetTextColor (handle: DeviceHandle; color: CARDINAL);

        (*  Der Farbindex der f�r die Textausgabe bestimmten Farbe
         *  wird festgelegt.
         *)


PROCEDURE SetTextEffects (handle: DeviceHandle; effects: TEffectSet);

        (*  Damit k�nnen bei Textausgaben besondere Effekte erzielt
         *  werden. Folgende Effekte, die beliebig kombiniert werden
         *  k�nnen, stehen zur Verf�gung:
         *
         *  'thickText'     -- Fettschrift
         *  'lightText'     -- Aufgehellte Schrift
         *  'slantText'     -- Kursive Schrift
         *  'underlineText' -- Die Schrift wird unterstrichen
         *  'outlineText'   -- Umrahmte Schrift
         *  'shadowText'    -- Schrift wird schattiert (Ist im GEM noch
         *                     nicht implementiert)
         *
         *  Hinweis: Einige Kombinationen sind allerdings nicht besonders
         *           sehenswert.
         *)
         

PROCEDURE SetTAlignment (handle: DeviceHandle;
                         hor   : THorJust;
                         vert  : TVertJust);

        (*  Hiermit kann der Text horizontal und vertikal ausgerichtet
         *  werden.
         *
         *  Horizontale Ausrichtung:
         *
         *  'leftJust'   -- Der Text wird linksb�ndig ausgegeben (Standardwert)
         *  'centerJust' -- Der Text wird zentriert
         *  'rightJust'  -- Der Text wird rechtsb�ndig ausgegeben
         *
         *  Vertikale Ausrichtung,
         *
         *  'baseJust'    -- an der base line (Grundlinie; Standardwert)
         *  'halfJust'    -- an der half line (Grenze der Kleinbuchstaben)
         *  'ascentJust'  -- an der ascent line (Grenze der Gro�buchstaben)
         *  'bottomJust'  -- an der bottom line (Unterer Rand der Zeichenzelle)
         *  'descentJust' -- an der descent line (Grenze der Unterl�ngen)
         *  'topJust'     -- an der top line (Oberer Rand der Zeichenzelle
         *)
         
         
                (*  F�ll Attribute  *)
                (*  ==============  *)


PROCEDURE SetFillType (handle: DeviceHandle; type: FillType);

        (*  Damit wird der F�lltyp bestimmt. Es werden folgende Typen
         *  unterst�tzt:
         *
         *  'hollowFill'   -- Die Fl�che wird nicht gef�llt.
         *  'solidFill'    -- Die Fl�che wird vollst�ndig mit der aktuellen
         *                    F�llfarbe gef�llt.
         *  'dottPattern'  -- Die Fl�che wird mit einem Punktmuster gef�llt.
         *  'hatchPattern' -- Die Fl�che wird mit einem Strichmuster gef�llt.
         *  'userPattern'  -- Die Fl�che wird mit einem selbstdefinierten
         *                    Muster gef�llt.
         *)

PROCEDURE SetFillIndex (handle: DeviceHandle; index: CARDINAL);

        (*  Diese Routine dient zum setzen des aktuellen F�llmusters.
         *  Ist der F�lltyp 'dottPattern', so kann man aus 24 ver-
         *  schiedenen Punktmuster eines ausw�hlen (index = 1..24),
         *  beim Typ 'hatchPattern' stehen 12 unterschiedliche Schraf-
         *  furen zur Auswahl (index = 1..12).
         *)

PROCEDURE SetFillColor (handle: DeviceHandle; color: CARDINAL);

        (*  Der Farbindex der aktuellen F�llfarbe wird festgelegt.
         *)

PROCEDURE SetFillPerimeter (handle: DeviceHandle; visible: BOOLEAN);

        (*  Diese Procedur erlaubt es, die Umrahmung von F�llfl�chen
         *  ein- und auszuschalten. Der Rahmen wird, falls gew�nscht,
         *  in der aktuellen F�llfarbe gezeichnet und die Linienattri-
         *  bute werden nicht beachtet.
         *
         *  'TRUE'  -- Rahmen zeichnen
         *  'FALSE' -- Rahmen weglassen
         *)


TYPE    FillPattern     = RECORD
                            CASE planes : CARDINAL OF
                              1: hiResPlane   : BitBlk16x16|

                              2: midResPlane1 : BitBlk16x16;
                                 midResPlane2 : BitBlk16x16|

                              4: lowResPlane1 : BitBlk16x16;
                                 lowResPlane2 : BitBlk16x16;
                                 lowResPlane3 : BitBlk16x16;
                                 lowResPlane4 : BitBlk16x16|
                            END;
                          END;
        PtrFillPattern  = POINTER TO FillPattern;

PROCEDURE DefUserFill (handle: DeviceHandle; pattern: PtrFillPattern);

        (*  Hiermit kann ein eigenes F�llmuster definiert werden.
         *  'pattern' ist ein Zeiger auf eine F�llmusterdefinition.
         *
         *  In 'pattern^.planes' wird die Anzahl der Bitebenen ein-
         *  getragen, dabei gilt:
         *
         *      Hohe Aufl�sung     -- 1 Bitebene  (schwarz/wei� Darstellung)
         *      Mittlere Aufl�sung -- 2 Bitebenen (4 verschiedene Farben)
         *      Niedrige Aufl�sung -- 4 Bitebenen (16 verschiedene Farben)
         *
         *  In dem varianten Teil des Records wird f�r jede Bitebene
         *  ein 16 x 16 Bit gro�es Muster angegeben.
         *)

END VDIAttributes.
