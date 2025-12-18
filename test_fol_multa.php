<?php
// Script para probar el stored procedure recaudadora_fol_multa actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_fol_multa...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_fol_multa.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar números de acta de ejemplo
    echo "2. Buscando números de acta de ejemplo...\n";
    $stmt = $pdo->query("
        SELECT DISTINCT num_acta, axo_acta, contribuyente, multa
        FROM publico.multas
        WHERE num_acta IS NOT NULL
        ORDER BY axo_acta DESC, num_acta DESC
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Actas encontradas:\n";
    foreach ($ejemplos as $ej) {
        echo "     - Acta: {$ej['num_acta']}, Año: {$ej['axo_acta']}, Contribuyente: " . substr($ej['contribuyente'], 0, 30) . ", Monto: $" . number_format($ej['multa'], 2) . "\n";
    }

    if (count($ejemplos) > 0) {
        $acta_ejemplo = $ejemplos[0]['num_acta'];
        $axo_ejemplo = $ejemplos[0]['axo_acta'];

        // 3. Probar con acta específica
        echo "\n\n3. Probando con acta '$acta_ejemplo' del año $axo_ejemplo...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_fol_multa(?, ?)");
        $stmt->execute([$acta_ejemplo, $axo_ejemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " multa(s) encontrada(s)\n";

        if (count($rows) > 0) {
            echo "\n   Detalles de la multa:\n";
            foreach ($rows as $i => $r) {
                echo "\n   " . ($i + 1) . ". Multa:\n";
                echo "      Folio: {$r['folio']}\n";
                echo "      Acta: {$r['numero_acta']} / {$r['axo_acta']}\n";
                echo "      Estado: {$r['estado']}\n";
                echo "      Nombre: {$r['nombre']}\n";
                echo "      Domicilio: {$r['domicilio']}\n";
                echo "      Actividad: {$r['actividad_giro']}\n";
                if ($r['numero_licencia']) {
                    echo "      Licencia: {$r['numero_licencia']}\n";
                }
                echo "      Importe Inicial: $" . number_format($r['importe_inicial'], 2) . "\n";
                echo "      Importe a Pagar: $" . number_format($r['importe_pagar'], 2) . "\n";
                echo "      Importe Pagado: $" . number_format($r['importe_pago'], 2) . "\n";
                echo "      Fecha Alta: {$r['fecha_alta']}\n";
                echo "      Fecha Recepción: {$r['fecha_recepcion']}\n";
                if ($r['fecha_pago']) {
                    echo "      Fecha Pago: {$r['fecha_pago']}\n";
                }
                echo "      Recaudadora: {$r['recaudadora']}\n";
                echo "      Zona: {$r['numero_zona']} / Subzona: {$r['sub_zona']}\n";
                echo "      Sector: {$r['sector']}\n";
            }
        }

        // 4. Probar sin especificar año (año = 0)
        echo "\n\n4. Probando con acta sin filtro de año...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_fol_multa(?, 0)");
        $stmt->execute([$acta_ejemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " multa(s) encontrada(s)\n";
        if (count($rows) > 0) {
            foreach ($rows as $r) {
                echo "     - Folio: {$r['folio']}, Acta: {$r['numero_acta']}/{$r['axo_acta']}, Estado: {$r['estado']}\n";
            }
        }

        // 5. Probar con otras actas
        echo "\n\n5. Probando con otras actas...\n";
        for ($i = 1; $i < min(3, count($ejemplos)); $i++) {
            $acta = $ejemplos[$i]['num_acta'];
            $axo = $ejemplos[$i]['axo_acta'];

            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_fol_multa(?, ?)");
            $stmt->execute([$acta, $axo]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   Acta $acta/$axo: " . count($rows) . " multa(s)\n";
            if (count($rows) > 0) {
                $r = $rows[0];
                echo "     - {$r['nombre']}, Monto: $" . number_format($r['importe_pagar'], 2) . ", Estado: {$r['estado']}\n";
            }
        }
    }

    // 6. Estadísticas
    echo "\n\n6. Estadísticas generales...\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM publico.multas");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total de multas: " . number_format($total['total']) . "\n";

    // Por estado
    $stmt = $pdo->query("
        SELECT
            CASE
                WHEN cvepago IS NOT NULL AND cvepago > 0 THEN 'PAGADA'
                WHEN fecha_cancelacion IS NOT NULL THEN 'CANCELADA'
                WHEN fecha_plazo IS NOT NULL AND fecha_plazo < CURRENT_DATE THEN 'VENCIDA'
                ELSE 'VIGENTE'
            END AS estado,
            COUNT(*) as cantidad
        FROM publico.multas
        GROUP BY estado
        ORDER BY cantidad DESC
    ");
    $estados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "\n   Distribución por estado:\n";
    foreach ($estados as $e) {
        echo "     - {$e['estado']}: " . number_format($e['cantidad']) . "\n";
    }

    // Por recaudadora
    $stmt = $pdo->query("
        SELECT recaud, COUNT(*) as cantidad
        FROM publico.multas
        GROUP BY recaud
        ORDER BY cantidad DESC
    ");
    $recauds = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "\n   Distribución por recaudadora:\n";
    foreach ($recauds as $rec) {
        $nombre = '';
        switch($rec['recaud']) {
            case 1: $nombre = 'Predial'; break;
            case 2: $nombre = 'Municipal'; break;
            case 3: $nombre = 'Multas'; break;
            case 4: $nombre = 'Licencias'; break;
            default: $nombre = 'Otras';
        }
        echo "     - {$rec['recaud']} ($nombre): " . number_format($rec['cantidad']) . "\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
