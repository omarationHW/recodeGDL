<?php
// Buscar tablas de requerimientos prediales para ModifMasiva.vue

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS DE REQUERIMIENTOS PREDIALES ===\n\n";

    // Buscar todas las tablas con "predial" y "req"
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE (tablename ILIKE '%req%' AND tablename ILIKE '%predial%')
        AND schemaname IN ('public', 'publico')
        ORDER BY schemaname, tablename
    ");

    $tablas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tablas as $tabla) {
        echo "Tabla: {$tabla['schemaname']}.{$tabla['tablename']}\n";

        // Contar registros
        $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$tabla['schemaname']}.{$tabla['tablename']}");
        $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
        echo "  Registros: " . number_format($count['total']) . "\n";

        // Ver si tiene los campos necesarios
        $cols_stmt = $pdo->query("
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = '{$tabla['schemaname']}'
            AND table_name = '{$tabla['tablename']}'
            AND (column_name ILIKE '%recaud%'
                 OR column_name ILIKE '%folio%'
                 OR column_name ILIKE '%vigencia%'
                 OR column_name ILIKE '%estado%'
                 OR column_name ILIKE '%cuenta%')
            ORDER BY ordinal_position
        ");

        $cols = $cols_stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($cols) > 0) {
            echo "  Campos relevantes: ";
            $col_names = array_map(function($c) { return $c['column_name']; }, $cols);
            echo implode(', ', $col_names) . "\n";
        }

        echo "\n" . str_repeat("-", 60) . "\n\n";
    }

    // Ver reqbfpredial en detalle
    echo "\n=== DETALLE DE public.reqbfpredial ===\n\n";

    $cols = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'reqbfpredial'
        ORDER BY ordinal_position
    ");

    echo "Columnas:\n";
    foreach ($cols->fetchAll(PDO::FETCH_ASSOC) as $col) {
        echo "  - {$col['column_name']} ({$col['data_type']})\n";
    }

    // Ver ejemplos
    echo "\n\nEjemplos de registros:\n";
    $stmt = $pdo->query("
        SELECT cvecuenta, recaud, vigencia, fecemi, total
        FROM public.reqbfpredial
        LIMIT 5
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $i => $row) {
        echo "  " . ($i + 1) . ". Cuenta: {$row['cvecuenta']}, Recaud: {$row['recaud']}, Vigencia: {$row['vigencia']}, Total: {$row['total']}\n";
    }

    echo "\n✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
