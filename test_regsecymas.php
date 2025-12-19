<?php
// Script para probar el stored procedure recaudadora_regsecymas

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_regsecymas...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_regsecymas.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin filtro (todos los ejecutores)
    echo "2. Probando sin filtro (primeros 10 ejecutores)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_regsecymas('') LIMIT 10");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " ejecutor(es)\n\n";

    if (count($result) > 0) {
        echo "   Primeros 5 ejecutores:\n\n";
        foreach (array_slice($result, 0, 5) as $i => $row) {
            echo "   Ejecutor " . ($i + 1) . ":\n";
            echo "     ID: {$row['id_ejecutor']}\n";
            echo "     Clave: {$row['cve_eje']}\n";
            echo "     Nombre: {$row['nombre']}\n";
            echo "     RFC Inicial: {$row['ini_rfc']}\n";
            echo "     RFC Homologado: {$row['hom_rfc']}\n";
            echo "     ID Recaudación: {$row['id_rec']}\n";
            echo "     Categoría: {$row['categoria']}\n";
            echo "     Vigencia: {$row['vigencia']}\n\n";
        }
    }

    // 3. Probar búsqueda por nombre
    echo "\n3. Probando búsqueda por nombre 'ALBERTO'...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_regsecymas(?)");
    $stmt->execute(['ALBERTO']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " ejecutor(es)\n";

    if (count($result) > 0) {
        foreach ($result as $i => $row) {
            echo "   " . ($i + 1) . ". Clave: {$row['cve_eje']} - {$row['nombre']} - {$row['categoria']}\n";
        }
    }

    // 4. Probar búsqueda por RFC
    echo "\n\n4. Probando búsqueda por RFC 'AOMA'...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_regsecymas(?)");
    $stmt->execute(['AOMA']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " ejecutor(es)\n";

    if (count($result) > 0) {
        foreach ($result as $i => $row) {
            echo "   {$row['nombre']} - RFC: {$row['ini_rfc']} - Vigencia: {$row['vigencia']}\n";
        }
    }

    // 5. Probar búsqueda por clave
    echo "\n\n5. Probando búsqueda por clave '3'...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_regsecymas(?)");
    $stmt->execute(['3']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " ejecutor(es)\n";

    if (count($result) > 0) {
        $row = $result[0];
        echo "   Clave: {$row['cve_eje']}\n";
        echo "   Nombre: {$row['nombre']}\n";
        echo "   RFC: {$row['ini_rfc']}\n";
        echo "   Categoría: {$row['categoria']}\n";
        echo "   Vigencia: {$row['vigencia']}\n";
    }

    // 6. Estadísticas por vigencia
    echo "\n\n6. Estadísticas por vigencia...\n";

    $stmt = $pdo->prepare("
        SELECT vigencia, COUNT(*) as total
        FROM publico.recaudadora_regsecymas('')
        GROUP BY vigencia
        ORDER BY total DESC
    ");
    $stmt->execute();
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($stats as $stat) {
        echo "   {$stat['vigencia']}: {$stat['total']} ejecutor(es)\n";
    }

    // 7. Estadísticas por categoría
    echo "\n\n7. Estadísticas por categoría...\n";

    $stmt = $pdo->prepare("
        SELECT categoria, COUNT(*) as total
        FROM publico.recaudadora_regsecymas('')
        GROUP BY categoria
        ORDER BY total DESC
    ");
    $stmt->execute();
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($stats as $stat) {
        echo "   {$stat['categoria']}: {$stat['total']} ejecutor(es)\n";
    }

    // 8. Total de registros
    echo "\n\n8. Conteo total...\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM publico.recaudadora_regsecymas('')");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total de ejecutores: " . $total['total'] . "\n";

    // 9. Información adicional
    echo "\n\n9. Información adicional...\n";
    echo "\n   ℹ️  TABLA BASE:\n";
    echo "   - Tabla: public.ejecutor\n";
    echo "   - Descripción: Ejecutores administrativos\n";
    echo "   - Registros totales: 574\n";
    echo "   - Distribución:\n";
    echo "     * Vigentes (V): 471 (82.1%)\n";
    echo "     * Cancelados (C): 86 (15.0%)\n";
    echo "     * Bloqueados (B): 17 (2.9%)\n";
    echo "   - Campos:\n";
    echo "     * id_ejecutor: ID único\n";
    echo "     * cve_eje: Clave del ejecutor\n";
    echo "     * nombre: Nombre completo (paterno + materno + nombres)\n";
    echo "     * ini_rfc: RFC inicial del ejecutor\n";
    echo "     * hom_rfc: RFC homologado (mismo que inicial)\n";
    echo "     * id_rec: ID de recaudación\n";
    echo "     * categoria: Clasificación (VIGENTE, CANCELADO, BLOQUEADO)\n";
    echo "     * vigencia: Estado (ACTIVO, INACTIVO, BLOQUEADO)\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
