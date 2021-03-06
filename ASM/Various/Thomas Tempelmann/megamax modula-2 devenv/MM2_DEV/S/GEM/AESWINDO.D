DEFINITION MODULE AESWindows;


(*  Megemax-Module 2 GEM-Library :  Die AES Fensterfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  05.11.87
 *
 *  Version   2.2     V#0016
 *)


FROM    MOSGlobals      IMPORT MemArea;

FROM    GrafBase        IMPORT Point, Rectangle;

FROM    GEMGlobals      IMPORT PtrMaxStr, PtrObjTree;



                (*  Window Manager  *)
                (*  ==============  *)


CONST   NoWindow        = 65535;    (*  Dies ist der Wert f�r ein nicht be-
                                     *  setztes Window-Handle
                                     *)

        DeskHandle      = 0;        (*  Dies ist das Fensterkennung der
                                     *  Desktop-Oberfl�che
                                     *)


TYPE    WindowElement   = (nameBar,    closer,    fuller,     mover,
                           infoBar,    sizer,     upArrow,    downArrow,
                           vertSlider, leftArrow, rightArrow, horSlider);

        WElementSet     = SET OF WindowElement;


PROCEDURE CreateWindow (    elems : WElementSet;
                            max   : Rectangle;
                        VAR handle: CARDINAL   );

        (*  Es wird ein neues Fenster beim AES angemeldet.
         *
         *  'elems'     -- die Elemente, die das Fenster besitzt.
         *  'max'       -- die maximalen Ausma�e des Fensters.
         *  'handle'    -- liefert die Fensterkennung als Ergebnis.Be-
         *                 sitzt es den Wert 'NoWindow', so konnte kein
         *                 Fenster mehr erzeugt werden. (Das GEM ist nur
         *                 f�r eine Verwaltung von h�chstens sieben
         *                 Fenstern ausgelegt).
         *)

PROCEDURE OpenWindow (handle: CARDINAL; frame: Rectangle);

        (*  Das Fenster mit der Kennung 'handle' wird in der Gr��e 'frame'
         *  auf den Bildschirm gebracht.
         *)

PROCEDURE CloseWindow (handle: CARDINAL);

        (*  Das durch die Kennung 'handle' bezeichnete Fenster wird vom
         *  Bildschirm entfernt. Es wird dabei nicht aus dem Speicher
         *  gel�scht.
         *)

PROCEDURE DeleteWindow (handle: CARDINAL);

        (*  Das Fenster, das die Kennung 'handle' besitzt wird abgemeldet.
         *  Das bedeutet, da� dieses Fenster nicht mehr angesprochen werden
         *  darf, es ist gel�scht.
         *)


TYPE    WSizeMode       = (workSize, borderSize, previousSize, fullSize);

PROCEDURE WindowSize (handle: CARDINAL; typ: WSizeMode): Rectangle;

        (*  Diese Funktion liefert die Ausma�e eines Fensters. Es k�nnen
         *  folgende Ausma�e erfragt werden:
         *
         *  'workSize'     -- Die Gr��e des Arbeitsbereichs (ohne Fenster-
         *                    elemente)
         *  'borderSize'   -- Die Gr��e des gesamten Fensters (mit Fenster-
         *                    elementen)
         *  'previousSize' -- Die letzte Gr��e des Gesamtfensters
         *  'fullSize'     -- Die maximale Gr��e des Fensters
         *
         *  Insbesondere k�nnen, mit Hilfe der Kennung 'DeskHandle', die
         *  Ausma�e des Desktop's erfragt werden.
         *)


TYPE    WSliderMode     = (horPosition, vertPosition, horSize, vertSize);

PROCEDURE WindowSliderValue (handle: CARDINAL; typ: WSliderMode): INTEGER;

        (*  Es wird die Position eines Fensterschiebers geliefert.
         *  'handle' enth�lt die Fensterkennung und 'typ' kann fol-
         *  gende Werte annehmen:
         *
         *  'horPosition'  -- Position des horizontalen Schiebers
         *  'vertPosition' -- Position des vertikalen Schiebers
         *  'horSize'      -- Ausma�e des horizontalen Schiebers
         *  'vertSize'     -- Ausma�e des vertikalen Schiebers
         *
         *  Schieberposition und Schiebergr��e werden in Promille ange-
         *  geben (Wertebereich: 0 - 1000), bei der Schiebergr��e ist
         *  allerdings auch der Wert -1 zugelassen, der die kleinste
         *  m�gliche Gr��e repr�sentiert.
         *)

PROCEDURE TopWindow (): CARDINAL;

        (*  Liefert die Fensterkennung des oben aufliegenden Fensters.
         *)


TYPE    RListMode       = (firstElem, nextElem);

PROCEDURE WindowRectList (handle: CARDINAL; typ: RListMode): Rectangle;

        (*  Zum Zeichnen innerhalb teilweiser verdeckter Fensterbereiche
         *  ist es unerl��lich, die nicht verdeckten Ausschnitte zu ken-
         *  nen. Genau diese Ausschnitte sind in der so genannten Recht-
         *  eckliste, die von dieser Funktion ausgelesen wird, festgehal-
         *  ten. Das Ende der Liste ist durch ein Rechteck mit der Fl�che
         *  Null gekennzeichnet.
         *  Besitzt 'typ' den Wert 'firstElem', so wird das erste Element
         *  der Rechteckliste gelesen. Bei jedem folgenden Aufruf mit
         *  'nextElem' wird sukzessiv ein weiteres Element ermittelt.
         *)

PROCEDURE ScreenBuffer (handle: CARDINAL): MemArea;

        (*  Es wird die Beschreibung eines Speicherbereichs geliefert,
         *  der vom AES zur Zwischenspeicherung von Bildschirminhalten
         *  benutzt wird.
         *  Dieser Bereich kann ohne weiteres auch von Anwendungspro-
         *  grammen mitverwendet werden. Allerdings sollte er nur f�r
         *  kurzfristige Aufgaben benutzt werden. Sein Umfang betr�gt
         *  in der Regel circa 8 kByte.
         *  Beim Aufruf der Funktion mu� als Kennung ('handle') 'Desk
         *  Handle' eingetragen werden.
         *)


TYPE    WStringMode     = (nameStr, infoStr);

PROCEDURE SetWindowString (handle: CARDINAL;
                           typ   : WStringMode;
                           str   : PtrMaxStr);

        (*  Einem Fenster wird eine Zeichenkette f�r einen Namen oder
         *  eine Informationszeile zugewiesen.
         *
         *  'handle'    -- Die Kennung des Fensters
         *  'typ'       -- '= nameStr': Name
         *                 '= infoStr': Infozeile
         *  'str'       -- Enth�lt einen Zeiger auf die Zeichenkette.
         *)

PROCEDURE SetWindowSize (handle: CARDINAL; frame: Rectangle);

        (*  Damit werden die Fensterausma�e des Fensters 'handle' auf
         *  'frame' gesetzt.
         *  Es mu� immer die Gr��e der Fensterau�enma�e angegeben werden.
         *)

PROCEDURE SetWindowSlider (handle: CARDINAL;
                           typ   : WSliderMode;
                           value : INTEGER);

        (*  Setzt ein Fensterschieberparameter auf den Wert 'value'.
         *  Die Parameterbeschreibung entspricht der von 'WindowSliderValue'.
         *)

PROCEDURE SetTopWindow (handle: CARDINAL);

        (*  Das Fenster mit der Kennung 'handle' wird nach oben gebracht.
         *)

PROCEDURE SetNewDesk (tree: PtrObjTree; first: CARDINAL);

        (*  Diese Routine erlaubt es eine eigene Desktop-Oberf�che anzu-
         *  melden. Dadurch kann der Bildschirmhintergrund frei gestaltet
         *  werden. Die Oberfl�che mu� in Form eines Objektbaumes vor-
         *  liegen.
         *  'tree'      -- derObjektbaum
         *  'first'     -- gibt das erste zu Zeichnende Objekt des
         *                 Baumes an.
         *
         *  Hinweis: Durch das Anmelden wird der neue Hintergrund noch
         *           nicht dargestellt, daf�r mu� erst ein Neuzeichnen
         *           veranla�t werden (Siehe 'AESForms.FormDial').
         *)

PROCEDURE FindWindow (loc: Point): CARDINAL;

        (*  Diese Funktion ermittelt, welches Fenster sich an der Position
         *  'loc' befindet. Als Ergebnis wird die Fensterkennung geliefert.
         *)

PROCEDURE UpdateWindow (update: BOOLEAN);

        (*  Hiermit wird dem AES mitgeteilt, zu welchem Zeitpunkt eine An-
         *  wendung Ausgaben in ein Fenster t�tigen will. W�hrend dieser
         *  Zeit reagiert das AES nicht auf Versuche des Anwenders die Menu-
         *  zeile zu benutzen oder Fensterelemente zu bedienen.
         *  Mit 'update = TRUE' werden die Ausgaben eingeleitet und mit
         *  'FALSE' beendet.
         *  Diese Routine hat einen internen Z�hler, so da� f�r zwei ge-
         *  schachtelte Aufrufe mit 'TRUE' auch zwei mit 'FALSE' folgen
         *  m��en.
         *)

PROCEDURE MouseControl (user: BOOLEAN);

        (*  Die Reaktion des AES auf diese Routine entspricht im wesentlichen
         *  der auf 'UpdateWindow', nur ist daf�r vorgesehen, da� die Anwen-
         *  dung die Kontrolle �ber alle Mausfunktionen selbst �bernimmt.
         *)


TYPE    WCalcMode       = (calcBorder, calcWork);

PROCEDURE CalcWindow (typ  : WCalcMode;
                      elems: WElementSet;
                      in   : Rectangle  ): Rectangle;

        (*  Diese Funktion berechnet aus Fensterau�enma�en die Arbeitsbe-
         *  reichsma�e und umgekehrt.
         *
         *  'elems'      -- enth�lt die Fensterelemente
         *
         *  F�r 'typ' gilt:
         *
         *  'calcBorder' -- 'in' enth�lt Arbeitsbereichsgr��e und das Er-
         *                   gebnis sind die Au�enma�e.
         *  'calcWork'   -- 'in' enth�lt die Au�enma�e un das Ergebnis ist
         *                   die Arbeitsbereichsgr��e.
         *)


PROCEDURE ResetWindows ();

        (*  Es werden alle noch offenen Fenster der Applikation geschlossen,
         *  au�erdem wird 'UpdateWindow' und 'MouseControl' zur�ckgesetzt.
         *
         *  ACHTUNG: Diese Prozedur ist erst ab TOS 1.4 funktionsf�hig.
         *           Die TOS-Version kann mit 'GEMEnv.GEMVersion' erfragt
         *           werden.
         *)


END AESWindows.