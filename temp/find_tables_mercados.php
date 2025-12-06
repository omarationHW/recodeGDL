<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Buscando todas las tablas ta_11_* ===\n\n";

$stmt = $pdo->query("
    SELECT table_schema, table_name,
           (SELECT COUNT(*) FROM information_schema.columns c WHERE c.table_schema = t.table_schema AND c.table_name = t.table_name) as num_columns
    FROM information_schema.tables t
    WHERE table_name LIKE 'ta_11_%'
    ORDER BY table_schema, table_name
");

$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($tables as $table) {
    echo "{$table['table_schema']}.{$table['table_name']} ({$table['num_columns']} columnas)\n";
}

echo "\n=== Buscando tablas con columnas relacionadas a requerimientos ===\n\n";

// Buscar tablas que tengan columnas tipo 'folio', 'diligencia', 'vigencia'
$stmt = $pdo->query("
    SELECT DISTINCT table_schema, table_name
    FROM information_schema.columns
    WHERE column_name IN ('folio', 'diligencia', 'vigencia', 'importe_multa', 'importe_gastos')
      AND table_name LIKE 'ta_%'
    ORDER BY table_schema, table_name
");

$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($tables as $t) {
    echo "{$t['table_schema']}.{$t['table_name']}\n";

    // Mostrar columnas
    $stmt2 = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = '{$t['table_schema']}'
          AND table_name = '{$t['table_name']}'
        ORDER BY ordinal_position
    ");
    $cols = $stmt2->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols as $col) {
        echo "  - {$col['column_name']} ({$col['data_type']})\n";
    }

    // Contar registros
    try {
        $stmt3 = $pdo->query("SELECT COUNT(*) as total FROM {$t['table_schema']}.{$t['table_name']}");
        $count = $stmt3->fetch(PDO::FETCH_ASSOC);
        echo "  Total registros: {$count['total']}\n";
    } catch (Exception $e) {
        echo "  Error: {$e->getMessage()}\n";
    }

    echo "\n";
}
