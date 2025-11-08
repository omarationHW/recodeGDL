<?php
$db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== SPs RELACIONADOS CON DEPENDENCIAS/INSPECCIONES ===\n\n";

// SPs en public
echo "📦 SPs en 'public':\n";
$stmt = $db->query("
    SELECT proname
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND (proname LIKE '%dependencia%' OR proname LIKE '%inspeccion%')
    ORDER BY proname
");
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  - public.{$row['proname']}\n";
}

// SPs en comun
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
    echo "  - comun.{$row['proname']}\n";
}

echo "\n";

// Información de tablas relevantes
echo "=== TABLAS RELEVANTES ===\n\n";

// comun.c_dependencias
echo "📊 comun.c_dependencias (90 registros):\n";
$stmt = $db->query("SELECT * FROM comun.c_dependencias LIMIT 3");
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  {$row['id_dependencia']} - " . trim($row['descripcion']) . " [{$row['tipo']}]\n";
}

// comun.ta_dependencias
echo "\n📊 comun.ta_dependencias (30 registros):\n";
$stmt = $db->query("SELECT * FROM comun.ta_dependencias LIMIT 3");
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  {$row['id_dependencia']} - {$row['dependencia']} [Estado: {$row['estado']}]\n";
}

// Verificar si existe tabla de inspecciones
echo "\n📋 Buscando tablas de inspecciones/visitas:\n";
$stmt = $db->query("
    SELECT schemaname, tablename
    FROM pg_tables
    WHERE (tablename LIKE '%inspeccion%' OR tablename LIKE '%visita%')
      AND (schemaname = 'public' OR schemaname = 'comun')
");
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  {$row['schemaname']}.{$row['tablename']}\n";
}
