<?php
// Verificar si existe el SP recaudadora_listareq
$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

echo "=== VERIFICACIÓN DE SP: recaudadora_listareq ===\n\n";

$result = pg_query($conn, "
    SELECT routine_schema, routine_name
    FROM information_schema.routines
    WHERE routine_name ILIKE '%listareq%'
    AND routine_type = 'FUNCTION'
");

if (pg_num_rows($result) > 0) {
    echo "✓ SPs encontrados:\n";
    while ($row = pg_fetch_assoc($result)) {
        echo "  - " . $row['routine_schema'] . "." . $row['routine_name'] . "\n";
    }
} else {
    echo "❌ No se encontró el SP recaudadora_listareq\n";
    echo "   Necesita ser creado.\n";
}

pg_close($conn);
