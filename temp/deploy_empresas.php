<?php
// Script para desplegar el SP recaudadora_empresas
error_reporting(E_ALL);
ini_set('display_errors', 1);

$conn = pg_connect("host=localhost port=5432 dbname=padron_licencias user=postgres password=postgres");

if (!$conn) {
    die("❌ Error de conexión a PostgreSQL\n");
}

echo "✅ Conectado a PostgreSQL (DB: padron_licencias)\n\n";

// Leer el archivo SQL
$sql_file = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_empresas.sql';

if (!file_exists($sql_file)) {
    die("❌ Archivo SQL no encontrado: $sql_file\n");
}

$sql = file_get_contents($sql_file);

echo "📄 Desplegando SP: recaudadora_empresas\n";
echo "📂 Desde: $sql_file\n\n";

// Ejecutar el SQL
$result = pg_query($conn, $sql);

if ($result) {
    echo "✅ SP recaudadora_empresas desplegado exitosamente\n\n";
} else {
    echo "❌ Error al desplegar SP:\n";
    echo pg_last_error($conn) . "\n\n";
    pg_close($conn);
    exit(1);
}

// Verificar que el SP existe
echo "🔍 Verificando existencia del SP...\n";
$verify_query = "
SELECT
    n.nspname as schema,
    p.proname as name,
    pg_catalog.pg_get_function_arguments(p.oid) as arguments
FROM pg_catalog.pg_proc p
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname = 'recaudadora_empresas'
  AND n.nspname = 'multas_reglamentos';
";

$result = pg_query($conn, $verify_query);
if ($result && pg_num_rows($result) > 0) {
    $row = pg_fetch_assoc($result);
    echo "✅ SP encontrado: {$row['schema']}.{$row['name']}({$row['arguments']})\n\n";
} else {
    echo "⚠️  SP no encontrado después del despliegue\n\n";
}

// Probar el SP con ejemplos
echo "🧪 Probando el SP con ejemplos:\n\n";

// Ejemplo 1: Buscar todos
echo "=== EJEMPLO 1: Buscar todos (primeros 5) ===\n";
$test_query = "SELECT * FROM multas_reglamentos.recaudadora_empresas('', 0, 5);";
$result = pg_query($conn, $test_query);
if ($result) {
    $total = 0;
    echo "Primeros registros:\n";
    $count = 0;
    while ($row = pg_fetch_assoc($result)) {
        $total = $row['total_count'];
        $count++;
        echo "$count. {$row['empresa']} - RFC: {$row['rfc']} - Contacto: {$row['contacto']} - Estatus: {$row['estatus']}\n";
    }
    echo "\nTotal de registros en BD: $total\n";
} else {
    echo "Error: " . pg_last_error($conn) . "\n";
}

echo "\n=== EJEMPLO 2: Buscar por nombre (filtro: 'EJECUTOR') ===\n";
$test_query = "SELECT * FROM multas_reglamentos.recaudadora_empresas('EJECUTOR', 0, 5);";
$result = pg_query($conn, $test_query);
if ($result) {
    $total = 0;
    echo "Registros encontrados:\n";
    $count = 0;
    while ($row = pg_fetch_assoc($result)) {
        $total = $row['total_count'];
        $count++;
        echo "$count. {$row['empresa']} - RFC: {$row['rfc']} - Contacto: {$row['contacto']} - Estatus: {$row['estatus']}\n";
    }
    echo "\nTotal de registros que coinciden con 'EJECUTOR': $total\n";
    if ($count == 0) {
        echo "No hay registros con ese filtro\n";
    }
} else {
    echo "Error: " . pg_last_error($conn) . "\n";
}

echo "\n=== EJEMPLO 3: Buscar por categoría (filtro: 'NOTIFICADOR') ===\n";
$test_query = "SELECT * FROM multas_reglamentos.recaudadora_empresas('NOTIFICADOR', 0, 5);";
$result = pg_query($conn, $test_query);
if ($result) {
    $total = 0;
    echo "Registros encontrados:\n";
    $count = 0;
    while ($row = pg_fetch_assoc($result)) {
        $total = $row['total_count'];
        $count++;
        echo "$count. {$row['empresa']} - RFC: {$row['rfc']} - Contacto: {$row['contacto']} - Estatus: {$row['estatus']}\n";
    }
    echo "\nTotal de registros que coinciden con 'NOTIFICADOR': $total\n";
    if ($count == 0) {
        echo "No hay registros con ese filtro\n";
    }
} else {
    echo "Error: " . pg_last_error($conn) . "\n";
}

echo "\n✅ Despliegue completado\n";

pg_close($conn);
?>
