<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "Verificando SPs de bloqueoDomicilios en servidor 192.168.6.146:\n\n";

$stmt = $pdo->query("
    SELECT n.nspname as schema, p.proname as nombre
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname LIKE 'sp_bloqueodomicilios%'
    ORDER BY n.nspname, p.proname
");

$procedures = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (count($procedures) > 0) {
    echo "SPs encontrados:\n";
    foreach ($procedures as $proc) {
        echo "  {$proc['schema']}.{$proc['nombre']}\n";
    }
} else {
    echo "⚠ NO se encontraron SPs de bloqueoDomicilios\n";
    echo "\nSe requiere ejecutar: temp/DEPLOY_BLOQUEODOMICILIOS_SPS.sql\n";
}
