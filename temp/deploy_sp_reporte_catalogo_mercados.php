<?php
/**
 * Script de despliegue: sp_reporte_catalogo_mercados
 * Fecha: 2025-12-05
 * Descripción: Corrige el SP para aceptar parámetros opcionales (p_oficina, p_estado)
 */

$host = '188.245.107.92';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'postgres';
$password = 'Guadalajara2024*';

// Conectar a la base de datos
$conn = pg_connect("host=$host port=$port dbname=$dbname user=$user password=$password");

if (!$conn) {
    die("Error: No se pudo conectar a la base de datos.\n");
}

echo "==============================================\n";
echo "DESPLIEGUE: sp_reporte_catalogo_mercados\n";
echo "==============================================\n\n";

// Leer el archivo SQL
$sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/RptCatalogoMerc_sp_reporte_catalogo_mercados_CORREGIDO.sql';

if (!file_exists($sqlFile)) {
    die("ERROR: No se encuentra el archivo SQL: $sqlFile\n");
}

$sql = file_get_contents($sqlFile);

// Eliminar el SP anterior si existe
echo "1. Eliminando versión anterior del SP...\n";
$dropSql = "DROP FUNCTION IF EXISTS public.sp_reporte_catalogo_mercados();";
$result = pg_query($conn, $dropSql);
if (!$result) {
    echo "   ADVERTENCIA: " . pg_last_error($conn) . "\n";
} else {
    echo "   ✓ SP anterior eliminado\n";
}

// Crear el nuevo SP
echo "\n2. Creando nueva versión del SP...\n";
$result = pg_query($conn, $sql);

if (!$result) {
    echo "   ✗ ERROR al crear el SP:\n";
    echo "   " . pg_last_error($conn) . "\n";
    pg_close($conn);
    exit(1);
} else {
    echo "   ✓ SP creado correctamente\n";
}

// Verificar que el SP fue creado correctamente
echo "\n3. Verificando el SP...\n";
$verifySql = "
SELECT
    p.proname AS nombre_funcion,
    pg_get_function_arguments(p.oid) AS parametros,
    pg_get_functiondef(p.oid) AS definicion
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname = 'sp_reporte_catalogo_mercados'
ORDER BY p.oid DESC
LIMIT 1;
";

$result = pg_query($conn, $verifySql);
if ($result && pg_num_rows($result) > 0) {
    $row = pg_fetch_assoc($result);
    echo "   ✓ Función: " . $row['nombre_funcion'] . "\n";
    echo "   ✓ Parámetros: " . $row['parametros'] . "\n";
} else {
    echo "   ✗ ERROR: No se pudo verificar el SP\n";
    pg_close($conn);
    exit(1);
}

// Probar el SP con diferentes casos
echo "\n4. Probando el SP...\n\n";

// Test 1: Sin filtros
echo "   Test 1: Sin filtros\n";
$testSql1 = "SELECT * FROM sp_reporte_catalogo_mercados(NULL, NULL) LIMIT 5;";
$result1 = pg_query($conn, $testSql1);
if ($result1) {
    $count1 = pg_num_rows($result1);
    echo "   ✓ Resultado: $count1 registros\n";
    if ($count1 > 0) {
        $row1 = pg_fetch_assoc($result1);
        echo "   Ejemplo: Oficina={$row1['oficina']}, Mercado={$row1['num_mercado_nvo']}, Estado={$row1['estado']}\n";
    }
} else {
    echo "   ✗ ERROR: " . pg_last_error($conn) . "\n";
}

// Test 2: Con filtro de oficina
echo "\n   Test 2: Con filtro oficina=1\n";
$testSql2 = "SELECT * FROM sp_reporte_catalogo_mercados(1, NULL) LIMIT 3;";
$result2 = pg_query($conn, $testSql2);
if ($result2) {
    $count2 = pg_num_rows($result2);
    echo "   ✓ Resultado: $count2 registros\n";
} else {
    echo "   ✗ ERROR: " . pg_last_error($conn) . "\n";
}

// Test 3: Con filtro de estado
echo "\n   Test 3: Con filtro estado='A' (Activos)\n";
$testSql3 = "SELECT * FROM sp_reporte_catalogo_mercados(NULL, 'A') LIMIT 3;";
$result3 = pg_query($conn, $testSql3);
if ($result3) {
    $count3 = pg_num_rows($result3);
    echo "   ✓ Resultado: $count3 registros\n";
} else {
    echo "   ✗ ERROR: " . pg_last_error($conn) . "\n";
}

// Test 4: Con ambos filtros
echo "\n   Test 4: Con filtro oficina=1 y estado='A'\n";
$testSql4 = "SELECT * FROM sp_reporte_catalogo_mercados(1, 'A');";
$result4 = pg_query($conn, $testSql4);
if ($result4) {
    $count4 = pg_num_rows($result4);
    echo "   ✓ Resultado: $count4 registros\n";
} else {
    echo "   ✗ ERROR: " . pg_last_error($conn) . "\n";
}

pg_close($conn);

echo "\n==============================================\n";
echo "DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
echo "==============================================\n";
echo "\nNOTA: El SP ahora acepta 2 parámetros opcionales:\n";
echo "  - p_oficina (SMALLINT): Filtro por recaudadora\n";
echo "  - p_estado (VARCHAR): Filtro por estado ('A' = Activo, 'I' = Inactivo)\n";
echo "\nEjemplos de uso:\n";
echo "  SELECT * FROM sp_reporte_catalogo_mercados(NULL, NULL);  -- Sin filtros\n";
echo "  SELECT * FROM sp_reporte_catalogo_mercados(1, NULL);     -- Solo oficina 1\n";
echo "  SELECT * FROM sp_reporte_catalogo_mercados(NULL, 'A');   -- Solo activos\n";
echo "  SELECT * FROM sp_reporte_catalogo_mercados(1, 'A');      -- Oficina 1 y activos\n";
?>
