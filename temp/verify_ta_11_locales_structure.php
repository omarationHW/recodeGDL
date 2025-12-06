<?php
// Verificar estructura de ta_11_locales

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== ESTRUCTURA DE publico.ta_11_locales ===\n\n";

$query = "
    SELECT
        column_name,
        data_type,
        udt_name,
        character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = 'publico'
      AND table_name = 'ta_11_locales'
    ORDER BY ordinal_position;
";

$result = pg_query($conn, $query);

if ($result && pg_num_rows($result) > 0) {
    echo sprintf("%-25s %-20s %-15s %s\n", "COLUMNA", "DATA_TYPE", "UDT_NAME", "MAX_LENGTH");
    echo str_repeat("-", 90) . "\n";

    while ($row = pg_fetch_assoc($result)) {
        echo sprintf(
            "%-25s %-20s %-15s %s\n",
            $row['column_name'],
            $row['data_type'],
            $row['udt_name'],
            $row['character_maximum_length'] ?? 'N/A'
        );
    }
} else {
    echo "❌ Error: " . pg_last_error($conn) . "\n";
}

echo "\n" . str_repeat("=", 90) . "\n\n";

// Verificar cantidad de registros
echo "=== CANTIDAD DE REGISTROS ===\n\n";

$count_query = "SELECT COUNT(*) as total FROM publico.ta_11_locales";
$count_result = pg_query($conn, $count_query);

if ($count_result) {
    $count_row = pg_fetch_assoc($count_result);
    echo "Total de locales: " . number_format($count_row['total']) . "\n";
}

pg_close($conn);
