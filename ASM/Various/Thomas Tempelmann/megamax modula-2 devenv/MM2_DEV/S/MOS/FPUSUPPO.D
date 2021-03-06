DEFINITION MODULE FPUSupport;

(*
 * Hilfsfunktionen f�r den Einsatz eines Mathe-Koprozessors (FPU) sowohl
 * im Atari ST/STE als auch im Atari TT.
 * Es bietet eine Funktion zum nachtr�glichen Initialisieren der FPU
 * sowie Modula-Versionen von FSAVE/FRESTORE (incl. FMOVEM).
 *
 * Unbedingt beachten, wenn eine FPU in Accessories oder Coroutinen
 * eingesetzt werden soll!
 *
 * Wenn Sie allerdings keine Programme mit den speziellen FPU-Direktiven
 * (siehe F-Direktive) oder mit einer FPU-Shell erzeugen (eine FPU-Shell
 * wird mit den speziellen Modulen aus den Ordnern ST_FPU bzw. TT_FPU
 * erzeugt und zeigt "IEEE" als Real-Format in den Umgebungsinformationen
 * an), brauchen Sie dieses Modul nicht weiter beachten.
 *
 * Die FPU hat eigene Register, die - entgegen den Registern der CPU
 * (Hauptprozessor, z.B. 68000 im ST) - nicht automatisch in Coroutinen
 * oder Task-Umschaltungen (bei Accessories) gerettet werden. Sollten
 * Sie also ein Modula-Programm erzeugen, das mit Reals rechnet und
 * dazu die FPU benutzt, sollten Sie beachten, da� ggf. noch andere
 * Programme gleichtzeitig die FPU benutzen k�nnten und Sie oder die
 * anderen Programme die Register der FPU ggf. unkontrolliert ver�ndern.
 *
 * Accessories (auch residente Programme)
 * --------------------------------------
 *   Eine laufende Hauptapplikation darf nach Definition von Atari davon
 * ausgehen, da� ihr die FPU alleine geh�rt. Sprich: Niemand darf ihr
 * reinpfuschen und ihr die FPU-Register ver�ndern. W�r' ja auch noch
 * sch�ner.
 *   So empfiehlt Atari dann auch, in Accessories die FPU gar nicht
 * zu benutzen, damit dies nicht passiert. Es sei denn, das Accessory
 * sorgt daf�r, da� die Hauoptanwendung nix merkt. Aber das fand man
 * bei Atari schon sehr abwegig. Nichtsdestotrotz bieten wir hier genau
 * die richtige L�sung. 'Save-' und 'RestoreContext' sind n�mlich genau
 * dazu f�hig. Sie brauchen in einem Accessory, das die FPU benutzen
 * soll, lediglich beim Aufruf des Acc. den FPU-Status der Hauptappl.
 * zu retten und den eigenen wiederherstellen und bei Verlassen des
 * Acc. das gleiche umgekehrt zu tun.
 *   Das ganze sieht dann etwa so aus:
 *
 * MODULE Acc;
 *  ...
 * VAR accFPU, applFPU: FPUContext; (* Puffer-Zeiger f�r die Register *)
 *  ...
 * BEGIN
 *    ... Initialisierung des ACC ...
 *   NewContext (accFPU);
 *   NewContext (applFPU);
 *   SaveContext (applFPU);   (* Vor jedem Restore- erstmal ein SaveContext! *)
 *    ... Nun die Event-Schleife:
 *   LOOP
 *     SaveContext (accFPU);      (* eigene FPU-Register sichern *)
 *     RestoreContext (applFPU);  (* FPU-Register der Hauptappl. laden *)
 *     MessageEvent (...);        (* nun kommen die anderen dran *)
 *     SaveContext (applFPU);     (* FPU-Register der Hauptappl. sichern *)
 *     RestoreContext (accFPU);   (* eigene FPU-Register zur�ckladen *)
 *     ...
 *   END
 *
 * Anmerkung zum obigen Beispiel:
 *   Der erste Aufruf von 'SaveContext (applFPU)' ist notwendig, da sonst ein
 * undefinierter Status beim folgenden Aufruf von 'RestoreContext (applFPU)'
 * vorl�ge, was zu einem Laufzeitfehler f�hren w�rde.
 *
 * Coroutinen
 * ----------
 *   Hier m�ssen Sie beachten, da� bei einem TRANSFER oder IOTRANSFER
 * die Register der FPU nicht mit umgeschaltet werden. Verwendet mehr
 * als eine Coroutine die FPU, m�ssen Sie die Register jeder Coroutine
 * vor ihrem Verlassen retten (mit 'SaveContext') und bei R�ckkehr
 * wiederherstellen (mit 'RestoreContext'). Rahmen Sie also sicherheits-
 * halber immer die TRANSFER-Aufrufe der Coroutinen, die mit Reals rechnen,
 * mit 'Save-' und 'RestoreContext' ein. Nat�rlich mu� es nicht dort
 * geschehen - nur sp�testens vor der Benutzung von Reals bei der
 * n�chsten Coroutine.
 *)


PROCEDURE FPUInit;
 (*
  * Inititialisiert die FPU so, da� alle Exceptions (Laufzeitfehler) gemeldet
  * werden, die durch Megamax-Modula-Routinen auftreten k�nnen. Dies sind:
  * Overflow, Div By Zero, Operand Error, Signalling NAN, Bcc/Scc On Unordered.
  *
  * Ein Modula-Programm, das eine FPU benutzt, macht diese Initialisierung
  * zu Beginn selbst�ndig. Ein expliziter Funktionsaufruf ist nur dann n�tig,
  * wenn dieser Status von anderen Routinen zerst�rt worden sein kann (s.o.).
  * Das ist aber in der Regel - wenn 'SaveContext' und 'RestoreContext' richtig
  * eingesetzt werden - nicht der Fall.
  *)

TYPE FPUContext;

PROCEDURE NewContext     (VAR context: FPUContext);
PROCEDURE DisposeContext (VAR context: FPUContext);
 (*
  * Reservieren einen Speicherbereich mit Storage.ALLOCATE, der als
  * Context-Puffer f�r 'SaveContext' und 'RestoreContext' dient.
  * Wenn der Speicher nicht mehr reicht (ca. 300 Byte), wird ein
  * Laufzeitfehler (MOSGlobals.OutOfMemory) ausgel�st.
  *
  * Damit es bei Accessories keine Probleme gibt, m�ssen evtl. Aufrufe
  * von 'NewContext' schon w�hrend der Initialisierung des ACCs
  * geschehen, d�rfen also nicht mehr gemacht werden, wenn das ACC
  * durch einen Event aufgerufen wird.
  *)

PROCEDURE SaveContext    (context: FPUContext);
PROCEDURE RestoreContext (context: FPUContext);
 (*
  * 'SaveContext' rettet den augenblicklichen Status der FPU incl. aller
  * Register, 'RestoreContext' stellt ihn wieder her.
  *
  * Entsprechen den FPU-Instruktionen FSAVE/FRESTORE incl. FMOVEM zum Retten
  * aller Register (FP0-FP7/FPCR/FPSR/FPIAR).
  *)

PROCEDURE AcknowledgeException (context: FPUContext);
 (*
  * Hiermit kann, anstatt die FPU ganz zur�ckzusetzen, bei einer FPU-Exception
  * das Bit 27 der BIU-Flags gesetzt werden. Dazu mu� im Exception-Handler
  * zuerst der Context mit 'SaveContext' gerettet werden, dann kann diese
  * Funktion aufgerufen werden. Danach kann der Context zur�ckgeladen und die
  * Exception beendet werden (z.B. durch R�ckgabe von FALSE bei einem Exc-
  * Handler, der �ber das Exceps-Modul angemeldet wurde).
  * Wird dieser Aufruf bei einer 68881 unterlassen, f�hrt das zwar zu keinen
  * Fehlern, bei einer 68882 (im Atari TT) w�rde das aber sehr wohl zu
  * Problemen f�hren!
  * Deshalb: Wer die FPU-Exceptions selbst abf�ngt, mu� entweder diese
  * Prozedur oder "FPUInit" bei Auftreten einer Exception aufrufen!
  *
  * Wenn Sie das Modul "EasyExceptions", "ErrBase" o. "HdlError" verwenden
  * oder wenn Sie einen der Error-Treiber einbinden, brauchen Sie sich aber
  * keine Gedanken hier�ber machen.
  *)

END FPUSupport.
