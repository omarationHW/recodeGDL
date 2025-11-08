<?php
/**
 * Analizar estructura de la tabla de dictámenes
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
    echo "ANÁLISIS DE TABLA DICTÁMENES\n";
    echo "========================================\n\n";

    // Buscar tabla en diferentes esquemas
    $schemas = ['guadalajara', 'comun', 'public'];
    $table_found = false;
    $table_schema = null;
    $table_name = null;

    foreach ($schemas as $schema) {
        $stmt = $pdo->query("
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = '$schema'
                AND table_name LIKE '%dictamen%'
        ");

        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);

        if (count($tables) > 0) {
            echo "📁 Tablas encontradas en esquema '$schema':\n";
            foreach ($tables as $tbl) {
                echo "   - $tbl\n";
                if (!$table_found) {
                    $table_found = true;
                    $table_schema = $schema;
                    $table_name = $tbl;
                }
            }
            echo "\n";
        }
    }

    if (!$table_found) {
        echo "❌ No se encontró ninguna tabla relacionada con 'dictamen'\n\n";
        exit(0);
    }

    echo "🔍 Analizando tabla: {$table_schema}.{$table_name}\n\n";

    // Estructura de la tabla
    echo "📋 ESTRUCTURA DE LA TABLA:\n";
    echo str_repeat("-", 120) . "\n";
    printf("%-30s %-25s %-15s %-15s %-15s\n",
        "Column Name", "Data Type", "Max Length", "Nullable", "Default");
    echo str_repeat("-", 120) . "\n";

    $stmt = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_schema = '$table_schema'
            AND table_name = '$table_name'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_OBJ);

    foreach ($columns as $col) {
        printf("%-30s %-25s %-15s %-15s %-15s\n",
            $col->column_name,
            $col->data_type,
            $col->character_maximum_length ?? 'N/A',
            $col->is_nullable,
            substr($col->column_default ?? 'NULL', 0, 15)
        );
    }
    echo str_repeat("-", 120) . "\n\n";

    // Índices existentes
    echo "🔑 ÍNDICES EXISTENTES:\n";
    echo str_repeat("-", 100) . "\n";

    $stmt = $pdo->query("
        SELECT
            i.relname as index_name,
            a.attname as column_name,
            ix.indisunique as is_unique,
            ix.indisprimary as is_primary
        FROM pg_class t
        JOIN pg_index ix ON t.oid = ix.indrelid
        JOIN pg_class i ON i.oid = ix.indexrelid
        JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
        JOIN pg_namespace n ON t.relnamespace = n.oid
        WHERE n.nspname = '$table_schema'
            AND t.relname = '$table_name'
        ORDER BY i.relname, a.attnum
    ");

    $indices = $stmt->fetchAll(PDO::FETCH_OBJ);

    if (count($indices) > 0) {
        $current_index = null;
        foreach ($indices as $idx) {
            if ($current_index !== $idx->index_name) {
                $type = $idx->is_primary ? 'PRIMARY KEY' : ($idx->is_unique ? 'UNIQUE' : 'INDEX');
                echo "\n📌 {$idx->index_name} ({$type})\n";
                echo "   Columnas: {$idx->column_name}";
                $current_index = $idx->index_name;
            } else {
                echo ", {$idx->column_name}";
            }
        }
        echo "\n";
    } else {
        echo "❌ No se encontraron índices\n";
    }
    echo str_repeat("-", 100) . "\n\n";

    // Estadísticas de la tabla
    echo "📊 ESTADÍSTICAS:\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM {$table_schema}.{$table_name}");
    $stats = $stmt->fetch(PDO::FETCH_OBJ);

    echo "Total de registros: " . number_format($stats->total) . "\n";

    // Muestra de datos
    echo "\n📄 MUESTRA DE DATOS (primeros 3 registros):\n";
    echo str_repeat("-", 120) . "\n";

    $stmt = $pdo->query("SELECT * FROM {$table_schema}.{$table_name} LIMIT 3");
    $sample = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($sample) > 0) {
        foreach ($sample as $row) {
            echo "\nRegistro:\n";
            foreach ($row as $key => $value) {
                $display_value = is_null($value) ? 'NULL' : substr($value, 0, 50);
                echo "  {$key}: {$display_value}\n";
            }
        }
    }

    echo "\n========================================\n";
    echo "ANÁLISIS COMPLETADO\n";
    echo "========================================\n\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n\n";
    exit(1);
}
