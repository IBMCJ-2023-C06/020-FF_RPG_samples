**FREE
//   H**********************************************************************
//   H*                                                                    *
//   H*   システム名      :ＲＰＧ教育                                *
//   H*   サブシステム名  :教育プログラム　　　　　　　　　　　      *
//   H*   プログラム名    :地区別受注一覧表                          *
//   H*   プログラムＩＤ  : BPL030                                     *
//   H*   会　社　名　　  :株式会社中部システム                      *
//   H*                                                                    *
//   H*     作　成　者    :㈱中部システム Y.USHIDA                   *
//   H*     作　成　日    : 2023/05/30                                 *
//   H*     管　理　番　号: CSC-202305-001                             *
//   H*                                                                    *
//   H*     変　更　者    :　　　　　　　　　　　　　　　　　　      *
//   H*     変　更　日    : ____/__/__                                 *
//   H*     管　理　番　号:                                            *
//   H*                                                                    *
//   H*  プログラム特記事項                                              *
//   H* 　　　　　　　　　　　＿　　　　　　　　　　　　　　　　　　   *
//   H* 　　　　　　　　　　　＿　　　　　　　　　　　　　　　　　　   *
//   H*                                                                    *
//   H*-*******************************************************************
//   H*-*Ｈ仕様書                                                      **
//   H*-*******************************************************************
CTL-OPT
       DATEDIT(*YMD)
       DECEDIT('0.')
       COPYRIGHT('COPYRIGHT(C) CHUBU SYSTEM CO.,LTD. ALL RIGHTS RESERVED')
;
//   F*-*******************************************************************
//   F*-*Ｆ仕様書                                                      **
//   F*-*******************************************************************
//   F*印刷装置
//DCL-F    BPL030P       PRINTER  OFLIND(*IN80                )                ;
DCL-F    BPL030P       PRINTER  OFLIND(W#FG_OF              )                ;
  DCL-S    W#FG_OF       IND                                                   ;
//   F*受注見出し
DCL-F    JUMIDL02      KEYED    USAGE(*INPUT                )                ;
//   F*得意先マスタ
DCL-F    TOKMSP        KEYED    USAGE(*INPUT                )                ;
//   D*-*******************************************************************
//   D*-*Ｄ仕様書                                                      **
//   D*-*******************************************************************
//   D*-********************************************************************
//   D*-* ＫＬＩＳＴ                                                    **
//   D*-********************************************************************
//受注見出
DCL-DS   JUMIDKEY1     LIKEREC(JUMIDR     : *KEY            ) INZ            ;
//得意先マスタ
DCL-DS   TOKMSKEY1     LIKEREC(TOKMSR     : *KEY            ) INZ            ;
//   D*-********************************************************************
//   D*-* テーブル／配列定義                                            **
//   D*-********************************************************************
//地区名称
DCL-S  IX            ZONED(1:0)                               ;  //指標
DCL-S  TIKCOD        CHAR(002) DIM(05) PERRCD(01) CTDATA      ;  //地区コード
DCL-S  TIKNAM        CHAR(008) DIM(05) ALT(TIKCOD)            ;  //地区名称
//   D*-********************************************************************
//   D*-* 変数定義                                                      **
//   D*-********************************************************************
//DCL-S  WTIMESTAMP    TIMESTAMP(*SYS )         ;  //タイムスタンプ
DCL-S  WTIMESTAMP    TIMESTAMP                ;  //タイムスタンプ
DCL-S  WDATE8        ZONED(8:0)               ;  //日付
DCL-S  WTIME6        ZONED(6:0)               ;  //時刻
DCL-S  W#CNTP        ZONED(9:0)               ;  //印刷件数

//------------------
//キーブレイク用
//------------------
DCL-S  W@JHTIKU      LIKE(JHTIKU      )       ;  //地区コード
DCL-S  W@JHTOKB      LIKE(JHTOKB      )       ;  //得意先番号

//   C*-********************************************************************
//   C*-* メインルーチン                                                **
//   C*-********************************************************************

//初期処理
EXSR      @INZ                         ;

//開始キー位置づけ
JUMIDKEY1.JHTIKU       = *LOVAL        ;      //地区コード
SETLL %KDS(JUMIDKEY1   ) JUMIDR        ;

DOW  1 = 1                             ;
  READ   JUMIDR                          ;
  IF        %EOF                         ;
    LEAVE                                  ;
  ENDIF                                  ;

  //初回はブレイクさせない
  IF      W#CNTP     <= *ZERO                ;
    EXSR      @SUM1                        ;       //集計処理
    ITER                                   ;
  ENDIF                                      ;

  //キーブレイクの判定
  IF      JHTIKU     <> W@JHTIKU             ;
    EXSR      @PTOTAL2                     ;       //地区計
  ELSEIF  JHTOKB     <> W@JHTOKB             ;
    EXSR      @PTOTAL1                     ;       //得意先計
  ENDIF                                  ;

  EXSR      @SUM1                        ;       //集計処理

ENDDO                                        ;

//印刷（見出し※０件の場合
IF W#CNTP     <= *ZERO                 ;
  EXSR      @PHEAD1                      ;
ELSE                                   ;
  EXSR      @PTOTAL2                     ;       //地区計
ENDIF                                  ;

//終了処理
EXSR      @END                         ;

//   C*-***************************************************************
//   C*-* @INZ        初期処理                                     **
//   C*-***************************************************************
BEGSR @INZ                                  ;

//システム日付
     WTIMESTAMP = %TIMESTAMP()                       ;
     WDATE8     = %DEC(%DATE(WTIMESTAMP) : *ISO )    ;
     WTIME6     = %DEC(%TIME(WTIMESTAMP) : *HMS )    ;

//変数の初期化
     //*IN(80) = *ON                                   ;    //オーバーフロー標識
     W#FG_OF = *ON                                   ;    //オーバーフロー標識
     W#CNTP  = *ZERO                                 ;    //印刷件数

     CLEAR PHEAD1                                    ;
     CLEAR PTOTAL1                                   ;
     CLEAR PTOTAL2                                   ;

ENDSR                                       ;
//   C*-***************************************************************
//   C*-* @PHEAD1     印刷処理（見出し                             **
//   C*-***************************************************************
BEGSR @PHEAD1                               ;

     //地区名の取得
     IX = %LOOKUP( PH1JHTIKU  : TIKCOD  )            ;
     IF IX     > *ZERO         ;
       PH1TIKNAM   = TIKNAM(IX)                      ;    //地区名称
     ELSE                    ;
       PH1TIKNAM   = *ALL'*'                         ;    //地区名称
     ENDIF                   ;

     WRITE PHEAD1                                    ;

     //オーバーフロー標識オフ
     //*IN(80) = *OFF                                  ;    //オーバーフロー標識
     W#FG_OF = *OFF                                  ;    //オーバーフロー標識

ENDSR                                       ;
//   C*-***************************************************************
//   C*-* @SUM1       集計処理                                     **
//   C*-***************************************************************
BEGSR @SUM1                                 ;

     PH1JHTIKU  =  JHTIKU                            ; //地区コード
     PT1JHTOKB  =  JHTOKB                            ; //得意先番号

     PT1_REC   +=  1                                 ; //レコード数
     PT1_KING  +=  JHKING                            ; //受注金額

     PT2_REC   +=  1                                 ; //レコード数
     PT2_KING  +=  JHKING                            ; //受注金額

     W#CNTP    += 1                                  ; //印刷件数

//ブレイクキー退避
     W@JHTIKU   =  JHTIKU                            ; //地区コード
     W@JHTOKB   =  JHTOKB                            ; //得意先番号

ENDSR                                       ;
//   C*-***************************************************************
//   C*-* @PTOTAL1    印刷処理（合計・得意先                       **
//   C*-***************************************************************
BEGSR @PTOTAL1                              ;

     //見出し印刷
     //IF *IN80 = *ON          ;
     IF W#FG_OF  = *ON       ;
       EXSR @PHEAD1                               ;
     ENDIF                   ;

     IF PT1_REC  <> *ZERO    ;
       EVAL(H) PT1_AVR    =  PT1_KING / PT1_REC                ; //平均金額
     ENDIF                 ;

     TOKMSKEY1.TKBANG     = PT1JHTOKB       ;      //得意先番号
     CHAIN %KDS(TOKMSKEY1   ) TOKMSR        ;
     IF %FOUND              ;
       PT1TKNAKJ  =  TKNAKJ                          ; //得意先名（漢字
     ELSE                   ;
       PT1TKNAKJ  =  *ALL'*'                         ; //得意先名（漢字
     ENDIF                  ;

     WRITE PTOTAL1                                   ;
     CLEAR PTOTAL1                                   ;

ENDSR                                       ;
//   C*-***************************************************************
//   C*-* @PTOTAL2    印刷処理（合計・得意先                       **
//   C*-***************************************************************
BEGSR @PTOTAL2                              ;

     //得意先計印刷
     EXSR @PTOTAL1                              ;

     //見出し印刷
     //IF *IN80 = *ON          ;
     IF W#FG_OF  = *ON       ;
     //*********  EXSR @PHEAD1                               ;
     ENDIF                   ;

     IF PT2_REC  <> *ZERO    ;
       EVAL(H) PT2_AVR    =  PT2_KING / PT2_REC                ; //平均金額
     ENDIF                 ;

     WRITE PTOTAL2                                   ;
     CLEAR PTOTAL2                                   ;

     //次回改ページ
     CLEAR PHEAD1                                    ;
     //*IN(80) = *ON                                   ;    //オーバーフロー標識
     W#FG_OF = *ON                                   ;    //オーバーフロー標識

ENDSR                                       ;
//   C*-***************************************************************
//   C*-* @END        終了処理                                     **
//   C*-***************************************************************
BEGSR @END                                  ;

     *INLR   = *ON                                   ;
     RETURN                                          ;

ENDSR                                       ;
** TIKCOD/TIKNAM 地区コード／地区名
01北海道
02東北
03北陸
04関東
05関西
