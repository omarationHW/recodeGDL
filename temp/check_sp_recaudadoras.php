<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
echo "Verificando SP sp_get_recaudadoras en mercados:\n\n";
$check = $pdo->query("SELECT routine_name, routine_schema FROM information_schema.routines WHERE routine_name = 'sp_get_recaudadoras' AND routine_schema = 'public'")->fetch(PDO::FETCH_ASSOC);
if ($check) {
    echo "✅ SP existe: {$check['routine_schema']}.{$check['routine_name']}\n\n";
    echo "Probando SP...\n";
    $stmt = $pdo->query('SELECT * FROM sp_get_recaudadoras() LIMIT 5');
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Recaudadoras: " . count($results) . "\n";
    foreach ($results as $r) {
        echo "  - ID: {$r['id_rec']}, Nombre: {$r['recaudadora']}\n";
    }
} else {
    echo "❌ SP no existe en la base de datos mercados\n";
}
?>
