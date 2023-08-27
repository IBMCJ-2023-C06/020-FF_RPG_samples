     H**********************************************************************
     H*                                                                    *
     H*   システム名      :ＲＰＧ教育                                *
     H*   サブシステム名  :帳票プログラム　　　　　　　　　　　      *
     H*   プログラム名    :得意先別受注一覧表                        *
     H*   プログラムＩＤ  : BPL020                                     *
     H*   会　社　名　　  :株式会社中部システム                      *
     H*                                                                    *
     H*     作　成　者    :㈱中部システム Y.USHIDA                   *
     H*     作　成　日    : 2023/05/30                                 *
     H*     管　理　番　号: CSC-202305-001                             *
     H*                                                                    *
     H*     変　更　者    :　　　　　　　　　　　　　　　　　　      *
     H*     変　更　日    : ____/__/__                                 *
     H*     管　理　番　号:                                            *
     H*                                                                    *
     H*  プログラム特記事項                                              *
     H* 　　　　　　　　　　　＿　　　　　　　　　　　　　　　　　　   *
     H* 　　　　　　　　　　　＿　　　　　　　　　　　　　　　　　　   *
     H*                                                                    *
     H*-*******************************************************************
     H*-*Ｈ仕様書                                                      **
     H*-*******************************************************************
     H DATEDIT(*YMD)
     H DECEDIT('0.')
     H COPYRIGHT('...')
     F*-*******************************************************************
     F*-*Ｆ仕様書                                                      **
     F*-*******************************************************************
     F*受注見出し
     FJUMIDL01  IF   E           K DISK
     F*得意先マスタ
     FTOKMSP    IF   E           K DISK
     F*印刷装置
     FBPL020P   O    E             PRINTER OFLIND(*IN80)
     C*-********************************************************************
     C*-* ＰＬＩＳＴ／ＫＬＩＳＴ                                        **
     C*-********************************************************************
     C     JUMIDKEY1     KLIST
     C                   KFLD                    K@JHTOKB                       得意先番号
     C                   KFLD                    K@JHCHUB                       受注番号
     C     *LIKE         DEFINE    JHTOKB        K@JHTOKB
     C     *LIKE         DEFINE    JHCHUB        K@JHCHUB
     C*
     C     TOKMSKEY1     KLIST
     C                   KFLD                    TKBANG                         得意先番号
     C*-********************************************************************
     C*-* メインルーチン                                                **
     C*-********************************************************************
     C*初期処理
     C                   EXSR      @INZ
     C*
     C*開始キー位置づけ
     C                   MOVEL(P)  *LOVAL        K@JHTOKB                       得意先番号
     C     JUMIDKEY1     SETLL     JUMIDR
     C*
     C                   DO        *HIVAL
     C*
     C*読取り
     C                   READ      JUMIDR
     C                   IF        %EOF
     C                   LEAVE
     C                   ENDIF
     C*印刷（明細
     C                   EXSR      @PITEM1
     C*
     C                   ENDDO
     C*
     C*印刷（見出し※０件の場合
     C                   IF        W#CNTP     <= *ZERO
     C                   EXSR      @PHEAD1
     C                   ENDIF
     C*
     C*印刷（合計
     C                   EXSR      @PTOTAL1
     C*
     C*終了処理
     C                   EXSR      @END
     C*-***************************************************************
     C*-* @INZ        初期処理                                     **
     C*-***************************************************************
     C     @INZ          BEGSR
     C*
     C*システム日付
     C                   TIME                    WTIME            14 0
     C                   MOVEL     WTIME         WTIME6            6 0
     C                   MOVE      WTIME         WDATE8            8 0
     C*
     C*オーバーフロー標識オン
     C                   SETON                                        80
     C*
     C*印刷件数
     C                   Z-ADD     *ZERO         W#CNTP            9 0          印刷件数
     C*
     C                   CLEAR                   PTOTAL1
     C*
     C                   ENDSR
     C*-***************************************************************
     C*-* @PHEAD1     印刷処理（見出し                             **
     C*-***************************************************************
     C     @PHEAD1       BEGSR
     C*
     C                   CLEAR                   PHEAD1
     C*
     C                   WRITE     PHEAD1
     C*
     C*オーバーフロー標識オフ
     C                   SETOFF                                       80
     C*
     C                   ENDSR
     C*-***************************************************************
     C*-* @PITEM1     印刷処理（明細                               **
     C*-***************************************************************
     C     @PITEM1       BEGSR
     C*
     C*見出し印刷
     C   80              EXSR      @PHEAD1
     C*
     C                   CLEAR                   PITEM1
     C*
     C                   MOVEL(P)  JHTOKB        PI1JHTOKB                      得意先番号
     C*
     C                   MOVEL(P)  JHTOKB        TKBANG                         得意先番号
     C     TOKMSKEY1     CHAIN     TOKMSR
     C                   IF        %FOUND
     C                   MOVEL(P)  TKNAKJ        PI1TKNAKJ                      得意先名（漢字
     C                   ELSE
     C                   MOVEL(P)  *ALL'*'       PI1TKNAKJ                      得意先名（漢字
     C                   ENDIF
     C*
     C                   Z-ADD     JHCHUB        PI1JHCHUB                      受注番号
     C                   Z-ADD     JHGYOS        PI1JHGYOS                      明細行数
     C                   Z-ADD     JHKING        PI1JHKING                      受注金額
     C*
     C                   WRITE     PITEM1
     C*
     C                   ADD       1             W#CNTP                         印刷件数
     C*
     C                   Z-ADD     W#CNTP        PT1KENSU                       レコード件数
     C                   ADD       JHKING        PT1GOKEI                       受注金額
     C*
     C                   ENDSR
     C*-***************************************************************
     C*-* @PTOTAL1    印刷処理（合計                               **
     C*-***************************************************************
     C     @PTOTAL1      BEGSR
     C*
     C                   IF        W#CNTP     <> *ZERO
     C     PT1GOKEI      DIV(H)    W#CNTP        PT1HEIKIN                      平均金額
     C                   ENDIF
     C*
     C                   WRITE     PTOTAL1
     C                   CLEAR                   PTOTAL1
     C*
     C                   ENDSR
     C*-***************************************************************
     C*-* @END        終了処理                                     **
     C*-***************************************************************
     C     @END          BEGSR
     C*
     C                   SETON                                        LR
     C                   RETURN
     C*
     C                   ENDSR
