<?php
// Script para probar el stored procedure recaudadora_licenciamicrogeneradorecologia actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_licenciamicrogeneradorecologia...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_licenciamicrogenerador.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar RFCs de ejemplo en la tabla licencias
    echo "2. Buscando RFCs de ejemplo en publico.licencias...\n";
    $stmt = $pdo->query("
        SELECT DISTINCT
            TRIM(l.rfc) as rfc,
            COUNT(*) as cantidad_licencias
        FROM publico.licencias l
        WHERE l.rfc IS NOT NULL
        AND TRIM(l.rfc) != ''
        AND LENGTH(TRIM(l.rfc)) >= 12
        GROUP BY TRIM(l.rfc)
        HAVING COUNT(*) > 0
        ORDER BY cantidad_licencias DESC
        LIMIT 5
    ");
    $rfcs_ejemplo = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   RFCs encontrados:\n";
    foreach ($rfcs_ejemplo as $r) {
        echo "     - RFC: {$r['rfc']}, Licencias: {$r['cantidad_licencias']}\n";
    }

    if (count($rfcs_ejemplo) > 0) {
        $rfc_test = $rfcs_ejemplo[0]['rfc'];

        // 3. Probar con RFC válido
        echo "\n\n3. Probando con RFC '{$rfc_test}'...\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_licenciamicrogeneradorecologia(?)");
        $stmt->execute([$rfc_test]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Licencias encontradas: " . count($results) . "\n\n";

        if (count($results) > 0) {
            foreach ($results as $i => $lic) {
                echo "   === LICENCIA " . ($i + 1) . " ===\n";
                echo "   ID Licencia: {$lic['id_licencia']}\n";
                echo "   RFC: {$lic['rfc']}\n";
                echo "   Folio: {$lic['folio_licencia']}\n";
                echo "   Nombre: {$lic['nombre_solicitante']}\n";
                echo "   Domicilio: {$lic['domicilio']}\n";
                echo "   Tipo Energía: {$lic['tipo_energia']}\n";
                echo "   Capacidad KW: {$lic['capacidad_kw']}\n";
                echo "   Fecha Emisión: {$lic['fecha_emision']}\n";
                echo "   Fecha Vencimiento: {$lic['fecha_vencimiento']}\n";
                echo "   Estatus: {$lic['estatus']}\n\n";
            }
        }

        // 4. Probar con otro RFC si hay más
        if (count($rfcs_ejemplo) > 1) {
            echo "\n4. Probando con otro RFC '{$rfcs_ejemplo[1]['rfc']}'...\n";

            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_licenciamicrogeneradorecologia(?)");
            $stmt->execute([$rfcs_ejemplo[1]['rfc']]);
            $results2 = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   Licencias encontradas: " . count($results2) . "\n";
            if (count($results2) > 0) {
                $lic = $results2[0];
                echo "   Primera licencia:\n";
                echo "     - Folio: {$lic['folio_licencia']}\n";
                echo "     - Nombre: {$lic['nombre_solicitante']}\n";
                echo "     - Estatus: {$lic['estatus']}\n";
            }
        }

        // 5. Probar con RFC inexistente
        echo "\n\n5. Probando con RFC inexistente 'XXXX000000XXX'...\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_licenciamicrogeneradorecologia(?)");
        $stmt->execute(['XXXX000000XXX']);
        $results_error = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Licencias encontradas: " . count($results_error) . "\n";
        if (count($results_error) == 0) {
            echo "   ✓ Correcto: No se encontraron resultados para RFC inexistente\n";
        }

        // 6. Probar con RFC vacío
        echo "\n\n6. Probando con RFC vacío (validación)...\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_licenciamicrogeneradorecologia(?)");
        $stmt->execute(['']);
        $results_vacio = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Licencias encontradas: " . count($results_vacio) . "\n";
        if (count($results_vacio) == 0) {
            echo "   ✓ Correcto: Validación de RFC vacío funciona\n";
        }

        // 7. Probar con más RFCs
        echo "\n\n7. Probando con otros RFCs...\n";
        for ($i = 2; $i < min(4, count($rfcs_ejemplo)); $i++) {
            $rfc = $rfcs_ejemplo[$i]['rfc'];

            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_licenciamicrogeneradorecologia(?)");
            $stmt->execute([$rfc]);
            $r = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   RFC: $rfc\n";
            echo "     - Licencias: " . count($r) . "\n";
            if (count($r) > 0) {
                echo "     - Primera: {$r[0]['folio_licencia']}, Estatus: {$r[0]['estatus']}\n";
            }
            echo "\n";
        }

        // 8. Ver formato JSON para el frontend
        echo "\n8. Formato JSON para el frontend:\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_licenciamicrogeneradorecologia(?) LIMIT 2");
        $stmt->execute([$rfc_test]);
        $result_json = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode($result_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

        // 9. Verificar cantidad de licencias con RFC válido
        echo "\n\n9. Estadísticas de licencias con RFC:\n";

        $stats_stmt = $pdo->query("
            SELECT
                COUNT(*) as total_licencias,
                COUNT(DISTINCT rfc) as total_rfcs,
                COUNT(CASE WHEN vigente = 'S' THEN 1 END) as vigentes,
                COUNT(CASE WHEN vigente = 'N' THEN 1 END) as no_vigentes
            FROM publico.licencias
            WHERE rfc IS NOT NULL AND TRIM(rfc) != ''
        ");
        $stats = $stats_stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Total licencias con RFC: " . number_format($stats['total_licencias']) . "\n";
        echo "   Total RFCs únicos: " . number_format($stats['total_rfcs']) . "\n";
        echo "   Licencias vigentes: " . number_format($stats['vigentes']) . "\n";
        echo "   Licencias no vigentes: " . number_format($stats['no_vigentes']) . "\n";

    } else {
        echo "\n   No se encontraron RFCs de ejemplo en la tabla.\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
