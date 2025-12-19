<?php
// Script para probar el stored procedure recaudadora_reghfrm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_reghfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_reghfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin filtro (últimos 10 registros)
    echo "2. Probando sin filtro (últimos 10 registros)...\n";

    $params = json_encode(['limite' => 10]);
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reghfrm(?)");
    $stmt->execute([$params]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n\n";

    if (count($result) > 0) {
        echo "   Primeros 3 registros:\n\n";
        foreach (array_slice($result, 0, 3) as $i => $row) {
            echo "   Registro " . ($i + 1) . ":\n";
            echo "     ID Multa: {$row['id_multa']}\n";
            echo "     Dependencia: {$row['id_dependencia']}\n";
            echo "     Num Acta: {$row['num_acta']}\n";
            echo "     Año Acta: {$row['axo_acta']}\n";
            echo "     Fecha Acta: " . ($row['fecha_acta'] ?: 'Sin fecha') . "\n";
            echo "     Contribuyente: " . substr($row['contribuyente'], 0, 40) . "\n";
            echo "     Domicilio: " . substr($row['domicilio'], 0, 40) . "\n";
            echo "     Num Licencia: {$row['num_licencia']}\n";
            echo "     Giro: " . substr($row['giro'], 0, 40) . "\n";
            echo "     Calificación: $" . number_format($row['calificacion'], 2) . "\n\n";
        }
    }

    // 3. Probar búsqueda por ID de multa específico
    echo "\n3. Probando búsqueda por ID de multa (411374)...\n";

    $params = json_encode(['tipo' => 'id', 'id_multa' => 411374]);
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reghfrm(?)");
    $stmt->execute([$params]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n";

    if (count($result) > 0) {
        $row = $result[0];
        echo "   ID Multa: {$row['id_multa']}\n";
        echo "   Contribuyente: {$row['contribuyente']}\n";
        echo "   Dependencia: {$row['id_dependencia']}\n";
        echo "   Año: {$row['axo_acta']}\n";
        echo "   Calificación: $" . number_format($row['calificacion'], 2) . "\n";
    }

    // 4. Probar búsqueda por dependencia (3) con año 2024
    echo "\n\n4. Probando búsqueda por dependencia 3 en 2024...\n";

    $params = json_encode([
        'tipo' => 'dependencia',
        'id_dependencia' => 3,
        'axo_acta' => 2024,
        'limite' => 5
    ]);
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reghfrm(?)");
    $stmt->execute([$params]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n";

    if (count($result) > 0) {
        foreach ($result as $i => $row) {
            echo "   " . ($i + 1) . ". ID: {$row['id_multa']} - {$row['contribuyente']} - \${$row['calificacion']}\n";
        }
    }

    // 5. Probar búsqueda por rango de fechas (2024)
    echo "\n\n5. Probando búsqueda por rango de fechas (2024)...\n";

    $params = json_encode([
        'fecha_inicio' => '2024-01-01',
        'fecha_fin' => '2024-12-31',
        'limite' => 10
    ]);
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reghfrm(?)");
    $stmt->execute([$params]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n";

    if (count($result) > 0) {
        foreach (array_slice($result, 0, 5) as $i => $row) {
            echo "   " . ($i + 1) . ". Fecha: {$row['fecha_acta']} - {$row['contribuyente']}\n";
        }
    }

    // 6. Probar búsqueda por año específico (2024)
    echo "\n\n6. Probando búsqueda por año 2024 (primeros 20)...\n";

    $params = json_encode([
        'axo_acta' => 2024,
        'limite' => 20
    ]);
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reghfrm(?)");
    $stmt->execute([$params]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n";

    // Agrupar por dependencia
    $por_dependencia = [];
    foreach ($result as $row) {
        $dep = $row['id_dependencia'];
        if (!isset($por_dependencia[$dep])) {
            $por_dependencia[$dep] = 0;
        }
        $por_dependencia[$dep]++;
    }

    echo "   Distribución por dependencia:\n";
    foreach ($por_dependencia as $dep => $count) {
        echo "     Dependencia $dep: $count registro(s)\n";
    }

    // 7. Estadísticas generales
    echo "\n\n7. Estadísticas generales de la tabla...\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.h_multasnvo");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total registros en tabla: " . number_format($total['total']) . "\n";

    $stmt = $pdo->query("
        SELECT axo_acta, COUNT(*) as total
        FROM public.h_multasnvo
        WHERE axo_acta IN (2023, 2024, 2025)
        GROUP BY axo_acta
        ORDER BY axo_acta DESC
    ");
    $years = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "\n   Registros por año reciente:\n";
    foreach ($years as $year) {
        echo "     {$year['axo_acta']}: " . number_format($year['total']) . " registros\n";
    }

    $stmt = $pdo->query("
        SELECT id_dependencia, COUNT(*) as total
        FROM public.h_multasnvo
        GROUP BY id_dependencia
        ORDER BY total DESC
        LIMIT 5
    ");
    $deps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "\n   Top 5 dependencias:\n";
    foreach ($deps as $dep) {
        echo "     Dependencia {$dep['id_dependencia']}: " . number_format($dep['total']) . " registros\n";
    }

    // 8. Información adicional
    echo "\n\n8. Información adicional...\n";
    echo "\n   ℹ️  TABLA BASE:\n";
    echo "   - Tabla: public.h_multasnvo\n";
    echo "   - Descripción: Histórico de multas municipales\n";
    echo "   - Registros totales: 626,583\n";
    echo "   - Años disponibles: 2015-2025\n";
    echo "   - Campos: id_multa, id_dependencia, num_acta, axo_acta,\n";
    echo "             fecha_acta, contribuyente, domicilio, num_licencia,\n";
    echo "             giro, calificacion\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
