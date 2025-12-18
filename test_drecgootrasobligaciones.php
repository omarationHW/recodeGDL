<?php
// Script para probar el stored procedure recaudadora_drecgootrasobligaciones actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_drecgootrasobligaciones...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_drecgootrasobligaciones.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar pagos de ejemplo
    echo "2. Buscando pagos diversos de ejemplo...\n";
    $stmt = $pdo->query("
        SELECT cvepago, concepto, referencia, axoini
        FROM public.pago_diversos
        WHERE cvepago IS NOT NULL
        ORDER BY cvepago DESC
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Pagos encontrados:\n";
    foreach ($ejemplos as $ej) {
        $concepto = substr($ej['concepto'], 0, 40);
        echo "     - Pago: {$ej['cvepago']}, Concepto: $concepto..., Año: {$ej['axoini']}\n";
    }

    if (count($ejemplos) > 0) {
        $pagoEjemplo = $ejemplos[0]['cvepago'];

        // 3. Probar sin filtro (listar todos)
        echo "\n\n3. Probando sin filtro (primeros 10 registros)...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgootrasobligaciones('') LIMIT 10");
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " obligación(es) encontrada(s)\n";

        if (count($rows) > 0) {
            echo "\n   Primeras 3 obligaciones:\n";
            foreach (array_slice($rows, 0, 3) as $i => $r) {
                echo "   " . ($i + 1) . ". Clave: {$r['clave_cuenta']}, Tipo: {$r['tipo_obligacion']}, ";
                echo "Concepto: " . substr($r['concepto'], 0, 40) . "...\n";
            }
        }

        // 4. Probar con clave específica
        echo "\n\n4. Probando con clave específica '$pagoEjemplo'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgootrasobligaciones(?)");
        $stmt->execute([$pagoEjemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " obligación(es) encontrada(s)\n";

        if (count($rows) > 0) {
            echo "\n   Detalles de la obligación:\n";
            $r = $rows[0];
            echo "      Clave Cuenta: {$r['clave_cuenta']}\n";
            echo "      Tipo: {$r['tipo_obligacion']}\n";
            echo "      Concepto: {$r['concepto']}\n";
            echo "      Importe: \$" . number_format($r['importe'], 2) . "\n";
            echo "      Ejercicio: {$r['ejercicio']}\n";
            echo "      Fecha Vencimiento: {$r['fecha_vencimiento']}\n";
            echo "      Estatus: {$r['estatus']}\n";
            echo "      Referencia: {$r['referencia']}\n";
            echo "      Observaciones: " . substr($r['observaciones'], 0, 80) . "...\n";
        }

        // 5. Probar con otra clave
        if (count($ejemplos) > 1) {
            $pagoEjemplo2 = $ejemplos[1]['cvepago'];

            echo "\n\n5. Probando con segunda clave '$pagoEjemplo2'...\n";
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgootrasobligaciones(?)");
            $stmt->execute([$pagoEjemplo2]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   Resultados: " . count($rows) . " obligación(es)\n";
            if (count($rows) > 0) {
                $r = $rows[0];
                echo "   - Concepto: " . substr($r['concepto'], 0, 50) . "\n";
                echo "   - Ejercicio: {$r['ejercicio']}, Estatus: {$r['estatus']}\n";
            }
        }

        // 6. Buscar por referencia
        echo "\n\n6. Buscando por referencia...\n";
        $stmt = $pdo->query("
            SELECT referencia
            FROM public.pago_diversos
            WHERE referencia IS NOT NULL AND referencia > 0
            LIMIT 1
        ");
        $refTest = $stmt->fetchColumn();

        if ($refTest) {
            echo "   Probando con referencia: $refTest\n";
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgootrasobligaciones(?)");
            $stmt->execute([$refTest]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   Resultados: " . count($rows) . " obligación(es) con esta referencia\n";
            if (count($rows) > 0) {
                $r = $rows[0];
                echo "   - Clave: {$r['clave_cuenta']}, Concepto: " . substr($r['concepto'], 0, 40) . "\n";
            }
        }

        // 7. Estadísticas
        echo "\n\n7. Estadísticas generales...\n";
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.pago_diversos");
        $total = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "   Total de pagos diversos en el sistema: " . number_format($total['total']) . "\n";

        // Ver distribución por años
        $stmt = $pdo->query("
            SELECT axoini, COUNT(*) as cantidad
            FROM public.pago_diversos
            WHERE axoini IS NOT NULL
            GROUP BY axoini
            ORDER BY axoini DESC
            LIMIT 5
        ");
        $anios = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Distribución por años (últimos 5):\n";
        foreach ($anios as $a) {
            echo "     - Año {$a['axoini']}: " . number_format($a['cantidad']) . " pagos\n";
        }
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
