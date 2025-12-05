<?php
/**
 * Script para obtener ejemplos de la tabla parametros
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== OBTENIENDO DATOS DE PARAMETROS ===\n\n";

    // Consultar la tabla parametros en catastro_gdl
    echo "1. Estructura de catastro_gdl.parametros:\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl' AND table_name = 'parametros'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        echo "   - {$col['column_name']} ({$col['data_type']})\n";
    }

    echo "\n2. Datos en la tabla:\n";
    $stmt = $pdo->query("SELECT * FROM catastro_gdl.parametros");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total de registros: " . count($rows) . "\n\n";

    foreach ($rows as $i => $row) {
        echo "   Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            $val = $value ?? 'NULL';
            if (strlen($val) > 80) $val = substr($val, 0, 80) . '...';
            echo "     $key: $val\n";
        }
        echo "\n";
    }

    echo "\n3. Probando el SP con diferentes años:\n\n";

    $test_years = [2024, 2023, 2025, 2022, 2026];

    foreach ($test_years as $year) {
        echo "   Ejercicio $year:\n";
        $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_periodo_inicial(:ejercicio)");
        $stmt->execute(['ejercicio' => $year]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($results) {
            echo "     ✓ Encontrado - {$results[0]['municipio']}\n";
            echo "       Rango: Bim {$results[0]['bimestre_inicial']}/{$results[0]['año_inicial']} a Bim {$results[0]['bimestre_final']}/{$results[0]['año_final']}\n";
        } else {
            echo "     ✗ Sin resultados\n";
        }
        echo "\n";
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
