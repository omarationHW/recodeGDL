<?php
// Buscar tabla ta_12_passwords en BD mercados

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== BUSCANDO TABLA DE USUARIOS EN BD MERCADOS ===\n\n";

// Buscar tablas con nombres similares
$query = "
    SELECT
        schemaname,
        tablename
    FROM pg_tables
    WHERE tablename LIKE '%password%'
       OR tablename LIKE '%usuario%'
       OR tablename LIKE '%user%'
       OR tablename = 'ta_12_passwords'
    ORDER BY schemaname, tablename;
";

$result = pg_query($conn, $query);

if ($result && pg_num_rows($result) > 0) {
    echo "Tablas encontradas:\n";
    while ($row = pg_fetch_assoc($result)) {
        echo "  - {$row['schemaname']}.{$row['tablename']}\n";
    }
} else {
    echo "No se encontraron tablas de usuarios\n";
}

echo "\n" . str_repeat("=", 80) . "\n\n";

// Verificar schema 'comun' en la BD actual
echo "Verificando schema 'comun' en BD mercados:\n";

$query2 = "
    SELECT
        tablename
    FROM pg_tables
    WHERE schemaname = 'comun'
      AND (tablename LIKE '%password%' OR tablename LIKE '%usuario%')
    ORDER BY tablename;
";

$result2 = pg_query($conn, $query2);

if ($result2 && pg_num_rows($result2) > 0) {
    echo "Tablas en schema 'comun':\n";
    while ($row = pg_fetch_assoc($result2)) {
        echo "  - comun.{$row['tablename']}\n";
    }

    // Verificar estructura de la tabla
    echo "\nVerificando estructura de comun.ta_12_passwords:\n";

    $query3 = "
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun'
          AND table_name = 'ta_12_passwords'
        ORDER BY ordinal_position;
    ";

    $result3 = pg_query($conn, $query3);

    if ($result3 && pg_num_rows($result3) > 0) {
        echo "Columnas:\n";
        while ($row = pg_fetch_assoc($result3)) {
            echo "  - {$row['column_name']} ({$row['data_type']})\n";
        }
    }

} else {
    echo "No se encontró schema 'comun' en BD mercados\n";
}

pg_close($conn);
