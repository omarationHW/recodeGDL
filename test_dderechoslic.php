<?php
// Script para probar el stored procedure recaudadora_dderechoslic actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_dderechoslic...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_dderechoslic.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar licencias de ejemplo
    echo "2. Buscando licencias de ejemplo...\n";
    $stmt = $pdo->query("
        SELECT DISTINCT id_licencia, axo
        FROM public.detreqlic
        WHERE id_licencia IS NOT NULL
        ORDER BY axo DESC, id_licencia DESC
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Licencias encontradas:\n";
    foreach ($ejemplos as $ej) {
        echo "     - Licencia: {$ej['id_licencia']}, Año: {$ej['axo']}\n";
    }

    if (count($ejemplos) > 0) {
        $licenciaEjemplo = $ejemplos[0]['id_licencia'];

        // 3. Probar sin filtro (listar todos los derechos)
        echo "\n\n3. Probando sin filtro (primeros 10 derechos)...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_dderechoslic(0) LIMIT 10");
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " derecho(s) encontrado(s)\n";

        if (count($rows) > 0) {
            echo "\n   Primeros 3 derechos:\n";
            foreach (array_slice($rows, 0, 3) as $i => $r) {
                echo "   " . ($i + 1) . ". Licencia: {$r['licencia']}, Concepto: {$r['concepto']}, ";
                echo "Importe: $" . number_format($r['importe'], 2) . ", ";
                echo "Ejercicio: {$r['ejercicio']}\n";
            }
        }

        // 4. Probar con licencia específica
        echo "\n\n4. Probando con licencia específica '$licenciaEjemplo'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_dderechoslic(?)");
        $stmt->execute([$licenciaEjemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " derecho(s) encontrado(s)\n";

        if (count($rows) > 0) {
            echo "\n   Derechos de la licencia $licenciaEjemplo:\n";
            $totalGeneral = 0;
            foreach ($rows as $i => $r) {
                echo "   " . ($i + 1) . ". {$r['concepto']}:\n";
                echo "      Descripción: {$r['descripcion']}\n";
                echo "      Importe: $" . number_format($r['importe'], 2) . "\n";
                echo "      Recargos: $" . number_format($r['recargos'], 2) . "\n";
                echo "      Total: $" . number_format($r['total'], 2) . "\n";
                echo "      Ejercicio: {$r['ejercicio']}\n";
                echo "      Estatus: {$r['estatus']}\n";
                $totalGeneral += $r['total'];
            }
            echo "\n   TOTAL GENERAL: $" . number_format($totalGeneral, 2) . "\n";
        }

        // 5. Probar con otra licencia
        if (count($ejemplos) > 1) {
            $licenciaEjemplo2 = $ejemplos[1]['id_licencia'];

            echo "\n\n5. Probando con segunda licencia '$licenciaEjemplo2'...\n";
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_dderechoslic(?)");
            $stmt->execute([$licenciaEjemplo2]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   Resultados: " . count($rows) . " derecho(s) encontrado(s)\n";

            if (count($rows) > 0) {
                echo "   Conceptos:\n";
                foreach ($rows as $r) {
                    echo "     - {$r['concepto']}: $" . number_format($r['importe'], 2) . "\n";
                }
            }
        }

        // 6. Contar total de registros
        echo "\n\n6. Contando total de derechos en el sistema...\n";
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM publico.recaudadora_dderechoslic(0)");
        $total = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "   Total de derechos en el sistema: " . number_format($total['total']) . "\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
