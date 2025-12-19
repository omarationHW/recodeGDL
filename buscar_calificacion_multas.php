<?php
// Buscar tablas de calificación de multas para multasfrmcalif.vue

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS DE CALIFICACIÓN DE MULTAS ===\n\n";

    // Buscar todas las tablas con "calific" en el nombre
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename ILIKE '%calific%'
        AND schemaname IN ('public', 'publico')
        ORDER BY schemaname, tablename
    ");

    $tablas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tablas as $tabla) {
        echo "Tabla: {$tabla['schemaname']}.{$tabla['tablename']}\n";

        // Contar registros
        $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$tabla['schemaname']}.{$tabla['tablename']}");
        $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
        echo "  Registros: " . number_format($count['total']) . "\n";

        // Ver estructura
        $cols_stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = '{$tabla['schemaname']}'
            AND table_name = '{$tabla['tablename']}'
            ORDER BY ordinal_position
        ");

        $cols = $cols_stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($cols) > 0) {
            echo "  Campos:\n";
            foreach ($cols as $col) {
                $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                echo "    - {$col['column_name']}: {$col['data_type']}$len\n";
            }
        }

        echo "\n" . str_repeat("-", 70) . "\n\n";
    }

    // Buscar también tablas de multas en general (que podrían tener calificación)
    echo "\n=== TABLAS DE MULTAS CON CAMPO CALIFICACION ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT table_schema, table_name
        FROM information_schema.columns
        WHERE column_name ILIKE '%calific%'
        AND table_schema IN ('public', 'publico')
        AND table_name ILIKE '%multa%'
        ORDER BY table_schema, table_name
    ");

    $tablas_con_calific = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tablas_con_calific as $tabla) {
        echo "Tabla: {$tabla['table_schema']}.{$tabla['table_name']}\n";

        // Contar registros
        $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$tabla['table_schema']}.{$tabla['table_name']}");
        $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
        echo "  Registros: " . number_format($count['total']) . "\n";

        // Ver solo campos relacionados con calificación
        $cols_stmt = $pdo->query("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = '{$tabla['table_schema']}'
            AND table_name = '{$tabla['table_name']}'
            AND column_name ILIKE '%calific%'
        ");

        $cols = $cols_stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "  Campos de calificación:\n";
        foreach ($cols as $col) {
            echo "    - {$col['column_name']}: {$col['data_type']}\n";
        }

        echo "\n" . str_repeat("-", 70) . "\n\n";
    }

    // Ver detalle de tipo_calificacion_multa
    echo "\n=== DETALLE DE publico.tipo_calificacion_multa ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'publico' AND table_name = 'tipo_calificacion_multa'
        ORDER BY ordinal_position
    ");

    echo "Estructura completa:\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $col) {
        $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}$len\n";
    }

    // Ver ejemplos de registros
    echo "\n\nEjemplos de registros:\n";
    $stmt = $pdo->query("
        SELECT
            tc.id_control,
            tc.id_multa,
            tc.tipo_calificacion,
            tc.usuario,
            tc.fecha_actual
        FROM publico.tipo_calificacion_multa tc
        ORDER BY tc.fecha_actual DESC
        LIMIT 5
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $i => $row) {
        echo "\n  " . ($i + 1) . ". ID Control: {$row['id_control']}\n";
        echo "     ID Multa: {$row['id_multa']}\n";
        echo "     Tipo Calificación: {$row['tipo_calificacion']}\n";
        echo "     Usuario: {$row['usuario']}\n";
        echo "     Fecha: {$row['fecha_actual']}\n";
    }

    // Ver si podemos hacer JOIN con tabla de multas
    echo "\n\n=== VERIFICAR RELACIÓN CON MULTAS ===\n\n";

    // Buscar la tabla principal de multas que tenga id_multa
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.columns
        WHERE column_name = 'id_multa'
        AND table_schema IN ('public', 'publico')
        AND table_name ILIKE '%multa%'
        AND table_name NOT LIKE '%tipo_calificacion%'
        GROUP BY table_schema, table_name
    ");

    $tablas_multas = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Tablas con campo id_multa:\n";
    foreach ($tablas_multas as $tm) {
        echo "  - {$tm['table_schema']}.{$tm['table_name']}\n";
    }

    // Ver distribución por tipo de calificación
    echo "\n\n=== DISTRIBUCIÓN POR TIPO DE CALIFICACIÓN ===\n\n";
    $stmt = $pdo->query("
        SELECT
            tipo_calificacion,
            COUNT(*) as total
        FROM publico.tipo_calificacion_multa
        GROUP BY tipo_calificacion
        ORDER BY total DESC
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        echo "  {$row['tipo_calificacion']}: " . number_format($row['total']) . "\n";
    }

    echo "\n\n✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
