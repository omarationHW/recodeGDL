<?php
// Verificar estructura real de ta_11_kilowhatts

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== ESTRUCTURA DE public.ta_11_kilowhatts ===\n\n";

$query = "
    SELECT
        column_name,
        data_type,
        udt_name,
        is_nullable,
        column_default
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'ta_11_kilowhatts'
    ORDER BY ordinal_position;
";

$result = pg_query($conn, $query);

if ($result && pg_num_rows($result) > 0) {
    echo sprintf("%-20s %-20s %-15s %s\n", "COLUMNA", "DATA_TYPE", "UDT_NAME", "NULLABLE");
    echo str_repeat("-", 80) . "\n";

    while ($row = pg_fetch_assoc($result)) {
        echo sprintf(
            "%-20s %-20s %-15s %s\n",
            $row['column_name'],
            $row['data_type'],
            $row['udt_name'],
            $row['is_nullable']
        );
    }
} else {
    echo "❌ Error: " . pg_last_error($conn) . "\n";
}

pg_close($conn);
