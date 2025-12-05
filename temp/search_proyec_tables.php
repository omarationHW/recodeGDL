<?php
// Buscar tablas relacionadas con proyecto
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BUSCANDO TABLAS CON 'PROYEC' ===\n\n";

    $sql = "
        SELECT
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables
        WHERE tablename ILIKE '%proyec%'
        AND schemaname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY schemaname, tablename
    ";

    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($tables)) {
        echo "No se encontraron tablas con 'proyec'\n\n";

        // Buscar tablas relacionadas con presupuesto
        echo "=== BUSCANDO TABLAS CON 'PRESUP' ===\n\n";

        $sql = "
            SELECT
                schemaname,
                tablename,
                pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
            FROM pg_tables
            WHERE tablename ILIKE '%presup%'
            AND schemaname IN ('comun', 'comunX', 'db_ingresos', 'public')
            ORDER BY schemaname, tablename
            LIMIT 20
        ";

        $stmt = $pdo->query($sql);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    foreach ($tables as $table) {
        echo "Schema: {$table['schemaname']}\n";
        echo "Tabla: {$table['tablename']}\n";
        echo "Tamaño: {$table['size']}\n";

        // Contar registros
        try {
            $countSql = "SELECT COUNT(*) as total FROM {$table['schemaname']}.{$table['tablename']}";
            $countStmt = $pdo->query($countSql);
            $count = $countStmt->fetch(PDO::FETCH_ASSOC);
            echo "Registros: {$count['total']}\n";
        } catch (Exception $e) {
            echo "Registros: Error al contar\n";
        }

        // Obtener estructura de columnas
        try {
            $colSql = "
                SELECT column_name, data_type, character_maximum_length
                FROM information_schema.columns
                WHERE table_schema = :schema AND table_name = :table
                ORDER BY ordinal_position
                LIMIT 10
            ";
            $colStmt = $pdo->prepare($colSql);
            $colStmt->execute([
                'schema' => $table['schemaname'],
                'table' => $table['tablename']
            ]);
            $columns = $colStmt->fetchAll(PDO::FETCH_ASSOC);

            echo "Columnas principales:\n";
            foreach ($columns as $col) {
                $type = $col['data_type'];
                if ($col['character_maximum_length']) {
                    $type .= "({$col['character_maximum_length']})";
                }
                echo "  - {$col['column_name']}: {$type}\n";
            }
        } catch (Exception $e) {
            echo "Error obteniendo columnas: {$e->getMessage()}\n";
        }

        echo "\n" . str_repeat("-", 60) . "\n\n";
    }

    // Buscar SPs existentes con proyec
    echo "\n=== STORED PROCEDURES CON 'PROYEC' ===\n\n";

    $spSql = "
        SELECT
            n.nspname as schema,
            p.proname as procedure_name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname ILIKE '%proyec%'
        AND n.nspname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY n.nspname, p.proname
    ";

    $spStmt = $pdo->query($spSql);
    $sps = $spStmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($sps)) {
        foreach ($sps as $sp) {
            echo "{$sp['schema']}.{$sp['procedure_name']}({$sp['arguments']})\n";
        }
    } else {
        echo "No se encontraron SPs con 'proyec'\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
