<?php
// Script para probar el stored procedure recaudadora_descmultampalfrm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_descmultampalfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_descmultampalfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar multas con descuentos de ejemplo
    echo "2. Buscando multas con descuentos de ejemplo...\n";
    $stmt = $pdo->query("
        SELECT DISTINCT id_multa, tipo_descto, valor, estado
        FROM public.descmultampal
        WHERE id_multa IS NOT NULL
        ORDER BY id_multa DESC
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Multas con descuentos encontradas:\n";
    foreach ($ejemplos as $ej) {
        $tipoDesc = $ej['tipo_descto'] == 'P' ? 'Porcentaje' : 'Importe';
        echo "     - Multa: {$ej['id_multa']}, Tipo: $tipoDesc, Valor: \${$ej['valor']}, Estado: {$ej['estado']}\n";
    }

    if (count($ejemplos) > 0) {
        $multaEjemplo = $ejemplos[0]['id_multa'];

        // 3. Probar con multa específica
        echo "\n\n3. Probando con multa específica '$multaEjemplo'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_descmultampalfrm(?)");
        $stmt->execute([$multaEjemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " descuento(s) encontrado(s)\n";

        if (count($rows) > 0) {
            echo "\n   Descuentos de la multa $multaEjemplo:\n";
            foreach ($rows as $i => $r) {
                echo "\n   " . ($i + 1) . ". Descuento:\n";
                echo "      ID Multa: {$r['id_multa']}\n";
                echo "      Tipo: {$r['tipo_descto']} (" . ($r['tipo_descto'] == 'P' ? 'Porcentaje' : 'Importe') . ")\n";
                echo "      Valor: $" . number_format($r['valor_descuento'], 2) . "\n";
                echo "      Cve Pago: {$r['cvepago']}\n";
                echo "      Fecha: {$r['fecha_descuento']}\n";
                echo "      Capturista: {$r['capturista']}\n";
                echo "      Autoriza: {$r['autoriza']}\n";
                echo "      Estado: {$r['estado_desc']}\n";
                echo "      Folio: {$r['folio']}\n";
                if ($r['observacion']) {
                    echo "      Observación: " . substr($r['observacion'], 0, 60) . "\n";
                }
            }
        }

        // 4. Probar con más multas
        echo "\n\n4. Probando con otras multas...\n";
        for ($i = 1; $i < min(3, count($ejemplos)); $i++) {
            $multaId = $ejemplos[$i]['id_multa'];
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_descmultampalfrm(?)");
            $stmt->execute([$multaId]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   Multa $multaId: " . count($rows) . " descuento(s)\n";
            if (count($rows) > 0) {
                $r = $rows[0];
                echo "     - Tipo: {$r['tipo_descto']}, Valor: \$" . number_format($r['valor_descuento'], 2);
                echo ", Estado: {$r['estado_desc']}\n";
            }
        }

        // 5. Buscar una multa con observaciones
        echo "\n\n5. Buscando multa con observaciones...\n";
        $stmt = $pdo->query("
            SELECT id_multa
            FROM public.descmultampal
            WHERE observacion IS NOT NULL AND observacion != ''
            LIMIT 1
        ");
        $multaConObs = $stmt->fetchColumn();

        if ($multaConObs) {
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_descmultampalfrm(?)");
            $stmt->execute([$multaConObs]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($rows) > 0) {
                echo "   Multa $multaConObs con observaciones:\n";
                $r = $rows[0];
                echo "     Tipo: {$r['tipo_descto']}, Valor: \$" . number_format($r['valor_descuento'], 2) . "\n";
                echo "     Observación: {$r['observacion']}\n";
            }
        }

        // 6. Estadísticas
        echo "\n\n6. Estadísticas generales...\n";
        $stmt = $pdo->query("
            SELECT
                COUNT(*) as total,
                COUNT(DISTINCT id_multa) as multas_distintas,
                tipo_descto,
                COUNT(*) as cantidad
            FROM public.descmultampal
            GROUP BY tipo_descto
        ");
        $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $stmt = $pdo->query("SELECT COUNT(DISTINCT id_multa) as total FROM public.descmultampal");
        $totalMultas = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Multas con descuentos: " . number_format($totalMultas['total']) . "\n";
        echo "   Por tipo de descuento:\n";
        foreach ($stats as $s) {
            $tipo = $s['tipo_descto'] == 'P' ? 'Porcentaje' : 'Importe';
            echo "     - $tipo: " . number_format($s['cantidad']) . " descuentos\n";
        }
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
