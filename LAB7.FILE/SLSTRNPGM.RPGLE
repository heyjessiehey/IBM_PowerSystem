000100190321     FSALESTRANSIF   E             DISK    RENAME(SALESTRANS:SALESTRANR)
000200190321     FSALESSTAF2UF A E           K DISK
000300190321     FQPRINT    O    F  132        PRINTER OFLIND(*INOF)
000400190321
000500190321     D SALESTRANSDS    DS
000600190321     D   TDEPT
000700190321     D   TSALESID
000800190321     D   TFNAME
000900190321     D   TLNAME
001000190321     D   TCITY
001100190321     D   TADDRESS
001200190321     D   TPCODE
001300190321
001400190321     D SALESSTAF2DS    DS
001500190321     D    DEPT
001600190321     D    SALESID
001700190321     D    FNAME
001800190321     D    LNAME
001900190321     D    CITY
002000190321     D    ADDRESS
002100190321     D    PCODE
002200190321
002300190321     D FullKey         DS                  LikeRec(SALESTFR: *Key)
002400190321
002500190321     C/FREE
002600190321                   EXCEPT  HEADINGS;
002700190321                   READ    SALESTRANS;
002800190321                   DOW NOT %EOF;
002900190321                     FULLKEY=TDEPT + TSALESID;
003000190321                     CHAIN %KDS(FULLKEY) SALESSTAF2;
003100190321                     SELECT;
003200190321                        WHEN %FOUND(SALESSTAF2);
003300190321                        SELECT;
003400190321                           WHEN TCODE = 'C';
003500190321                              EXSR CHGREC;
003600190321                           WHEN TCODE = 'D';
003700190321                              EXSR DELREC;
003800190321                           OTHER;
003900190321                              EXSR ERROR;
004000190321                        ENDSL;
004100190321                        WHEN NOT %FOUND(SALESSTAF2);
004200190321                           IF TCODE = 'A';
004300190321                              EXSR ADDREC;
004400190321                           ELSE;
004500190321                              EXSR ERROR;
004600190321                           ENDIF;
004700190321                        WHEN %ERROR;
004800190321                              EXSR ERROR;
004900190321                        ENDSL;
005000190321                        EXCEPT DETAIL;
005100190321                        READ   SALESTRANS;
005200190321                   ENDDO;
005300190321                   *INLR = *ON;
005400190321                   RETURN;
005500190321
005600190321       BEGSR  ADDREC;
005700190321               SALESSTAF2DS = SALESTRANSDS;
005800190321               PHONE = %DEC(TPHONE:10:0);
005900190321               WRITE SALESTFR;
006000190321       ENDSR;
006100190321                BEGSR  CHGREC;
006200190321                   SALESSTAF2DS = SALESTRANSDS;
006300190321                   Phone        = %Dec(TPhone:10:0);
006400190321                   UPDATE SALESTFR;
006500190321         ENDSR;
006600190321         BEGSR  DELREC;
006700190321                   DELETE SALESTFR;
006800190321         ENDSR;
006900190321         BEGSR  ERROR;
007000190321                   TFNAME = 'UPDATE/DELETE/CHANGE';
007100190321                   TLNAME = 'E R R O R';
007200190321         ENDSR;
007300190321      /END-FREE
007400190321     OQPRINT    E            HEADINGS       2 02
007500190321     O                                            8 'PAGE'
007600190321     O                       PAGE                13
007700190321     O                                           50 'SALESSTAFF UPDATE'
007800190321     O                                           64 'DATE'
007900190321     O                       UDATE         Y     73
008000190321     O          E            HEADINGS       1
008100190321     O                                            4 'CODE'
008200190321     O                                           10 'DEPT'
008300190321     O                                           14 'ID'
008400190321     O                                           28 'FIRST NAME'
008500190321     O                                           49 'LAST NAME'
008600190321     O                                           66 'CITY'
008700190321     O                                           91 'ADDRESS'
008800190321     O                                          113 'PHONE'
008900190321     O                                          125 'POSTAL'
009000190321     O          E            HEADINGS       2
009100190321     O                                          124 'CODE'
009200190321     O          E            DETAIL         1
009300190321     O                       TCODE                2
009400190321     O                       TDEPT                9
009500190321     O                       TSALESID            15
009600190321     O                       TFNAME              38
009700190321     O                       TLNAME              60
009800190321     O                       TCITY               82
009900190321     O                       TADDRESS           102
010000190321     O                       TPHONE             116
010100190321     O                       TPCODE             125
010200190321
