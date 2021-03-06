DEFINITION MODULE Paths;

!!!
  > vielleicht ein Modul "TextLists" erstellen, das speziell f�r Listen
    von Strings ausgelegt ist.
    Der Puffer kann dann entweder beim �ffnen auf eine statische Gr��e
    alloziert werden oder ggf auch ein dynamischer Modus aktiviert
    werden.
    Dies Modul k�nnte dann von CallModule auch f�r die 'driver'-Liste
    verwendet werden.
    Vielleicht l��t sich das auch mit den STR-Dateien, wie bei H�nisch,
    kombinieren?

(*
 * Verwaltet Listen von Pfadnamen und bietet Funktionen, um Dateien
 * auf diesen Pfaden zu suchen.
 *)

FROM SYSTEM IMPORT ADDRESS, LOC;
FROM MOSGlobals IMPORT MemArea;

TYPE    PathList = RECORD
                     buf : MemArea; (* s. Anmerkung gleich unten *)
                     heap: BOOLEAN;
                     seps: ARRAY [0..1] OF CHAR
                   END;
          (*
           * Anmerkung: Ist 'mem.length' Null, wird 'mem.bottom'
           * schlicht als Zeiger auf einen Null-terminierten String
           * beliebiger L�nge verwendet. So kann der String nachtr�glich
           * verl�ngert werden, allerdings nicht mit den hiesigen, sonst
           * daf�r vorgesehenen, Funktionen, sondern durch Direktzugriff
           * auf den String.
           *)

(*
 * Auswerten der Pfadlisten
 * ------------------------
 *)

problem:
  die pfadlisten sind nun extern, beim aufrufer, gespeichert. dort werden
  ggf. mehrere pro proze� angelegt.
(*
 * Verwalten der Pfadlisten
 * ------------------------
 *)

        (*
         * Trennzeichen zwischen den Pfaden:
         *)
        Separator = (dftSep,       (* internes Zeichen, unbestimmt   *)
                     lineSep,      (* CR/LF (zeilenweise)            *)
                     spcSep,       (* Leerzeichen                    *)
                     envSep);      (* ';' (f�r Environment-Variable) *)

PROCEDURE InitPathList (VAR handle: PathList);
  (*
   * Setzt 'handle' in einen definierten Zustand:
   * Die Liste enth�lt keine Pfade.
   *)

PROCEDURE CreatePathList (VAR handle: PathList; size: LONGCARD);
  (*
   * Legt einen Pfad-Puffer mit 'size' Bytes mithilfe der
   * ALLOCATE-Funktion aus Storage an.
   * Als Separator wird erstmal der Interne ('dftSep') definiert.
   * Der Puffer wird gel�scht.
   *
   * Am Ende sollte der Puffer mit 'DeletePathList' wieder freigegeben
   * werden.
   *)

PROCEDURE DeletePathList (VAR handle: PathList);
  (*
   * Gibt einen mit 'CreatePathList' reservierten Puffer wieder frei.
   *)

PROCEDURE DefinePathList (VAR handle: PathList; buffer: MemArea);
  (*
   * Alternativ zu 'CreatePathList' kann mit dieser Funktion ein
   * bereits angelegter Puffer (z.B. durch 'SysAlloc' oder eine
   * globale Variable) als Pfadlisten-Puffer initialisiert werden.
   * Als Separator wird erstmal der Interne ('dftSep') definiert.
   * Der Puffer wird gel�scht.
   *)

PROCEDURE SetPathList (VAR handle: PathList; buffer: MemArea; sep: Separator);
  (*
   * Wie 'DefinePathList', nur wird davon ausgegangen, da� der
   * angegebene Puffer bereits eine Pfadliste enth�lt, er wird also
   * nicht gel�scht. Das verwendete Trennzeichen ist in 'sep' anzugeben.
   * Anwendung findet diese Funktion, wenn z.B. die Environment-Variable
   * "PATH" f�r eine Pfadliste verwendet werden soll (n�heres im Modul
   * 'Environment', Funktion 'ArgMEM'.
   *)

PROCEDURE ClearPathList (VAR handle: PathList);
  (*
   * L�scht den Puffer
   *)

PROCEDURE Separate (handle: PathList; sep: Separator);
  (*
   * Die Pfade werden mit den in 'sep' angegebenen Trennzeichen
   * getrennt.
   * Dies ist sinnvoll, wenn danach die Liste ausgegeben werden soll,
   * beispielsweise in eine Datei: Wird 'Separate (path, lineSep)'
   * aufgerufen und danach die .............

   *)

PROCEDURE AppendPaths (from: PathList; VAR to: PathList);

PROCEDURE AppendPath (path: ARRAY OF CHAR; VAR to: PathList);

END Paths.
