DEFINITION MODULE EasyExceptions;

(*
 * Portable Laufzeitfehler-Behandlung f�r Megamax Modula-2
 * Programmiert von Thomas Tempelmann nach einem Vorschlag von K. John Gough
 *
 * Dies Modul setzt auf die im Handbuch beschriebenen Module 'Excepts',
 * 'ErrBase' und 'HdlError' auf. Es bietet die universellste und komfor-
 * tabelste Art der konkreten Fehlerbehandlung im Programm.
 *
 * Die Funktion 'Call' dieses Moduls ersetzt die - umst�ndlichere -
 * Anwendung der Funktion 'CallProcess' in Verbindung mit 'CatchErrors',
 * die im Handbuch unter dem Kapitel "Laufzeitfehler-Behandlung" beschrieben
 * ist.
 *
 * Ein Anwendungsbeispiel befindet sich in "EXCTEST.M" (DEMO-Ordner)
 *
 * Besonders hilfreich ist die Fehler-Abfangprozedur 'Call' (s.u.) in
 * Accessories einsetzbar:
 * Denn tritt in einem Accessory ein Laufzeitfehler (B�mbchen) auf,
 * st�rzt der Rechner gnadenlos ab - alle Daten im Speicher sind verloren.
 * Wenn aber solch ein Laufzeitfehler (�berlauf, Division durch Null,
 * sogar Bus-Error, usw) in einer von 'Call' gerufenen Prozedur auftritt,
 * geschieht in der Regel �berhaupt nichts, was den Rechner "aufh�ngen"
 * k�nnte. Aus diesem Grund sollten Sie bei jedem Accessory alle Ihre
 * Funktionen mittels 'Call' aufrufen. Das ist sehr einfach: In einem
 * Accessory haben Sie immer eine Endlosschleife, in der Sie auf Ereignisse,
 * meist �ber 'EventMulti', warten. Sobald ein Event f�r Ihr Accessory
 * gemeldet wird, rufen Sie die auswertende Funktion �ber 'Call' auf.
 * Keinesfalls sollte schon die Endlosschleife selbst durch 'Call'
 * aufgerufen worden sein, weil dann die Fehlerabfangmechanismen auch auf
 * die anderen Programme wirken w�rden, was wiederum zu Fehlern f�hren
 * kann. Sie wollen ja aber erst bei Aufruf Ihrer eigenen Routinen m�gliche
 * Fehler abfangen und d�rfen deshalb auch nur f�r diese Zeit den Abfang-
 * mechanismus aktivieren.
 * Auch hierzu finden Sie eine beispielhafte Programmierung im Modul
 * "ACCDEMO.M" im "DEMO"-Ordner.
 *
 * �brigens wurde dieses Modul vollst�ndig in Modula-2 (also ohne Assembler)
 * implementiert - dies war durch die schon vorhandenen, leistungsf�higen
 * Systemmodule m�glich. Grundlegend wurden die Funktionen 'SetJump' und
 * 'LongJump' aus dem Modul 'SysUtil2' verwendet, ansonsten wurden nur noch
 * 'HdlError.CatchErrors' (zum Abfangen der Standard-Laufzeitfehler des
 * Modula-Systems) und 'ErrBase.RaiseError' (nicht unbedingt notwendig)
 * ben�tigt.
 *
 * Dieses Modul ist damit von seiner Definition als auch seiner Implementation
 * her auf jedes andere Modula-System leicht portabel!
 * Bei Bedarf stellen wir Ihnen gerne die Quellen hierzu zur Verf�gung.
 *)

TYPE Exception;

(*$H+*)
PROCEDURE Call (p: PROC; VAR result: Exception);
  (*
   * Ruft eine Prozedur auf.
   * Entsteht innerhalb der darin ausgef�hrten Routinen ein Laufzeitfehler
   * (entweder ausgel�st, wie im Handbuch beschrieben, oder durch Aufruf
   * von 'Raise'), kehrt 'Call' sofort zur�ck und in 'result' ist die Art
   * des Fehlers beschrieben. Tritt bis zur R�ckkehr aus 'p' kein Fehler
   * auf, ist 'reason' = 'NormalReturn()'.
   * Verschachtelte Aufrufe von 'Call' sind erlaubt.
   * Es ist m�glich, auch lokale Prozeduren an 'p' zu �bergeben.
   *)

PROCEDURE Raise (reason: Exception);
  (*
   * Signalisiert einen Fehler (in 'reason').
   * Es wird aus der zuletzt �ber 'Call' aufgerufenen Prozedur zur�ckgekehrt.
   * War kein 'Call' erfolgt, wird der Fehler an die Laufzeitfehler-Behand-
   * lung von 'ErrBase' weitergeleitet (es wird 'RaiseError' aufgerufen),
   * was in der Regel zur Anzeige des Fehler f�hrt (bei gelinkten Programmen
   * mu� dazu 'GEMError' oder 'SimpleError' eingelinkt sein!).
   * Diese Funktion sollte auch unbedingt immer dann verwendet werden, wenn
   * nach einem Call-Aufruf ein Fehler aufgetreten ist, der aber nicht
   * erwartet und auch nicht behandelt wird. Dann sollte der 'result'-Wert
   * mittels 'Raise' an den evtl. vorher installierten Fehler-Behandler
   * weitergereicht werden (siehe Demo-Programm 'ExcTest').
   *)

PROCEDURE New (VAR id: Exception);
  (*
   * Funktionen, die selbst eigene Laufzeitfehler ausl�sen wollen,
   * m�ssen hier�ber eine daf�r notwendige eindeutige Kennung anfordern
   * (siehe Demo-Programm 'ExcTest').
   * Intern wird f�r die Kennung Speicher angefordert
   *)

PROCEDURE StdErrNo (id: Exception): INTEGER;
  (*
   * Liefert bei Standardkennungen (die unten definierten) die entsprechende
   * MOSGlobals-Fehlernummer.
   * Liefert den Wert <Eins>, wenn 'id' eine vom Anwenderprogramm (mit 'New')
   * erzeugte Kennung ist.
   * Hiermit kann auf einfache Weise der Fehlermeldungstext (der z.B. im
   * Konfigurationsmodul 'GEMError' initialisiert wird) zu einem Standard-
   * fehler ermittelt werden:
   *   EasyExceptions.Call (tueWas, result);
   *   IF result <> EasyExceptions.NormalReturn () THEN
   *     HdlError.GetErrorMsg (EasyExceptions.StdErrNo (result), errorMsg);
   *     WriteString (errorMsg);
   *
   * Vorsicht: Diese Funktion ist so nicht unbedingt portabel!
   *)


  (*
   * Die folgenden Funktionen liefern die Kennungen verschiedener
   * Standard-Laufzeitfehler (siehe Handbuch und Modul 'MOSGlobals').
   * In Klammern stehen die entsprechenden Fehlernummern aus MOSGlobals.
   *)

PROCEDURE NormalReturn ()    : Exception; (* NoError *)

PROCEDURE RangeError ()      : Exception; (* OutOfRange *)
PROCEDURE Overflow ()        : Exception; (* Overflow *)
PROCEDURE DivByZero ()       : Exception; (* DivByZero *)
PROCEDURE RealValueError ()  : Exception; (* GenFPErr *)
PROCEDURE CaseSelectError () : Exception; (* CaseSelectErr *)
PROCEDURE StringOverflow ()  : Exception; (* StringOverflow *)
PROCEDURE StackOverflow ()   : Exception; (* OutOfStack *)
PROCEDURE StorageError ()    : Exception; (* OutOfMemory *)
PROCEDURE IOError ()         : Exception; (* FileSystemErr *)

  (*
   * F�r die restlichen Laufzeitfehler gibt es keine direkte
   * Abfragem�glichkeit, ihre Einzelauswertung d�rfte aber auch
   * kaum interessant sein, notfalls ist 'StdErrNo' zu Hilfe zu
   * nehmen.
   *)

  (*
   * Der Fehler MOSGlobals.UserBreak wird nicht durch 'Call'
   * abgefangen, sondern sofort an 'ErrBase' weitergereicht
   * (und damit normalerweise an 'SimpleError' bzw. 'GEMError').
   * 'UserBreak' ist an sich kein Fehler, sondern kann nur von
   * au�en ausgel�st werden. Dies ist nur dann m�glich, wenn
   * daf�r extra Abfragen vorgesehen sind: z.B. durch Einbindung des
   * Moduls 'UserBreak' und Aufruf von 'EnableBreak' oder beim
   * Starten von Modulen unter der Shell, wenn 'Abbruch mit Ctrl-C'
   * in den Shell-Optionen aktiviert ist.
   *)

END EasyExceptions.
