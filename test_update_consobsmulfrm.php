<?php
// Script para probar el stored procedure recaudadora_consobsmulfrm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_consobsmulfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_consobsmulfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar con query vacío (todas las observaciones)
    echo "2. Probando con query vacío (primeras 10 observaciones)...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consobsmulfrm('') LIMIT 10");
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " observaciones\n";

    if (count($rows) > 0) {
        echo "\n   Primeras 3 observaciones:\n";
        foreach (array_slice($rows, 0, 3) as $i => $r) {
            echo "   ---\n";
            echo "   Observación " . ($i + 1) . ":\n";
            echo "     ID: " . $r["id_observacion"] . "\n";
            echo "     Folio: " . $r["folio_multa"] . "\n";
            echo "     Tipo: " . $r["tipo_observacion"] . "\n";
            echo "     Observación: " . substr($r["observacion"], 0, 50) . "...\n";
            echo "     Fecha: " . $r["fecha_observacion"] . "\n";
            echo "     Usuario: " . $r["usuario"] . "\n";
            echo "     Estado: " . $r["estado"] . "\n";
            echo "     Días desde observación: " . $r["dias_desde_observacion"] . "\n";
        }
    }

    // 3. Probar búsqueda por folio específico
    echo "\n\n3. Probando con folio '120431'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consobsmulfrm(?)");
    $stmt->execute(['120431']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " observaciones encontradas\n";

    if (count($rows) > 0) {
        $r = $rows[0];
        echo "\n   Primera observación:\n";
        echo "     Folio: {$r['folio_multa']}\n";
        echo "     Observación: " . substr($r['observacion'], 0, 80) . "\n";
        echo "     Fecha: {$r['fecha_observacion']}\n";
        echo "     Usuario: {$r['usuario']}\n";
    }

    // 4. Probar búsqueda por texto
    echo "\n\n4. Probando búsqueda por texto 'GRABAN'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consobsmulfrm(?)");
    $stmt->execute(['GRABAN']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " observaciones encontradas\n";

    if (count($rows) > 0) {
        echo "\n   Primeras 2 coincidencias:\n";
        foreach (array_slice($rows, 0, 2) as $r) {
            echo "     - Folio: {$r['folio_multa']}, Fecha: {$r['fecha_observacion']}\n";
        }
    }

    // 5. Probar búsqueda por usuario
    echo "\n\n5. Probando búsqueda por usuario 'proceso'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consobsmulfrm(?) LIMIT 5");
    $stmt->execute(['proceso']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " observaciones encontradas\n";

    // 6. Estadísticas
    echo "\n\n6. Estadísticas de observaciones...\n";
    $stmt = $pdo->query("
        SELECT COUNT(*) as total,
               MIN(fecha_movimiento) as fecha_mas_antigua,
               MAX(fecha_movimiento) as fecha_mas_reciente
        FROM publico.reqmulta_obs_hist
    ");
    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total de observaciones: {$stats['total']}\n";
    echo "   Fecha más antigua: {$stats['fecha_mas_antigua']}\n";
    echo "   Fecha más reciente: {$stats['fecha_mas_reciente']}\n";

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
