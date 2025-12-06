<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
echo "Verificando SP sp_get_mercados_by_recaudadora:\n\n";
$check = $pdo->query("SELECT routine_name FROM information_schema.routines WHERE routine_name = 'sp_get_mercados_by_recaudadora' AND routine_schema = 'public'")->fetch();
if ($check) {
    echo "✅ SP existe\n\n";
    echo "Probando con recaudadora 1...\n";
    $stmt = $pdo->prepare('SELECT * FROM sp_get_mercados_by_recaudadora(?)');
    $stmt->execute([1]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Mercados encontrados: " . count($results) . "\n";
    foreach ($results as $i => $r) {
        if ($i < 3) {
            echo "  - Mercado {$r['num_mercado_nvo']}: {$r['descripcion']}\n";
        }
    }
    echo "\n✅ SP FUNCIONANDO CORRECTAMENTE\n";
} else {
    echo "❌ SP no existe\n";
}
?>
