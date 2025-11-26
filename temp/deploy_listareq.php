<?php
// Desplegar SP recaudadora_listareq
$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("❌ Error de conexión\n");
}

echo "╔═══════════════════════════════════════════════════════════╗\n";
echo "║       DESPLIEGUE DE SP: recaudadora_listareq              ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";

$sql_file = 'C:\recodeGDL\RefactorX\Base\multas_reglamentos\database\generated\recaudadora_listareq.sql';
$sql = file_get_contents($sql_file);

if (!$sql) {
    die("❌ No se pudo leer el archivo SQL\n");
}

echo "📄 Desplegando SP...\n";

$result = pg_query($conn, $sql);

if ($result) {
    echo "✅ SP desplegado exitosamente\n\n";

    // Verificar
    $verify = pg_query($conn, "
        SELECT routine_schema, routine_name
        FROM information_schema.routines
        WHERE routine_name = 'recaudadora_listareq'
        AND routine_type = 'FUNCTION'
    ");

    echo "--- VERIFICACIÓN ---\n";
    while ($row = pg_fetch_assoc($verify)) {
        echo "✓ " . $row['routine_schema'] . "." . $row['routine_name'] . "\n";
    }

    // Probar el SP
    echo "\n--- PRUEBA RÁPIDA ---\n";
    $test = pg_query($conn, "SELECT * FROM recaudadora_listareq('') LIMIT 3");

    if ($test && pg_num_rows($test) > 0) {
        echo "Total de registros: " . pg_num_rows($test) . "\n";
        while ($row = pg_fetch_assoc($test)) {
            echo sprintf(
                "  CVE: %-5s | Cuenta: %-10s | Folio: %-8s\n",
                $row['cvereq'],
                $row['cvecuenta'],
                $row['folioreq']
            );
        }
    } else {
        echo "Sin registros o error en prueba\n";
    }

} else {
    echo "❌ Error al desplegar:\n";
    echo pg_last_error($conn) . "\n";
}

pg_close($conn);
echo "\n✅ Proceso completado\n";
