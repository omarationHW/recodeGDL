# ============================================
# SCRIPT DE INSTALACIÓN AUTOMÁTICA (PowerShell)
# STORED PROCEDURES - MÓDULO CEMENTERIOS
# ============================================
# Base de Datos: padron_licencias
# Host: 192.168.6.146
# Puerto: 5432
# Usuario: refact
# Total Archivos: 39
# Total SPs: 93
# Fecha: 2025-11-09
# ============================================

# Configuración de colores
$Host.UI.RawUI.ForegroundColor = "White"

# Configuración de conexión
$DB_HOST = "192.168.6.146"
$DB_PORT = "5432"
$DB_NAME = "padron_licencias"
$DB_USER = "refact"
$DB_PASS = "FF)-BQk2"

# Directorio base
$BASE_DIR = "C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\cementerios\database\ok"

# Contadores
$TOTAL_FILES = 39
$TOTAL_SPS = 93
$SUCCESS_COUNT = 0
$ERROR_COUNT = 0
$SP_INSTALLED = 0

# Log file
$LOG_FILE = "install_cementerios_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$TIMESTAMP = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# ============================================
# FUNCIÓN: Imprimir header
# ============================================
function Print-Header {
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  INSTALACIÓN DE STORED PROCEDURES" -ForegroundColor Cyan
    Write-Host "  MÓDULO CEMENTERIOS" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "Base de Datos: " -NoNewline
    Write-Host "$DB_NAME" -ForegroundColor Green
    Write-Host "Host: " -NoNewline
    Write-Host "${DB_HOST}:${DB_PORT}" -ForegroundColor Green
    Write-Host "Total Archivos: " -NoNewline
    Write-Host "$TOTAL_FILES" -ForegroundColor Green
    Write-Host "Total SPs Esperados: " -NoNewline
    Write-Host "$TOTAL_SPS" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================
# FUNCIÓN: Verificar psql
# ============================================
function Verify-PSQL {
    Write-Host "[0/4] Verificando herramienta psql..." -ForegroundColor Yellow

    $psqlPath = Get-Command psql -ErrorAction SilentlyContinue

    if ($null -eq $psqlPath) {
        Write-Host "✗ psql no encontrado en PATH" -ForegroundColor Red
        Write-Host ""
        Write-Host "SOLUCIÓN:" -ForegroundColor Yellow
        Write-Host "1. Instalar PostgreSQL Client" -ForegroundColor White
        Write-Host "2. Agregar psql al PATH de Windows" -ForegroundColor White
        Write-Host "3. O ejecutar desde el directorio bin de PostgreSQL" -ForegroundColor White
        Write-Host ""
        Write-Host "Ejemplo de PATH típico:" -ForegroundColor Yellow
        Write-Host "  C:\Program Files\PostgreSQL\15\bin" -ForegroundColor White
        Write-Host ""
        return $false
    }

    Write-Host "✓ psql encontrado: " -NoNewline -ForegroundColor Green
    Write-Host $psqlPath.Source -ForegroundColor Gray
    return $true
}

# ============================================
# FUNCIÓN: Verificar estado inicial
# ============================================
function Verify-InitialState {
    Write-Host ""
    Write-Host "[1/4] Verificando estado inicial de la base de datos..." -ForegroundColor Yellow

    $env:PGPASSWORD = $DB_PASS

    $query = "SELECT COUNT(*) as total_sps_actuales FROM information_schema.routines WHERE routine_schema = 'public';"

    $result = psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c $query 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Conexión exitosa a PostgreSQL" -ForegroundColor Green
        Write-Host "  SPs actuales en esquema public: " -NoNewline
        Write-Host $result.Trim() -ForegroundColor Cyan
        "Inicio de instalación: $TIMESTAMP" | Out-File -FilePath $LOG_FILE
        "SPs antes de instalar: $($result.Trim())" | Out-File -FilePath $LOG_FILE -Append
        return $true
    } else {
        Write-Host "✗ Error al conectar a PostgreSQL" -ForegroundColor Red
        Write-Host "  Error: $result" -ForegroundColor Red
        return $false
    }
}

# ============================================
# FUNCIÓN: Instalar archivo SQL
# ============================================
function Install-SQLFile {
    param(
        [string]$FileName,
        [int]$SPCount,
        [int]$FileNum
    )

    Write-Host ""
    Write-Host "[$FileNum/$TOTAL_FILES] Instalando: " -NoNewline -ForegroundColor Cyan
    Write-Host "$FileName" -ForegroundColor Yellow
    Write-Host "  → SPs esperados: $SPCount" -ForegroundColor Gray

    $FilePath = Join-Path $BASE_DIR $FileName

    if (-not (Test-Path $FilePath)) {
        Write-Host "  ✗ Archivo no encontrado" -ForegroundColor Red
        "ERROR: Archivo no encontrado - $FileName" | Out-File -FilePath $LOG_FILE -Append
        $script:ERROR_COUNT++
        return
    }

    "========================================" | Out-File -FilePath $LOG_FILE -Append
    "Instalando: $FileName" | Out-File -FilePath $LOG_FILE -Append
    "Fecha/Hora: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $LOG_FILE -Append
    "========================================" | Out-File -FilePath $LOG_FILE -Append

    $env:PGPASSWORD = $DB_PASS

    $output = psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $FilePath 2>&1

    $output | Out-File -FilePath $LOG_FILE -Append

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Instalado exitosamente" -ForegroundColor Green
        $script:SUCCESS_COUNT++
        $script:SP_INSTALLED += $SPCount
    } else {
        Write-Host "  ✗ Error durante instalación" -ForegroundColor Red
        Write-Host "  ! Consultar log: $LOG_FILE" -ForegroundColor Yellow
        $script:ERROR_COUNT++
    }
}

# ============================================
# FUNCIÓN: Instalar todos los archivos
# ============================================
function Install-AllFiles {
    Write-Host ""
    Write-Host "[2/4] Instalando archivos SQL..." -ForegroundColor Yellow

    # FASE 1: CORE
    Install-SQLFile "01_SP_CEMENTERIOS_CORE_all_procedures.sql" 9 1
    Install-SQLFile "02_SP_CEMENTERIOS_GESTION_all_procedures.sql" 8 2
    Install-SQLFile "03_SP_CEMENTERIOS_ABC_all_procedures.sql" 5 3

    # FASE 2: MÓDULOS EXACTO
    Install-SQLFile "01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql" 2 4
    Install-SQLFile "02_SP_CEMENTERIOS_ABCRECARGOS_EXACTO_all_procedures.sql" 5 5
    Install-SQLFile "03_SP_CEMENTERIOS_ACCESO_EXACTO_all_procedures.sql" 1 6
    Install-SQLFile "04_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql" 3 7
    Install-SQLFile "05_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql" 11 8
    Install-SQLFile "06_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql" 3 9
    Install-SQLFile "07_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql" 3 10
    Install-SQLFile "08_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql" 3 11
    Install-SQLFile "09_SP_CEMENTERIOS_DESCUENTOS_EXACTO_all_procedures.sql" 1 12
    Install-SQLFile "10_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql" 2 13
    Install-SQLFile "11_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures.sql" 1 14
    Install-SQLFile "12_SP_CEMENTERIOS_LIST_MOV_EXACTO_all_procedures.sql" 1 15
    Install-SQLFile "13_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql" 2 16
    Install-SQLFile "14_SP_CEMENTERIOS_ABCRECARGOS_EXACTO_all_procedures.sql" 5 17
    Install-SQLFile "15_SP_CEMENTERIOS_ACCESO_EXACTO_all_procedures.sql" 1 18
    Install-SQLFile "16_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql" 2 19
    Install-SQLFile "17_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql" 6 20
    Install-SQLFile "18_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql" 2 21
    Install-SQLFile "19_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql" 2 22
    Install-SQLFile "20_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql" 2 23
    Install-SQLFile "21_SP_CEMENTERIOS_DESCUENTOS_EXACTO_all_procedures.sql" 1 24
    Install-SQLFile "22_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql" 1 25
    Install-SQLFile "23_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures.sql" 1 26
    Install-SQLFile "24_SP_CEMENTERIOS_LIST_MOV_EXACTO_all_procedures.sql" 1 27
    Install-SQLFile "25_SP_CEMENTERIOS_MODULO_EXACTO_all_procedures.sql" 2 28
    Install-SQLFile "26_SP_CEMENTERIOS_MULTIPLENOMBRE_EXACTO_all_procedures.sql" 1 29
    Install-SQLFile "27_SP_CEMENTERIOS_MULTIPLERCM_EXACTO_all_procedures.sql" 1 30
    Install-SQLFile "28_SP_CEMENTERIOS_MULTIPLEFECHA_EXACTO_all_procedures.sql" 1 31
    Install-SQLFile "29_SP_CEMENTERIOS_REP_BON_EXACTO_all_procedures.sql" 1 32
    Install-SQLFile "30_SP_CEMENTERIOS_REP_A_COBRAR_EXACTO_all_procedures.sql" 1 33
    Install-SQLFile "31_SP_CEMENTERIOS_RPTTITULOS_EXACTO_all_procedures.sql" 2 34
    Install-SQLFile "32_SP_CEMENTERIOS_TITULOSSIN_EXACTO_all_procedures.sql" 2 35
    Install-SQLFile "33_SP_CEMENTERIOS_TITULOS_EXACTO_all_procedures.sql" 3 36
    Install-SQLFile "34_SP_CEMENTERIOS_TRASLADOFOLSIN_EXACTO_all_procedures.sql" 1 37
    Install-SQLFile "35_SP_CEMENTERIOS_TRASLADOS_EXACTO_all_procedures.sql" 2 38
    Install-SQLFile "36_SP_CEMENTERIOS_SFRM_CHGPASS_EXACTO_all_procedures.sql" 1 39
}

# ============================================
# FUNCIÓN: Verificar instalación
# ============================================
function Verify-Installation {
    Write-Host ""
    Write-Host "[3/4] Verificando instalación..." -ForegroundColor Yellow

    $env:PGPASSWORD = $DB_PASS

    $query = @"
SELECT COUNT(*) as total_sps
FROM information_schema.routines
WHERE routine_schema = 'public'
AND (routine_name LIKE 'sp_%' OR routine_name LIKE 'SP_CEMENTERIOS_%');
"@

    Write-Host "  Consultando stored procedures instalados..." -ForegroundColor Gray
    "Consultando stored procedures instalados..." | Out-File -FilePath $LOG_FILE -Append

    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c $query | Out-File -FilePath $LOG_FILE -Append

    Write-Host "✓ Verificación completada" -ForegroundColor Green
    Write-Host "  Consultar detalles en: " -NoNewline
    Write-Host "$LOG_FILE" -ForegroundColor Yellow
}

# ============================================
# FUNCIÓN: Ejecutar pruebas básicas
# ============================================
function Run-BasicTests {
    Write-Host ""
    Write-Host "[4/4] Ejecutando pruebas básicas..." -ForegroundColor Yellow

    $env:PGPASSWORD = $DB_PASS

    "Ejecutando pruebas de SPs críticos..." | Out-File -FilePath $LOG_FILE -Append

    # Test 1
    Write-Host "  Test 1: " -NoNewline
    Write-Host "sp_estad_adeudo_resumen" -ForegroundColor Cyan
    $output = psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT * FROM sp_estad_adeudo_resumen() LIMIT 5;" 2>&1
    $output | Out-File -FilePath $LOG_FILE -Append

    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✓ SP ejecuta correctamente" -ForegroundColor Green
    } else {
        Write-Host "    ✗ Error al ejecutar SP" -ForegroundColor Red
    }

    # Test 2
    Write-Host "  Test 2: " -NoNewline
    Write-Host "SP_CEMENTERIOS_ESTADISTICAS" -ForegroundColor Cyan
    $output = psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT * FROM SP_CEMENTERIOS_ESTADISTICAS();" 2>&1
    $output | Out-File -FilePath $LOG_FILE -Append

    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✓ SP ejecuta correctamente" -ForegroundColor Green
    } else {
        Write-Host "    ✗ Error al ejecutar SP" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "✓ Pruebas completadas" -ForegroundColor Green
}

# ============================================
# FUNCIÓN: Mostrar resumen
# ============================================
function Show-Summary {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  RESUMEN DE INSTALACIÓN" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan

    Write-Host "Archivos procesados: " -NoNewline
    Write-Host "$TOTAL_FILES" -ForegroundColor Green

    Write-Host "Archivos exitosos: " -NoNewline
    Write-Host "$SUCCESS_COUNT" -ForegroundColor Green

    Write-Host "Archivos con error: " -NoNewline
    if ($ERROR_COUNT -gt 0) {
        Write-Host "$ERROR_COUNT" -ForegroundColor Red
    } else {
        Write-Host "$ERROR_COUNT" -ForegroundColor Green
    }

    Write-Host "SPs instalados: " -NoNewline
    Write-Host "$SP_INSTALLED / $TOTAL_SPS" -ForegroundColor Green

    Write-Host ""
    Write-Host "Log completo: " -NoNewline
    Write-Host "$LOG_FILE" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    "========================================" | Out-File -FilePath $LOG_FILE -Append
    "RESUMEN FINAL" | Out-File -FilePath $LOG_FILE -Append
    "========================================" | Out-File -FilePath $LOG_FILE -Append
    "Archivos procesados: $TOTAL_FILES" | Out-File -FilePath $LOG_FILE -Append
    "Archivos exitosos: $SUCCESS_COUNT" | Out-File -FilePath $LOG_FILE -Append
    "Archivos con error: $ERROR_COUNT" | Out-File -FilePath $LOG_FILE -Append
    "SPs instalados: $SP_INSTALLED / $TOTAL_SPS" | Out-File -FilePath $LOG_FILE -Append
    "Fin de instalación: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $LOG_FILE -Append

    if ($ERROR_COUNT -gt 0) {
        Write-Host "⚠ ADVERTENCIA: Se encontraron errores durante la instalación" -ForegroundColor Yellow
        Write-Host "  Revisar el archivo de log para más detalles" -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host "✓ INSTALACIÓN COMPLETADA EXITOSAMENTE" -ForegroundColor Green
        Write-Host ""
    }
}

# ============================================
# MAIN EXECUTION
# ============================================

Clear-Host
Print-Header

# Verificar psql
if (-not (Verify-PSQL)) {
    Write-Host "Presione cualquier tecla para salir..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Verificar estado inicial
if (-not (Verify-InitialState)) {
    Write-Host "Presione cualquier tecla para salir..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Instalar archivos
Install-AllFiles

# Verificar instalación
Verify-Installation

# Ejecutar pruebas
Run-BasicTests

# Mostrar resumen
Show-Summary

Write-Host "Presione cualquier tecla para salir..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
