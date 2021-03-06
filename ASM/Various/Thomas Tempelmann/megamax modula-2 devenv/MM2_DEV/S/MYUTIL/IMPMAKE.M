MODULE ImpMake; (*$ E MTP *)

(*
 *                                          Hilfprogramm f�r Megamax Modula-2
 *                                                  Thomas Tempelmann 26.8.88
 *  Mini-Make
 *  ---------
 *  Schreibt alle Namen von Impl-Texten, deren Codes �lter sind, in eine Datei.
 *)

FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD, VAL;

FROM Terminal IMPORT WriteLn, Read, WriteString, FlushKbd;

FROM ArgCV IMPORT PtrArgStr, InitArgCV;

FROM Clock IMPORT Time, Date, PackTime, PackDate, UnpackTime, UnpackDate;

FROM Directory IMPORT DirQuery, FileAttrSet, FileAttr, SetFileAttr, DirEntry,
        SplitName;

FROM Paths IMPORT ListPos, SearchFile;

IMPORT Text;

FROM ShellMsg IMPORT ImpPaths;

FROM Files IMPORT File, Open, Create, Access, ReplaceMode, GetStateMsg,
        State, Close, SetDateTime;

FROM Strings IMPORT String, Upper, Assign, Compare, Relation;

FROM FuncStrings IMPORT ConcStr;


MODULE directory2; (* lokales Modul *)

  IMPORT DirEntry, UnpackDate, UnpackTime;

  EXPORT GetDirEntry; (* wird demn�chst von 'Directory' exportiert *)

  PROCEDURE str0;
    (*$L-*)
    BEGIN
      ASSEMBLER
          ; D0: HIGH (s)
          ; A0: ADR (s)
          ; D2 erhalten !
          MOVE.L  (A7)+,A1
          
          MOVE    D0,D1
          ADDQ    #3,D1
          BCLR    #0,D1
          
          ; LINK:
          PEA     (A5)
          MOVE.L  A7,A5
          SUBA.W  D1,A7
          
          CMPA.L  A3,A7
          BLS     E
          MOVE.L  A7,A2
          
       L: MOVE.B  (A0)+,(A2)+
          DBRA    D0,L
          CLR.B   (A2)+
          
          MOVE.L  A7,D0
          JMP     (A1)
       
       E: TRAP    #6      ; OUT OF STACK
          DC.W    -10
      END
    END str0;
    (*$L=*)
  
  PROCEDURE setDta;
    (*$L-*)
    BEGIN
      ASSEMBLER
          ; get old DTA
          MOVE    #$2F,-(A7)
          TRAP    #1
          MOVE.L  D0,D3           ; alten DTA merken in D3
          ; set new DTA
          MOVE.L  D4,-(A7)
          MOVE    #$1A,-(A7)
          TRAP    #1
          ADDQ.L  #8,A7
      END
    END setDta;
    (*$L=*)
  
  PROCEDURE rstDta;
    (*$L-*)
    BEGIN
      ASSEMBLER
          ; reset old DTA, erhalte D0 !
          MOVE.L  D0,-(A7)
          MOVE.L  D3,-(A7)
          MOVE    #$1A,-(A7)
          TRAP    #1
          ADDQ.L  #6,A7
          MOVE.L  (A7)+,D0
      END
    END rstDta;
    (*$L=*)
  
  PROCEDURE GetDirEntry (fileName: ARRAY OF CHAR;
                         VAR entry: DirEntry ): BOOLEAN;
    (*$L-*)
    BEGIN
      ASSEMBLER
          MOVE.L  -10(A3),A0
          MOVE.W  -06(A3),D0
          JSR     str0
          
          MOVEM.L D3/D4,-(A7)
          
          ; DTA anlegen
          SUBA.W  #44,A7
          MOVE.L  A7,D4
          
          CLR.W   -(A7)           ; Attribut
          MOVE.L  D0,-(A7)        ; zuerst D0 (^name) sichern
          JSR     setDta          ; dann DTA sichern/umsetzen
          MOVE    #$4E,-(A7)
          TRAP    #1              ; FSFIRST
          ADDQ.L  #8,A7
          JSR     rstDta
          
          MOVE.L  -4(A3),A1       ; ADR (entry)
          
          ; Name in Dir vorhanden ?
          TST.L   D0
          BMI     fals
          
          ; Pr�fen, ob es ein normales File ist (nicht Subdir/volID)
          MOVE.B  21(A7),D0
          ANDI    #11000%,D0
          BNE     fals
          
          ; DirEntry kopieren, DTA ist direkt auf dem Systemstack
          ; name
          MOVEQ   #5,D0
          LEA     $1E(A7),A0
      L0: MOVE.W  (A0)+,(A1)+
          DBRA    D0,L0
          ; attr
          MOVE.B  21(A7),(A1)+
          CLR.B   (A1)+
          ; time
          MOVE    22(A7),(A3)+
          MOVE.L  A1,-(A7)
          JSR     UnpackTime
          MOVE.L  (A7)+,A1
          MOVE.L  -6(A3),(A1)+
          MOVE.W  -(A3),(A1)+
          SUBQ.L  #4,A3
          ; date
          MOVE    24(A7),(A3)+
          MOVE.L  A1,-(A7)
          JSR     UnpackDate
          MOVE.L  (A7)+,A1
          MOVE.L  -6(A3),(A1)+
          MOVE.W  -(A3),(A1)+
          SUBQ.L  #4,A3
          ; size
          MOVE.L  26(A7),(A1)+
          MOVEQ   #1,D0
          BRA     ende
          
        fals
          ; entry l�schen
          MOVEQ   #14,D0
      l1: CLR.W   (A1)+
          DBRA    D0,l1
          MOVEQ   #0,D0
          
        ende
          SUBA.W  #10,A3          ; name + entry
          ADDA.W  #44,A7
          MOVEM.L (A7)+,D3/D4
          UNLK    A5
          MOVE    D0,(A3)+
      END
    END GetDirEntry;
    (*$L=*)

  END directory2;  (* lokales Modul *)


VAR     argv: ARRAY [0..3] OF PtrArgStr;
        argc: CARDINAL;
        open: BOOLEAN;
        f: File;

PROCEDURE showErr ( i: INTEGER );
  VAR msg: ARRAY [0..31] OF CHAR;
  BEGIN
    WriteLn;
    WriteString ('Fehler: ');
    GetStateMsg ( i, msg );
    WriteString ( msg );
    WriteLn;
  END showErr;

PROCEDURE wait;
  VAR c: CHAR;
  BEGIN
    WriteLn;
    WriteString ('Taste...');
    FlushKbd;
    Read (c)
  END wait;

PROCEDURE query ( path: ARRAY OF CHAR; entry: DirEntry ): BOOLEAN;

  VAR name: String;
      comp, exist: BOOLEAN;
      de: DirEntry;
      sfx: ARRAY [0..2] OF CHAR;

  BEGIN
    (* nur normale Dateien - keine Subdirs, Volume-Labels *)
    IF entry.attr * FileAttrSet{volLabelAttr,subdirAttr} = FileAttrSet{} THEN
      (* Suffix von Quellnamen entfernen *)
      SplitName (entry.name, name, sfx);
      (* Nach der zugeh�rigen Codedatei auf den Impl-Pfaden suchen *)
      SearchFile ( ConcStr (name, '.IMP'), ImpPaths, fromStart, exist, name);
      comp:= FALSE;
      IF NOT exist THEN
        (* Quelltext sollte compiliert werden *)
        comp:= TRUE
      ELSE
        (* Datum und Zeit der beiden Dateien vergleichen *)
        IF  GetDirEntry ( name, de )
        AND (   (PackDate(entry.date)>PackDate(de.date))
             OR (    (PackDate(entry.date)=PackDate(de.date))
                 AND (PackTime(entry.time)>PackTime(de.time)) ) ) THEN
          (* Quelltext mu� neu compiliert werden *)
          comp:= TRUE
        END
      END;
      IF comp THEN
        (* ggf. die Make-Datei er�ffnen *)
        IF NOT open THEN
          Create (f, argv[2]^, writeOnly, replaceOld);
          Text.WriteLn (f);
          open:= TRUE;
        END;
        (* Inlcude-Anweisung in Make-Datei schreiben *)
        Text.WriteString (f, '(*$Q+, I ');
        Text.WriteString (f, path);
        Text.WriteString (f, entry.name);
        Text.WriteString (f, ' *)');
        IF NOT exist THEN
          Text.WriteString (f, '  (* noch kein Code *)')
        END;
        Text.WriteLn (f);
      END
    END;
    RETURN TRUE (* Die n�chste, bitte *)
  END query;


PROCEDURE usage;
  BEGIN
    WriteLn;
    WriteString ('Aufruf: IMPMAKE impPfad makeDatei');
    WriteLn;
    WriteString
      ("        Erzeugt makeDatei f�r alle neuen '*.I' auf dem impPfad.");
    WriteLn;
  END usage;


VAR     result: INTEGER;
        ok: BOOLEAN;

BEGIN
  InitArgCV ( argc, argv );
  IF argc = 3 THEN
    (* Alle Implementationstexte pr�fen... *)
    Upper (argv[1]^);
    DirQuery ( ConcStr (argv[1]^, '*.I'), FileAttrSet {}, query, result );
    IF open THEN
      (* Make-Datei wurde erzeugt und mu� nun geschlossen werden *)
      Close (f)
    ELSE
      (* Keine Make-Datei erzeugt *)
      WriteString ('Keine Implementationen aus ');
      WriteString (argv[1]^);
      WriteString (' zu compilieren.');
      WriteLn;
      wait
    END;
    (* War Fehler bei 'DirQuery ?' *)
    IF result < 0 THEN showErr ( result ); wait END
  ELSE
    usage;
    wait
  END;
END ImpMake.
 
(* $FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$00001817$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78$FFF6AD78�$00001840T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$FFF6C864$00001841$000017DA$00001801$00001840$000014F2$00001786$000017BB$00001839$00001819$0000179B$00001801$000017EF$000017DA$00001819$00001801���*)
