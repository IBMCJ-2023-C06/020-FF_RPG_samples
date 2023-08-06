     H**********************************************************************
     H*                                                                    *
     H*   システム名      :ＲＰＧ教育                                *
     H*   サブシステム名  :帳票プログラム　　　　　　　　　　　      *
     H*   プログラム名    :品目マスタ一覧表                          *
     H*   プログラムＩＤ  : BPL010                                     *
     H*   会　社　名　　  :株式会社中部システム                      *
     H*                                                                    *
     H*     作　成　者    :㈱中部システム Y.USHIDA                   *
     H*     作　成　日    : 2023/05/24                                 *
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
     F*品目マスタ
     FHINMSP    IF   E           K DISK
     F*印刷装置
     FBPL010P   O    E             PRINTER OFLIND(*IN80)
     C*-********************************************************************
     C*-* ＰＬＩＳＴ／ＫＬＩＳＴ                                        **
     C*-********************************************************************
     C     HINMSKEY1     KLIST
     C                   KFLD                    K@HNBANG                       品目番号
     C     *LIKE         DEFINE    HNBANG        K@HNBANG
     C*-********************************************************************
     C*-* メインルーチン                                                **
     C*-********************************************************************
     C*初期処理
     C                   EXSR      @INZ
     C*
     C*開始キー位置づけ
     C                   MOVEL(P)  *LOVAL        K@HNBANG                       品目番号
     C     HINMSKEY1     SETLL     HINMSR
     C*
     C                   DO        *HIVAL
     C*
     C*読取り
     C                   READ      HINMSR
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
     C                   MOVEL(P)  HNBANG        PI1HNBANG                      品目番号
     C                   MOVEL(P)  HNNAKJ        PI1HNNAKJ                      品目名（漢字
     C                   MOVEL(P)  HNNAKN        PI1HNNAKN                      品目名（カナ
     C                   Z-ADD     HNTEIK        PI1HNTEIK                      定価
     C                   Z-ADD     HNGENK        PI1HNGENK                      原価
     C                   Z-ADD     HNGSUR        PI1HNGSUR                      当月売上数量
     C                   Z-ADD     HNGKIN        PI1HNGKIN                      当月売上高
     C*
     C                   WRITE     PITEM1
     C*
     C                   ADD       1             W#CNTP                         印刷件数
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
