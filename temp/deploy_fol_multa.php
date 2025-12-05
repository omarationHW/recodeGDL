<?php
echo "=== DESPLEGANDO SP: recaudadora_fol_multa ===\n\n";

$conn = pg_connect('host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2');

if (!$conn) {
    die("Error de conexión a la base de datos\n");
}

// Leer el archivo SQL
$sql = file_get_contents(__DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_fol_multa.sql');

// Ejecutar el SQL
$result = pg_query($conn, $sql);

if ($result) {
    echo "✓ SP desplegado exitosamente en schema db_ingresos\n\n";

    // Verificar que el SP existe
    $verify = pg_query($conn, "
        SELECT routine_schema, routine_name,
               pg_get_function_arguments(p.oid) as parameters
        FROM information_schema.routines r
        JOIN pg_proc p ON p.proname = r.routine_name
        WHERE routine_name = 'recaudadora_fol_multa'
          AND routine_schema = 'db_ingresos'
    ");

    if ($row = pg_fetch_assoc($verify)) {
        echo "SP encontrado:\n";
        echo "  Schema: " . $row['routine_schema'] . "\n";
        echo "  Nombre: " . $row['routine_name'] . "\n";
        echo "  Parámetros: " . $row['parameters'] . "\n";
    } else {
        echo "⚠ Advertencia: No se pudo verificar el SP\n";
    }
} else {
    echo "✗ Error al desplegar SP: " . pg_last_error($conn) . "\n";
}

pg_close($conn);
echo "\n=== FIN DEL DESPLIEGUE ===\n";
