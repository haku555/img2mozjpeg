#pragma compile(FileVersion, 1.1.3)
$Version = "1.1.3"

#include <GuiConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GuiListView.au3>
#include <SliderConstants.au3>
#include <UpDownConstants.au3>
#include <Array.au3>
#include <file.au3>

;前回のウィンドウ位置を取得
$PosX = IniRead("bin\setting.ini", "pos", "x", -1)
$PosY = IniRead("bin\setting.ini", "pos", "y", -1)
;メインウィンドウ
$Window = GUICreate("img2mozjpeg", 380, 360,$PosX,$PosY,-1,$WS_EX_ACCEPTFILES) ;$WS_EX_ACCEPTFILES //ファイルドロップを可能にする
GUISetBkColor(0xFFFBF0)

$MenuItem1 = GUICtrlCreateMenu("ファイル")
$MenuItem2 = GUICtrlCreateMenuItem("終了", $MenuItem1)
$MenuItem3 = GUICtrlCreateMenu("ヘルプ")
$MenuItem4 = GUICtrlCreateMenuItem("使用方法", $MenuItem3)
$MenuItem5 = GUICtrlCreateMenuItem("WEBサイトへ", $MenuItem3)
$MenuItem6 = GUICtrlCreateMenuItem("バージョン情報", $MenuItem3)

$Label = GUICtrlCreateLabel("↓画像ファイルまたはフォルダをドラッグ＆ドロップ", 5, 3)

$FileInput = GUICtrlCreateInput("", 0, 20, 380, 270,BitOr($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
GUICtrlSetBkColor($FileInput, 0xffffff) ;白背景
GUICtrlSetState($FileInput, $GUI_DROPACCEPTED) ;ファイルドロップを受け付ける

GUICtrlCreateLabel("画質", 10, 295)
$Compress = IniRead("bin\setting.ini", "img2mozjpeg", "compress", 90) ;iniファイルから画質を読み込む。存在しない場合は９０がデフォルトになる
$input = GUICtrlCreateInput($Compress, 38, 292, 45, 20,$ES_NUMBER) ;数字のみ受け付ける
$updown = GUICtrlCreateUpdown($input,$UDS_ARROWKEYS) ;アップダウンコントロール。キーボード上下に対応
GUICtrlSetLimit($updown, 100, 0)  ;最小/最大値を0~100に設定
$Slider = GUICtrlCreateSlider(10, 315, 360, 20,$TBS_NOTICKS) ;画質スライダー
GUICtrlSetLimit($Slider, 100, 0)  ;最小/最大値を変更に設定

GUICtrlSetState($Label, $GUI_FOCUS) ;GUIのフォーカスをラベルにする
GUISetState(@SW_SHOW)
GUICtrlSetData($Slider, $Compress)  ;スライダーのカーソル設定

$PreInput = $Compress
$PreSlider = $Compress
While 1
   ;現在の値を取得
    $CurrentInput = GUICtrlRead($input)
    $CurrentSlider = GUICtrlRead($Slider)
    ;画質のインプット値の制限
    If $CurrentInput > 100 Then
      GUICtrlSetData($input, 100)
    ElseIf $CurrentInput < 0 Then
      GUICtrlSetData($input, 0)
    EndIf
    ;画質インプットとスライダーの値を結びつける
    If $CurrentInput <> $PreInput Then
      GUICtrlSetData($Slider,$CurrentInput)
    ElseIf $CurrentSlider <> $PreSlider Then
      GUICtrlSetData($input,$CurrentSlider)
    EndIf
    ;過去の値として現在の値を保存
    $PreInput = $CurrentInput
    $PreSlider = $CurrentSlider
    ;イベント処理
    $msg = GUIGetMsg()
    Switch $msg
        Case $GUI_EVENT_CLOSE
            $Pos = WinGetPos($Window) ;ウィンドウ位置・サイズ取得
            ;プログラム終了前に設定をiniファイルに書き込む
            IniWrite("bin\setting.ini", "pos", "x", $Pos[0])
            IniWrite("bin\setting.ini", "pos", "y", $Pos[1])
            IniWrite("bin\setting.ini", "img2mozjpeg", "compress", $CurrentInput)
            Exit
        Case $GUI_EVENT_DROPPED
            If @GUI_DropId = $FileInput Then
              $tmp = GUICtrlRead($FileInput)
              GUICtrlSetData($FileInput, "")
              ;"|"で配列に分割
              $InputFileArr = StringSplit($tmp,"|")
              ;_ArrayDisplay($InputFileArr)
              Dim $szDrive, $szDir, $szFName, $szExt
              $DirPath = _PathSplit($InputFileArr[1], $szDrive, $szDir, $szFName, $szExt) ;ファイル及びフォルダパスを分割
              DirCreate($DirPath[1] & $DirPath[2] & "jpg") ;出力フォルダ作成
              DirCreate($DirPath[1] & $DirPath[2] & "temp-img2mozjpeg") ;一次保存フォルダ作成
              ;MsgBox(0, "test", FileGetAttrib($InputFileArr[1]))
              ;与えられたファイル及びフォルダを処理する
              For $i = 1 to UBound( $InputFileArr ) - 1
                ;$InputFileArr[$i] = '"' & $InputFileArr[$i] & '"' ;ファイル名の両端に"を追加
                $PS = _PathSplit($InputFileArr[$i], $szDrive, $szDir, $szFName, $szExt) ;ファイル及びフォルダパスを分割
                ;MsgBox(0, "test",'"'&$InputFileArr[$i]&'" "'&$PS[1]&$PS[2]&"temp-img2mozjpeg\"&$PS[3]&'.png"')
                ;もしディレクトリフォルダなら中に入っている画像ファイルを処理する（サブディレクトリの再帰処理はしない）
                If FileGetAttrib($InputFileArr[$i]) == "D" Then
                  ;MsgBox(0, "test", $InputFileArr[$i])
                  ; 現在のディレクトリ内の全てのファイルのファイル名を表示
                  $search = FileFindFirstFile($InputFileArr[$i]&"\*.*")
                  ; 検索が成功したかを調べる
                  If $search = -1 Then ContinueLoop
                  DirCreate($InputFileArr[$i] & "\jpg") ;出力フォルダ作成
                  DirCreate($InputFileArr[$i] & "\temp-img2mozjpeg") ;一次保存フォルダ作成
                  ;ファイルのみ処理（サブディレクトリは除外）
                  Dim $szDrive2, $szDir2, $szFName2, $szExt2
                  While 1
                    $file = FileFindNextFile($search)
                    If @error Then ExitLoop
                    If @extended Then ContinueLoop
                    $FS = _PathSplit($InputFileArr[$i]&"\"&$file, $szDrive2, $szDir2, $szFName2, $szExt2) ;ファイルパスを分割
                    ;MsgBox(4096, "File:", $file)
                    ;_ArrayDisplay($FS)
                    If $FS[4] == ".webp" Then
                      ShellExecuteWait("dwebp.exe",'"'&$FS[0]&'" -o "'&$FS[1]&$FS[2]&"temp-img2mozjpeg\"&$FS[3]&'.png"', @ScriptDir & "\bin",default,@SW_HIDE)
                      ShellExecuteWait("cjpeg.exe","-optimize -quality "&$CurrentInput&' -outfile "'&$FS[1]&$FS[2]&"jpg\"&$FS[3]&'.jpg" "'&$FS[1]&$FS[2]&"temp-img2mozjpeg\"&$FS[3]&'.png"', @ScriptDir & "\bin",default,@SW_HIDE)
                    ElseIf $FS[4] == ".avif" Then
                      ShellExecuteWait("avifdec.exe",'"'&$FS[0]&'" "'&$FS[1]&$FS[2]&"temp-img2mozjpeg\"&$FS[3]&'.png"', @ScriptDir & "\bin",default,@SW_HIDE)
                      ShellExecuteWait("cjpeg.exe","-optimize -quality "&$CurrentInput&' -outfile "'&$FS[1]&$FS[2]&"jpg\"&$FS[3]&'.jpg" "'&$FS[1]&$FS[2]&"temp-img2mozjpeg\"&$FS[3]&'.png"', @ScriptDir & "\bin",default,@SW_HIDE)
                    ;もしアーカイブファイルなら
                    ElseIf FileGetAttrib($FS[0]) == "A" Then
                      ShellExecuteWait("cjpeg.exe","-optimize -quality "&$CurrentInput&' -outfile "'&$FS[1]&$FS[2]&"jpg\"&$FS[3]&'.jpg" "'&$FS[0]&'"', @ScriptDir & "\bin",default,@SW_HIDE)
                    EndIf
                  WEnd
                  DirRemove($InputFileArr[$i] & "jpg") ;空の場合出力フォルダを削除
                  DirRemove($InputFileArr[$i] & "\temp-img2mozjpeg", 1) ;一次保存フォルダを削除
                  ; 検索ハンドルを閉じる
                  FileClose($search)
                ElseIf $PS[4] == ".webp" Then
                  ShellExecuteWait("dwebp.exe",'"'&$InputFileArr[$i]&'" -o "'&$PS[1]&$PS[2]&"temp-img2mozjpeg\"&$PS[3]&'.png"', @ScriptDir & "\bin",default,@SW_HIDE)
                  ShellExecuteWait("cjpeg.exe","-optimize -quality "&$CurrentInput&' -outfile "'&$PS[1]&$PS[2]&"jpg\"&$PS[3]&'.jpg" "'&$PS[1]&$PS[2]&"temp-img2mozjpeg\"&$PS[3]&'.png"', @ScriptDir & "\bin",default,@SW_HIDE)
                ElseIf $PS[4] == ".avif" Then
                  ShellExecuteWait("avifdec.exe",'"'&$InputFileArr[$i]&'" "'&$PS[1]&$PS[2]&"temp-img2mozjpeg\"&$PS[3]&'.png"', @ScriptDir & "\bin",default,@SW_HIDE)
                  ShellExecuteWait("cjpeg.exe","-optimize -quality "&$CurrentInput&' -outfile "'&$PS[1]&$PS[2]&"jpg\"&$PS[3]&'.jpg" "'&$PS[1]&$PS[2]&"temp-img2mozjpeg\"&$PS[3]&'.png"', @ScriptDir & "\bin",default,@SW_HIDE)
                ;もしアーカイブファイルなら
                ElseIf FileGetAttrib($InputFileArr[$i]) == "A" Then
                  ShellExecuteWait("cjpeg.exe","-optimize -quality "&$CurrentInput&' -outfile "'&$PS[1]&$PS[2]&"jpg\"&$PS[3]&'.jpg" "'&$InputFileArr[$i]&'"', @ScriptDir & "\bin",default,@SW_HIDE)
                EndIf
              Next
              DirRemove($DirPath[1] & $DirPath[2] & "jpg") ;空の場合出力フォルダを削除
              DirRemove($DirPath[1] & $DirPath[2] & "temp-img2mozjpeg", 1) ;一次保存フォルダを削除
              ;_ArrayDisplay($InputFileArr)
              ;_ArrayDisplay(_PathSplit($InputFileArr[1], $szDrive, $szDir, $szFName, $szExt))
              #cs
              ;画質をiniファイルに書き込む
              IniWrite("bin\setting.ini", "img2mozjpeg", "compress", $CurrentInput)
              ;配列から文字列に戻す。間は空白で開ける
              $InputFile = _ArrayToString($InputFileArr, " ", 1, UBound( $InputFileArr ) - 1)
              ;bat（処理本体）を呼び出す。引数に成形した$InputFileを指定
              If $InputFile <> "" Then
                ShellExecute("img2mozjpeg.bat", $InputFile, @ScriptDir & "\bin",default,@SW_HIDE)
              EndIf
              #ce
            EndIf
        Case $MenuItem2; 終了
            Exit
        Case $MenuItem4; 使用方法
            MsgBox(0, "使用方法","入力ファイルはwebp、jpg、png、bmp、gif、avifに対応確認済みです"& @CRLF &"出力先は画像を入力した同じフォルダのjpgフォルダになります"& @CRLF &"複数ファイルドラッグ＆ドロップ対応しています"& @CRLF &"注意点として画像ファイル以外の全ての拡張子のファイルも処理するのでフォルダをドラッグ＆ドロップする際は画像のみのフォルダにしてください（カスタム拡張子など多くの形式に対応するため）", 0, $Window)
        Case $MenuItem5; WEBサイトへ
            ShellExecute("https://haku.cf")
        Case $MenuItem6; バージョン情報
            MsgBox(0, "バージョン情報","#-------------------------------------------------------------------------------"& @CRLF &"# img2mozjpeg v"& $Version & @CRLF &"# script by HK https://haku.cf"& @CRLF &"#-------------------------------------------------------------------------------", 0, $Window)
    EndSwitch
WEnd