DEFINITION MODULE Compressions;

FROM    SYSTEM  IMPORT  ADDRESS;


CONST   DestOverhead = 6L;
        (*
         * Um soviel Bytes sollte der Kodierungs-Puffer gr��er als der
         * Ausgangspuffer sein, damit die Komprimierung nicht fehlschlagen
         * kann.
         *)

PROCEDURE Encode (    type:      CARDINAL;
                      source:    ADDRESS;
                      sourceLen: LONGCARD;
                      dest:      ADDRESS;
                      destLen:   LONGCARD;
                  VAR codeLen:   LONGCARD );
  (*
   * Komprimiert beliebige Daten
   *
   * Eingabe:
   *  'type':      Bei Null wird die optimale Komprimierung ausgesucht (bisher
   *               nur LZW), ist sie Eins, wird eine Lempel-Ziv-Welch-Kodierung
   *               vorgenommen, sonst wird wie bei Null vorgegangen.
   *  'source':    Adresse der Originaldaten
   *  'sourceLen': L�nge der Originaldaten
   *  'dest':      Zieladresse f�r komprimierte Daten
   *  'destLen':   L�nge des Puffers f�r komprimierte Daten, mu� um Sechs
   *               gr��er sein, damit Komprimierung IMMER erfolgreich ist.
   *               Bei der Kodierung wird keinesfalls �ber diesen Puffer
   *               hinausgeschrieben.
   * R�ckgabe:
   *  'codeLen':   L�nge der komprimierten Daten, egal, ob sie in den Puffer
   *               passen oder nicht. Ist 'codeLen' Null oder gr��er als
   *               'destLen', sind die Daten im dest-Puffer nicht g�ltig.
   *               Dies kann nur passieren, wenn 'destLen' nicht um Sechs
   *               gr��er als 'sourceLen' ist.
   *
   * Sonderfall:
   *  Ist 'dest' NIL oder 'destLen' Null, wird keine Komprimierung
   *  vorgenommen, 'codeLen' enth�lt dann trotzdem die theoritische
   *  L�nge der komprimierten Daten.
   *
   * Ist die Komprimierung erfolgreich, werden im komprimierten Code
   * die Informationen �ber dessen Komprimierungsart und Originall�nge
   * abgelegt.
   *)

PROCEDURE GetInfo (     code:   ADDRESS;
                    VAR type:   CARDINAL;
                    VAR length: LONGCARD );
  (*
   * Eingabe:
   *   'source': Puffer der mit 'Encode' kodierten Daten.
   * R�ckgabe:
   *   'type': 0 -> nicht komprimiert
   *           1 -> Lempel-Ziv-Welch-Kodierung
   *   'length': Originall�nge
   *)

PROCEDURE Decode (    code:    ADDRESS;
                      codeLen: LONGCARD;
                      orig:    ADDRESS;
                      origLen: LONGCARD;
                  VAR success: BOOLEAN );
  (*
   * Dekomprimiert die Daten wieder.
   * Es mu� noch mind. 8 KB Speicher frei sein!
   *
   * Eingabe:
   *   'code': Adresse der kodierten Daten
   *   'codeLen': L�nge der kodierten Daten
   *   'orig': Zieladresse f�r Originaldaten
   *   'origLen': Vermeintliche L�nge der Originaldaten
   *              (kann von 'sourceLen'-Parameter bei 'Encode' �bernommen
   *               oder �ber 'GetInfo' ermittelt werden).
   * R�ckgabe:
   *   'success': Wenn 'origLen' nicht mit der internen Information
   *              �bereinstimmt oder wenn ein unbekannter Koprimierungs-
   *              algorithmus verwendet wurde, liefert 'success' FALSE,
   *              sonst TRUE.
   *)

(*
 * Beispiel:
 *
 *   (* Zuerst die Daten komprimieren *)
 *   (* 'data' zeigt auf die Daten im Speicher, 'len' ist ihre L�nge *)
 *   destLen:= len + DestOverhead;
 *   ALLOCATE (destData, destLen);
 *   Encode (0, data, len, destData, destLen, codeLen);
 *   (* Hierbei kann kein Fehler aufgetreten sein *)
 *   (* Der Code ist nun 'codeLen' Bytes lang *)
 *
 *   Der Code kann abgespeichert werden...
 *
 *   (* Nun wieder dekomprimieren *)
 *   GetInfo (destData, len);
 *   Decode (destData, destLen, data, len, ok);
 *   IF NOT ok THEN Fehler END;
 *)

END Compressions.
