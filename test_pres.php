<?php
// Script para probar el stored procedure recaudadora_pres con datos reales

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_pres...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_pres.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin filtro (todos los ejercicios, primeros registros)
    echo "2. Probando sin filtro (todos los ejercicios)...\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pres('') LIMIT 10");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $time = round(microtime(true) - $start, 2);

    echo "   Total encontrados: " . count($result) . " registro(s) (primeros 10)\n";
    echo "   Tiempo: {$time}s\n\n";

    if (count($result) > 0) {
        echo "   === PRIMEROS 3 REGISTROS ===\n\n";
        foreach (array_slice($result, 0, 3) as $i => $row) {
            echo "   Registro " . ($i + 1) . ":\n";
            echo "     Ejercicio: {$row['ejercicio']}\n";
            echo "     Cuenta: {$row['cta_aplicacion']}\n";
            echo "     Presupuesto Anual: $" . number_format($row['presup_anual'], 2) . "\n";
            echo "     Enero: $" . number_format($row['enero'], 2) . "\n";
            echo "     Febrero: $" . number_format($row['febrero'], 2) . "\n";
            echo "     Marzo: $" . number_format($row['marzo'], 2) . "\n";
            echo "     Total 1er Trimestre: $" . number_format($row['enero'] + $row['febrero'] + $row['marzo'], 2) . "\n\n";
        }
    }

    // 3. Probar con filtro de ejercicio 2024
    echo "\n3. Probando con filtro de ejercicio '2024'...\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pres(?)");
    $stmt->execute(['2024']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $time = round(microtime(true) - $start, 2);

    echo "   Total encontrados: " . count($result) . " cuenta(s)\n";
    echo "   Tiempo: {$time}s\n\n";

    if (count($result) > 0) {
        echo "   === RESUMEN 2024 ===\n\n";

        $total_anual = 0;
        foreach ($result as $row) {
            $total_anual += $row['presup_anual'];
            echo "   Cuenta {$row['cta_aplicacion']}:\n";
            echo "     Presupuesto: $" . number_format($row['presup_anual'], 2) . "\n";
            echo "     Q1 (Ene-Mar): $" . number_format($row['enero'] + $row['febrero'] + $row['marzo'], 2) . "\n";
            echo "     Q2 (Abr-Jun): $" . number_format($row['abril'] + $row['mayo'] + $row['junio'], 2) . "\n";
            echo "     Q3 (Jul-Sep): $" . number_format($row['julio'] + $row['agosto'] + $row['septiembre'], 2) . "\n";
            echo "     Q4 (Oct-Dic): $" . number_format($row['octubre'] + $row['noviembre'] + $row['diciembre'], 2) . "\n\n";
        }

        echo "   Total presupuesto 2024: $" . number_format($total_anual, 2) . "\n";
    }

    // 4. Probar con filtro de ejercicio 2023
    echo "\n\n4. Probando con filtro de ejercicio '2023'...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pres(?)");
    $stmt->execute(['2023']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " cuenta(s)\n";

    if (count($result) > 0) {
        $total_2023 = 0;
        foreach ($result as $row) {
            $total_2023 += $row['presup_anual'];
        }
        echo "   Total presupuesto 2023: $" . number_format($total_2023, 2) . "\n";
    }

    // 5. Estadísticas generales
    echo "\n\n5. Estadísticas generales...\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total_registros
        FROM publico.recaudadora_pres('')
    ");
    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "\n   Total de registros disponibles: " . number_format($stats['total_registros']) . "\n";

    // Contar ejercicios únicos
    $stmt = $pdo->query("
        SELECT COUNT(DISTINCT ejercicio) as ejercicios
        FROM publico.recaudadora_pres('')
    ");
    $ejercicios = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Ejercicios diferentes: " . $ejercicios['ejercicios'] . "\n";

    // 6. Información adicional
    echo "\n\n6. Información adicional...\n";
    echo "\n   ✅ IMPORTANTE:\n";
    echo "   - Esta función usa la tabla 'public.auditoria' (29.5M registros)\n";
    echo "   - Simula presupuesto devengado desde movimientos de auditoría\n";
    echo "   - Convierte datos BIMESTRALES a MENSUALES\n";
    echo "   - Cada bimestre se divide en 2 meses iguales\n";
    echo "   - Permite filtrar por ejercicio\n";
    echo "   - La estructura retornada incluye:\n";
    echo "     * ejercicio: Año fiscal\n";
    echo "     * cta_aplicacion: Cuenta aplicación\n";
    echo "     * presup_anual: Total anual\n";
    echo "     * 12 campos mensuales (enero-diciembre)\n\n";
    echo "   📌 Los datos son APROXIMADOS ya que se derivan de bimestres.\n";
    echo "      Bimestre 1 (Ene-Feb) se divide 50/50 en enero y febrero.\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
