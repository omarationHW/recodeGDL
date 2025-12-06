<?php
/**
 * Verificación y Creación de Stored Procedures para Cuotas de Energía
 * Módulo: Cuotas de Energía Mantenimiento
 */

// Configuración de conexión
$config = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'database' => 'mercados',
    'user' => 'refact',
    'password' => 'FF)-BQk2'
];

try {
    $dsn = "pgsql:host={$config['host']};port={$config['port']};dbname={$config['database']}";
    $pdo = new PDO($dsn, $config['user'], $config['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "===== VERIFICACIÓN CUOTAS DE ENERGÍA =====\n\n";

    // PASO 1: Buscar la tabla correcta
    echo "PASO 1: Buscando tabla de kilowhatts/cuotas energía...\n";
    echo str_repeat("-", 80) . "\n";

    $searchTables = $pdo->query("
        SELECT
            schemaname,
            tablename,
            schemaname || '.' || tablename as full_name
        FROM pg_tables
        WHERE schemaname IN ('publico', 'public', 'mercados')
        AND (
            tablename LIKE '%kilowh%'
            OR tablename LIKE '%cuota%energia%'
            OR tablename LIKE '%energia%'
            OR tablename = 'ta_11_kilowhatts'
        )
        ORDER BY tablename
    ");

    $tables = $searchTables->fetchAll();
    echo "Tablas encontradas: " . count($tables) . "\n";
    foreach ($tables as $table) {
        echo "  - {$table['full_name']}\n";
    }
    echo "\n";

    // PASO 2: Verificar estructura de ta_11_kilowhatts
    echo "PASO 2: Verificando estructura de publico.ta_11_kilowhatts...\n";
    echo str_repeat("-", 80) . "\n";

    $structureQuery = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_schema = 'publico'
        AND table_name = 'ta_11_kilowhatts'
        ORDER BY ordinal_position
    ");

    $columns = $structureQuery->fetchAll();
    if (count($columns) > 0) {
        echo "Estructura de publico.ta_11_kilowhatts:\n";
        foreach ($columns as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) {
                $type .= "({$col['character_maximum_length']})";
            }
            $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
            $default = $col['column_default'] ? " DEFAULT {$col['column_default']}" : "";
            echo sprintf("  %-20s %-20s %-10s %s\n",
                $col['column_name'],
                $type,
                $nullable,
                $default
            );
        }
    } else {
        echo "⚠️  Tabla publico.ta_11_kilowhatts NO existe\n";
        // Buscar en otros esquemas
        $altQuery = $pdo->query("
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name = 'ta_11_kilowhatts'
        ");
        $altTables = $altQuery->fetchAll();
        if (count($altTables) > 0) {
            echo "Encontrada en:\n";
            foreach ($altTables as $t) {
                echo "  - {$t['table_schema']}.{$t['table_name']}\n";
            }
        }
    }
    echo "\n";

    // PASO 3: Verificar datos de ejemplo
    echo "PASO 3: Verificando datos de ejemplo...\n";
    echo str_repeat("-", 80) . "\n";

    try {
        $dataQuery = $pdo->query("
            SELECT * FROM publico.ta_11_kilowhatts
            ORDER BY axo DESC, periodo DESC
            LIMIT 5
        ");
        $sampleData = $dataQuery->fetchAll();

        if (count($sampleData) > 0) {
            echo "Registros de ejemplo (últimos 5):\n";
            foreach ($sampleData as $row) {
                echo "  " . json_encode($row, JSON_UNESCAPED_UNICODE) . "\n";
            }
            echo "\nTotal de registros: ";
            $countQuery = $pdo->query("SELECT COUNT(*) as total FROM publico.ta_11_kilowhatts");
            $count = $countQuery->fetch();
            echo $count['total'] . "\n";
        } else {
            echo "⚠️  Tabla vacía\n";
        }
    } catch (Exception $e) {
        echo "❌ Error: " . $e->getMessage() . "\n";
    }
    echo "\n";

    // PASO 4: Verificar SPs existentes
    echo "PASO 4: Verificando stored procedures existentes...\n";
    echo str_repeat("-", 80) . "\n";

    $spQuery = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as procedure_name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname IN ('publico', 'public')
        AND (
            p.proname LIKE '%cuota%energia%'
            OR p.proname LIKE '%kilowh%'
        )
        ORDER BY p.proname
    ");

    $existingSPs = $spQuery->fetchAll();
    if (count($existingSPs) > 0) {
        echo "SPs existentes relacionados:\n";
        foreach ($existingSPs as $sp) {
            echo "  - {$sp['schema']}.{$sp['procedure_name']}({$sp['arguments']})\n";
        }
    } else {
        echo "No se encontraron SPs existentes relacionados con cuotas de energía\n";
    }
    echo "\n";

    // PASO 5: Buscar SPs específicos
    echo "PASO 5: Buscando SPs específicos requeridos...\n";
    echo str_repeat("-", 80) . "\n";

    $requiredSPs = [
        'sp_list_cuotas_energia',
        'sp_insert_cuota_energia',
        'sp_update_cuota_energia',
        'sp_cuotas_energia_list',
        'sp_cuotas_energia_create',
        'sp_cuotas_energia_update'
    ];

    foreach ($requiredSPs as $spName) {
        $checkSP = $pdo->query("
            SELECT
                n.nspname as schema,
                p.proname,
                pg_get_functiondef(p.oid) as definition
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname = '$spName'
            AND n.nspname IN ('publico', 'public')
        ");

        $sp = $checkSP->fetch();
        if ($sp) {
            echo "✓ {$sp['schema']}.{$spName} EXISTE\n";
        } else {
            echo "✗ {$spName} NO EXISTE\n";
        }
    }
    echo "\n";

    echo "===== FIN VERIFICACIÓN =====\n";

} catch (PDOException $e) {
    echo "❌ ERROR DE CONEXIÓN: " . $e->getMessage() . "\n";
    exit(1);
}
