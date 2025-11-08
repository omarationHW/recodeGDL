<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "VERIFICAR SP DE ANUNCIOS\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Verificar SPs existentes relacionados con anuncios
    echo "Buscando stored procedures de anuncios...\n\n";

    $stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as function_name,
            pg_get_function_arguments(p.oid) as arguments,
            pg_get_function_result(p.oid) as return_type
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname IN ('public', 'comun')
        AND (
            p.proname ILIKE '%anuncio%'
            OR p.proname ILIKE '%consulta_anuncios%'
        )
        ORDER BY n.nspname, p.proname
    ");

    $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($sps) > 0) {
        echo "✓ SPs encontrados: " . count($sps) . "\n\n";
        foreach ($sps as $sp) {
            echo "========================================\n";
            echo "Schema: " . $sp['schema'] . "\n";
            echo "Función: " . $sp['function_name'] . "\n";
            echo "Argumentos: " . $sp['arguments'] . "\n";
            echo "Retorno: " . $sp['return_type'] . "\n";
            echo "========================================\n\n";
        }
    } else {
        echo "⚠ No se encontraron SPs para anuncios\n\n";
    }

    // Verificar tabla de anuncios
    echo "========================================\n";
    echo "ANALIZANDO TABLA DE ANUNCIOS\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables
        WHERE tablename ILIKE '%anuncio%'
        AND schemaname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY schemaname, tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "✓ Tablas encontradas: " . count($tables) . "\n\n";
        foreach ($tables as $table) {
            echo "Schema: {$table['schemaname']}\n";
            echo "Tabla: {$table['tablename']}\n";
            echo "Tamaño: {$table['size']}\n\n";

            // Obtener conteo de registros
            $countStmt = $pdo->query("SELECT COUNT(*) as total FROM {$table['schemaname']}.{$table['tablename']}");
            $count = $countStmt->fetch(PDO::FETCH_ASSOC);
            echo "Registros: " . number_format($count['total']) . "\n\n";

            // Verificar índices
            $idxStmt = $pdo->prepare("
                SELECT
                    indexname,
                    indexdef
                FROM pg_indexes
                WHERE schemaname = :schema
                AND tablename = :table
                ORDER BY indexname
            ");
            $idxStmt->execute([
                'schema' => $table['schemaname'],
                'table' => $table['tablename']
            ]);
            $indices = $idxStmt->fetchAll(PDO::FETCH_ASSOC);

            echo "Índices existentes: " . count($indices) . "\n";
            foreach ($indices as $idx) {
                echo "  ✓ {$idx['indexname']}\n";
            }
            echo "\n";

            // Verificar columnas importantes
            $colStmt = $pdo->prepare("
                SELECT
                    column_name,
                    data_type,
                    is_nullable
                FROM information_schema.columns
                WHERE table_schema = :schema
                AND table_name = :table
                AND column_name IN ('vigente', 'zona', 'fecha_otorgamiento', 'anuncio', 'id_anuncio', 'id_licencia')
                ORDER BY column_name
            ");
            $colStmt->execute([
                'schema' => $table['schemaname'],
                'table' => $table['tablename']
            ]);
            $columnas = $colStmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($columnas) > 0) {
                echo "Columnas importantes:\n";
                foreach ($columnas as $col) {
                    echo "  - {$col['column_name']} ({$col['data_type']}) - Nullable: {$col['is_nullable']}\n";
                }
                echo "\n";
            }

            echo "========================================\n\n";
        }
    } else {
        echo "⚠ No se encontraron tablas de anuncios\n";
    }

    echo "✅ Análisis completado\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
