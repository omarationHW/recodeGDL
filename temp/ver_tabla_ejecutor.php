<?php
/**
 * Ver estructura y datos de la tabla ejecutor
 */

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("❌ Error de conexión\n");
}

echo "=== TABLA EJECUTOR ===\n\n";

// 1. Ver estructura
echo "1. Estructura de catastro_gdl.ejecutor:\n";
$query = "
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'catastro_gdl'
    AND table_name = 'ejecutor'
ORDER BY ordinal_position
";
$result = pg_query($conn, $query);
$columnas = [];
while ($row = pg_fetch_assoc($result)) {
    echo "   - {$row['column_name']} ({$row['data_type']})\n";
    $columnas[] = $row['column_name'];
}

// 2. Ver datos activos
echo "\n2. Ejecutores activos (vigentes):\n";
$query = "
SELECT *
FROM catastro_gdl.ejecutor
WHERE vigencia = 'V'
ORDER BY cveejecutor
LIMIT 10
";
$result = pg_query($conn, $query);
$count = pg_num_rows($result);
echo "   Total de ejecutores vigentes: $count\n\n";

if ($count > 0) {
    echo "   Ejecutores:\n";
    while ($row = pg_fetch_assoc($result)) {
        $cols = [];
        foreach ($row as $k => $v) {
            if (!is_null($v) && trim($v) !== '') {
                $cols[] = "$k: " . trim($v);
            }
        }
        echo "   - " . implode(" | ", $cols) . "\n";
    }
} else {
    // Si no hay vigentes, mostrar todos
    echo "\n3. Mostrando TODOS los ejecutores (no hay vigentes):\n";
    $query = "SELECT * FROM catastro_gdl.ejecutor LIMIT 10";
    $result = pg_query($conn, $query);
    while ($row = pg_fetch_assoc($result)) {
        $cols = [];
        foreach ($row as $k => $v) {
            if (!is_null($v) && trim($v) !== '') {
                $cols[] = "$k: " . trim($v);
            }
        }
        echo "   - " . implode(" | ", $cols) . "\n";
    }
}

// 3. Ver tabla ta_15_ejecutores (podría tener más info)
echo "\n4. Verificando comun.ta_15_ejecutores:\n";
$query = "
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'comun'
    AND table_name = 'ta_15_ejecutores'
ORDER BY ordinal_position
";
$result = pg_query($conn, $query);
if (pg_num_rows($result) > 0) {
    echo "   Columnas:\n";
    while ($row = pg_fetch_assoc($result)) {
        echo "   - {$row['column_name']} ({$row['data_type']})\n";
    }

    // Ver datos
    echo "\n   Datos de ejemplo:\n";
    $query = "SELECT * FROM comun.ta_15_ejecutores LIMIT 5";
    $result = pg_query($conn, $query);
    while ($row = pg_fetch_assoc($result)) {
        echo "   - " . json_encode($row, JSON_UNESCAPED_UNICODE) . "\n";
    }
}

pg_close($conn);
echo "\n✅ Verificación completada.\n";
