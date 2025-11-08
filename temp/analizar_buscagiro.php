<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "ANÁLISIS: BÚSQUEDA DE GIROS\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // 1. Verificar tabla de giros
    echo "========================================\n";
    echo "1. ANÁLISIS TABLA GIROS\n";
    echo "========================================\n\n";

    // Buscar tabla de giros en diferentes schemas
    $stmt = $pdo->query("
        SELECT table_schema, table_name,
               pg_size_pretty(pg_total_relation_size(quote_ident(table_schema) || '.' || quote_ident(table_name))) AS size
        FROM information_schema.tables
        WHERE table_name LIKE '%giro%'
        AND table_schema NOT IN ('pg_catalog', 'information_schema')
        ORDER BY table_schema, table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "Tablas encontradas relacionadas con 'giro':\n\n";
        foreach ($tables as $table) {
            echo "  • {$table['table_schema']}.{$table['table_name']} ({$table['size']})\n";
        }
        echo "\n";
    }

    // 2. Buscar la tabla principal de giros
    echo "========================================\n";
    echo "2. ESTRUCTURA TABLA PRINCIPAL\n";
    echo "========================================\n\n";

    // Intentar con comun.giros primero
    $schemas = ['comun', 'guadalajara', 'padron_licencias', 'public'];
    $girosTable = null;
    $girosSchema = null;

    foreach ($schemas as $schema) {
        try {
            $stmt = $pdo->query("SELECT COUNT(*) FROM {$schema}.giros");
            if ($stmt->fetchColumn() > 0) {
                $girosTable = 'giros';
                $girosSchema = $schema;
                break;
            }
        } catch (Exception $e) {
            continue;
        }
    }

    if ($girosTable) {
        echo "Tabla principal encontrada: {$girosSchema}.{$girosTable}\n\n";

        // Obtener estructura
        $stmt = $pdo->query("
            SELECT
                column_name,
                data_type,
                character_maximum_length,
                is_nullable
            FROM information_schema.columns
            WHERE table_schema = '{$girosSchema}'
            AND table_name = 'giros'
            ORDER BY ordinal_position
        ");

        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "Columnas de {$girosSchema}.giros:\n\n";
        foreach ($columns as $col) {
            $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : '';
            echo sprintf("  %-30s %s%s %s\n",
                $col['column_name'],
                $col['data_type'],
                $length,
                $nullable
            );
        }
        echo "\n";

        // Contar registros
        $stmt = $pdo->query("SELECT COUNT(*) FROM {$girosSchema}.giros");
        $total = $stmt->fetchColumn();
        echo "Total de registros: " . number_format($total) . "\n\n";

        // Verificar índices
        $stmt = $pdo->query("
            SELECT
                indexname,
                indexdef
            FROM pg_indexes
            WHERE schemaname = '{$girosSchema}'
            AND tablename = 'giros'
        ");

        $indices = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "Índices existentes:\n\n";
        if (count($indices) > 0) {
            foreach ($indices as $idx) {
                echo "  • {$idx['indexname']}\n";
                echo "    {$idx['indexdef']}\n\n";
            }
        } else {
            echo "  ⚠️ NO HAY ÍNDICES (excepto PK)\n\n";
        }
    } else {
        echo "⚠️ No se encontró tabla 'giros' en ningún schema\n\n";
    }

    // 3. Verificar SP
    echo "========================================\n";
    echo "3. STORED PROCEDURES\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname ILIKE '%buscagiro%'
        OR p.proname ILIKE '%busca_giro%'
        OR p.proname ILIKE '%giro%list%'
        ORDER BY n.nspname, p.proname
    ");

    $procedures = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($procedures) > 0) {
        echo "Stored procedures encontrados:\n\n";
        foreach ($procedures as $proc) {
            echo "  • {$proc['schema']}.{$proc['name']}\n";
            echo "    Parámetros: {$proc['arguments']}\n\n";
        }
    } else {
        echo "⚠️ No se encontraron SPs para búsqueda de giros\n\n";
    }

    // 4. Test query simple
    if ($girosTable && $girosSchema) {
        echo "========================================\n";
        echo "4. TEST CONSULTA SIMPLE\n";
        echo "========================================\n\n";

        $start = microtime(true);
        $stmt = $pdo->query("
            SELECT * FROM {$girosSchema}.giros
            WHERE descripcion ILIKE '%comercio%'
            LIMIT 10
        ");
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $duration = round((microtime(true) - $start) * 1000, 2);

        echo "Consulta: Buscar giros con 'comercio' (10 registros)\n";
        echo "⏱ Tiempo: {$duration}ms\n\n";

        if (count($results) > 0) {
            echo "Ejemplo de resultado:\n\n";
            $sample = $results[0];
            foreach ($sample as $key => $value) {
                echo sprintf("  %-25s: %s\n", $key, $value);
            }
            echo "\n";
        }
    }

    // 5. Análisis de filtros comunes
    if ($girosTable && $girosSchema) {
        echo "========================================\n";
        echo "5. ANÁLISIS DE DATOS\n";
        echo "========================================\n\n";

        // Tipos
        $stmt = $pdo->query("
            SELECT tipo, COUNT(*) as total
            FROM {$girosSchema}.giros
            GROUP BY tipo
            ORDER BY total DESC
        ");
        $tipos = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "Distribución por tipo:\n";
        foreach ($tipos as $tipo) {
            echo sprintf("  %-20s: %s\n", $tipo['tipo'] ?? 'NULL', number_format($tipo['total']));
        }
        echo "\n";

        // Vigentes vs No vigentes
        $stmt = $pdo->query("
            SELECT vigente, COUNT(*) as total
            FROM {$girosSchema}.giros
            GROUP BY vigente
            ORDER BY total DESC
        ");
        $vigentes = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "Distribución por vigencia:\n";
        foreach ($vigentes as $vig) {
            echo sprintf("  %-20s: %s\n", $vig['vigente'] ?? 'NULL', number_format($vig['total']));
        }
        echo "\n";
    }

    echo "✅ Análisis completado\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
