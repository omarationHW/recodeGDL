<?php
/**
 * Check actual table structure
 */

$host = '192.168.6.146';
$db = 'padron_licencias';
$user = 'refact';
$pass = 'FF)-BQk2';

$conn = @pg_connect("host={$host} dbname={$db} user={$user} password={$pass}");

if (!$conn) {
    die("ERROR: No se pudo conectar\n");
}

$tables = [
    'ta_16_operacion',
    'ta_16_empresas',
    'ta_16_gastos',
    'ta_16_recargos',
    'ta_16_recaudadoras',
    'ta_16_tipo_aseo',
    'ta_16_tipos_aseo',
    'ta_16_tipos_emp',
    'ta_16_unidades',
    'ta_16_zonas'
];

foreach ($tables as $table) {
    echo "\n===============================================\n";
    echo "Table: {$table}\n";
    echo "===============================================\n";

    $sql = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = '{$table}'
        ORDER BY ordinal_position
    ";

    $result = pg_query($conn, $sql);

    if ($result && pg_num_rows($result) > 0) {
        while ($row = pg_fetch_assoc($result)) {
            $len = $row['character_maximum_length'] ?? '';
            echo "  - {$row['column_name']} ({$row['data_type']}";
            if ($len) echo " {$len}";
            echo ")\n";
        }
    } else {
        echo "  TABLE DOES NOT EXIST\n";
    }
}

pg_close($conn);
