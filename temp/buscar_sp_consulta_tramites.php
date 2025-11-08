<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "Buscando SP 'consulta_tramites_list':\n\n";

$stmt = $pdo->query("
    SELECT n.nspname, p.proname, pg_get_functiondef(p.oid) as definition
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname = 'consulta_tramites_list'
");

$sp = $stmt->fetch(PDO::FETCH_ASSOC);

if ($sp) {
    echo "Encontrado: {$sp['nspname']}.{$sp['proname']}\n\n";
    echo "Definición:\n";
    echo $sp['definition'];
} else {
    echo "No se encontró el SP\n\n";

    // Buscar SPs similares
    echo "SPs similares:\n";
    $stmt = $pdo->query("
        SELECT n.nspname, p.proname
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname LIKE '%consulta%tramite%'
        OR p.proname LIKE '%tramite%list%'
        ORDER BY p.proname
        LIMIT 10
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  - {$row['nspname']}.{$row['proname']}\n";
    }
}
