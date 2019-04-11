000100190330     F**************************************************************************
000101190330     F*  CUSTOMER19 READ BY NATIVE LANGUAGE (ILE RPG)
000102190330     F*  CONTACTW19 ROW RETRIEVED WITH EMBEDDED SQL
000103190330     F*  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER19 AND CONTACTW19
000104190330     F*  SUMMARY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS
000105190330     F**************************************************************************
000107190330     FCUSTOMER19IF   E             DISK    RENAME(CUSTOMER19:CUSTOMERRF)
000108190330     FQPRINT    O    F  132        PRINTER OFLIND(*INOF) FORMOFL(30) FORMLEN(66)
000111190330
000112190330     D CONTACTW19    E DS
000113190330     D ContactTotal    S              5  0
000114190330     D CustomerTotal   S              5  0
000115190330     D UnknownTotal    S              5  0
000116190330     D OldestDate      S               D
000117190330     D MostRecentDate  S               D
000118190330     D User            S             10
000119190330     D Server          S             10
000120190330     D TimeStamp       S               Z
000121190330     D DateIn          S              5  0
000123190330     D INDLASTDATEC    S              4B 0
000124190330     D INDNEXTDATEC    S              4B 0
000130190330     D Dummy           S              1  0
000131190330     D Flag            S              7
000132190330     D NextCallDate    S               D
000133190330     C/EJECT
000134190330
000135190330     C**************************************************************************
000136190330     C*                        ***   M A I N   R O U T I N E   ***
000137190330     C**************************************************************************
000138190330      /FREE
000139190330                EXSR SummaryInfo;
000140190330                EXCEPT HEADINGS;
000141190330                READ CUSTOMER19;
000142190330                DOW NOT %EOF;
000143190330                    EXSR SQLSelect;
000144190330                    IF *INOF = *ON;
000145190330                       EXCEPT HEADINGS;
000146190330                       *INOF = *OFF;
000147190330                    ENDIF;
000148190330                    EXCEPT DETAIL;
000149190330                   READ CUSTOMER19;
000150190330                ENDDO;
000151190330                EXCEPT TOTALS;
000152190330                *INLR = *ON;
000153190330                RETURN;
000154190330 
000155190330      //*************************************************************************
000156190330      //   S Q L S E L E C T   S U B R O U T I N E
000157190330      //*************************************************************************
000158190330      // A row from the contacts table has the same customer number found in the record
000159190330      // read from the CUSTOMER19 file. That row is retrieved to find out the last date
000160190330      // called, phone number, comments and the salesperson number.
000161190330
000162190330      //  The call back interval is added to the last date called to determine the
000163190330      //  next date to call.  Since null values may be stored in the last date called
000164190330      // indicator variables are used.
000165190330                BEGSR SQLSELECT;
000166190330                 EXEC SQL
000167190330                      SELECT PHNLDC + PHNCIT DAYS, PHNLDC, CSTPHN, PHNCOM,
000168190330                             CSTSLN
000169190330                      INTO   :NEXTCALLDATE :INDNEXTDATEC,
000170190330                             :PHNLDC :INDLASTDATEC,
000171190330                             :CSTPHN, :PHNCOM, :CSTSLN
000172190330                      FROM   BCI433LIB/CONTACTW19
000173190330                      WHERE  CSTNUM = :CSTNUM;
000174190330
000175190330                      SELECT;
000176190330                        WHEN SQLSTATE = '00000';
000177190330                          DUMMY = 0;
000178190330                        WHEN SQLSTATE = '02000';
000179190330                          CSTPHN = 'NOT FOUND';
000180190330                          NEXTCALLDATE = D'9999-09-09';
000181190330                          PHNLDC = D'9999-09-09';
000182190330                          PHNCOM = *ALL'*';
000183190330                          CSTSLN = *ALL'*';
000184190330                        WHEN %Subst (SQLSTATE :1 :2) = '01';
000185190330                          NEXTCALLDATE = D'9999-09-09';
000186190330                          PHNLDC = D'9999-09-09';
000187190330                          PHNCOM = *ALL'*';
000188190330                          CSTSLN = *ALL'*';
000189190330                          CSTPHN = *ALL'*';
000190190330                        OTHER;
000191190330                          NEXTCALLDATE = D'9999-09-09';
000192190330                          PHNLDC = D'9999-09-09';
000194190330                          PHNCOM = *ALL'*';
000195190330                          CSTSLN = *ALL'*';
000196190330                          CSTPHN = *ALL'*';
000197190330                      ENDSL;
000198190330
000199190330                      IF INDLASTDATEC = -1;
000200190330                         CSTPHN = 'UNKNOWN DATE';
000201190330                         NEXTCALLDATE = D'9999-09-09';
000202190330                         PHNLDC = D'9999-09-09';
000203190330                      ELSE;
000204190330                         IF INDLASTDATEC <> 0;
000205190330                            CSTPHN = 'DATE PROBLEM';
000206190330                            NEXTCALLDATE = D'9999-09-09';
000207190330                            PHNLDC = D'9999-09-09';
000208190330                         ENDIF;
000209190330                      ENDIF;
000212190330                ENDSR;
000213190330
000214190330      //**********************************************************************
000215190330      // S U M M A R Y I N F O   S U B R O U T I N E
000216190330      //**********************************************************************
000217190330                BEGSR  SummaryInfo;
000218190330      //  D E T E R M I N E   T O T A L S   F O R   CONTACTW19 & CUSTOMER19
000219190330                 EXEC SQL
000220190330                      SELECT COUNT(*)
000221190330                      INTO   :CONTACTTOTAL
000222190330                      FROM   BCI433LIB/CONTACTW19;
000223190330
000224190330                      IF SQLCODE <> 0 OR SQLWN0 = 'W';
000225190330                        CONTACTTOTAL = -99999;
000226190330                      ENDIF;
000227190330                 EXEC SQL
000228190330                      SELECT COUNT(*)
000229190330                      INTO   :CUSTOMERTOTAL
000230190330                      FROM   BCI433LIB/CONTACTW19;
000231190330
000232190330                      IF SQLCODE <> 0 OR SQLWN0 = 'W';
000233190330                        CUSTOMERTOTAL = -99999;
000234190330                      ENDIF;
000235190330
000236190330      // D E T E R M I N E   N U M B E R   O F   U N K N O W N   L A S T   D A T E
000237190330      //  C A L L E D   R E C O R D S
000240190330                 EXEC SQL
000241190330                      SELECT COUNT(*)
000242190330                      INTO   :UNKNOWNTOTAL
000243190330                      FROM   BCI433LIB/CONTACTW19
000244190330                      WHERE  CSTLASTCALLDATE IS NULL;
000245190330
000246190330                      IF NOT(SQLCODE = 0) OR (SQLWN0 = 'W');
000247190330                        UNKNOWNTOTAL = -99999;
000248190330                      ENDIF;
000249190330
000250190330      //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  L A S T
000251190330      //   C A L L B A C K   D A T E S
000252190330                 EXEC SQL
000253190330                      SELECT MIN(PHNLDC)
000254190330                      INTO   :OLDESTDATE
000255190330                      FROM   BCI433LIB/CONTACTW19;
000256190330
000257190330                      IF SQLCODE <> 0 OR SQLWN0 = 'W' AND SQLWN2 <> 'W';
000258190330                        OLDESTDATE = D'9999-09-09';
000259190330                      ENDIF;
000260190330
000261190330                 EXEC SQL
000262190330                      SELECT MAX(PHNLDC)
000263190330                      INTO   :MOSTRECENTDATE
000264190330                      FROM   BCI433LIB/CONTACTW19;
000265190330
000266190330                      SELECT;
000267190330                        WHEN SQLWN2 = 'W';
000268190330                          DUMMY = 0;
000269190330                        WHEN NOT(SQLCODE = 0) OR (SQLWN0 ='W');
000270190330                          MOSTRECENTDATE = D'9999-09-09';
000272190330                      ENDSL;
000273190330
000274190330      // D E T E R M I N E   T H E   U S E R,  S E R V E R,  &   T I M E S T A M P
000275190330                 EXEC SQL
000276190330                      SELECT USER, CURRENT TIMESTAMP, CURRENT SERVER
000277190330                      INTO   :USER, :TIMESTAMP, :SERVER
000278190330                      FROM   SYSIBM/SYSDUMMY1;
000280190330
000281190330                ENDSR;
000282190330      /END-FREE
000283190330     OQPRINT    E            HEADINGS       2 02
000284190330     O                                            5 'USER:'
000285190330     O                       USER                16
000286190330     O                                           28 'TIMESTAMP:'
000287190330     O                       TIMESTAMP           55
000288190330     O                                           64 'SERVER:'
000289190330     O                       SERVER              75
000290190330     O                                           87 'PAGE:'
000291190330     O                       PAGE                90
000292190330     O          E            HEADINGS       2
000293190330     O                                           54 'Phone Log Report'
000294190330     O                       UDATE         Y     89
000295190330     O          E            HEADINGS       1
000296190330     O                                            5 'Sales'
000297190330     O                                           15 'Customer'
000298190330     O                                           31 'Customer Name'
000299190330     O                                           59 'Telephone'
000300190330     O                                           75 'Last Call'
000301190330     O                                           88 'Oldest Call'
000302190330     O                                          101 'Next Call'
000303190330     O          E            HEADINGS       2
000304190330     O                                            3 'ID'
000305190330     O                                           13 'Number'
000306190330     O                                           73 'Date'
000307190330     O                                           85 'Date'
000308190330     O                                           98 'Date'
000309190330     O          E            DETAIL         1
000310190330     O                       CSTSLN               3
000311190330     O                       CSTNUM              13
000312190330     O                       CSTNAM              48
000313190330     O                       CSTPHN              64
000314190330     O                       PHNLDC              75
000315190330     O                       FLAG                86
000316190330     O                       NextCallDate       101
000317190330     O          E            TOTALS      2  2
000318190330     O                                           32 'Summary Information'
000319190330     O          E            TOTALS         1
000320190330     O                                           26 'CONTACTW19 Total Records:'
000321190330     O                       ContactTotal  1     34
000322190330     O          E            TOTALS         1
000323190330     O                                           26 'CUSTOMER19 Total Records:'
000324190330     O                       CustomerTotal 1     34
000325190330     O          E            TOTALS      1  1
000326190330     O                                           27 'Oldest Last Callback Date:'
000327190330     O                       OldestDate          42
000328190330     O          E            TOTALS         1
000329190330     O                                           27 'Most Recent Callback Date:'
000330190330     O                       MostRecentDate      42
000331190330     O          E            TOTALS      2  1
000332190330     O                                           22 'Total Records with an'
000333190330     O                                           47 'Unknown Last Date Called'
000334190330     O                                           62 'in CONTACTW19:'
000335190330     O                       UnknownTotal        70
