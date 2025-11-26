<?php
// Desplegar SP recaudadora_req a la base de datos
$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("❌ Error de conexión a la base de datos\n");
}

echo "╔═══════════════════════════════════════════════════════════╗\n";
echo "║       DESPLIEGUE DE SP: recaudadora_req                   ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";

// Leer el archivo SQL
$sql_file = 'C:\recodeGDL\RefactorX\Base\multas_reglamentos\database\generated\recaudadora_req.sql';
$sql = file_get_contents($sql_file);

if (!$sql) {
    die("❌ No se pudo leer el archivo SQL\n");
}

echo "📄 Archivo SQL leído: recaudadora_req.sql\n";
echo "📦 Tamaño: " . strlen($sql) . " bytes\n\n";

// Ejecutar el SQL
echo "🚀 Desplegando SP a la base de datos...\n\n";

$result = pg_query($conn, $sql);

if ($result) {
    echo "✅ SP desplegado exitosamente\n\n";

    // Verificar que el SP existe
    $verify = pg_query($conn, "
        SELECT routine_schema, routine_name,
               routine_type, data_type
        FROM information_schema.routines
        WHERE routine_name = 'recaudadora_req'
        AND routine_type = 'FUNCTION'
    ");

    echo "--- VERIFICACIÓN ---\n";
    while ($row = pg_fetch_assoc($verify)) {
        echo "Schema: " . $row['routine_schema'] . "\n";
        echo "Nombre: " . $row['routine_name'] . "\n";
        echo "Tipo:   " . $row['routine_type'] . "\n";
        echo "\n";
    }

    // Ver los parámetros del SP
    $params = pg_query($conn, "
        SELECT
            p.parameter_name,
            p.data_type,
            p.parameter_mode
        FROM information_schema.parameters p
        WHERE p.specific_schema = 'public'
        AND p.specific_name LIKE '%recaudadora_req%'
        ORDER BY p.ordinal_position
    ");

    echo "--- PARÁMETROS DEL SP ---\n";
    if (pg_num_rows($params) > 0) {
        while ($row = pg_fetch_assoc($params)) {
            echo sprintf(
                "  - %s (%s) [%s]\n",
                $row['parameter_name'] ?: 'return',
                $row['data_type'],
                $row['parameter_mode']
            );
        }
    } else {
        echo "  (Sin parámetros de entrada)\n";
    }

    echo "\n✅ Despliegue completado exitosamente\n";

} else {
    echo "❌ Error al desplegar el SP:\n";
    echo pg_last_error($conn) . "\n";
}

pg_close($conn);
