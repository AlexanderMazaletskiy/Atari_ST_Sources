DEFINITION MODULE WindowLists;

(*  System              : Megamax Modula-2
 *  Autor & Copyright   : Manuel Chakravarty
 *  Vertrieb            : Application Systems Heidelberg
 *  Version             : V1.4
 *)

(*  Dieses Modul dient zur weitgehend automatischen Verwaltung von Fenster,
 *  deren Inhalt aus zeilenorientiertem Text besteht. Zur Beschreibung des
 *  Fensterinhalts wird eine Liste verwendet, deren einzelne Elemente die
 *  Daten f�r je eine Zeile des Fensters enthalten.
 *
 *  Eine Beispielanwendung zeigt das Modul 'WDWLists' im DEMO-Ordner!
 *
 *  Einige Bemerkungen zu den F�higkeiten und der Programmierung
 *  ------------------------------------------------------------
 *
 *  -- Jede Zeile eines Fensterliste kann mit einer Reihe von Attributen ver-
 *     sehen werden, um sie zu kennzeichnen oder herauszuheben. Eine spezielle
 *     Funktion erf�llt das Attribut 'selectWL' (Siehe 'DetectWindowWL' und
 *     'SelectAreaWL').
 *  -- Da die Abbildung der Listenelemente auf die angezeigten Zeichenketten
 *     durch eine vom Klientenmodul bestimmte Prozedur erfolgt, ist das Format
 *     der Listenelemente und der Zeichenketten beliebig. Die einzige Ein-
 *     schr�nkung ist, da� ein Listeneintrag auf genau eine Textzeile im Fen-
 *     ster abbgebildet werden mu�.
 *  -- Die Listen werden mit der Prozedur 'SetListWL' gesetzt und k�nnen mit
 *     'GetListWL' wieder zur�ckgefordert werden. Ein Wechsel zwischen zwei
 *     verschiedenen Listen ist auch w�hrend das Fenster offen ist m�glich,
 *     doch sollte 'GetListWL' und 'SetListWL' m�glichst direkt aufeinander
 *     folgen.
 *  -- Beispiel f�r die Anwendung dieses Moduls sind die Directory- und Modul-
 *     Fenster der Module-Shell oder die (noch) auszudruckenden Files eines
 *     Druckerspoolers oder Kurzdarstellung aller Datens�tze einer Datei.
 *
 *  Implementationshinweis: Dieses Modul basiert in seinen wesentlichen
 *    Funktionen vollst�ndig auf 'WindowBase' und einigen VDI-Routinen.
 *)


FROM SYSTEM     IMPORT ADDRESS;

FROM Strings    IMPORT String;

FROM Lists      IMPORT List;

FROM GrafBase   IMPORT Point, Rectangle;

FROM GEMGlobals IMPORT MaxStr;

FROM WindowBase IMPORT CenterWdw, MaxWdw;


TYPE    WindowList;

        (*  M�gliche Attribute eines 'WindowList'-Eintrags.
         *)

        AttributeWL      = (selectedWL, disabledWL, markedWL);
        AttributesWL     = SET OF AttributeWL;

        (*  Diese, vom Klientenmodul zu stellende Prozedur, wandelt die Daten
         *  eines Listenelements in die im Fenster darzustellende Zeichen-
         *  kette um.
         *)
        EntryToStrProcWL= PROCEDURE (    (*entry      : *) ADDRESS,
                                         (*environment: *) ADDRESS,
                                     VAR (*str        : *) MaxStr);

        (*  Eine Prozedur diesen Typs wird aufgerufen, sobald der Anwender
         *  den Close-Button eines Fenster angeklickt hat.
         *)
        CloseProcWL     = PROCEDURE ((*wl         : *) WindowList,
                                     (*environment: *) ADDRESS   );

        (*  Eine Prozedur diesen Typs wird aufgerufen, sobald der Benutzer
         *  einen Fenstereintrag angew�hlt hat.
         *  Zusicherung: Diese Prozedur wird niemals f�r einen Eintrag auf-
         *               gerufen, der das Attribut 'disabledWL' besitzt.
         *)
        SelectEntryProcWL= PROCEDURE ((*wl         : *) WindowList,
                                      (*entry      : *) ADDRESS,
                                      (*environment: *) ADDRESS,
                                      (*selMode    : *) LONGCARD);


CONST   NoWindowList    = WindowList (NIL);

        CenterWindowWL  = CenterWdw;    (*  Hor./vert. zentriert          *)
        MaxWindowWL     = MaxWdw;       (*  Maximale Fensterbreite/-h�he  *)



                        (*  Verwaltungsroutinen  *)
                        (*  ===================  *)

PROCEDURE CreateWL (VAR wl      : WindowList;
                        infoline: BOOLEAN;
                        size    : Rectangle);

        (*  Dient zum Erzeugen einer neuen Fensterliste.
         *
         *  Dabei gibt 'size' die anf�nglichen Ausma�e des Fensters in Zeichen-
         *  koordinaten an. Als Sonderwerte d�rfen auch 'CenterWindowWL' und
         *  'MaxWindowWL' angegeben werden.
         *  Ist 'infoLine = TRUE', so erh�lt das Fenster eine Informations-
         *  zeile.
         *
         *  Ist danach 'StateWL (wl) = invalidWL', so konnte die Fensterliste
         *  nicht korrekt erzeugt werden.
         *)

PROCEDURE SysCreateWL (VAR wl      : WindowList;
                           infoline: BOOLEAN;
                           size    : Rectangle);

        (*  Dient zum Erzeugen einer Fensterliste, die bei Modulterminierung
         *  nicht automatisch abgemeldet wird.
         *
         *  Parameter entsprechen 'SysCreateWL'.
         *)

PROCEDURE DeleteWL (VAR wl: WindowList);

        (*  Dient zum Freigeben einer nicht mehr ben�tigten Fensterliste.
         *)

PROCEDURE SetListWL (    wl         : WindowList;
                         l          : List;
                         entryToStr : EntryToStrProcWL;
                         closeWList : CloseProcWL;
                         selectEntry: SelectEntryProcWL;
                         environment: ADDRESS;
                         width      : CARDINAL;
                     REF title      : ARRAY OF CHAR);

        (*  Diese Routine dient zum Spezifizieren des Inhalts und des
         *  Verhaltens einer Fensterliste und zum Setzen des Fonts
         *  (Zeichensatz).
         *
         *  Dabei ist 'l' eine Liste, deren Elemente den Inhalt je einer
         *  Zeile des Fensterinhaltes bestimmen, 'entryToStr' eine Pro-
         *  zedur, die ein Listenelement in die darzustellende Zeichen-
         *  kette umwandelt. 'closeWList' wird beim Anklicken des Close-
         *  Buttons und 'selectEntry' beim Anklicken einer Fensterzeile
         *  mittels 'DetectWindowWL' aufgerufen. 'environment' wird beim
         *  Aufruf jeder der drei vorangegangenen Prozeduren mit �bergeben
         *  und steht dem Klientenmodul zur freien Verf�gung (Ersatz einer
         *  dynamischen Aufrufumgebung). Au�erdem legt 'width' die maximale
         *  Breite eines Fenstereintrages und 'title' den Fenstertitel fest.
         *
         *  ACHTUNG: Die Liste 'l' darf nach diesem Aufruf nicht mehr vom
         *           Klientenmodul verwendet werden (weder schreibend noch
         *           lesend). Siehe auch 'GetListWL'.
         *           Die in 'l' verwalteten Adressen m�ssen paarweise ver-
         *           schieden und ungleich 'NIL' sein.
         *
         *  Um den Font zu setzen, ist f�r "entryToStr" 'EntryToStrProcWL(NIL)'
         *  zu �bergeben.
         *  'width' bestimmt dann die Zeichenh�he in Punkt (s. SetPtsTHeight)
         *  und 'title' bestimmt den Namen des Fonts. Die restlichen Parameter
         *  sind unbenutzt und d�rfen beliebige Werte enthalten.
         *  Wird 'NoWindowList' in 'wl' �bergeben, wird der Default-Font
         *  bestimmt, der beim Anlegen (CreateWL) aller neuen Fenster benutzt
         *  wird. Ansonsten wird der aktuelle Font des angegebenen Fensters
         *  ersetzt.
         *)

PROCEDURE GetListWL (wl: WindowList; VAR l: List);

        (*  Hiermit erh�lt das Klientenmodul wieder Zugriff auf eine mit
         *  'SetListWL' �bergeben Liste. Zugleich werden alle anderen
         *  mit diesem 'SetListWL' gemachten Angaben aufgehoben.
         *
         *  ACHTUNG: Falls die Fensterliste 'wl' zum Zeitpunkt dieses Auf-
         *           rufs sichtbar ist, so mu� sichergestellt werden, da�
         *           keine Aktionen ausgel��t werden, die dieses Fenster
         *           betreffen, bis es entweder versteckt wird oder mit
         *           'SetListWL' erneut g�ltige Parameter erh�lt.
         *)

PROCEDURE ShowWindowWL (wl: WindowList);

        (*  Die Fensterliste wird auf dem Bildschirm dargestellt oder falls
         *  sie schon sichtbar war, neu gezeichnet.
         *)

PROCEDURE HideWindowWL (wl: WindowList);

        (*  Die Fensterliste wird vom Bildschirm entfernt.
         *)

PROCEDURE EnhancedOutputWL (wl: WindowList; enhanced: BOOLEAN);

        (*  Aktiviert die schnelle �bergabe von Daten an das Modul, ohne
         *  da� dabei Fensterbereiche neu gezeichnet werden.
         *
         *  Wird hiermit der Enhanced-Mode angeschaltet, so wird der
         *  Fensterinhalt nicht mehr neu gezeichnet, bis der Enhanced-Modus
         *  wieder abgeschaltet wird. Beim Abschalten wird der komplette
         *  Fensterinhalt auf einen Schlag neu gezeichnet.
         *)

TYPE    ErrorStateWL    = (okWL, listNotSetWL, wdwNotOpenWL, unkownEntryWL,
                           listFaultWL, outOfMemoryWL, cantShowWL, invalidWL);

PROCEDURE StateWL (wl: WindowList): ErrorStateWL;

        (*  Der aktuelle Fehlerzustand der Fensterliste wird geliefert.
         *
         *  Dabei bezieht sich der aufgetrettenen Fehler immer auf die vor-
         *  angegangene Operation. Ist ein Fehler erkannt worden, so sollte
         *  anschlie�end 'ResetStateWL' aufgerufen werden, da sonst bei der
         *  n�chsten Operation ein Laufzeitfehler ausgel��t wird.
         *
         *  'okWL'         -- Kein Fehler.
         *  'listNotSetWL' -- Es ist kein g�ltiger 'SetListWL'-Aufruf durch-
         *                    worden, obwohl dies vor der letzten Operation
         *                    n�tig gewesen w�re.
         *  'wdwNotOpenWL' -- Das Fenster ist nicht auf dem Bildschirm dar-
         *                    gestellt, obwohl dies f�r die letzte Operation
         *                    notwendig gewesen w�re.
         *  'unkownEntryWL'-- Das Klientenmodul hat der letzten Operation
         *                    einen Listeneintrag genannt, der nicht in der
         *                    benutzen Liste enthalten ist.
         *  'listFaultWL'  -- Interner Fehler.
         *  'outOfMemoryWL'-- Der letzten Operation wurde der ben�tigte
         *                    Speicher nicht vom Betriebssystem zur Verf�gung
         *                    gestellt.
         *  'cantShowWL'   -- Die Fensterliste kann nicht auf dem Bildschirm
         *                    dargestellt werden.
         *  'invalidWL'    -- 'wl' ist keine g�ltige Referenz auf eine Fenster-
         *                    liste.
         *)

PROCEDURE ResetStateWL (wl: WindowList);

        (*  Setzt den aktuellen Fehlerzustand auf 'okWL'.
         *
         *  Sollte nach jedem erkannten Fehler aufgerufen werden (siehe auch
         *  'StateWL'). Die einzige Ausnahme ist 'inavlidWL'.
         *)


                        (*  Listenoperationen  *)
                        (*  =================  *)

PROCEDURE AddEntryWL (wl: WindowList; entry, predEntry: ADDRESS);

        (*  F�gt einen Eintrag in eine Fensterliste ein.
         *
         *  Dabei wird 'entry' nach 'predEntry' eingef�gt. Ist 'predEntry
         *  = NIL', so wird am Listenanfang eingef�gt.
         *)

PROCEDURE AppendEntryWL (wl: WindowList; entry: ADDRESS);

        (*  H�ngt einen Eintrag an eine Fensterliste an.
         *)

PROCEDURE RemoveEntryWL (wl: WindowList; entry: ADDRESS);

        (*  Entfernt einen Eintrag aus einer Fensterliste.
         *)

PROCEDURE ReplaceEntryWL (wl        : WindowList;
                          oldEntry,
                          newEntry  : ADDRESS;
                          keepAttrs : BOOLEAN);

        (*  Ersetzt einen Eintrag einer Fensterliste durch einen neuen.
         *
         *  Dabei gibt 'keepAttrs = TRUE' an, da� der neue Eintrag die
         *  Attribute des alten �bernehmen soll.
         *)

TYPE    QueryDirectionWL   = (forwardWL, backwardWL);
        QueryProcWL        = PROCEDURE (    (* entry: *) ADDRESS,
                                            (* env  : *) ADDRESS,
                                        VAR (* attrs: *) AttributesWL): BOOLEAN;

PROCEDURE QueryListWL (    wl   : WindowList;
                           dir  : QueryDirectionWL;
                           proc : QueryProcWL;
                           env  : ADDRESS;
                       VAR cut  : BOOLEAN;
                       VAR entry: ADDRESS);

        (*  Ruft eine Prozedur f�r jedes Element einer Liste auf. Dabei ist
         *  sowohl die Laufrichtung frei w�hlbar, als es der auf die Listen-
         *  elemente angewendeten Prozedur auch freisteht den Vorgang abzu-
         *  brechen.
         *
         *  F�r jedes Listenelement der Liste von 'wl' wird 'proc' aufgerufen
         *  und bekommt dabei die Elementreferenz 'entry' und die f�r dieses
         *  Element gesetzten Attribute 'attrs' �bergeben. Durch R�ckgabe
         *  des Wertes 'FALSE' kann 'proc' den Vorgang unterbrechen, dessen
         *  Laufrichtung durch 'dir' festgelegt wird. Dabei beginnt 'forwardWL'
         *  am Listenanfang und 'backwardWL' am Listenende.
         *  Liefert 'cut' den Wert 'TRUE', so wurde der Vorgang durch 'proc'
         *  abgebrochen, sonst sind alle Elemente durchlaufen worden. Auf
         *  jeden Fall liefert 'entry' den Eintrag, der als letzter an 'proc'
         *  �bergeben wurde.
         *  Wird der Parameter 'attrs' ge�ndert, so wird der neue Wert �ber-
         *  nommen und das entsprechende Element neu gezeichnet.
         *
         *  ACHTUNG: 'proc' darf auf keine Fall destruktive Listenoperationen
         *           auf die Liste von 'wl' anwenden.
         *)

PROCEDURE EntryAttributesWL (wl: WindowList; entry: ADDRESS): AttributesWL;

        (*  Liefert die Attribute eines Listeneintrags (einer Fensterzeile).
         *)

PROCEDURE SetEntryAttributesWL (wl   : WindowList;
                                entry: ADDRESS;
                                attrs: AttributesWL);

        (*  Setzt die Attribute eines Listeneintrags (einer Fensterzeile).
         *)

PROCEDURE GetEntryBoxWL (    wl     : WindowList;
                             entry  : ADDRESS;
                         VAR box    : Rectangle;
                         VAR visible: BOOLEAN);

        (*  Liefert das kleinste Rechteck, das einen Eintrag v�llig um-
         *  schlie�t.
         *
         *  Dabei werden in 'box' die absoluten Pixelkoordinaten �ber-
         *  geben.
         *  Ist 'visible = FALSE', so ist kein Auschnitt von 'entry' in-
         *  nerhalb des sichtbaren Fensterbereichs.
         *)


                        (*  Fensteroperationen  *)
                        (*  ==================  *)

PROCEDURE SetInfoLineWL (wl: WindowList; REF infoStr: ARRAY OF CHAR);

        (*  Weist der Informationszeile des Fensters einen neuen Text zu.
         *)

PROCEDURE ViewLineWL (wl: WindowList; line: CARDINAL);

        (*  Scrollt das Fenster derart, da� die angegebene Zeile
         *  m�glichst mittig sichtbar ist.
         *
         *  Z�hlung der Zeilen beginnt bei 1.
         *)

PROCEDURE SetWindowSizeWL (wl: WindowList; size: Rectangle);

        (*  Setzt die Ausma�e des Fensterarbeitsbereichs in Zeichen-
         *  koordinaten.
         *
         *  Die Sonderwerte 'CenterWindowWL' und 'MaxWindowWL' sind
         *  erlaubt.
         *)

PROCEDURE PutWindowOnTopWL (wl: WindowList);

        (*  Macht das Fenster zum oben aufliegenden Fenster.
         *)

PROCEDURE WindowSizeWL (wl: WindowList): Rectangle;

        (*  Liefert die aktuellen Ausma�e des Fensterarbeitsbereichs
         *  in Zeichenkoordinaten.
         *)

PROCEDURE IsTopWindowWL (wl: WindowList): BOOLEAN;

        (*  Ermittelt ob das Fenster einer Fensterliste, das oberste
         *  aller sichtbaren Fenster ist.
         *)

TYPE    DetectModeWL    = (scanWL, selectWL);

PROCEDURE DetectWindowWL (REF targets: ARRAY OF WindowList; noTrg: CARDINAL;
                              loc    : Point;
                              mode   : DetectModeWL;
                              selMode: LONGCARD;
                          VAR wl     : WindowList;
                          VAR entry,
                              env    : ADDRESS;
                          VAR empty  : BOOLEAN);

        (*  Dient zum Feststellen des Fensterinhaltes an einer bestimmten
         *  Bildschirmposition (z.B. Mauszeiger).
         *
         *  Dabei werden in 'targets' alle Fensterlisten �bergeben, von
         *  denen festgestellt werden soll, ob ihre Fenster die Bildschirm-
         *  position 'loc' (absolute Pixelkoordinaten) belegen. In 'targets'
         *  d�rfen Entr�ge auch den Wert NoWindowList' annehmen. Die Anzahl
         *  der zu ber�cksichtigenden Elemente von 'targets' wird in 'noTrg'
         *  angegeben; ist dieser Wert '0', so werden alle Elemente ausge-
         *  wertet.
         *  Au�erdem gibt 'mode' an, ob f�r einen eventuell an dieser Position
         *  befindlichen Fenstereintrag die Prozedur 'selectEntry', der zuge-
         *  h�rigen Fensterliste aufgerufen werden soll. Bei einem solchen
         *  Aufruf wird 'selMode' als ein frei vom Klientenmodul zu benutzender
         *  Parameter �bergeben. Der Aufruf findet bei �bergabe von 'selectWL'
         *  statt.
         *  Folgende vier F�lle k�nnen unterschieden werden:
         *
         *    i)   An der angegebenen Position befindet sich �berhaupt kein
         *         Fenster, gleichg�ltig ob es eine Fensterliste oder in
         *         'targets' angegeben ist.
         *         Daraufhin liefert 'empty' den Wert 'TRUE', alle anderen
         *         VAR-Parameter sind undefiniert.
         *
         *    ii)  An der angegebenen Position liegt zwar ein Fenster, doch
         *         ist es nicht in 'targets' eingetragen.
         *         Es liefert 'empty' den Wert 'FALSE' und 'wl' enth�lt den
         *         Wert 'NoWindowList'.
         *
         *    iii) An der Position liegt ein in 'targets' eingetragenes Fen-
         *         ster, doch befindet sich dort kein Fenstereintrag.
         *         So ist 'empty = FALSE', 'wl' enth�lt eine Referenz auf das
         *         gefundene Fenster und 'env' den bei dem letzten 'SetListWL'
         *         Aufruf mit dieser Referenz �bergenen Parameter 'environment'.
         *         Au�erdem ist 'entry = NIL'.
         *
         *    iv)  Entspricht in Voraussetzung und Nachbedinung iii), doch
         *         befindet sich an der angegebenen Position innerhalb des
         *         Fensters ein Eintrag.
         *         Dessen Referenz in der Fensterliste wird in 'entry' ge-
         *         liefert.
         *)

PROCEDURE SelectAreaWL (wl             : WindowList;
                        area           : Rectangle;
                        firstSelMode,
                        reminderSelMode: LONGCARD);

        (*  Dient zum Selektieren einer einer zusammenh�ngenden Reihe von
         *  Eintr�gen.
         *
         *  Dabei wird f�r alle Eintr�ge der Fensterliste 'wl', die in dem
         *  Bereich 'area' (absolute Pixelkoordinaten) liegen, die Prozedur
         *  'selectEntry' der Fensterliste aufgerufen. Es wird beim ersten
         *  Aufruf 'firstSelMode' und danach 'reminderSelMode' als vom
         *  Klieentenmodul frei zu definierender Parameter �bergeben.
         *)


END WindowLists.
