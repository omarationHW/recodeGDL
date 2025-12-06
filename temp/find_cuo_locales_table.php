<?php
// Buscar la tabla ta_11_cuo_locales en todos los schemas

$dbConfig = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'dbname' => 'mercados',
    'user' => 'refact',
    'password' => 'FF)-BQk2'
];

try {
    $dsn = "pgsql:host={$dbConfig['host']};port={$dbConfig['port']};dbname={$dbConfig['dbname']}";
    $pdo = new PDO($dsn, $dbConfig['user'], $dbConfig['password']);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a la base de datos\n\n";

    // Buscar tablas con 'cuo' y 'local' en el nombre
    echo "Buscando tablas con 'cuo' y 'local'...\n";
    echo str_repeat('=', 100) . "\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename,
            schemaname || '.' || tablename as full_name
        FROM pg_tables
        WHERE tablename LIKE '%cuo%loc%'
           OR tablename LIKE '%cuota%loc%'
           OR tablename = 'ta_11_cuo_locales'
        ORDER BY schemaname, tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "Schema: {$table['schemaname']}\n";
            echo "Tabla: {$table['tablename']}\n";
            echo "Nombre completo: {$table['full_name']}\n";

            // Obtener estructura de la tabla
            $stmtCols = $pdo->prepare("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = :schema
                AND table_name = :table
                ORDER BY ordinal_position
                LIMIT 10
            ");
            $stmtCols->execute([
                'schema' => $table['schemaname'],
                'table' => $table['tablename']
            ]);
            $cols = $stmtCols->fetchAll(PDO::FETCH_ASSOC);

            echo "Columnas: ";
            echo implode(', ', array_column($cols, 'column_name'));
            echo "\n";
            echo str_repeat('-', 100) . "\n";
        }
    } else {
        echo "No se encontraron tablas con ese patrón.\n\n";

        // Buscar tablas que puedan ser de cuotas
        echo "Buscando tablas relacionadas con cuotas...\n";
        echo str_repeat('=', 100) . "\n";

        $stmt = $pdo->query("
            SELECT
                schemaname,
                tablename
            FROM pg_tables
            WHERE tablename LIKE '%cuota%'
               OR tablename LIKE '%cuo_%'
            ORDER BY schemaname, tablename
        ");

        $cuotasTables = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($cuotasTables as $table) {
            echo "{$table['schemaname']}.{$table['tablename']}\n";
        }
    }

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
