<?php
// Verificar SP padron_global

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== VERIFICANDO SP_PADRON_GLOBAL ===\n\n";

// Buscar el SP
$query = "
    SELECT
        n.nspname as schema,
        p.proname as function_name,
        pg_get_function_arguments(p.oid) as arguments
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname = 'sp_padron_global'
    ORDER BY n.nspname;
";

$result = pg_query($conn, $query);

if ($result && pg_num_rows($result) > 0) {
    echo "✅ SP ENCONTRADO:\n";
    while ($row = pg_fetch_assoc($result)) {
        echo "  Schema: {$row['schema']}\n";
        echo "  Función: {$row['function_name']}\n";
        echo "  Argumentos: {$row['arguments']}\n\n";
    }

    // Probar el SP con datos reales
    echo "=== PROBANDO SP CON DATOS ===\n\n";

    $year = date('Y');
    $month = date('n');
    $status = 'A';

    echo "Parámetros: year=$year, month=$month, status='$status'\n\n";

    $test_query = "SELECT * FROM sp_padron_global($year, $month, '$status') LIMIT 5";

    $test_result = pg_query($conn, $test_query);

    if ($test_result) {
        $count = pg_num_rows($test_result);
        echo "✅ SP ejecutado correctamente: $count registros encontrados\n\n";

        if ($count > 0) {
            echo "Primeros 5 registros:\n";
            echo str_repeat("-", 120) . "\n";
            while ($row = pg_fetch_assoc($test_result)) {
                echo sprintf(
                    "ID: %s | Registro: %s | Nombre: %-30s | Renta: $%s | Adeudo: %s\n",
                    $row['id_local'],
                    $row['registro'],
                    substr($row['nombre'], 0, 30),
                    number_format($row['renta'], 2),
                    $row['leyenda']
                );
            }
        } else {
            echo "⚠️ No se encontraron locales con los criterios especificados\n";
        }
    } else {
        echo "❌ Error al ejecutar SP: " . pg_last_error($conn) . "\n";
    }

} else {
    echo "❌ SP NO ENCONTRADO\n";
}

echo "\n" . str_repeat("=", 80) . "\n";
echo "=== VERIFICANDO TABLAS REQUERIDAS ===\n\n";

$tablas = [
    'ta_11_locales',
    'ta_11_mercados',
    'ta_11_cuo_locales',
    'ta_11_adeudo_local',
    'ta_11_fecha_desc'
];

foreach ($tablas as $tabla) {
    $tabla_query = "
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename = '$tabla'
        ORDER BY schemaname;
    ";

    $tabla_result = pg_query($conn, $tabla_query);

    if ($tabla_result && pg_num_rows($tabla_result) > 0) {
        while ($row = pg_fetch_assoc($tabla_result)) {
            echo "  ✅ {$row['schemaname']}.{$tabla}\n";
        }
    } else {
        echo "  ❌ $tabla NO ENCONTRADA\n";
    }
}

pg_close($conn);
