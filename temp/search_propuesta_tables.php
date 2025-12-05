<?php
// Buscar tablas relacionadas con propuesta
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BUSCANDO TABLAS CON 'PROPUESTA' ===\n\n";

    $sql = "
        SELECT
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables
        WHERE tablename ILIKE '%propuesta%'
        AND schemaname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY schemaname, tablename
    ";

    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($tables)) {
        echo "No se encontraron tablas con 'propuesta'\n\n";
    } else {
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
                ";
                $colStmt = $pdo->prepare($colSql);
                $colStmt->execute([
                    'schema' => $table['schemaname'],
                    'table' => $table['tablename']
                ]);
                $columns = $colStmt->fetchAll(PDO::FETCH_ASSOC);

                echo "Columnas:\n";
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
    }

    // Buscar también en vistas
    echo "\n=== BUSCANDO VISTAS CON 'PROPUESTA' ===\n\n";

    $viewSql = "
        SELECT
            schemaname,
            viewname
        FROM pg_views
        WHERE viewname ILIKE '%propuesta%'
        AND schemaname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY schemaname, viewname
    ";

    $viewStmt = $pdo->query($viewSql);
    $views = $viewStmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($views)) {
        foreach ($views as $view) {
            echo "Schema: {$view['schemaname']}\n";
            echo "Vista: {$view['viewname']}\n\n";
        }
    } else {
        echo "No se encontraron vistas con 'propuesta'\n";
    }

} catch (PDOException $e) {
    echo "Error de conexión: " . $e->getMessage() . "\n";
}
