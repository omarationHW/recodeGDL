<?php
// Script para probar el stored procedure recaudadora_descpredfrm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_descpredfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_descpredfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar cuentas con descuentos de ejemplo
    echo "2. Buscando cuentas con descuentos de ejemplo...\n";
    $stmt = $pdo->query("
        SELECT DISTINCT cvecuenta, cvedescuento, status
        FROM public.descpred
        WHERE cvecuenta IS NOT NULL
        ORDER BY cvecuenta DESC
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Cuentas con descuentos encontradas:\n";
    foreach ($ejemplos as $ej) {
        $statusDesc = $ej['status'] == 'V' ? 'Vigente' : ($ej['status'] == 'C' ? 'Cancelado' : 'Otro');
        echo "     - Cuenta: {$ej['cvecuenta']}, Descuento: {$ej['cvedescuento']}, Status: $statusDesc\n";
    }

    if (count($ejemplos) > 0) {
        $cuentaEjemplo = $ejemplos[0]['cvecuenta'];

        // 3. Probar con cuenta específica
        echo "\n\n3. Probando con cuenta específica '$cuentaEjemplo'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_descpredfrm(?)");
        $stmt->execute([$cuentaEjemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " descuento(s) encontrado(s)\n";

        if (count($rows) > 0) {
            echo "\n   Descuentos de la cuenta $cuentaEjemplo:\n";
            foreach ($rows as $i => $r) {
                echo "\n   " . ($i + 1) . ". Descuento:\n";
                echo "      Cuenta: {$r['cvecuenta']}\n";
                echo "      Código Descuento: {$r['cvedescuento']}\n";
                echo "      Descripción: {$r['descripcion']}\n";
                echo "      Porcentaje: {$r['porcentaje']}%\n";
                echo "      Ejercicio: {$r['ejercicio']}\n";
                echo "      Periodo: Bimestre {$r['bimini']} a {$r['bimfin']}\n";
                echo "      Fecha Alta: {$r['fecalta']}\n";
                echo "      Capturista: {$r['captalta']}\n";
                echo "      Status: {$r['status_desc']} ({$r['status']})\n";
                echo "      Solicitante: {$r['solicitante']}\n";
                if ($r['observaciones']) {
                    echo "      Observaciones: " . substr($r['observaciones'], 0, 60) . "\n";
                }
            }
        }

        // 4. Probar con otras cuentas
        echo "\n\n4. Probando con otras cuentas...\n";
        for ($i = 1; $i < min(3, count($ejemplos)); $i++) {
            $cuenta = $ejemplos[$i]['cvecuenta'];
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_descpredfrm(?)");
            $stmt->execute([$cuenta]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   Cuenta $cuenta: " . count($rows) . " descuento(s)\n";
            if (count($rows) > 0) {
                $r = $rows[0];
                echo "     - Descuento: {$r['cvedescuento']}, {$r['descripcion']}, {$r['porcentaje']}%\n";
            }
        }

        // 5. Buscar cuenta con descuento vigente
        echo "\n\n5. Buscando cuenta con descuento vigente...\n";
        $stmt = $pdo->query("
            SELECT cvecuenta
            FROM public.descpred
            WHERE status = 'V'
            LIMIT 1
        ");
        $cuentaVigente = $stmt->fetchColumn();

        if ($cuentaVigente) {
            echo "   Probando con cuenta vigente: $cuentaVigente\n";
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_descpredfrm(?)");
            $stmt->execute([$cuentaVigente]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($rows) > 0) {
                $r = $rows[0];
                echo "   - Desc: {$r['descripcion']}, {$r['porcentaje']}%, Status: {$r['status_desc']}\n";
            }
        }

        // 6. Estadísticas
        echo "\n\n6. Estadísticas generales...\n";
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.descpred");
        $total = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "   Total de descuentos prediales: " . number_format($total['total']) . "\n";

        // Por status
        $stmt = $pdo->query("
            SELECT status, COUNT(*) as cantidad
            FROM public.descpred
            WHERE status IS NOT NULL
            GROUP BY status
            ORDER BY cantidad DESC
        ");
        $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Distribución por status:\n";
        foreach ($stats as $s) {
            $desc = $s['status'] == 'V' ? 'Vigente' : ($s['status'] == 'C' ? 'Cancelado' : 'Otro');
            echo "     - {$s['status']} ($desc): " . number_format($s['cantidad']) . "\n";
        }

        // Tipos de descuento más usados
        $stmt = $pdo->query("
            SELECT d.cvedescuento, c.descripcion, COUNT(*) as cantidad
            FROM public.descpred d
            LEFT JOIN public.c_descpred c ON d.cvedescuento = c.cvedescuento
            GROUP BY d.cvedescuento, c.descripcion
            ORDER BY cantidad DESC
            LIMIT 5
        ");
        $topDesc = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "\n   Top 5 tipos de descuento más usados:\n";
        foreach ($topDesc as $td) {
            $desc = $td['descripcion'] ? substr(trim($td['descripcion']), 0, 40) : 'Sin descripción';
            echo "     - {$td['cvedescuento']}: $desc (" . number_format($td['cantidad']) . ")\n";
        }
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
