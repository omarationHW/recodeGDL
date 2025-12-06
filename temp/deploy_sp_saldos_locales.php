<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
echo "Desplegando sp_rpt_saldos_locales...\n\n";
$sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/RptSaldosLocales_sp_rpt_saldos_locales.sql';
$sql = file_get_contents($sqlFile);
try {
    $pdo->exec($sql);
    echo "SP desplegado exitosamente\n\n";
    $check = $pdo->query("SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public' AND routine_name = 'sp_rpt_saldos_locales'")->fetch();
    if ($check) {
        echo "Verificacion: SP existe\n\n";
        $test = $pdo->query("SELECT DISTINCT m.oficina, l.num_mercado FROM publico.ta_11_locales l INNER JOIN publico.ta_11_mercados m ON m.num_mercado_nvo = l.num_mercado LIMIT 1")->fetch(PDO::FETCH_ASSOC);
        if ($test) {
            echo "Probando con: Oficina={$test['oficina']}, Mercado={$test['num_mercado']}\n\n";
            $stmt = $pdo->prepare("SELECT * FROM sp_rpt_saldos_locales(?, ?, NULL)");
            $stmt->execute([$test['oficina'], $test['num_mercado']]);
            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo "Registros obtenidos: " . count($results) . "\n";
            if (count($results) > 0) {
                $r = $results[0];
                echo "\nPrimer local:\n";
                echo "  Mercado: {$r['num_mercado']}, Seccion: {$r['seccion']}, Local: {$r['local']}\n";
                echo "  Nombre: {$r['nombre']}\n";
                echo "  Total adeudos: ${$r['total_adeudos']}\n";
                echo "  Total pagos: ${$r['total_pagos']}\n";
                echo "  Saldo: ${$r['saldo']}\n";
                echo "  Periodos adeudo: {$r['periodos_adeudo']}\n";
            }
            echo "\nSP FUNCIONANDO CORRECTAMENTE\n";
        }
    }
} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
?>
