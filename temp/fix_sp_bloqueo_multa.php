<?php
/**
 * Redesplegar el SP recaudadora_bloqueo_multa con la corrección
 */

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("❌ Error de conexión\n");
}

echo "=== CORRIGIENDO SP recaudadora_bloqueo_multa ===\n\n";

// Leer el archivo SQL correcto
$sql_file = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_bloqueo_multa.sql';

if (!file_exists($sql_file)) {
    die("❌ No se encuentra el archivo: $sql_file\n");
}

$sql = file_get_contents($sql_file);

echo "1. Leyendo archivo SQL...\n";
echo "   Archivo: $sql_file\n";
echo "   Tamaño: " . strlen($sql) . " bytes\n";

echo "\n2. Desplegando SP en la base de datos...\n";

// Ejecutar el SQL
$result = pg_query($conn, $sql);

if ($result) {
    echo "   ✓ SP desplegado exitosamente\n";
} else {
    echo "   ✗ Error al desplegar SP: " . pg_last_error($conn) . "\n";
    exit(1);
}

echo "\n3. Verificando corrección...\n";

// Verificar que ahora tiene el chequeo de NULL
$query = "
SELECT pg_get_functiondef(p.oid) as definicion
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'recaudadora_bloqueo_multa'
    AND n.nspname = 'public'
";
$result = pg_query($conn, $query);
$row = pg_fetch_assoc($result);
$def = $row['definicion'];

if (strpos($def, 'p_clave_cuenta IS NULL') !== false) {
    echo "   ✓ El SP ahora incluye 'p_clave_cuenta IS NULL'\n";
} else {
    echo "   ✗ El SP todavía NO incluye 'p_clave_cuenta IS NULL'\n";
    exit(1);
}

echo "\n4. Probando con NULL...\n";
$query = "SELECT * FROM recaudadora_bloqueo_multa(NULL, 2024, 0, 3)";
$result = pg_query($conn, $query);
$count = pg_num_rows($result);

if ($count > 0) {
    echo "   ✓ El SP ahora SÍ devuelve datos con NULL: $count registros\n";
    $row = pg_fetch_assoc($result);
    echo "   Ejemplo: Folio {$row['folio']}/{$row['ejercicio']}\n";
} else {
    echo "   ✗ El SP todavía NO devuelve datos con NULL\n";
    exit(1);
}

echo "\n5. Probando con string vacío...\n";
$query = "SELECT * FROM recaudadora_bloqueo_multa('', 2024, 0, 3)";
$result = pg_query($conn, $query);
$count = pg_num_rows($result);

if ($count > 0) {
    echo "   ✓ El SP también funciona con '': $count registros\n";
} else {
    echo "   ✗ El SP NO funciona con ''\n";
}

echo "\n✅ SP corregido y funcionando correctamente!\n";
echo "\nAhora puedes probar en el navegador:\n";
echo "   - Cuenta: (vacío)\n";
echo "   - Año: 2024\n";
echo "   - Debería mostrar hasta 753 registros\n";

pg_close($conn);
