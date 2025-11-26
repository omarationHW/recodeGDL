<?php
// Ver estructura de tablas multas y reqmultas
$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("Error de conexión\n");
}

echo "=== ESTRUCTURA DE TABLAS ===\n\n";

// Estructura de tabla multas
echo "--- TABLA: comun.multas ---\n";
$query1 = "
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'comun'
    AND table_name = 'multas'
ORDER BY ordinal_position";

$result1 = pg_query($conn, $query1);
if ($result1) {
    while ($row = pg_fetch_assoc($result1)) {
        echo sprintf(
            "  %-30s | %-20s | %s\n",
            $row['column_name'],
            $row['data_type'],
            $row['character_maximum_length'] ?: ''
        );
    }
}

// Estructura de tabla reqmultas
echo "\n--- TABLA: comun.reqmultas ---\n";
$query2 = "
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'comun'
    AND table_name = 'reqmultas'
ORDER BY ordinal_position";

$result2 = pg_query($conn, $query2);
if ($result2) {
    while ($row = pg_fetch_assoc($result2)) {
        echo sprintf(
            "  %-30s | %-20s | %s\n",
            $row['column_name'],
            $row['data_type'],
            $row['character_maximum_length'] ?: ''
        );
    }
}

// Obtener algunos datos de ejemplo de multas
echo "\n--- PRIMEROS 5 REGISTROS DE comun.multas ---\n";
$query3 = "SELECT * FROM comun.multas LIMIT 5";
$result3 = pg_query($conn, $query3);

if ($result3 && pg_num_rows($result3) > 0) {
    $first = true;
    while ($row = pg_fetch_assoc($result3)) {
        if ($first) {
            echo "Columnas disponibles: " . implode(", ", array_keys($row)) . "\n\n";
            $first = false;
        }
        echo "Registro:\n";
        foreach ($row as $key => $value) {
            if (!empty($value)) {
                echo "  $key: $value\n";
            }
        }
        echo "\n";
    }
} else {
    echo "No hay datos en la tabla multas\n";
}

pg_close($conn);
echo "\n✓ Consulta completada\n";
