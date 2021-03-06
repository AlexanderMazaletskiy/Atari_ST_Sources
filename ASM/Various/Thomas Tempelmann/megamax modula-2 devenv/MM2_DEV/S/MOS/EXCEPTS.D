DEFINITION MODULE Excepts;

(*
 * Low-Level Modul, mit dem Modula-Prozeduren ohne Assembler-Einsatz
 * zum Abfangen jeder beliebigen Prozessor-Exception (TRAP-Instruktionen,
 * Bus-Error, usw.) installiert werden k�nnen.
 * Damit ist es beispielsweise ein Kinderspiel, die TRAP #2 - Aufrufe
 * zu den GEM-Funktionen abzufangen, um dann eine eigene File-Selektor-
 * Funktion statt der Normalen ausf�hren zu lassen.
 *
 * Ein kurzes Beispielprogramm ist
 *
 *   ExcDemo.M  im DEMO-Ordner
 *)


FROM SYSTEM IMPORT WORD, ADDRESS;

FROM MOSGlobals IMPORT MemArea;

FROM SysTypes IMPORT AnyLongType, PtrAnyType, ExcSet, Exceptions, BusError,
                     AddrError, ExcDesc;


TYPE PreExcProc = PROCEDURE (VAR ExcDesc): BOOLEAN;
                      (* RETURN: FALSE: Return from Exc, TRUE: call others *)

PROCEDURE InstallPreExc (REF traps: ExcSet;
                         call: PreExcProc; usermode: BOOLEAN;
                         workSpace: MemArea; VAR hdl: ADDRESS);
  (*
   * Installiert eine Exception-Behandlungsroutine 'call' f�r die
   * in 'traps' angegebenen Exceptions. Der Routine 'call' wird
   * bei Eintritt einer der Exceptions ein Feld mit allen Systemregistern
   * (ExcDesc) �bergeben. Bei R�ckkehr der Routine mu� sie entweder FALSE
   * liefern, wenn das durch den Fehler unterbrochene Programm weiterge-
   * f�hrt werden soll (ggf. mu� 'regPC' hinter die fehlerausl�sende Anwei-
   * sung gesetzt werden) oder TRUE liefern, wenn evtl. vor dem 'InstallExc'
   * Aufruf installierte Routinen zus�tzlich ausgef�hrt werden sollen
   * (dies ist z.B. bei Interrupt-Routinen und 'EtvTimer' sinnvoll).
   *
   * Ist 'usermode' TRUE, wird die Routine 'call' im User-Mode aufgerufen.
   * Ist 'usermode' FALSE, wird sie im Supervisor-Mode aufgerufen (ist
   * u.a. auch schneller!). Allerdingso darf dies nicht auf die Bus error-
   * und Address error-Exceptions angewendet werden!
   *
   * Bei Mi�erfolg (weil zu wenig freier Speicher) ist 'hdl' = NIL; ansonsten
   * ist 'hdl' bei Freigabe der Exceptions mit 'DeInstallExc' wieder zu
   * �bergeben.
   *
   * 'call' erh�lt in 'ExcDesc.parms' den Zeiger auf die evtl. auf dem Stack
   * �bergebenen Daten.
   *
   * Vorsicht: Wenn mit dieser Funktion Interruptroutinen installiert werden,
   * kann es passieren, da� schon vor R�ckkehr aus dieser Funktion die
   * Prozedur 'call' aufgerufen wird! Ggf. m�ssen vor diesem Aufruf die
   * Interrupts gesperrt werden.
   *
   * Falls die aufzurufende Prozedur in Assembler programmiert wird,
   * weisen wir darauf hin, da� es n�tig ist, die Register D3-D7/A3-A6,
   * wie bei jeder normalen Modula-Routine, zu retten!
   *)


TYPE PostExcProc = PROCEDURE (VAR ExcDesc);

PROCEDURE InstallPostExc (REF traps: ExcSet;
                          call: PostExcProc; usermode: BOOLEAN;
                          workSpace: MemArea; VAR hdl: ADDRESS);
  (*
   * Wie 'InstallPreExc', jedoch werden bei Auftreten der Exception
   * zuerst die vorher installierten Handler und erst dann 'call'
   * aufgerufen.
   *)


PROCEDURE DeInstallExc (VAR hdl: ADDRESS);
  (*
   * Entfernt alle unter 'hdl' installierte Exception-Handler.
   *)


TYPE    HardExceptions = [2..255];

PROCEDURE RaiseExc ( excNo: HardExceptions );
  (*
   * Simuliert die gew�nschte Exception 'excNo' an der Stelle hinter
   * dem Aufruf dieser Funktion.
   *
   * Darf sowohl im Usermode als auch im Supervisormode aufgerufen werden -
   * allerdings nicht in Interruptroutinen, die im Usermode ablaufen.
   *)


PROCEDURE SysInstallPreExc (REF traps: ExcSet; call: PreExcProc;
             usermode: BOOLEAN; workSpace: MemArea; VAR hdl: ADDRESS);

PROCEDURE SysInstallPostExc (REF traps: ExcSet; call: PostExcProc;
             usermode: BOOLEAN; workSpace: MemArea; VAR hdl: ADDRESS);

END Excepts.
