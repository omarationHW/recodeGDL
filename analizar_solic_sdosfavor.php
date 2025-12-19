<?php
// Script para analizar solic_sdosfavor

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ANÁLISIS DE public.solic_sdosfavor ===\n\n";

    // Contar registros
    $count = $pdo->query("SELECT COUNT(*) as total FROM public.solic_sdosfavor")->fetch(PDO::FETCH_ASSOC);
    echo "Total de registros: " . number_format($count['total']) . "\n\n";

    // Estructura
    echo "ESTRUCTURA:\n";
    echo str_repeat("=", 80) . "\n";

    $stmt = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'solic_sdosfavor'
        ORDER BY ordinal_position
    ");

    $columnas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columnas as $col) {
        $tipo = $col['data_type'];
        if ($col['character_maximum_length']) {
            $tipo .= "(" . $col['character_maximum_length'] . ")";
        }
        $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
        echo str_pad($col['column_name'], 20) . " " . str_pad($tipo, 20) . " " . $nullable . "\n";
    }

    // Muestra de datos
    echo "\n\nMUESTRA DE DATOS (5 registros):\n";
    echo str_repeat("=", 80) . "\n\n";

    $stmt = $pdo->query("
        SELECT *
        FROM public.solic_sdosfavor
        ORDER BY id_solic DESC
        LIMIT 5
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $idx => $reg) {
        echo "REGISTRO " . ($idx + 1) . ":\n";
        echo str_repeat("-", 80) . "\n";
        foreach ($reg as $key => $value) {
            echo "  " . str_pad($key, 20) . ": " . ($value !== null ? $value : 'NULL') . "\n";
        }
        echo "\n";
    }

    // Estadísticas
    echo "\nESTADÍSTICAS:\n";
    echo str_repeat("=", 80) . "\n\n";

    $stmt = $pdo->query("
        SELECT
            MIN(id_solic) as min_id,
            MAX(id_solic) as max_id,
            COUNT(DISTINCT cvecuenta) as total_cuentas,
            MIN(axofol) as min_anio,
            MAX(axofol) as max_anio,
            MIN(feccap) as min_fecha,
            MAX(feccap) as max_fecha
        FROM public.solic_sdosfavor
    ");
    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "  ID mínimo: " . $stats['min_id'] . "\n";
    echo "  ID máximo: " . $stats['max_id'] . "\n";
    echo "  Cuentas únicas: " . number_format($stats['total_cuentas']) . "\n";
    echo "  Años de folio: " . $stats['min_anio'] . " - " . $stats['max_anio'] . "\n";
    echo "  Fechas captura: " . $stats['min_fecha'] . " - " . $stats['max_fecha'] . "\n\n";

    // Distribución por status
    $stmt = $pdo->query("
        SELECT
            status,
            COUNT(*) as cantidad
        FROM public.solic_sdosfavor
        GROUP BY status
        ORDER BY cantidad DESC
    ");

    echo "  Distribución por status:\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        echo "    " . ($row['status'] ?: 'NULL') . ": " . number_format($row['cantidad']) . " registros\n";
    }

    // Distribución por año
    echo "\n  Top 10 años con más solicitudes:\n";
    $stmt = $pdo->query("
        SELECT
            axofol,
            COUNT(*) as cantidad
        FROM public.solic_sdosfavor
        GROUP BY axofol
        ORDER BY cantidad DESC
        LIMIT 10
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        echo "    " . $row['axofol'] . ": " . number_format($row['cantidad']) . " solicitudes\n";
    }

    // Campos NULL
    echo "\n\nCAMPOS CON VALORES NULL:\n";
    echo str_repeat("=", 80) . "\n\n";

    foreach ($columnas as $col) {
        $nombre = $col['column_name'];
        $count = $pdo->query("
            SELECT COUNT(*) as nulls
            FROM public.solic_sdosfavor
            WHERE $nombre IS NULL
        ")->fetch(PDO::FETCH_ASSOC);

        if ($count['nulls'] > 0) {
            echo "  " . str_pad($nombre, 20) . ": " . number_format($count['nulls']) . " NULL\n";
        }
    }

    echo "\n✅ Análisis completado\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
