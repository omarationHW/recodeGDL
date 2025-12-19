<?php
// Script para analizar la estructura de resolucion_juez

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ANÁLISIS DETALLADO DE public.resolucion_juez ===\n\n";

    // 1. Contar registros
    $count = $pdo->query("SELECT COUNT(*) as total FROM public.resolucion_juez")->fetch(PDO::FETCH_ASSOC);
    echo "Total de registros: " . $count['total'] . "\n\n";

    // 2. Estructura de la tabla
    echo "ESTRUCTURA DE LA TABLA:\n";
    echo str_repeat("=", 80) . "\n\n";

    $stmt = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            column_default,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'resolucion_juez'
        ORDER BY ordinal_position
    ");

    $columnas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columnas as $col) {
        $tipo = $col['data_type'];
        if ($col['character_maximum_length']) {
            $tipo .= "(" . $col['character_maximum_length'] . ")";
        }
        $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
        $default = $col['column_default'] ? " DEFAULT " . $col['column_default'] : "";

        echo "  " . str_pad($col['column_name'], 25) . " ";
        echo str_pad($tipo, 25) . " ";
        echo str_pad($nullable, 10) . $default . "\n";
    }

    // 3. Muestra de datos (todos los registros ya que son solo 59)
    echo "\n\n";
    echo "MUESTRA DE DATOS (primeros 5 registros):\n";
    echo str_repeat("=", 80) . "\n\n";

    $stmt = $pdo->query("
        SELECT *
        FROM public.resolucion_juez
        ORDER BY id_resolucion DESC
        LIMIT 5
    ");

    $registros = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($registros as $idx => $reg) {
        echo "REGISTRO " . ($idx + 1) . ":\n";
        echo str_repeat("-", 80) . "\n";
        foreach ($reg as $key => $value) {
            echo "  " . str_pad($key, 25) . ": " . ($value !== null ? $value : 'NULL') . "\n";
        }
        echo "\n";
    }

    // 4. Estadísticas
    echo "\n";
    echo "ESTADÍSTICAS:\n";
    echo str_repeat("=", 80) . "\n\n";

    // Rango de IDs
    $stmt = $pdo->query("
        SELECT
            MIN(id_resolucion) as min_id,
            MAX(id_resolucion) as max_id,
            COUNT(DISTINCT cvecuenta) as total_cuentas,
            MIN(axoini) as min_anio,
            MAX(axofin) as max_anio
        FROM public.resolucion_juez
    ");
    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "  ID mínimo: " . $stats['min_id'] . "\n";
    echo "  ID máximo: " . $stats['max_id'] . "\n";
    echo "  Cuentas únicas: " . $stats['total_cuentas'] . "\n";
    echo "  Año inicio (min): " . $stats['min_anio'] . "\n";
    echo "  Año fin (max): " . $stats['max_anio'] . "\n\n";

    // Distribución por vigencia
    $stmt = $pdo->query("
        SELECT
            vigencia,
            COUNT(*) as cantidad
        FROM public.resolucion_juez
        GROUP BY vigencia
        ORDER BY cantidad DESC
    ");

    echo "  Distribución por vigencia:\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        echo "    " . ($row['vigencia'] ?: 'NULL') . ": " . $row['cantidad'] . " registros\n";
    }

    // Distribución por accesorios
    $stmt = $pdo->query("
        SELECT
            accesorios,
            COUNT(*) as cantidad
        FROM public.resolucion_juez
        GROUP BY accesorios
        ORDER BY cantidad DESC
    ");

    echo "\n  Distribución por accesorios:\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        echo "    " . ($row['accesorios'] ?: 'NULL') . ": " . $row['cantidad'] . " registros\n";
    }

    // 5. Verificar campos NULL
    echo "\n\n";
    echo "ANÁLISIS DE CAMPOS NULL:\n";
    echo str_repeat("=", 80) . "\n\n";

    foreach ($columnas as $col) {
        $nombre = $col['column_name'];
        $count = $pdo->query("
            SELECT COUNT(*) as nulls
            FROM public.resolucion_juez
            WHERE $nombre IS NULL
        ")->fetch(PDO::FETCH_ASSOC);

        if ($count['nulls'] > 0) {
            echo "  " . str_pad($nombre, 25) . ": " . $count['nulls'] . " NULL\n";
        }
    }

    echo "\n✅ Análisis completado\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
