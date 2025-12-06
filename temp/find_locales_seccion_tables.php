<?php
// Buscar tablas de locales con columna seccion

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

    echo "Conectado a la base de datos\n\n";

    echo "TABLAS CON 'LOCAL' EN EL NOMBRE:\n";
    echo str_repeat('=', 100) . "\n";

    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename LIKE '%local%'
        ORDER BY schemaname, tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "{$table['schemaname']}.{$table['tablename']}\n";

        $stmtCols = $pdo->prepare("
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = :schema
            AND table_name = :table
            AND column_name = 'seccion'
        ");
        $stmtCols->execute([
            'schema' => $table['schemaname'],
            'table' => $table['tablename']
        ]);
        $hasSeccion = $stmtCols->fetch(PDO::FETCH_ASSOC);

        if ($hasSeccion) {
            echo "  HAS seccion column\n";

            $stmtValues = $pdo->query("
                SELECT DISTINCT seccion
                FROM {$table['schemaname']}.{$table['tablename']}
                WHERE seccion IS NOT NULL
                ORDER BY seccion
                LIMIT 10
            ");
            $values = $stmtValues->fetchAll(PDO::FETCH_COLUMN);

            if (count($values) > 0) {
                echo "  Values: " . implode(', ', $values) . "\n";
            }
        }
        echo "\n";
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
