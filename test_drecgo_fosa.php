<?php
// Script para probar el stored procedure recaudadora_drecgo_fosa actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_drecgo_fosa...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_drecgo_fosa.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar fosas de ejemplo
    echo "2. Buscando fosas de ejemplo...\n";
    $stmt = $pdo->query("
        SELECT control_rcm, cementerio, nombre, fosa, seccion, linea
        FROM publico.ta_13_datosrcm
        WHERE vigencia = 'V'
        ORDER BY control_rcm
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Fosas encontradas:\n";
    foreach ($ejemplos as $ej) {
        echo "     - Control: {$ej['control_rcm']}, Cementerio: {$ej['cementerio']}, ";
        echo "Fosa: {$ej['fosa']}, Titular: " . substr($ej['nombre'], 0, 30) . "\n";
    }

    if (count($ejemplos) > 0) {
        $controlEjemplo = $ejemplos[0]['control_rcm'];

        // 3. Probar sin filtro (listar todas las fosas)
        echo "\n\n3. Probando sin filtro (primeras 10 fosas)...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgo_fosa(0)");
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " fosa(s) encontrada(s)\n";

        if (count($rows) > 0) {
            echo "\n   Primeras 3 fosas:\n";
            foreach (array_slice($rows, 0, 3) as $i => $r) {
                echo "   " . ($i + 1) . ". Control: {$r['id_control']}, Cementerio: {$r['cementerio']}, ";
                echo "Fosa: {$r['fosa']}, Titular: {$r['nombre_titular']}\n";
            }
        }

        // 4. Probar con folio específico
        echo "\n\n4. Probando con folio específico '$controlEjemplo'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgo_fosa(?)");
        $stmt->execute([$controlEjemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " fosa(s) encontrada(s)\n";

        if (count($rows) > 0) {
            echo "\n   Detalles de la fosa:\n";
            $r = $rows[0];
            echo "      ID Control: {$r['id_control']}\n";
            echo "      Cementerio: {$r['cementerio']}\n";
            echo "      Clase: {$r['clase']}\n";
            echo "      Sección: {$r['seccion']}\n";
            echo "      Línea: {$r['linea']}\n";
            echo "      Fosa: {$r['fosa']}\n";
            echo "      Titular: {$r['nombre_titular']}\n";
            echo "      Año Mínimo: {$r['anio_minimo']}\n";
            echo "      Año Máximo: {$r['anio_maximo']}\n";
        }

        // 5. Probar con otros controles
        echo "\n\n5. Probando con otros folios...\n";
        for ($i = 1; $i < min(3, count($ejemplos)); $i++) {
            $controlId = $ejemplos[$i]['control_rcm'];
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgo_fosa(?)");
            $stmt->execute([$controlId]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($rows) > 0) {
                $r = $rows[0];
                echo "   Control $controlId: Cementerio {$r['cementerio']}, ";
                echo "Fosa {$r['fosa']}, Titular: " . substr($r['nombre_titular'], 0, 30) . "\n";
            }
        }

        // 6. Estadísticas por cementerio
        echo "\n\n6. Estadísticas por cementerio...\n";
        $stmt = $pdo->query("
            SELECT f.cementerio, c.nombre, COUNT(*) as total_fosas
            FROM publico.ta_13_datosrcm f
            LEFT JOIN publico.tc_13_cementerios c ON f.cementerio = c.cementerio
            WHERE f.vigencia = 'V'
            GROUP BY f.cementerio, c.nombre
            ORDER BY total_fosas DESC
        ");
        $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Fosas vigentes por cementerio:\n";
        foreach ($stats as $s) {
            echo "     - {$s['cementerio']} ({$s['nombre']}): " . number_format($s['total_fosas']) . " fosas\n";
        }

        // Total general
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM publico.ta_13_datosrcm WHERE vigencia = 'V'");
        $totalGeneral = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "\n   Total general: " . number_format($totalGeneral['total']) . " fosas vigentes\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
