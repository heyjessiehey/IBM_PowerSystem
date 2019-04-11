000100190330     F************************************************************************************
000101190330     F* THIS PROGRAM USES A CURSOR TO LOAD A TEMPORARY RESULT TABLE THAT JOINS THE ORDERS,
000102190330     F* ORDERLINE, CUSTOMER, PART AND SALESREP TABLES.  ORDER NUMBER IS USED AS A CONTROL*
000103190330     F* BREAK FIELD WHERE CUSTOMER TOTALS ARE PRINTED ON NEW ORDER NUMBERS               *
000104190330     F************************************************************************************
000105190330
000106190330     FQPRINT    O    F  132        PRINTER OFLIND(*INOF) FORMOFL(60) FORMLEN(66)
000107190330     D CustomerRecord  DS
000108190330     D CustId                         6
000109190330     D FullName                      31
000110190330     D City                          20
000111190330     D Purchase                       7  2
000112190330     D PDate                           D
000113190330     D Province                      10
000114190330     D ProvinceH       S             10
000115190330     D TotalCost       S              8  2
000116190330     D TotalRecords    S              5  0
000117190330     D TotalExtended   S              9  2
000118190330     D OntarioTot      S              3  0
000119190330     D QuebecTot       S              3  0
000120190330     D ManitobaTot     S              3  0
000121190330     D EndOfFile       S               N
000122190330     C/EJECT
000123190330
000124190330     C************************************************************************************
000125190330     C*                        ***   M A I N   R O U T I N E   ***                       *
000126190330     C************************************************************************************
000127190330      /FREE
000128190330                EXSR PrepareFiles;
000129190330                EXCEPT HEADINGS;
000130190330                EXSR GetRow;
000131190330                Except NewProv;
000132190330                ProvinceH = Province;
000133190330                DOW NOT EndOfFile;
000134190330                    IF *INOF = *ON;
000135190330                        EXCEPT HEADINGS;
000136190330                       *INOF = *OFF;
000137190330                    ENDIF;
000138190330                    If ProvinceH = Province;
000139190330                       Except Detail;
000140190330                    Else;
000141190330                       ProvinceH = Province;
000142190330                       Except NewProv;
000143190330                       Except Detail;
000144190330                    EndIf;
000145190330                    TotalCost     = TotalCost     + Purchase;
000146190330                    TotalRecords= TotalRecords + 1;
000147190330                    EXSR GetRow;
000148190330                ENDDO;
000149190330                EXSR   WRAPUP;
000150190330                EXCEPT Totals;
000151190330                *INLR = *ON;
000152190330                RETURN;
000153190330
000154190330 
000155190330      // O P E N F I L E S   S U B R O U T I N E
000158190330         BEGSR  PrepareFiles;
000159190330      // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  S T R U C T U R E
000160190330       EXEC SQL
000161190330              DECLARE ALLPROVCURSOR CURSOR
000162190330            FOR
000163190330            SELECT    CUSTID, TRIM(FNAME) || ' ' || TRIM(LNAME),
000164190330                      CITY,   PURCHASE, PDATE,
000165190330                      'Ontario' AS PROVINCE
000166190330            FROM      BCI433LIB/ONTARIO
000167190330            WHERE PURCHASE > 150
000168190330            UNION ALL
000169190330            SELECT    CUSTID, TRIM(FNAME) || ' ' || TRIM(LNAME),
000170190330                      CITY,   PURCHASE, PDATE,
000171190330                      'Quebec' AS PROVINCE
000172190330            FROM      BCI433LIB/QUEBEC
000173190330            WHERE PURCHASE > 150
000174190330            UNION ALL
000175190330            SELECT    CUSTID, TRIM(FNAME) || ' ' || TRIM(LNAME),
000176190330                      CITY,   PURCHASE, PDATE,
000177190330                      'Manitoba' AS PROVINCE
000178190330            FROM      BCI433LIB/MANITOBA
000179190330            WHERE PURCHASE > 150
000180190330              FOR READ ONLY;
000181190330
000182190330      // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D
000183190330       EXEC SQL
000184190330             OPEN ALLPROVCURSOR;
000185190330
000186190330
000187190330             If SQLCODE <> 0 OR SQLWN0 = 'W';
000188190330                EndOfFile = *ON;
000189190330             EndIf;
000190190330
000191190330            ENDSR;
000192190330      //**********************************************************************
000193190330      //   G E T     R O W    S U B R O U T I N E
000194190330      //**********************************************************************
000195190330            BEGSR     GETROW;
000196190330        EXEC SQL
000197190330             FETCH NEXT
000198190330             FROM  ALLPROVCURSOR
000199190330             INTO :CustomerRecord;
000200190330
000201190330
000202190330             If SQLCODE <> 0 OR SQLWN0 = 'W';
000203190330                EndOfFile = *ON;
000204190330             EndIf;
000205190330
000206190330             ENDSR;
000207190330
000216190330        //**********************************************************************
000217190330        // W R A P U P     S U B R O U T I N E
000218190330        //**********************************************************************
000219190330           BEGSR WRAPUP;
000220190330        EXEC SQL
000221190330             CLOSE ALLPROVCURSOR;
000222190330
000223190330
000224190330             If SQLCODE <> 0 OR SQLWN0 = 'W';
000225190330                EndOfFile = *ON;
000226190330             EndIf;
000227190330
000228190330        EXEC SQL
000229190330             SELECT COUNT(*) INTO :OntarioTot
000230190330             From   BCI433LIB/ONTARIO
000231190330             Where  Purchase <= 150;
000232190330
000233190330             If SQLCODE <> 0 OR SQLWN0 = 'W';
000234190330                OntarioTot = -999;
000235190330             EndIf;
000236190330        EXEC SQL
000237190330             SELECT COUNT(*) INTO :QuebecTot
000238190330             From   BCI433LIB/QUEBEC
000239190330             Where  Purchase <= 150;
000240190330
000241190330             If SQLCODE <> 0 OR SQLWN0 = 'W';
000242190330                QuebecTot = -999;
000243190330             EndIf;
000244190330        EXEC SQL
000245190330             SELECT COUNT(*) INTO :ManitobaTot
000246190330             From   BCI433LIB/MANITOBA
000247190330             Where  Purchase <= 150;
000248190330
000249190330             If SQLCODE <> 0 OR SQLWN0 = 'W';
000250190330                ManitobaTot = -999;
000251190330             EndIf;
000252190330          ENDSR;
000253190330      /END-FREE
000254190330 
000255190330     OQPRINT    E            HEADINGS       2 02
000256190330     O                                           67 'Customers > $150.00'
000257190330     O                                          110 'Page:'
000258190330     O                       PAGE               115
000259190330     O          E            HEADINGS       1
000260190330     O                                            8 'Province'
000261190330     O                                           23 'Customer ID'
000262190330     O                                           42 'Full Name'
000263190330     O                                           64 'City'
000264190330     O                                           90 'Purchase'
000265190330     O                                          101 'Purchase'
000266190330     O          E            HEADINGS       2
000267190330     O                                           89 'Amount'
000268190330     O                                           99 'Date'
000269190330     o          E            NewProv        1
000270190330     O                       Province            10
000271190330     o          E            DETAIL         1
000272190330     O                       CustID              20
000273190330     O                       FullName            61
000274190330     O                       City                74
000275190330     O                       Purchase      1     90
000276190330     O                       PDate              103
000277190330     O          E            Totals      2  1
000278190330     O                                           79 'Total Amount:'
000279190330     O                       TotalCost     1     90
000280190330     O          E            Totals      1  1
000281190330     O                                           17 'Total Customers:'
000282190330     O                       TotalRecords  1     24
000283190330     O          E            TOTALS         2 02
000284190330     O                                           67 'Customers <= $150.00'
000285190330     O                                          110 'Page:'
000286190330     O                       PAGE               115
000287190330     O          E            Totals         2
000288190330     O                                           18 'Ontario'
000289190330     O                                           41 'Quebec'
000290190330     O                                           69 'Manitoba'
000291190330     O          E            Totals         1
000292190330     O                       OntarioTot    1     15
000293190330     O                       QuebecTot     1     38
000294190330     O                       ManitobaTot   1     66
000295190330
000296190330
