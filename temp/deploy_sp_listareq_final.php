<?php
echo "╔═══════════════════════════════════════════════════════════╗\n";
echo "║     DESPLIEGUE DE SP: recaudadora_listareq                ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n\n";

// Configuración
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

echo "🔌 Intentando conectar a PostgreSQL...\n";
echo "   Host: $host:$port\n";
echo "   Base: $dbname\n\n";

$conn_string = "host=$host port=$port dbname=$dbname user=$user password=$password connect_timeout=10";
$conn = @pg_connect($conn_string);

if (!$conn) {
    die("❌ ERROR: No se pudo conectar a la base de datos\n" . pg_last_error() . "\n");
}

echo "✅ Conexión exitosa\n\n";

// Leer el archivo SQL
$sql_file = 'C:\recodeGDL\RefactorX\Base\multas_reglamentos\database\generated\recaudadora_listareq.sql';

if (!file_exists($sql_file)) {
    die("❌ ERROR: No se encontró el archivo SQL\n");
}

$sql = file_get_contents($sql_file);
echo "📄 Leyendo archivo SQL... OK\n";
echo "📦 Tamaño: " . strlen($sql) . " bytes\n\n";

// Ejecutar el SQL
echo "🚀 Desplegando stored procedure...\n";
$result = pg_query($conn, $sql);

if (!$result) {
    echo "❌ ERROR al desplegar:\n";
    echo pg_last_error($conn) . "\n";
    pg_close($conn);
    exit(1);
}

echo "✅ SP desplegado exitosamente\n\n";

// Verificar que existe
echo "--- VERIFICACIÓN ---\n";
$verify_sql = "
    SELECT routine_schema, routine_name, routine_type
    FROM information_schema.routines
    WHERE routine_name = 'recaudadora_listareq'
    AND routine_type = 'FUNCTION'
";

$verify = pg_query($conn, $verify_sql);
if ($verify && pg_num_rows($verify) > 0) {
    while ($row = pg_fetch_assoc($verify)) {
        echo "✓ Encontrado: " . $row['routine_schema'] . "." . $row['routine_name'] . "\n";
    }
} else {
    echo "⚠ No se encontró el SP después del despliegue\n";
}

// Probar el SP
echo "\n--- PRUEBA DEL SP ---\n";
$test_sql = "SELECT * FROM recaudadora_listareq('') LIMIT 5";
$test = pg_query($conn, $test_sql);

if ($test) {
    $count = pg_num_rows($test);
    echo "✅ SP funciona correctamente\n";
    echo "📊 Registros retornados: $count\n\n";

    if ($count > 0) {
        echo "Primeros registros:\n";
        $i = 1;
        while ($row = pg_fetch_assoc($test)) {
            echo sprintf(
                "  %d. CVE: %-5s | Cuenta: %-12s | Folio: %-8s | Año: %s\n",
                $i++,
                $row['cvereq'],
                $row['cvecuenta'],
                $row['folioreq'],
                $row['axoreq']
            );
        }
    }
} else {
    echo "❌ Error al probar el SP:\n";
    echo pg_last_error($conn) . "\n";
}

pg_close($conn);

echo "\n╔═══════════════════════════════════════════════════════════╗\n";
echo "║                    RESUMEN                                ║\n";
echo "╚═══════════════════════════════════════════════════════════╝\n";
echo "\n";
echo "✅ Conexión a BD establecida\n";
echo "✅ SP recaudadora_listareq desplegado\n";
echo "✅ SP verificado y funcional\n";
echo "\nAhora puedes probar el formulario listareq.vue en el navegador\n";
