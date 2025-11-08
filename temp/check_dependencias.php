<?php
$db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== BUSCAR TABLAS CON 'DEPENDENCIA' O 'INSPECCION' ===\n\n";

// Buscar tablas
$stmt = $db->query("
    SELECT schemaname, tablename
    FROM pg_tables
    WHERE tablename LIKE '%dependencia%'
       OR tablename LIKE '%inspeccion%'
       OR tablename LIKE '%tramite%'
    ORDER BY schemaname, tablename
");

echo "📊 TABLAS ENCONTRADAS:\n";
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "{$row['schemaname']}.{$row['tablename']}\n";

    // Ver estructura
    $table = "{$row['schemaname']}.{$row['tablename']}";
    $stmt2 = $db->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = '{$row['schemaname']}'
          AND table_name = '{$row['tablename']}'
        ORDER BY ordinal_position
    ");
    $cols = $stmt2->fetchAll(PDO::FETCH_ASSOC);
    foreach($cols as $col) {
        echo "  - {$col['column_name']}: {$col['data_type']}\n";
    }

    // Contar
    try {
        $stmt3 = $db->query("SELECT COUNT(*) as total FROM $table");
        $count = $stmt3->fetch(PDO::FETCH_ASSOC)['total'];
        echo "  Total: $count registros\n\n";
    } catch (Exception $e) {
        echo "  Error contando: {$e->getMessage()}\n\n";
    }
}

echo "\n=== BUSCAR SPs ===\n\n";

// Buscar SPs en public
$stmt = $db->query("
    SELECT proname
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND (proname LIKE '%dependencia%' OR proname LIKE '%inspeccion%')
    ORDER BY proname
");
echo "📦 SPs en 'public':\n";
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "public.{$row['proname']}\n";
}

// Buscar SPs en comun
echo "\n📦 SPs en 'comun':\n";
$stmt = $db->query("
    SELECT proname
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'comun'
      AND (proname LIKE '%dependencia%' OR proname LIKE '%inspeccion%')
    ORDER BY proname
");
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "comun.{$row['proname']}\n";
}
