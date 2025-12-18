<?php
// Script para probar el stored procedure recaudadora_listanotificacionesfrm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_listanotificacionesfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_listanotificacionesfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar con parámetros reales
    echo "2. Probando con recaud=3, año=2025, folios 1-150000, tipo R...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listanotificacionesfrm(?, ?, ?, ?, ?::VARCHAR, ?::VARCHAR)");
    $stmt->execute([3, 2025, 1, 150000, 'R', 'lote']);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Notificaciones encontradas: " . count($results) . "\n\n";

    if (count($results) > 0) {
        echo "   === PRIMERAS 3 NOTIFICACIONES ===\n";
        for ($i = 0; $i < min(3, count($results)); $i++) {
            $not = $results[$i];
            echo "\n   NOTIFICACIÓN " . ($i + 1) . ":\n";
            echo "   Abrevia: {$not['abrevia']}\n";
            echo "   Año Acta: {$not['axo_acta']}\n";
            echo "   Num Acta: {$not['num_acta']}\n";
            echo "   Num Lote: {$not['num_lote']}\n";
            echo "   Folio Req: {$not['folioreq']}\n";
            echo "   Contribuyente: " . substr($not['contribuyente'], 0, 40) . "\n";
            echo "   Total: $" . number_format($not['total'], 2) . "\n";
        }
    }

    echo "\n\n✅ Prueba completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
