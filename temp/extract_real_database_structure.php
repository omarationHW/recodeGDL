<?php
/**
 * Script para extraer la estructura REAL de la base de datos PostgreSQL
 * Genera reportes con la estructura exacta de las tablas más importantes
 */

// Configuración de conexión
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    echo "🔌 Conectando a PostgreSQL...\n";
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✅ Conectado exitosamente\n\n";

    $report = [
        'timestamp' => date('Y-m-d H:i:s'),
        'database' => $dbname,
        'schemas' => []
    ];

    // 1. Obtener todos los schemas
    echo "📊 Obteniendo schemas...\n";
    $schemasQuery = "
        SELECT schema_name,
               (SELECT COUNT(*) FROM information_schema.tables t WHERE t.table_schema = s.schema_name AND t.table_type = 'BASE TABLE') as table_count
        FROM information_schema.schemata s
        WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
        ORDER BY schema_name
    ";
    $schemas = $pdo->query($schemasQuery)->fetchAll(PDO::FETCH_ASSOC);

    echo "   Schemas encontrados: " . count($schemas) . "\n\n";
    foreach ($schemas as $schema) {
        echo "   - {$schema['schema_name']}: {$schema['table_count']} tablas\n";
    }
    echo "\n";

    // 2. Para tablas específicas importantes, obtener estructura completa
    $importantTables = [
        // Aseo Contratado
        ['schema' => 'public', 'table' => 'ta_16_contratos'],
        ['schema' => 'public', 'table' => 'ta_16_empresas'],
        ['schema' => 'public', 'table' => 'ta_16_pagos'],
        ['schema' => 'comun', 'table' => 'ta_16_tipo_aseo'],

        // Padrón de Licencias
        ['schema' => 'comun', 'table' => 'licencias'],
        ['schema' => 'comun', 'table' => 'anuncios'],
        ['schema' => 'comun', 'table' => 'tramites'],
        ['schema' => 'comun', 'table' => 'c_giros'],
        ['schema' => 'comun', 'table' => 'bloqueo'],
        ['schema' => 'public', 'table' => 'certificaciones'],

        // Mercados
        ['schema' => 'comun', 'table' => 'ta_11_mercados'],
        ['schema' => 'comun', 'table' => 'ta_11_locales'],

        // Transversales
        ['schema' => 'comun', 'table' => 'ta_12_recaudadoras'],
        ['schema' => 'comun', 'table' => 'ta_12_operaciones'],
        ['schema' => 'comun', 'table' => 'ta_12_passwords'],
    ];

    echo "📋 Analizando tablas importantes...\n\n";

    $tableDetails = [];

    foreach ($importantTables as $tableInfo) {
        $schema = $tableInfo['schema'];
        $table = $tableInfo['table'];

        echo "   Analizando {$schema}.{$table}...\n";

        // Verificar si la tabla existe
        $checkQuery = "
            SELECT COUNT(*) as exists
            FROM information_schema.tables
            WHERE table_schema = :schema AND table_name = :table
        ";
        $stmt = $pdo->prepare($checkQuery);
        $stmt->execute(['schema' => $schema, 'table' => $table]);
        $exists = $stmt->fetch(PDO::FETCH_ASSOC)['exists'];

        if ($exists == 0) {
            echo "      ⚠️ Tabla NO existe\n";
            continue;
        }

        // Obtener columnas
        $columnsQuery = "
            SELECT
                column_name,
                data_type,
                character_maximum_length,
                numeric_precision,
                numeric_scale,
                is_nullable,
                column_default,
                ordinal_position
            FROM information_schema.columns
            WHERE table_schema = :schema AND table_name = :table
            ORDER BY ordinal_position
        ";
        $stmt = $pdo->prepare($columnsQuery);
        $stmt->execute(['schema' => $schema, 'table' => $table]);
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Obtener constraints
        $constraintsQuery = "
            SELECT
                tc.constraint_name,
                tc.constraint_type,
                kcu.column_name,
                ccu.table_schema AS foreign_table_schema,
                ccu.table_name AS foreign_table_name,
                ccu.column_name AS foreign_column_name
            FROM information_schema.table_constraints AS tc
            LEFT JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
              AND tc.table_schema = kcu.table_schema
            LEFT JOIN information_schema.constraint_column_usage AS ccu
              ON ccu.constraint_name = tc.constraint_name
              AND ccu.table_schema = tc.table_schema
            WHERE tc.table_schema = :schema AND tc.table_name = :table
        ";
        $stmt = $pdo->prepare($constraintsQuery);
        $stmt->execute(['schema' => $schema, 'table' => $table]);
        $constraints = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Obtener índices
        $indexesQuery = "
            SELECT
                indexname,
                indexdef
            FROM pg_indexes
            WHERE schemaname = :schema AND tablename = :table
        ";
        $stmt = $pdo->prepare($indexesQuery);
        $stmt->execute(['schema' => $schema, 'table' => $table]);
        $indexes = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Obtener conteo de registros (LIMIT para evitar timeout)
        try {
            $countQuery = "SELECT COUNT(*) as total FROM {$schema}.{$table}";
            $count = $pdo->query($countQuery)->fetch(PDO::FETCH_ASSOC)['total'];
        } catch (Exception $e) {
            $count = 'N/A';
        }

        $tableDetails[] = [
            'schema' => $schema,
            'table' => $table,
            'columns' => $columns,
            'constraints' => $constraints,
            'indexes' => $indexes,
            'row_count' => $count
        ];

        $colCount = $columns ? count($columns) : 0;
        $formattedCount = ($count !== 'N/A') ? number_format($count) : 'N/A';
        echo "      ✓ {$colCount} columnas, " .
             count($constraints) . " constraints, " .
             count($indexes) . " índices, " .
             $formattedCount . " registros\n";
    }

    echo "\n";

    // 3. Generar reporte Markdown
    echo "📝 Generando reporte Markdown...\n";

    $markdown = "# ESTRUCTURA REAL DE LA BASE DE DATOS - VERIFICADA\n\n";
    $markdown .= "**Generado:** " . date('Y-m-d H:i:s') . "\n";
    $markdown .= "**Base de Datos:** $dbname\n";
    $markdown .= "**Servidor:** $host:$port\n";
    $markdown .= "**Usuario:** $user\n\n";
    $markdown .= "---\n\n";
    $markdown .= "## ⚠️ IMPORTANTE\n\n";
    $markdown .= "Este documento contiene la estructura REAL extraída directamente de PostgreSQL.\n";
    $markdown .= "Todos los tipos de datos, constraints e índices son VERIFICADOS.\n\n";
    $markdown .= "---\n\n";
    $markdown .= "## RESUMEN DE SCHEMAS\n\n";
    $markdown .= "| Schema | Tablas | Observaciones |\n";
    $markdown .= "|--------|--------|---------------|\n";

    foreach ($schemas as $schema) {
        $markdown .= "| {$schema['schema_name']} | {$schema['table_count']} | ";

        switch ($schema['schema_name']) {
            case 'public':
                $markdown .= "Schema principal - SPs y tablas específicas";
                break;
            case 'comun':
                $markdown .= "Tablas compartidas entre módulos";
                break;
            case 'catastro_gdl':
                $markdown .= "Datos catastrales";
                break;
            case 'informix':
                $markdown .= "Legacy - Migración de Informix";
                break;
            case 'db_ingresos':
                $markdown .= "Ingresos municipales";
                break;
            default:
                $markdown .= "-";
        }

        $markdown .= " |\n";
    }

    $markdown .= "\n---\n\n";
    $markdown .= "## TABLAS ANALIZADAS (ESTRUCTURA VERIFICADA)\n\n";

    foreach ($tableDetails as $tableData) {
        $schema = $tableData['schema'];
        $table = $tableData['table'];
        $columns = $tableData['columns'];
        $constraints = $tableData['constraints'];
        $indexes = $tableData['indexes'];
        $count = $tableData['row_count'];

        $markdown .= "### Tabla: `{$schema}.{$table}`\n\n";
        $markdown .= "**Registros:** " . ($count !== 'N/A' ? number_format($count) : 'N/A') . "\n\n";

        // Columnas
        $markdown .= "#### Campos\n\n";
        $markdown .= "| Campo | Tipo | Nulo | Default | Observaciones |\n";
        $markdown .= "|-------|------|------|---------|---------------|\n";

        foreach ($columns as $col) {
            $type = $col['data_type'];

            // Agregar precisión si aplica
            if ($col['character_maximum_length']) {
                $type .= "({$col['character_maximum_length']})";
            } elseif ($col['numeric_precision']) {
                $type .= "({$col['numeric_precision']}";
                if ($col['numeric_scale']) {
                    $type .= ",{$col['numeric_scale']}";
                }
                $type .= ")";
            }

            $nullable = $col['is_nullable'] === 'YES' ? 'SÍ' : 'NO';
            $default = $col['column_default'] ? substr($col['column_default'], 0, 30) . '...' : '-';

            // Buscar si es PK o FK
            $notes = [];
            foreach ($constraints as $constraint) {
                if ($constraint['column_name'] === $col['column_name']) {
                    if ($constraint['constraint_type'] === 'PRIMARY KEY') {
                        $notes[] = '**PK**';
                    } elseif ($constraint['constraint_type'] === 'FOREIGN KEY') {
                        $notes[] = "FK → {$constraint['foreign_table_schema']}.{$constraint['foreign_table_name']}";
                    } elseif ($constraint['constraint_type'] === 'UNIQUE') {
                        $notes[] = '**UK**';
                    }
                }
            }

            $observations = !empty($notes) ? implode(', ', $notes) : '-';

            $markdown .= "| {$col['column_name']} | {$type} | {$nullable} | {$default} | {$observations} |\n";
        }

        // Constraints
        if (!empty($constraints)) {
            $markdown .= "\n#### Constraints\n\n";

            $pks = array_filter($constraints, function($c) { return $c['constraint_type'] === 'PRIMARY KEY'; });
            $fks = array_filter($constraints, function($c) { return $c['constraint_type'] === 'FOREIGN KEY'; });
            $uks = array_filter($constraints, function($c) { return $c['constraint_type'] === 'UNIQUE'; });

            if (!empty($pks)) {
                $markdown .= "**Primary Keys:**\n";
                foreach ($pks as $pk) {
                    $markdown .= "- `{$pk['column_name']}`\n";
                }
                $markdown .= "\n";
            }

            if (!empty($fks)) {
                $markdown .= "**Foreign Keys:**\n";
                foreach ($fks as $fk) {
                    $markdown .= "- `{$fk['column_name']}` → `{$fk['foreign_table_schema']}.{$fk['foreign_table_name']}({$fk['foreign_column_name']})`\n";
                }
                $markdown .= "\n";
            }

            if (!empty($uks)) {
                $markdown .= "**Unique Keys:**\n";
                foreach ($uks as $uk) {
                    $markdown .= "- `{$uk['column_name']}`\n";
                }
                $markdown .= "\n";
            }
        }

        // Índices
        if (!empty($indexes)) {
            $markdown .= "#### Índices\n\n";
            foreach ($indexes as $index) {
                $markdown .= "- **{$index['indexname']}**\n";
                $markdown .= "  ```sql\n";
                $markdown .= "  {$index['indexdef']}\n";
                $markdown .= "  ```\n\n";
            }
        }

        $markdown .= "---\n\n";
    }

    // Guardar el reporte
    $outputPath = __DIR__ . '/../ESTRUCTURA_BD_REAL_VERIFICADA.md';
    file_put_contents($outputPath, $markdown);
    echo "✅ Reporte guardado en: $outputPath\n\n";

    // También guardar JSON para referencia
    $jsonPath = __DIR__ . '/database-structure-real.json';
    file_put_contents($jsonPath, json_encode(['schemas' => $schemas, 'tables' => $tableDetails], JSON_PRETTY_PRINT));
    echo "✅ JSON guardado en: $jsonPath\n\n";

    echo "═══════════════════════════════════════════════════\n";
    echo "✅ EXTRACCIÓN COMPLETADA\n";
    echo "═══════════════════════════════════════════════════\n\n";

} catch (PDOException $e) {
    echo "❌ Error de conexión: " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
