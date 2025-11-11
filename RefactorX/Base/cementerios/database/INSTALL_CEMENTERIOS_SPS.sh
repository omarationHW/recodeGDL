#!/bin/bash
# ============================================
# SCRIPT DE INSTALACIÓN AUTOMÁTICA
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

# Configuración de conexión
DB_HOST="192.168.6.146"
DB_PORT="5432"
DB_NAME="padron_licencias"
DB_USER="refact"
DB_PASS="FF)-BQk2"

# Directorio base
BASE_DIR="C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\cementerios\database\ok"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
TOTAL_FILES=39
TOTAL_SPS=93
SUCCESS_COUNT=0
ERROR_COUNT=0
SP_INSTALLED=0

# Log file
LOG_FILE="install_cementerios_$(date +%Y%m%d_%H%M%S).log"

# ============================================
# FUNCIÓN: Imprimir header
# ============================================
print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  INSTALACIÓN DE STORED PROCEDURES${NC}"
    echo -e "${BLUE}  MÓDULO CEMENTERIOS${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo -e "Base de Datos: ${GREEN}$DB_NAME${NC}"
    echo -e "Host: ${GREEN}$DB_HOST:$DB_PORT${NC}"
    echo -e "Total Archivos: ${GREEN}$TOTAL_FILES${NC}"
    echo -e "Total SPs Esperados: ${GREEN}$TOTAL_SPS${NC}"
    echo -e "${BLUE}============================================${NC}\n"
}

# ============================================
# FUNCIÓN: Verificar estado inicial
# ============================================
verify_initial_state() {
    echo -e "${YELLOW}[1/4] Verificando estado inicial de la base de datos...${NC}"

    PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        SELECT COUNT(*) as total_sps_actuales
        FROM information_schema.routines
        WHERE routine_schema = 'public';
    " >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Conexión exitosa a PostgreSQL${NC}"
    else
        echo -e "${RED}✗ Error al conectar a PostgreSQL${NC}"
        exit 1
    fi
}

# ============================================
# FUNCIÓN: Instalar archivo SQL
# ============================================
install_file() {
    local file=$1
    local sp_count=$2
    local file_num=$3

    echo -e "\n${BLUE}[$file_num/$TOTAL_FILES]${NC} Instalando: ${YELLOW}$file${NC}"
    echo -e "  → SPs esperados: ${sp_count}"
    echo "========================================" >> "$LOG_FILE"
    echo "Instalando: $file" >> "$LOG_FILE"
    echo "Fecha/Hora: $(date)" >> "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"

    # Ejecutar archivo SQL
    PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$BASE_DIR/$file" >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓ Instalado exitosamente${NC}"
        ((SUCCESS_COUNT++))
        ((SP_INSTALLED+=$sp_count))
    else
        echo -e "  ${RED}✗ Error durante instalación${NC}"
        echo -e "  ${YELLOW}! Consultar log: $LOG_FILE${NC}"
        ((ERROR_COUNT++))
    fi
}

# ============================================
# FUNCIÓN: Instalar todos los archivos
# ============================================
install_all_files() {
    echo -e "\n${YELLOW}[2/4] Instalando archivos SQL...${NC}\n"

    # Array de archivos en orden óptimo de instalación
    # Primero archivos CORE y GESTION (fundamentales)
    # Luego archivos EXACTO por orden numérico

    # FASE 1: CORE (9 SPs)
    install_file "01_SP_CEMENTERIOS_CORE_all_procedures.sql" 9 1

    # FASE 2: GESTIÓN (8 SPs)
    install_file "02_SP_CEMENTERIOS_GESTION_all_procedures.sql" 8 2

    # FASE 3: ABC (5 SPs)
    install_file "03_SP_CEMENTERIOS_ABC_all_procedures.sql" 5 3

    # FASE 4: MÓDULOS EXACTO (orden numérico)
    install_file "01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql" 2 4
    install_file "02_SP_CEMENTERIOS_ABCRECARGOS_EXACTO_all_procedures.sql" 5 5
    install_file "03_SP_CEMENTERIOS_ACCESO_EXACTO_all_procedures.sql" 1 6
    install_file "04_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql" 3 7
    install_file "05_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql" 11 8
    install_file "06_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql" 3 9
    install_file "07_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql" 3 10
    install_file "08_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql" 3 11
    install_file "09_SP_CEMENTERIOS_DESCUENTOS_EXACTO_all_procedures.sql" 1 12
    install_file "10_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql" 2 13
    install_file "11_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures.sql" 1 14
    install_file "12_SP_CEMENTERIOS_LIST_MOV_EXACTO_all_procedures.sql" 1 15
    install_file "13_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql" 2 16
    install_file "14_SP_CEMENTERIOS_ABCRECARGOS_EXACTO_all_procedures.sql" 5 17
    install_file "15_SP_CEMENTERIOS_ACCESO_EXACTO_all_procedures.sql" 1 18
    install_file "16_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql" 2 19
    install_file "17_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql" 6 20
    install_file "18_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql" 2 21
    install_file "19_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql" 2 22
    install_file "20_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql" 2 23
    install_file "21_SP_CEMENTERIOS_DESCUENTOS_EXACTO_all_procedures.sql" 1 24
    install_file "22_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql" 1 25
    install_file "23_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures.sql" 1 26
    install_file "24_SP_CEMENTERIOS_LIST_MOV_EXACTO_all_procedures.sql" 1 27
    install_file "25_SP_CEMENTERIOS_MODULO_EXACTO_all_procedures.sql" 2 28
    install_file "26_SP_CEMENTERIOS_MULTIPLENOMBRE_EXACTO_all_procedures.sql" 1 29
    install_file "27_SP_CEMENTERIOS_MULTIPLERCM_EXACTO_all_procedures.sql" 1 30
    install_file "28_SP_CEMENTERIOS_MULTIPLEFECHA_EXACTO_all_procedures.sql" 1 31
    install_file "29_SP_CEMENTERIOS_REP_BON_EXACTO_all_procedures.sql" 1 32
    install_file "30_SP_CEMENTERIOS_REP_A_COBRAR_EXACTO_all_procedures.sql" 1 33
    install_file "31_SP_CEMENTERIOS_RPTTITULOS_EXACTO_all_procedures.sql" 2 34
    install_file "32_SP_CEMENTERIOS_TITULOSSIN_EXACTO_all_procedures.sql" 2 35
    install_file "33_SP_CEMENTERIOS_TITULOS_EXACTO_all_procedures.sql" 3 36
    install_file "34_SP_CEMENTERIOS_TRASLADOFOLSIN_EXACTO_all_procedures.sql" 1 37
    install_file "35_SP_CEMENTERIOS_TRASLADOS_EXACTO_all_procedures.sql" 2 38
    install_file "36_SP_CEMENTERIOS_SFRM_CHGPASS_EXACTO_all_procedures.sql" 1 39
}

# ============================================
# FUNCIÓN: Verificar instalación
# ============================================
verify_installation() {
    echo -e "\n${YELLOW}[3/4] Verificando instalación...${NC}\n"

    # Contar SPs instalados
    echo "Consultando stored procedures instalados..." >> "$LOG_FILE"
    PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        SELECT COUNT(*) as total_sps
        FROM information_schema.routines
        WHERE routine_schema = 'public'
        AND (routine_name LIKE 'sp_%' OR routine_name LIKE 'SP_CEMENTERIOS_%');
    " >> "$LOG_FILE" 2>&1

    # Listar SPs de cementerios
    PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'public'
        AND (routine_name LIKE 'sp_%cementerio%'
             OR routine_name LIKE 'sp_13_%'
             OR routine_name LIKE 'sp_estad_%'
             OR routine_name LIKE 'sp_bonificaciones_%')
        ORDER BY routine_name;
    " >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}✓ Verificación completada${NC}"
    echo -e "  ${YELLOW}Consultar detalles en: $LOG_FILE${NC}"
}

# ============================================
# FUNCIÓN: Mostrar resumen
# ============================================
show_summary() {
    echo -e "\n${BLUE}============================================${NC}"
    echo -e "${BLUE}  RESUMEN DE INSTALACIÓN${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo -e "Archivos procesados: ${GREEN}$TOTAL_FILES${NC}"
    echo -e "Archivos exitosos: ${GREEN}$SUCCESS_COUNT${NC}"
    echo -e "Archivos con error: ${RED}$ERROR_COUNT${NC}"
    echo -e "SPs instalados: ${GREEN}$SP_INSTALLED${NC} / $TOTAL_SPS"
    echo -e ""
    echo -e "Log completo: ${YELLOW}$LOG_FILE${NC}"
    echo -e "${BLUE}============================================${NC}\n"

    if [ $ERROR_COUNT -gt 0 ]; then
        echo -e "${YELLOW}⚠ ADVERTENCIA: Se encontraron errores durante la instalación${NC}"
        echo -e "${YELLOW}  Revisar el archivo de log para más detalles${NC}\n"
    else
        echo -e "${GREEN}✓ INSTALACIÓN COMPLETADA EXITOSAMENTE${NC}\n"
    fi
}

# ============================================
# FUNCIÓN: Pruebas básicas
# ============================================
run_basic_tests() {
    echo -e "${YELLOW}[4/4] Ejecutando pruebas básicas...${NC}\n"

    echo "Ejecutando pruebas de SPs críticos..." >> "$LOG_FILE"

    # Test 1: sp_estad_adeudo_resumen
    echo -e "Test 1: ${BLUE}sp_estad_adeudo_resumen${NC}"
    PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        SELECT * FROM sp_estad_adeudo_resumen() LIMIT 5;
    " >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓ SP ejecuta correctamente${NC}"
    else
        echo -e "  ${RED}✗ Error al ejecutar SP${NC}"
    fi

    # Test 2: SP_CEMENTERIOS_ESTADISTICAS
    echo -e "Test 2: ${BLUE}SP_CEMENTERIOS_ESTADISTICAS${NC}"
    PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        SELECT * FROM SP_CEMENTERIOS_ESTADISTICAS();
    " >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓ SP ejecuta correctamente${NC}"
    else
        echo -e "  ${RED}✗ Error al ejecutar SP${NC}"
    fi

    echo -e "\n${GREEN}✓ Pruebas completadas${NC}"
}

# ============================================
# MAIN EXECUTION
# ============================================

echo "Inicio de instalación: $(date)" > "$LOG_FILE"
print_header
verify_initial_state
install_all_files
verify_installation
run_basic_tests
show_summary

echo "Fin de instalación: $(date)" >> "$LOG_FILE"

exit 0
