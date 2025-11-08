<?php
/**
 * Analizar estructura de la tabla de producción: comun.dictamenes
 * Fecha: 2025-11-05
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "\n========================================\n";
    echo "TABLA DE PRODUCCIÓN: comun.dictamenes\n";
    echo "========================================\n\n";

    // Estructura completa
    echo "📋 ESTRUCTURA COMPLETA:\n";
    echo str_repeat("-", 130) . "\n";
    printf("%-30s %-25s %-15s %-15s %-30s\n",
        "Column Name", "Data Type", "Max Length", "Nullable", "Default");
    echo str_repeat("-", 130) . "\n";

    $stmt = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_schema = 'comun'
            AND table_name = 'dictamenes'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_OBJ);

    foreach ($columns as $col) {
        printf("%-30s %-25s %-15s %-15s %-30s\n",
            $col->column_name,
            $col->data_type,
            $col->character_maximum_length ?? 'N/A',
            $col->is_nullable,
            substr($col->column_default ?? 'NULL', 0, 30)
        );
    }
    echo str_repeat("-", 130) . "\n\n";

    // Índices
    echo "🔑 ÍNDICES EXISTENTES:\n";
    echo str_repeat("-", 100) . "\n";

    $stmt = $pdo->query("
        SELECT
            i.relname as index_name,
            string_agg(a.attname, ', ' ORDER BY a.attnum) as columns,
            ix.indisunique as is_unique,
            ix.indisprimary as is_primary
        FROM pg_class t
        JOIN pg_index ix ON t.oid = ix.indrelid
        JOIN pg_class i ON i.oid = ix.indexrelid
        JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
        JOIN pg_namespace n ON t.relnamespace = n.oid
        WHERE n.nspname = 'comun'
            AND t.relname = 'dictamenes'
        GROUP BY i.relname, ix.indisunique, ix.indisprimary
        ORDER BY i.relname
    ");

    $indices = $stmt->fetchAll(PDO::FETCH_OBJ);

    if (count($indices) > 0) {
        foreach ($indices as $idx) {
            $type = $idx->is_primary ? 'PRIMARY KEY' : ($idx->is_unique ? 'UNIQUE' : 'INDEX');
            echo "📌 {$idx->index_name} ({$type})\n";
            echo "   Columnas: {$idx->columns}\n\n";
        }
    } else {
        echo "❌ No se encontraron índices (CRÍTICO para 17K registros)\n";
    }
    echo str_repeat("-", 100) . "\n\n";

    // Estadísticas detalladas
    echo "📊 ESTADÍSTICAS DETALLADAS:\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $pdo->query("
        SELECT
            COUNT(*) as total,
            COUNT(DISTINCT propietario) as propietarios_unicos,
            COUNT(DISTINCT domicilio) as domicilios_unicos,
            COUNT(DISTINCT actividad) as actividades_unicas,
            MIN(fecha) as fecha_min,
            MAX(fecha) as fecha_max,
            AVG(supconst) as promedio_sup_const,
            AVG(area_util) as promedio_area_util
        FROM comun.dictamenes
    ");

    $stats = $stmt->fetch(PDO::FETCH_OBJ);

    echo "Total de registros: " . number_format($stats->total) . "\n";
    echo "Propietarios únicos: " . number_format($stats->propietarios_unicos) . "\n";
    echo "Domicilios únicos: " . number_format($stats->domicilios_unicos) . "\n";
    echo "Actividades únicas: " . number_format($stats->actividades_unicas) . "\n";
    echo "Rango de fechas: {$stats->fecha_min} a {$stats->fecha_max}\n";
    echo "Promedio superficie construida: " . number_format($stats->promedio_sup_const, 2) . " m²\n";
    echo "Promedio área útil: " . number_format($stats->promedio_area_util, 2) . " m²\n\n";

    // Análisis del campo 'dictamen' (valores posibles)
    echo "🔍 VALORES DEL CAMPO 'dictamen':\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $pdo->query("
        SELECT
            dictamen,
            COUNT(*) as cantidad,
            ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM comun.dictamenes), 2) as porcentaje
        FROM comun.dictamenes
        GROUP BY dictamen
        ORDER BY cantidad DESC
    ");

    $valores = $stmt->fetchAll(PDO::FETCH_OBJ);

    foreach ($valores as $val) {
        $estado = is_null($val->dictamen) ? 'NULL' : $val->dictamen;
        echo "{$estado}: " . number_format($val->cantidad) . " ({$val->porcentaje}%)\n";
    }

    echo "\n";

    // Muestra de 2 registros recientes
    echo "📄 MUESTRA DE REGISTROS RECIENTES:\n";
    echo str_repeat("-", 120) . "\n";

    $stmt = $pdo->query("
        SELECT * FROM comun.dictamenes
        ORDER BY fecha DESC NULLS LAST
        LIMIT 2
    ");

    $sample = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($sample as $idx => $row) {
        echo "\n--- Registro #" . ($idx + 1) . " ---\n";
        foreach ($row as $key => $value) {
            $display_value = is_null($value) ? 'NULL' : (is_string($value) ? trim($value) : $value);
            if (strlen((string)$display_value) > 60) {
                $display_value = substr($display_value, 0, 60) . '...';
            }
            echo "  {$key}: {$display_value}\n";
        }
    }

    echo "\n========================================\n";
    echo "ANÁLISIS COMPLETADO\n";
    echo "========================================\n\n";

    echo "⚠️  RECOMENDACIONES:\n";
    echo "1. Crear índices en: propietario, domicilio, actividad, fecha, dictamen\n";
    echo "2. Considerar índice compuesto para búsquedas combinadas\n";
    echo "3. Crear los 5 SPs necesarios en esquema 'comun'\n";
    echo "4. Verificar y limpiar datos con CHAR (espacios en blanco)\n\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n\n";
    exit(1);
}
