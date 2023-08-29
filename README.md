# ushiday FF-RPG作成記録

---
## 更新履歴

- 2023.05.24  
  + **BLP010@YU1.RPGLE（固定版・品目マスタ一覧** を新規作成  
  + **BLP010@YU2.RPGLE（ＦＦ版・品目マスタ一覧** を新規作成  

---

- 2023.05.30
  + **BLP010@YU3.RPGLE（ＦＦ－ＳＱＬ版・品目マスタ一覧** を新規作成  
  + **BLP020@YU1.RPGLE（固定版・得意先別受注一覧表** を新規作成  
  + **BLP020@YU2.RPGLE（ＦＦ版・得意先別受注一覧表** を新規作成  
  + **BLP020@YU3.RPGLE（ＦＦ版－ＳＱＬ・得意先別受注一覧表** を新規作成  
  + **BLP030@YU1.RPGLE（固定版・地区先別受注一覧表** を新規作成  
  + **BLP030@YU2.RPGLE（ＦＦ版・地区先別受注一覧表** を新規作成  
  + **BLP030@YU3.RPGLE（ＦＦ版－ＳＱＬ１・地区先別受注一覧表** を新規作成  
  + **BLP030@YU4.RPGLE（ＦＦ版－ＳＱＬ２／GROUP BY・地区先別受注一覧表** を新規作成  
  + **BLP030@YU5.RPGLE（ＦＦ版－ＳＱＬ３／ROLLUP・地区先別受注一覧表** を新規作成  

---

- 2023.06.14
  + **IPL010@YU2.RPGLE（ＦＦ版・品目マスター照会** を新規作成  
  + **IPL020@YU2.RPGLE（ＦＦ版・品目マスター一覧照会** を新規作成  
  + **@USHIDAY10.RPGLE（固定版・ＦＦで許可されていない記述集１** を新規作成  
  + **@USHIDAY11.RPGLE（ＦＦ版・ＦＦで許可されていない記述集１** を新規作成  

---

- 2023.07.07

  + **BLP010@YU9.RPGLE（品目マスタ一覧（ＦＦ＠記述制約** を新規作成  
  + 

---

- 2023.08.08
  + **QEOLFF ライブラリのSAVF(V7R3M0)** を新規作成  

---

- 2023.08.27
  + **DCLDS1@YU1.RPGLE（固定版・ＤＳサンプル１** を新規作成  
  + **DCLDS1@YU2.RPGLE（ＦＦ版・ＤＳサンプル１** を新規作成  
  + QRPGLESRCを `COPYRIGHT('...')` に修正
  + **QEOLFF ライブラリのSAVF(V7R3M0)** を更新

---

- 2023.08.29
  + **IPL010@YU2.RPGLE（品目マスタ照会（ＦＦ** を更新
  + **IPL020@YU2.RPGLE（品目マスタ一覧照会（ＦＦ** を更新
  + **QEOLFF ライブラリのSAVF(V7R3M0)** を更新

---
- 2023.xx.xx
  + **______@YU1.RPGLE（固定版・** を新規作成  
  + **______@YU2.RPGLE（ＦＦ版・** を新規作成  
  + **______@YU3.RPGLE（ＦＦ版－ＳＱＬ・** を新規作成  


### 制御オプションの順序

ソースコードの先頭に記述

```txt
     53 CTL-OPT
 ======>AAAAAAA
 *RNF0203 30 A      005300  STATEMENT TYPE OUT OF SEQUENCE FOR MAIN PROCEDURE.
   67        COPYRIGHT('COPYRIGHT(C) CHUBU SYSTEM CO.,LTD. ALL RIGHTS RESERVED')
   68 ;
```

### ファイル宣言の順序

メイン・ルーチンより前に記述

```txt
    58 //DCL-F    BPL010P       PRINTER  OFLIND(*IN80                )                ;
    59 DCL-F    BPL010P       PRINTER  OFLIND(W#FG_OF              )                ;
======>AAAAA
*RNF0203 30 A      005900  STATEMENT TYPE OUT OF SEQUENCE FOR MAIN PROCEDURE.
```

### 変数、DS宣言の順序

メイン・ルーチンより前に記述。
LIKERECなどレコード展開後の変数を使用する場合は、該当の「DCL-F」より後に記述

```txt
    85 DCL-S  WXXXXX        ZONED(6:0)               ;  // 時刻
======>AAAAA
*RNF0203 30 A      007400  STATEMENT TYPE OUT OF SEQUENCE FOR MAIN PROCEDURE.
```
