<?php
/**
 * Buscar tabla de fechas de descuento y verificar estructura
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "=== BÚSQUEDA DE TABLA FECHAS DESCUENTO ===\n\n";

    // Buscar tablas con nombres similares
    $patterns = [
        'fecha_desc%',
        'fechas_desc%',
        '%fecha%desc%',
        'ta_11_fecha%',
        'ta_11_fechas%'
    ];

    $allTables = [];

    foreach ($patterns as $pattern) {
        $stmt = $pdo->prepare("
            SELECT
                table_schema,
                table_name,
                table_type
            FROM information_schema.tables
            WHERE table_name LIKE :pattern
            AND table_schema NOT IN ('pg_catalog', 'information_schema')
            ORDER BY table_schema, table_name
        ");
        $stmt->execute([':pattern' => $pattern]);
        $tables = $stmt->fetchAll();

        foreach ($tables as $table) {
            $key = $table['table_schema'] . '.' . $table['table_name'];
            $allTables[$key] = $table;
        }
    }

    if (empty($allTables)) {
        echo "❌ No se encontraron tablas con nombres relacionados a fechas de descuento\n\n";

        // Buscar en tablas que empiecen con ta_11
        echo "=== BUSCANDO TODAS LAS TABLAS ta_11 ===\n\n";
        $stmt = $pdo->query("
            SELECT
                table_schema,
                table_name
            FROM information_schema.tables
            WHERE table_name LIKE 'ta_11%'
            AND table_schema NOT IN ('pg_catalog', 'information_schema')
            ORDER BY table_schema, table_name
        ");
        $ta11Tables = $stmt->fetchAll();

        foreach ($ta11Tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }
    } else {
        echo "✅ Tablas encontradas:\n\n";
        foreach ($allTables as $key => $table) {
            echo "  📋 {$key} ({$table['table_type']})\n";
        }

        // Verificar estructura de cada tabla
        echo "\n=== ESTRUCTURA DE TABLAS ===\n\n";

        foreach ($allTables as $key => $table) {
            $schema = $table['table_schema'];
            $tableName = $table['table_name'];

            echo "📊 Tabla: {$schema}.{$tableName}\n";
            echo str_repeat("-", 80) . "\n";

            // Obtener columnas
            $stmt = $pdo->prepare("
                SELECT
                    column_name,
                    data_type,
                    character_maximum_length,
                    is_nullable,
                    column_default
                FROM information_schema.columns
                WHERE table_schema = :schema
                AND table_name = :table_name
                ORDER BY ordinal_position
            ");
            $stmt->execute([':schema' => $schema, ':table_name' => $tableName]);
            $columns = $stmt->fetchAll();

            foreach ($columns as $col) {
                $type = $col['data_type'];
                if ($col['character_maximum_length']) {
                    $type .= "({$col['character_maximum_length']})";
                }
                $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
                $default = $col['column_default'] ? " DEFAULT {$col['column_default']}" : '';

                echo sprintf("  %-25s %-25s %-10s%s\n",
                    $col['column_name'],
                    $type,
                    $nullable,
                    $default
                );
            }

            // Contar registros
            try {
                $stmt = $pdo->query("SELECT COUNT(*) as total FROM {$schema}.{$tableName}");
                $count = $stmt->fetch();
                echo "\n  📊 Total de registros: {$count['total']}\n";

                // Si tiene pocos registros, mostrarlos
                if ($count['total'] > 0 && $count['total'] <= 20) {
                    echo "\n  📄 Datos:\n";
                    $stmt = $pdo->query("SELECT * FROM {$schema}.{$tableName} ORDER BY 1 LIMIT 20");
                    $rows = $stmt->fetchAll();

                    if (!empty($rows)) {
                        // Mostrar headers
                        $headers = array_keys($rows[0]);
                        echo "  " . implode(" | ", $headers) . "\n";
                        echo "  " . str_repeat("-", 100) . "\n";

                        foreach ($rows as $row) {
                            echo "  " . implode(" | ", array_map(function($v) {
                                return $v === null ? 'NULL' : (string)$v;
                            }, $row)) . "\n";
                        }
                    }
                }
            } catch (Exception $e) {
                echo "\n  ⚠️  Error al contar registros: {$e->getMessage()}\n";
            }

            echo "\n";
        }
    }

    // Buscar stored procedures existentes relacionados
    echo "\n=== STORED PROCEDURES EXISTENTES ===\n\n";

    $stmt = $pdo->query("
        SELECT
            n.nspname as schema_name,
            p.proname as proc_name,
            pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE (
            p.proname LIKE '%fecha%desc%'
            OR p.proname LIKE '%fechadescuento%'
        )
        AND n.nspname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY n.nspname, p.proname
    ");

    $procs = $stmt->fetchAll();

    if (empty($procs)) {
        echo "❌ No se encontraron stored procedures relacionados\n";
    } else {
        echo "✅ Stored procedures encontrados: " . count($procs) . "\n\n";
        foreach ($procs as $proc) {
            echo "📝 {$proc['schema_name']}.{$proc['proc_name']}\n";
            echo str_repeat("=", 80) . "\n";
            echo $proc['definition'] . "\n\n";
        }
    }

    echo "\n✅ Análisis completado\n";

} catch (PDOException $e) {
    echo "❌ Error de conexión: " . $e->getMessage() . "\n";
    exit(1);
}
