<?php
// Script para probar el stored procedure recaudadora_ejecutores actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_ejecutores...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_ejecutores.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin parámetros (listar todos)
    echo "2. Probando sin parámetros (primeros ejecutores)...\n";
    $stmt = $pdo->query("SELECT * FROM publico.recaudadora_ejecutores('')");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " ejecutor(es) encontrado(s)\n\n";

    if (count($rows) > 0) {
        echo "   Primeros 5 ejecutores:\n";
        for ($i = 0; $i < min(5, count($rows)); $i++) {
            $r = $rows[$i];
            echo "\n   " . ($i + 1) . ". {$r['nombre_completo']}\n";
            echo "      ID: {$r['id_ejecutor']}\n";
            echo "      Cargo: {$r['cargo']}\n";
            echo "      Área: {$r['area']}\n";
            echo "      Fecha Ingreso: {$r['fecha_ingreso']}\n";
            echo "      Status: {$r['status']}\n";
            if ($r['observaciones']) {
                echo "      Observaciones: {$r['observaciones']}\n";
            }
        }
    }

    // 3. Buscar por nombre
    echo "\n\n3. Probando búsqueda por nombre 'SANCHEZ'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ejecutores(?)");
    $stmt->execute(['SANCHEZ']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " ejecutor(es) encontrado(s)\n";
    if (count($rows) > 0) {
        foreach ($rows as $i => $r) {
            echo "     - {$r['nombre_completo']} (ID: {$r['id_ejecutor']}, {$r['status']})\n";
        }
    }

    // 4. Buscar por ID
    echo "\n\n4. Probando búsqueda por ID '3'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ejecutores(?)");
    $stmt->execute(['3']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        $r = $rows[0];
        echo "   Ejecutor encontrado:\n";
        echo "     ID: {$r['id_ejecutor']}\n";
        echo "     Nombre: {$r['nombre_completo']}\n";
        echo "     Número Empleado: {$r['numero_empleado']}\n";
        echo "     Cargo: {$r['cargo']}\n";
        echo "     Área: {$r['area']}\n";
        echo "     Fecha Ingreso: {$r['fecha_ingreso']}\n";
        echo "     Status: {$r['status']}\n";
        echo "     Observaciones: {$r['observaciones']}\n";
    }

    // 5. Buscar ejecutores activos
    echo "\n\n5. Buscando ejecutores activos (vigencia = V)...\n";
    $stmt = $pdo->query("
        SELECT e.cveejecutor, TRIM(CONCAT(e.nombres, ' ', e.paterno, ' ', e.materno)) as nombre, e.vigencia
        FROM public.ejecutor e
        WHERE e.vigencia = 'V'
        ORDER BY e.cveejecutor
        LIMIT 10
    ");
    $activos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Ejecutores activos encontrados: " . count($activos) . "\n";
    foreach ($activos as $a) {
        echo "     - {$a['cveejecutor']}: {$a['nombre']}\n";
    }

    // 6. Estadísticas
    echo "\n\n6. Estadísticas generales...\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.ejecutor");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total de ejecutores: " . number_format($total['total']) . "\n";

    // Por status
    $stmt = $pdo->query("
        SELECT vigencia, COUNT(*) as cantidad
        FROM public.ejecutor
        WHERE vigencia IS NOT NULL
        GROUP BY vigencia
        ORDER BY cantidad DESC
    ");
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Distribución por vigencia:\n";
    foreach ($stats as $s) {
        $desc = $s['vigencia'] == 'V' ? 'Activo' : ($s['vigencia'] == 'C' ? 'Cancelado' : 'Otro');
        echo "     - {$s['vigencia']} ($desc): " . number_format($s['cantidad']) . "\n";
    }

    // Por área de recaudación
    $stmt = $pdo->query("
        SELECT recaud, COUNT(*) as cantidad
        FROM public.ejecutor
        WHERE recaud IS NOT NULL
        GROUP BY recaud
        ORDER BY recaud
    ");
    $areas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "\n   Distribución por área de recaudación:\n";
    foreach ($areas as $a) {
        $desc = '';
        switch($a['recaud']) {
            case 1: $desc = 'Recaudación Predial'; break;
            case 2: $desc = 'Recaudación Municipal'; break;
            case 3: $desc = 'Multas'; break;
            case 4: $desc = 'Licencias'; break;
            default: $desc = 'Otro';
        }
        echo "     - {$a['recaud']} ($desc): " . number_format($a['cantidad']) . "\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
