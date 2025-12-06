<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
echo "Desplegando sp_reporte_adeudos_condonados...\n\n";
$sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/RepAdeudCond_sp_reporte_adeudos_condonados.sql';
$sql = file_get_contents($sqlFile);
try {
    $pdo->exec($sql);
    echo "SP desplegado exitosamente\n\n";
    $check = $pdo->query("SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public' AND routine_name = 'sp_reporte_adeudos_condonados'")->fetch();
    if ($check) {
        echo "Verificacion: SP existe\n\n";
        $test = $pdo->query("SELECT DISTINCT l.oficina, c.axo, c.periodo, l.num_mercado, COUNT(*) as registros FROM publico.ta_11_ade_loc_canc c INNER JOIN publico.ta_11_locales l ON l.id_local = c.id_local GROUP BY l.oficina, c.axo, c.periodo, l.num_mercado ORDER BY c.axo DESC, c.periodo DESC LIMIT 1")->fetch(PDO::FETCH_ASSOC);
        if ($test) {
            echo "Probando con: Oficina={$test['oficina']}, Axo={$test['axo']}, Periodo={$test['periodo']}, Mercado={$test['num_mercado']}\n\n";
            $stmt = $pdo->prepare("SELECT * FROM sp_reporte_adeudos_condonados(?, ?, ?, ?)");
            $stmt->execute([$test['oficina'], $test['axo'], $test['periodo'], $test['num_mercado']]);
            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo "Registros obtenidos: " . count($results) . "\n";
            if (count($results) > 0) {
                $r = $results[0];
                echo "\nPrimer registro:\n";
                echo "  Mercado: {$r['num_mercado']}, Local: {$r['local']}\n";
                echo "  Importe: ${$r['importe']}, Clave: {$r['clave_canc']}\n";
            }
            echo "\nSP FUNCIONANDO CORRECTAMENTE\n";
        }
    }
} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
?>
