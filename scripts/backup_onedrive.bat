@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul

title Copy Backup MySQL Portal --> OneDrive

color 1F

echo.
echo ============================================================
echo              BACKUP MYSQL PORTAL - INICIO
echo ============================================================
echo.

REM =====================================================
REM CAMINHOS
REM =====================================================

set "BASE=C:\Backup_mysql_portal"

set "SCRIPTS=%BASE%\scripts"
set "LOGS=%BASE%\logs"
set "PROCESSADOS=%BASE%\processados"
set "ERROS=%BASE%\erros"

set "ORIGEM=Z:"

set "DESTINO=%UserProfile%\OneDrive - CorporateAccount\DatabaseBackups"

echo [1/10] Validando diretorios...
echo.

if not exist "%BASE%" mkdir "%BASE%"
if not exist "%SCRIPTS%" mkdir "%SCRIPTS%"
if not exist "%LOGS%" mkdir "%LOGS%"
if not exist "%PROCESSADOS%" mkdir "%PROCESSADOS%"
if not exist "%ERROS%" mkdir "%ERROS%"

echo [OK] Diretorios validados.
echo.

REM =====================================================
REM LOG EXECUCAO
REM =====================================================

echo [2/10] Gerando log de execucao...

echo EXECUTADO EM %date% %time% > "%SCRIPTS%\execucao.txt"
whoami >> "%SCRIPTS%\execucao.txt"

echo [OK] Log de execucao atualizado.
echo.

REM =====================================================
REM DATA / HORA
REM =====================================================

set "DATA=%date:~6,4%%date:~3,2%%date:~0,2%"
set "HORA=%time:~0,2%%time:~3,2%"
set "HORA=%HORA: =0%"

set "LOG=%LOGS%\backup_%DATA%_%HORA%.log"

echo ==================================================== >> "%LOG%"
echo INICIO: %date% %time% >> "%LOG%"
echo ==================================================== >> "%LOG%"

REM =====================================================
REM REDE
REM =====================================================

echo [3/10] Conectando rede...

net use Z: /delete /y >> "%LOG%" 2>&1
net use Z: \\LINUX_SERVER\shared_backup >> "%LOG%" 2>&1

if errorlevel 1 (
    echo ERRO AO MAPEAR REDE >> "%LOG%"
    exit /b
)

timeout /t 5 > nul

REM =====================================================
REM DEBUG CAMINHOS
REM =====================================================

echo [4/10] Validando caminhos...

echo ORIGEM=[%ORIGEM%] >> "%LOG%"
echo DESTINO=[%DESTINO%] >> "%LOG%"

echo TESTE DE ESCRITA > "%DESTINO%\_teste_write.txt"
if errorlevel 1 (
    echo ERRO: OneDrive NAO permite escrita >> "%LOG%"
    echo ERRO DE ESCRITA NO ONEDRIVE > "%ERROS%\erro_write_%DATA%_%HORA%.txt"
    exit /b
)
del "%DESTINO%\_teste_write.txt" > nul 2>&1

echo OneDrive escrita OK >> "%LOG%"

if not exist "%ORIGEM%\*.sql" (
    echo Nenhum arquivo SQL encontrado >> "%LOG%"
    goto :MOVE_PROCESSADOS
)

REM =====================================================
REM TESTE ORIGEM
REM =====================================================

echo [5/10] Testando origem...

dir "%ORIGEM%" >> "%LOG%" 2>&1

REM =====================================================
REM COPIA PARA ONEDRIVE
REM =====================================================

echo [6/10] Copiando para OneDrive...

robocopy "%ORIGEM%" "%DESTINO%" *.sql /Z /FFT /R:3 /W:5 /XO /V /TS /FP /LOG+:"%LOG%"

set "RC=%ERRORLEVEL%"

echo ROBocopy EXIT CODE = %RC% >> "%LOG%"
echo ROBocopy EXIT CODE = %RC%

REM =====================================================
REM VALIDA COPIA
REM =====================================================

echo [7/10] Validando resultado...

dir "%DESTINO%" >> "%LOG%" 2>&1

for %%F in ("%DESTINO%\*.sql") do (
    echo ARQUIVO NO DESTINO: %%F >> "%LOG%"
)

REM =====================================================
REM DECISAO
REM =====================================================

if %RC% LSS 8 (

    echo COPIA OK >> "%LOG%"

    echo [8/10] Movendo para processados...

    robocopy "%ORIGEM%" "%PROCESSADOS%" *.sql /MOV /R:3 /W:5 /LOG+:"%LOG%"

    echo MOVIMENTO OK >> "%LOG%"

) else (

    echo ERRO NA COPIA >> "%LOG%"
    echo ERRO NA COPIA > "%ERROS%\erro_copia_%DATA%_%HORA%.txt"

)

REM =====================================================
REM FINAL
REM =====================================================

echo ==================================================== >> "%LOG%"
echo FIM: %date% %time% >> "%LOG%"
echo ==================================================== >> "%LOG%"

echo.
echo PROCESSO FINALIZADO
echo.

echo Log: %LOG%

:MOVE_PROCESSADOS
echo [10/10] Fim do processo - sem arquivos a processar...
echo Fim do processo >> "%LOG%"

pause