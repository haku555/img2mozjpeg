@echo off
pushd "%~1" 2>nul

rem 画像圧縮率(0~100)
set compress=90

rem フォルダ入力の場合
if not errorlevel 1 (
  popd
  cd /d "%1"
  mkdir "jpg" > nul 2>&1
  mkdir "temp-img2mozjpeg" > nul 2>&1
  for %%A in (*) do (
    rem もし入力ファイルがwebpならpngに変換して作業フォルダに保存してから更にmozjpegに変換
    if ".webp"=="%%~xA" (
      "%~dp0dwebp.exe" "%%A" -o "temp-img2mozjpeg\%%~nA.png"
      "%~dp0cjpeg.exe" -optimize -quality %compress% -outfile "jpg\%%~nA.jpg" "temp-img2mozjpeg\%%~nA.png"
    
    rem もし入力ファイルがavifならpngに変換して作業フォルダに保存してから更にmozjpegに変換
    ) else if ".avif"=="%%~xA" (
      "%~dp0avifdec.exe" --no-strict "%%A" "temp-img2mozjpeg\%%~nA.png"
      "%~dp0cjpeg.exe" -optimize -quality %compress% -outfile "jpg\%%~nA.jpg" "temp-img2mozjpeg\%%~nA.png"
    
    rem その他画像ファイルをmozjpegに変換
    ) else (
      "%~dp0cjpeg.exe" -optimize -quality %compress% -outfile "jpg\%%~nA.jpg" "%%A"
    )
  )
  rem 作業フォルダ削除
  del /q "temp-img2mozjpeg"
  rmdir /q "temp-img2mozjpeg"

rem １または複数ファイル入力の場合
) else if exist "%~1" (
  cd /d "%~dp0"
  mkdir "%~dp1jpg\" > nul 2>&1
  mkdir "%~dp1temp-img2mozjpeg\" > nul 2>&1
  for %%A in (%*) do (
    rem もし入力ファイルがwebpならpngに変換して作業フォルダに保存してから更にmozjpegに変換
    if ".webp"=="%%~xA" (
      "%~dp0dwebp.exe" %%A -o "%~dp1temp-img2mozjpeg\%%~nA.png"
      "%~dp0cjpeg.exe" -optimize -quality %compress% -outfile "%~dp1jpg\%%~nA.jpg" "%~dp1temp-img2mozjpeg\%%~nA.png"
  
    rem もし入力ファイルがavifならpngに変換して作業フォルダに保存してから更にmozjpegに変換
    ) else if ".avif"=="%%~xA" (
      "%~dp0avifdec.exe" --no-strict %%A "%~dp1temp-img2mozjpeg\%%~nA.png"
      "%~dp0cjpeg.exe" -optimize -quality %compress% -outfile "%~dp1jpg\%%~nA.jpg" "%~dp1temp-img2mozjpeg\%%~nA.png"

    rem その他画像ファイルをmozjpegに変換
    ) else (
      "%~dp0cjpeg.exe" -optimize -quality %compress% -outfile "%~dp1jpg\%%~nA.jpg" %%A
    )
  )
  rem 作業フォルダ削除
  del /q "%~dp1temp-img2mozjpeg"
  rmdir /q "%~dp1temp-img2mozjpeg"
)