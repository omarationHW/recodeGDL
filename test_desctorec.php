<?php
// Script para probar el stored procedure recaudadora_desctorec actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_desctorec...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_desctorec.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar cuentas con descuentos de recargos de ejemplo
    echo "2. Buscando cuentas con descuentos de recargos de ejemplo...\n";
    $stmt = $pdo->query("
        SELECT DISTINCT cvecuenta, vigencia, porcentaje, axoini, bimini, fecalta
        FROM public.descrec
        WHERE cvecuenta IS NOT NULL
        ORDER BY fecalta DESC
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Cuentas con descuentos de recargos encontradas:\n";
    foreach ($ejemplos as $ej) {
        $statusDesc = $ej['vigencia'] == 'V' ? 'Vigente' : ($ej['vigencia'] == 'C' ? 'Cancelado' : ($ej['vigencia'] == 'P' ? 'Pendiente' : 'Otro'));
        echo "     - Cuenta: {$ej['cvecuenta']}, {$ej['porcentaje']}%, Status: $statusDesc, Periodo: {$ej['axoini']}-{$ej['bimini']}\n";
    }

    if (count($ejemplos) > 0) {
        $cuentaEjemplo = $ejemplos[0]['cvecuenta'];

        // 3. Probar con cuenta específica
        echo "\n\n3. Probando con cuenta específica '$cuentaEjemplo'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_desctorec(?)");
        $stmt->execute([$cuentaEjemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " descuento(s) de recargos encontrado(s)\n";

        if (count($rows) > 0) {
            echo "\n   Descuentos de recargos de la cuenta $cuentaEjemplo:\n";
            foreach ($rows as $i => $r) {
                echo "\n   " . ($i + 1) . ". Descuento de Recargos:\n";
                echo "      Cuenta: {$r['cvecuenta']}\n";
                echo "      Porcentaje: {$r['porcentaje']}%\n";
                echo "      Periodo: Año {$r['axoini']} Bim {$r['bimini']} a Año {$r['axofin']} Bim {$r['bimfin']}\n";
                echo "      Fecha Alta: {$r['fecalta']}\n";
                echo "      Capturista: {$r['captalta']}\n";
                echo "      Status: {$r['vigencia_desc']} ({$r['vigencia']})\n";
                if ($r['fecbaja']) {
                    echo "      Fecha Baja: {$r['fecbaja']}\n";
                    echo "      Capturista Baja: {$r['captbaja']}\n";
                }
            }
        }

        // 4. Probar con otras cuentas
        echo "\n\n4. Probando con otras cuentas...\n";
        for ($i = 1; $i < min(3, count($ejemplos)); $i++) {
            $cuenta = $ejemplos[$i]['cvecuenta'];
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_desctorec(?)");
            $stmt->execute([$cuenta]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   Cuenta $cuenta: " . count($rows) . " descuento(s)\n";
            if (count($rows) > 0) {
                $r = $rows[0];
                echo "     - {$r['porcentaje']}%, Periodo: {$r['axoini']}-{$r['bimini']} a {$r['axofin']}-{$r['bimfin']}, Status: {$r['vigencia_desc']}\n";
            }
        }

        // 5. Buscar cuenta con descuento vigente
        echo "\n\n5. Buscando cuenta con descuento de recargos vigente...\n";
        $stmt = $pdo->query("
            SELECT cvecuenta
            FROM public.descrec
            WHERE vigencia = 'V'
            LIMIT 1
        ");
        $cuentaVigente = $stmt->fetchColumn();

        if ($cuentaVigente) {
            echo "   Probando con cuenta vigente: $cuentaVigente\n";
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_desctorec(?)");
            $stmt->execute([$cuentaVigente]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($rows) > 0) {
                $r = $rows[0];
                echo "   - {$r['porcentaje']}%, Status: {$r['vigencia_desc']}\n";
            }
        }

        // 6. Estadísticas
        echo "\n\n6. Estadísticas generales...\n";
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.descrec");
        $total = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "   Total de descuentos de recargos: " . number_format($total['total']) . "\n";

        // Por status
        $stmt = $pdo->query("
            SELECT vigencia, COUNT(*) as cantidad
            FROM public.descrec
            WHERE vigencia IS NOT NULL
            GROUP BY vigencia
            ORDER BY cantidad DESC
        ");
        $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Distribución por status:\n";
        foreach ($stats as $s) {
            $desc = $s['vigencia'] == 'V' ? 'Vigente' : ($s['vigencia'] == 'C' ? 'Cancelado' : ($s['vigencia'] == 'P' ? 'Pendiente' : 'Otro'));
            echo "     - {$s['vigencia']} ($desc): " . number_format($s['cantidad']) . "\n";
        }

        // Porcentajes más comunes
        $stmt = $pdo->query("
            SELECT porcentaje, COUNT(*) as cantidad
            FROM public.descrec
            GROUP BY porcentaje
            ORDER BY cantidad DESC
            LIMIT 10
        ");
        $topPct = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "\n   Top 10 porcentajes de descuento más usados:\n";
        foreach ($topPct as $tp) {
            echo "     - {$tp['porcentaje']}%: " . number_format($tp['cantidad']) . " veces\n";
        }
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
