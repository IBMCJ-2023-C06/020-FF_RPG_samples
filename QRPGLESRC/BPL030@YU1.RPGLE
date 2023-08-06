     H**********************************************************************
     H*                                                                    *
     H*   システム名      :ＲＰＧ教育                                *
     H*   サブシステム名  :帳票プログラム　　　　　　　　　　　      *
     H*   プログラム名    :地区別受注一覧表                          *
     H*   プログラムＩＤ  : BPL030                                     *
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
     H COPYRIGHT('COPYRIGHT(C) CHUBU SYSTEM CO.,LTD. ALL RIGHTS RESERVED')
     F*-*******************************************************************
     F*-*Ｆ仕様書                                                      **
     F*-*******************************************************************
     F*受注見出し
     FJUMIDL02  IF   E           K DISK
     F*得意先マスタ
     FTOKMSP    IF   E           K DISK
     F*印刷装置
     FBPL030P   O    E             PRINTER OFLIND(*IN80)
     D*-********************************************************************
     D*-* テーブル／配列定義                                            **
     D*-********************************************************************
     D*地区名称
     D   IX            S              1S 0
     D   TIKCOD        S              2A   DIM(05) PERRCD(01) CTDATA
     D   TIKNAM        S              8A   DIM(05) ALT(TIKCOD)
     C*-********************************************************************
     C*-* ＰＬＩＳＴ／ＫＬＩＳＴ                                        **
     C*-********************************************************************
     C     JUMIDKEY1     KLIST
     C                   KFLD                    K@JHTIKU                       地区コード
     C                   KFLD                    K@JHTOKB                       得意先番号
     C                   KFLD                    K@JHCHUB                       受注番号
     C     *LIKE         DEFINE    JHTIKU        K@JHTIKU
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
     C                   MOVEL(P)  *LOVAL        K@JHTIKU                       地区コード
     C     JUMIDKEY1     SETLL     JUMIDR
     C*
     C                   DO        *HIVAL
     C*
     C*読取り
     C                   READ      JUMIDR
     C                   IF        %EOF
     C                   LEAVE
     C                   ENDIF
     C*
     C*初回はブレイクさせない
     C                   IF        W#CNTP     <= *ZERO
     C                   EXSR      @SUM1                                        集計処理
     C                   ITER
     C                   ENDIF
     C*
     C*キーブレイク判定
     C*    地区計）
     C                   IF        JHTIKU     <> W@JHTIKU
     C                   EXSR      @PTOTAL2
     C*    得意先計）
     C                   ELSEIF    JHTOKB     <> W@JHTOKB
     C                   EXSR      @PTOTAL1
     C                   ENDIF
     C*
     C                   EXSR      @SUM1                                        集計処理
     C*
     C                   ENDDO
     C*
     C*印刷（見出し※０件の場合
     C                   IF        W#CNTP     <= *ZERO
     C                   EXSR      @PHEAD1
     C*印刷（地区計
     C                   ELSE
     C                   EXSR      @PTOTAL2
     C                   ENDIF
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
     C                   CLEAR                   PHEAD1
     C                   CLEAR                   PTOTAL1
     C                   CLEAR                   PTOTAL2
     C*
     C     *LIKE         DEFINE    JHTIKU        W@JHTIKU                       地区コード
     C     *LIKE         DEFINE    JHTOKB        W@JHTOKB                       得意先番号
     C*
     C                   ENDSR
     C*-***************************************************************
     C*-* @PHEAD1     印刷処理（見出し                             **
     C*-***************************************************************
     C     @PHEAD1       BEGSR
     C*
     C*地区名の取得
     C                   Z-ADD     1             IX
     C     PH1JHTIKU     LOOKUP    TIKCOD(IX)                             28
     C                   IF        *IN28       = *ON
     C                   MOVEL(P)  TIKNAM(IX)    PH1TIKNAM                      地区名称
     C                   ELSE
     C                   MOVEL(P)  *ALL'*'       PH1TIKNAM                      地区名称
     C                   ENDIF
     C*
     C                   WRITE     PHEAD1
     C*
     C*オーバーフロー標識オフ
     C                   SETOFF                                       80
     C*
     C                   ENDSR
     C*-***************************************************************
     C*-* @SUM1       集計処理                                     **
     C*-***************************************************************
     C     @SUM1         BEGSR
     C*
     C                   MOVEL(P)  JHTIKU        PH1JHTIKU                      地区コード
     C*
     C                   MOVEL(P)  JHTOKB        PT1JHTOKB                      得意先番号
     C*
     C                   ADD       1             PT1_REC                        レコード数
     C                   ADD       JHKING        PT1_KING                       受注金額
     C*
     C                   ADD       1             PT2_REC                        レコード数
     C                   ADD       JHKING        PT2_KING                       受注金額
     C*
     C                   ADD       1             W#CNTP                         印刷件数
     C*
     C*ブレイクキー退避
     C                   MOVEL(P)  JHTIKU        W@JHTIKU                       地区コード
     C                   MOVEL(P)  JHTOKB        W@JHTOKB                       得意先番号
     C*
     C                   ENDSR
     C*-***************************************************************
     C*-* @PTOTAL1    印刷処理（合計・得意先                       **
     C*-***************************************************************
     C     @PTOTAL1      BEGSR
     C*
     C*見出し印刷
     C   80              EXSR      @PHEAD1
     C*
     C                   IF        PT1_REC    <> *ZERO
     C     PT1_KING      DIV(H)    PT1_REC       PT1_AVR                        平均金額
     C                   ENDIF
     C*
     C                   MOVEL(P)  PT1JHTOKB     TKBANG                         得意先番号
     C     TOKMSKEY1     CHAIN     TOKMSR
     C                   IF        %FOUND
     C                   MOVEL(P)  TKNAKJ        PT1TKNAKJ                      得意先名（漢字
     C                   ELSE
     C                   MOVEL(P)  *ALL'*'       PT1TKNAKJ                      得意先名（漢字
     C                   ENDIF
     C*
     C                   WRITE     PTOTAL1
     C                   CLEAR                   PTOTAL1
     C*
     C                   ENDSR
     C*-***************************************************************
     C*-* @PTOTAL2    印刷処理（合計・地区                         **
     C*-***************************************************************
     C     @PTOTAL2      BEGSR
     C*
     C*得意先計印刷
     C                   EXSR      @PTOTAL1
     C*
     C*見出し印刷
     C******   80              EXSR      @PHEAD1
     C*
     C                   IF        PT2_REC    <> *ZERO
     C     PT2_KING      DIV(H)    PT2_REC       PT2_AVR                        平均金額
     C                   ENDIF
     C*
     C                   WRITE     PTOTAL2
     C                   CLEAR                   PTOTAL2
     C*
     C*次回改ページ
     C                   CLEAR                   PHEAD1
     C                   SETON                                        80
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
** TIKCOD/TIKNAM 地区コード／地区名
01北海道
02東北
03北陸
04関東
05関西
