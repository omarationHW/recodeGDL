<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Buscando SPs de requerimientos/locales ===\n\n";

$stmt = $pdo->query("
    SELECT routine_schema, routine_name,
           pg_get_function_arguments(p.oid) as arguments
    FROM information_schema.routines r
    JOIN pg_proc p ON p.proname = r.routine_name
    WHERE routine_name LIKE '%requerimiento%'
       OR routine_name LIKE '%locales_by%'
    ORDER BY routine_name
");

$sps = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($sps as $sp) {
    echo "{$sp['routine_schema']}.{$sp['routine_name']}({$sp['arguments']})\n";
}

echo "\n=== Verificando tabla ta_15_periodos ===\n";
$stmt = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name = 'ta_15_periodos'
");
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
if (count($tables) > 0) {
    foreach ($tables as $t) {
        echo "✓ Encontrada: {$t['table_schema']}.{$t['table_name']}\n";

        // Ver estructura
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
    }
} else {
    echo "✗ NO existe la tabla ta_15_periodos\n";
}

echo "\n=== Test directo del SP ===\n";
try {
    $stmt = $pdo->prepare("SELECT * FROM public.sp_get_locales_by_mercado(?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([1, 2, 1, 'SS', 1, null, null]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "✓ SP funciona! Resultados: " . count($result) . "\n";
} catch (Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
}
