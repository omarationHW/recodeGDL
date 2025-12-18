<?php
// Script para probar el stored procedure recaudadora_consreq400 actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_consreq400...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_consreq400.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar ejemplos de id_multa
    echo "2. Buscando requerimientos de ejemplo...\n";
    $stmt = $pdo->query("
        SELECT id_multa, cvereq, folioreq, axoreq, vigencia
        FROM publico.reqmultas
        WHERE id_multa IS NOT NULL
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Requerimientos encontrados:\n";
    foreach ($ejemplos as $ej) {
        echo "     - ID Multa: {$ej['id_multa']}, Folio: {$ej['folioreq']}, Año: {$ej['axoreq']}, Vigencia: {$ej['vigencia']}\n";
    }

    if (count($ejemplos) > 0) {
        $idMultaEjemplo = $ejemplos[0]['id_multa'];
        $axoEjemplo = $ejemplos[0]['axoreq'];

        // 3. Probar con parámetros vacíos (listar todos)
        echo "\n\n3. Probando sin filtros (primeros 10 requerimientos)...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consreq400('', 0, 0, 10)");
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " requerimiento(s) encontrado(s)\n";
        if (count($rows) > 0) {
            echo "   Total en BD: " . $rows[0]['total_count'] . " requerimientos\n";
            echo "\n   Primeros 3 requerimientos:\n";
            foreach (array_slice($rows, 0, 3) as $i => $r) {
                echo "   " . ($i + 1) . ". Cuenta: {$r['clave_cuenta']}, Folio: {$r['folio']}, Ejercicio: {$r['ejercicio']}, Estatus: {$r['estatus']}\n";
            }
        }

        // 4. Probar con clave_cuenta específica
        echo "\n\n4. Probando con clave_cuenta específica '$idMultaEjemplo'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consreq400(?, 0, 0, 10)");
        $stmt->execute([$idMultaEjemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " requerimiento(s) encontrado(s)\n";

        if (count($rows) > 0) {
            $r = $rows[0];
            echo "\n   Datos del requerimiento:\n";
            echo "     ID: {$r['id_requerimiento']}\n";
            echo "     Cuenta: {$r['clave_cuenta']}\n";
            echo "     Folio: {$r['folio']}\n";
            echo "     Ejercicio: {$r['ejercicio']}\n";
            echo "     Estatus: {$r['estatus']}\n";
            echo "     Fecha: {$r['fecha']}\n";
            echo "     Vigencia: {$r['vigreq']}\n";
            echo "     Observaciones: " . substr($r['observr'], 0, 50) . "\n";
        }

        // 5. Probar con filtro por ejercicio
        echo "\n\n5. Probando con filtro por ejercicio '$axoEjemplo'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consreq400('', ?, 0, 5)");
        $stmt->execute([$axoEjemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " requerimiento(s) del ejercicio $axoEjemplo\n";
        if (count($rows) > 0) {
            echo "   Total para este ejercicio: " . $rows[0]['total_count'] . "\n";
        }

        // 6. Probar paginación
        echo "\n\n6. Probando paginación (offset=10, limit=5)...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consreq400('', 0, 10, 5)");
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " requerimiento(s) en página 2\n";
        if (count($rows) > 0) {
            foreach ($rows as $i => $r) {
                echo "   " . ($i + 11) . ". ID: {$r['id_requerimiento']}, Cuenta: {$r['clave_cuenta']}\n";
            }
        }
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
