<?php
/**
 * Buscar tabla de ejecutores en la base de datos
 */

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("❌ Error de conexión\n");
}

echo "=== BUSCANDO TABLA DE EJECUTORES ===\n\n";

// 1. Buscar tablas que contengan "ejecutor" en el nombre
echo "1. Tablas con 'ejecutor' en el nombre:\n";
$query = "
SELECT schemaname, tablename
FROM pg_tables
WHERE tablename LIKE '%ejecutor%'
ORDER BY schemaname, tablename
";
$result = pg_query($conn, $query);
$tablas_ejecutor = [];
while ($row = pg_fetch_assoc($result)) {
    echo "   {$row['schemaname']}.{$row['tablename']}\n";
    $tablas_ejecutor[] = $row;
}

if (empty($tablas_ejecutor)) {
    echo "   (No se encontraron tablas con 'ejecutor')\n";
}

// 2. Buscar tablas con 'empresa' en el nombre
echo "\n2. Tablas con 'empresa' en el nombre:\n";
$query = "
SELECT schemaname, tablename
FROM pg_tables
WHERE tablename LIKE '%empresa%'
ORDER BY schemaname, tablename
LIMIT 10
";
$result = pg_query($conn, $query);
$tablas_empresa = [];
while ($row = pg_fetch_assoc($result)) {
    echo "   {$row['schemaname']}.{$row['tablename']}\n";
    $tablas_empresa[] = $row;
}

// 3. Si encontramos tabla de ejecutores, ver su estructura
if (!empty($tablas_ejecutor)) {
    $tabla = $tablas_ejecutor[0];
    $schema = $tabla['schemaname'];
    $table = $tabla['tablename'];

    echo "\n3. Estructura de {$schema}.{$table}:\n";
    $query = "
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = '$schema'
        AND table_name = '$table'
    ORDER BY ordinal_position
    ";
    $result = pg_query($conn, $query);
    echo "   Columnas:\n";
    while ($row = pg_fetch_assoc($result)) {
        echo "   - {$row['column_name']} ({$row['data_type']})\n";
    }

    // Ver algunos datos
    echo "\n4. Datos de ejemplo:\n";
    $query = "SELECT * FROM {$schema}.{$table} LIMIT 5";
    $result = pg_query($conn, $query);

    if (pg_num_rows($result) > 0) {
        echo "   Total de registros: " . pg_num_rows($result) . "\n";
        echo "   Primeros 5:\n";
        while ($row = pg_fetch_assoc($result)) {
            echo "   - " . json_encode($row, JSON_UNESCAPED_UNICODE) . "\n";
        }
    } else {
        echo "   (Tabla vacía)\n";
    }
}

// 4. Buscar en tablas comunes
echo "\n5. Verificando en tablas comunes (comun schema):\n";
$query = "
SELECT tablename
FROM pg_tables
WHERE schemaname = 'comun'
    AND (tablename LIKE '%ejecutor%' OR tablename LIKE '%empresa%')
LIMIT 10
";
$result = pg_query($conn, $query);
if (pg_num_rows($result) > 0) {
    while ($row = pg_fetch_assoc($result)) {
        echo "   comun.{$row['tablename']}\n";
    }
} else {
    echo "   (No se encontraron)\n";
}

pg_close($conn);
echo "\n✅ Búsqueda completada.\n";
