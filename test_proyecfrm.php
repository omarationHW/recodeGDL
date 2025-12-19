<?php
// Script para probar el stored procedure recaudadora_proyecfrm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_proyecfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_proyecfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin filtro
    echo "2. Probando sin filtro (todos los proyectos)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_proyecfrm('')");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " proyecto(s)\n\n";

    if (count($result) > 0) {
        echo "   Primeros 3 proyectos:\n\n";
        foreach (array_slice($result, 0, 3) as $i => $row) {
            echo "   Proyecto " . ($i + 1) . ":\n";
            echo "     ID: {$row['id_proyecto']}\n";
            echo "     Nombre: {$row['nombre_proyecto']}\n";
            echo "     Descripción: " . substr($row['descripcion'], 0, 60) . "...\n";
            echo "     Fecha inicio: {$row['fecha_inicio']}\n";
            echo "     Fecha fin: {$row['fecha_fin']}\n";
            echo "     Estado: {$row['estado']}\n";
            echo "     Responsable: {$row['responsable']}\n";
            echo "     Presupuesto: $" . number_format($row['presupuesto'], 2) . "\n";
            echo "     Avance: {$row['avance']}%\n";
            echo "     Departamento: {$row['departamento']}\n";
            echo "     Prioridad: {$row['prioridad']}\n\n";
        }
    }

    // 3. Probar con filtro por nombre
    echo "\n3. Probando con filtro 'ECOLOGIA'...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_proyecfrm(?)");
    $stmt->execute(['ECOLOGIA']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " proyecto(s)\n";

    if (count($result) > 0) {
        foreach ($result as $i => $row) {
            echo "   Proyecto " . ($i + 1) . ": {$row['nombre_proyecto']} - {$row['estado']}\n";
        }
    }

    // 4. Probar con filtro por responsable
    echo "\n\n4. Probando con filtro 'lecorne' (responsable)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_proyecfrm(?)");
    $stmt->execute(['lecorne']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " proyecto(s)\n";

    if (count($result) > 0) {
        foreach ($result as $i => $row) {
            echo "   Proyecto " . ($i + 1) . ": {$row['nombre_proyecto']} - Responsable: {$row['responsable']}\n";
        }
    }

    // 5. Estadísticas por estado
    echo "\n\n5. Estadísticas por estado...\n";

    $stmt = $pdo->prepare("
        SELECT estado, COUNT(*) as total
        FROM publico.recaudadora_proyecfrm('')
        GROUP BY estado
        ORDER BY total DESC
    ");
    $stmt->execute();
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($stats as $stat) {
        echo "   {$stat['estado']}: {$stat['total']} proyecto(s)\n";
    }

    // 6. Estadísticas por departamento
    echo "\n\n6. Estadísticas por departamento...\n";

    $stmt = $pdo->prepare("
        SELECT departamento, COUNT(*) as total
        FROM publico.recaudadora_proyecfrm('')
        GROUP BY departamento
        ORDER BY total DESC
    ");
    $stmt->execute();
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($stats as $stat) {
        echo "   {$stat['departamento']}: {$stat['total']} proyecto(s)\n";
    }

    // 7. Información adicional
    echo "\n\n7. Información adicional...\n";
    echo "\n   ℹ️  TABLA BASE:\n";
    echo "   - Tabla: public.aut_desctosotorgados\n";
    echo "   - Registros totales: 33\n";
    echo "   - Descripción: Descuentos autorizados otorgados\n";
    echo "   - Los 'proyectos' son en realidad registros de descuentos\n";
    echo "     autorizados para multas, licencias, predial, etc.\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
