<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Buscando tablas de requerimientos ===\n\n";

// Buscar tablas con 'requerimiento' en el nombre
$stmt = $pdo->query("
    SELECT table_schema, table_name,
           (SELECT COUNT(*) FROM information_schema.columns c WHERE c.table_schema = t.table_schema AND c.table_name = t.table_name) as num_columns
    FROM information_schema.tables t
    WHERE table_name LIKE '%requerimiento%'
    ORDER BY table_schema, table_name
");

$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($tables as $table) {
    echo "Schema: {$table['table_schema']}, Tabla: {$table['table_name']}, Columnas: {$table['num_columns']}\n";

    // Mostrar estructura de cada tabla
    $stmt2 = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = '{$table['table_schema']}'
          AND table_name = '{$table['table_name']}'
        ORDER BY ordinal_position
        LIMIT 15
    ");

    $columns = $stmt2->fetchAll(PDO::FETCH_ASSOC);
    foreach ($columns as $col) {
        echo "  - {$col['column_name']} ({$col['data_type']})\n";
    }

    // Contar registros
    try {
        $stmt3 = $pdo->query("SELECT COUNT(*) as total FROM {$table['table_schema']}.{$table['table_name']}");
        $count = $stmt3->fetch(PDO::FETCH_ASSOC);
        echo "  Total registros: {$count['total']}\n";
    } catch (Exception $e) {
        echo "  Error al contar: " . $e->getMessage() . "\n";
    }

    echo "\n";
}

// Buscar tablas relacionadas con locales y periodos
echo "\n=== Buscando tablas relacionadas ===\n\n";
$stmt = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE (table_name LIKE '%local%' OR table_name LIKE '%periodo%')
      AND table_name LIKE '%11%'
    ORDER BY table_schema, table_name
");

$related = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($related as $r) {
    echo "{$r['table_schema']}.{$r['table_name']}\n";
}
