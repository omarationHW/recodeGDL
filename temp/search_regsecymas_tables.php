<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "=== BUSCANDO TABLAS ADMINISTRATIVAS ===\n\n";

$stmt = $pdo->query("
    SELECT tablename, schemaname
    FROM pg_tables
    WHERE (
        tablename LIKE '%secretaria%'
        OR tablename LIKE '%admin%'
        OR tablename LIKE '%ejecutor%'
        OR tablename LIKE '%policia%'
    )
    AND schemaname IN ('public', 'comun', 'db_ingresos')
    ORDER BY schemaname, tablename
    LIMIT 20
");

$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($tables as $t) {
    echo "{$t['schemaname']}.{$t['tablename']}\n";
}

// Verificar tabla de ejecutores
echo "\n\n=== VERIFICANDO TABLA EJECUTORES ===\n\n";
$stmt2 = $pdo->query("SELECT COUNT(*) FROM comun.ejecutor");
echo "Total ejecutores: " . $stmt2->fetchColumn() . "\n";

$stmt3 = $pdo->query("
    SELECT
        cve_ejecutor,
        nombre,
        paterno,
        materno,
        badge
    FROM comun.ejecutor
    ORDER BY cve_ejecutor
    LIMIT 10
");

$ejecutores = $stmt3->fetchAll(PDO::FETCH_ASSOC);
echo "\nEjemplos:\n";
foreach ($ejecutores as $e) {
    $nombreCompleto = trim("{$e['nombre']} {$e['paterno']} {$e['materno']}");
    echo "  ID: {$e['cve_ejecutor']} | Nombre: $nombreCompleto | Badge: {$e['badge']}\n";
}
?>
