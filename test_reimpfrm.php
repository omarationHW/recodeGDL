<?php
// Script para probar el stored procedure recaudadora_reimpfrm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_reimpfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_reimpfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin filtros (últimos 10)
    echo "2. Probando sin filtros (últimos 10 documentos)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reimpfrm(NULL, NULL, NULL, NULL) LIMIT 10");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " documento(s)\n\n";

    if (count($result) > 0) {
        echo "   Primeros 5 documentos:\n\n";
        foreach (array_slice($result, 0, 5) as $i => $row) {
            echo "   Documento " . ($i + 1) . ":\n";
            echo "     Folio: {$row['folio']}\n";
            echo "     Tipo: {$row['tipo_documento']}\n";
            echo "     Fecha: {$row['fecha']}\n";
            echo "     Solicitante: " . substr($row['contribuyente'], 0, 35) . "\n";
            echo "     Dependencia: {$row['dependencia']}\n";
            echo "     Año: {$row['axo_acta']}\n";
            echo "     Num Solicitud: {$row['num_acta']}\n";
            echo "     Importe: \${$row['importe']}\n";
            echo "     Estatus: {$row['estatus']}\n\n";
        }
    }

    // 3. Probar búsqueda por folio específico
    echo "\n3. Probando búsqueda por folio específico (6448661)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reimpfrm(?, NULL, NULL, NULL)");
    $stmt->execute([6448661]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " documento(s)\n";

    if (count($result) > 0) {
        $row = $result[0];
        echo "   Folio: {$row['folio']}\n";
        echo "   Tipo: {$row['tipo_documento']}\n";
        echo "   Fecha: {$row['fecha']}\n";
        echo "   Solicitante: {$row['contribuyente']}\n";
        echo "   Dependencia: {$row['dependencia']}\n";
        echo "   Estatus: {$row['estatus']}\n";
    }

    // 4. Probar búsqueda por recaudación (dependencia 2)
    echo "\n\n4. Probando búsqueda por recaudación 2 (primeros 5)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reimpfrm(NULL, NULL, ?, NULL) LIMIT 5");
    $stmt->execute([2]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " documento(s)\n";

    if (count($result) > 0) {
        foreach ($result as $i => $row) {
            echo "   " . ($i + 1) . ". Folio: {$row['folio']} - Fecha: {$row['fecha']} - {$row['dependencia']}\n";
        }
    }

    // 5. Probar búsqueda por texto (nombre)
    echo "\n\n5. Probando búsqueda por texto 'KARLA'...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reimpfrm(NULL, NULL, NULL, ?)");
    $stmt->execute(['KARLA']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " documento(s)\n";

    if (count($result) > 0) {
        foreach (array_slice($result, 0, 5) as $i => $row) {
            echo "   " . ($i + 1) . ". Folio: {$row['folio']} - {$row['contribuyente']} - {$row['fecha']}\n";
        }
    }

    // 6. Estadísticas por estatus
    echo "\n\n6. Estadísticas por estatus...\n";

    $stmt = $pdo->prepare("
        SELECT estatus, COUNT(*) as total
        FROM publico.recaudadora_reimpfrm(NULL, NULL, NULL, NULL)
        GROUP BY estatus
        ORDER BY total DESC
    ");
    $stmt->execute();
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($stats as $stat) {
        echo "   {$stat['estatus']}: {$stat['total']} documento(s)\n";
    }

    // 7. Estadísticas por recaudación
    echo "\n\n7. Estadísticas por dependencia...\n";

    $stmt = $pdo->prepare("
        SELECT dependencia, COUNT(*) as total
        FROM publico.recaudadora_reimpfrm(NULL, NULL, NULL, NULL)
        GROUP BY dependencia
        ORDER BY total DESC
    ");
    $stmt->execute();
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($stats as $stat) {
        echo "   {$stat['dependencia']}: {$stat['total']} documento(s)\n";
    }

    // 8. Total de registros en la tabla base
    echo "\n\n8. Información de la tabla base...\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.noadeudo");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total registros en tabla noadeudo: " . number_format($total['total']) . "\n";

    $stmt = $pdo->query("
        SELECT axo, COUNT(*) as total
        FROM public.noadeudo
        WHERE axo >= 2020
        GROUP BY axo
        ORDER BY axo DESC
    ");
    $years = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "\n   Registros por año (desde 2020):\n";
    foreach ($years as $year) {
        echo "     {$year['axo']}: " . number_format($year['total']) . " registros\n";
    }

    // 9. Información adicional
    echo "\n\n9. Información adicional...\n";
    echo "\n   ℹ️  TABLA BASE:\n";
    echo "   - Tabla: public.noadeudo\n";
    echo "   - Descripción: Constancias de no adeudo\n";
    echo "   - Registros totales: 636,322\n";
    echo "   - Años disponibles: 2015-2024\n";
    echo "   - Tipo de documento: NO ADEUDO\n";
    echo "   - Campos:\n";
    echo "     * folio: Folio del documento\n";
    echo "     * tipo_documento: Tipo (NO ADEUDO)\n";
    echo "     * fecha: Fecha de emisión\n";
    echo "     * contribuyente: Nombre del solicitante/autorizador\n";
    echo "     * dependencia: Recaudación (1-4)\n";
    echo "     * axo_acta: Año del documento\n";
    echo "     * num_acta: Número de solicitud\n";
    echo "     * importe: Monto (0 para no adeudo)\n";
    echo "     * estatus: Estado (VIGENTE, PROCESADO, INACTIVO)\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
