<?php
// Buscar todas las tablas usadas en sp_padron_global

$dbConfig = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'dbname' => 'mercados',
    'user' => 'refact',
    'password' => 'FF)-BQk2'
];

$tablesToFind = [
    'ta_11_locales',
    'ta_11_mercados',
    'ta_11_cuo_locales',
    'ta_11_fecha_desc',
    'ta_11_adeudo_local'
];

try {
    $dsn = "pgsql:host={$dbConfig['host']};port={$dbConfig['port']};dbname={$dbConfig['dbname']}";
    $pdo = new PDO($dsn, $dbConfig['user'], $dbConfig['password']);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a la base de datos\n\n";
    echo "Buscando ubicación de tablas...\n";
    echo str_repeat('=', 100) . "\n\n";

    foreach ($tablesToFind as $table) {
        echo "Tabla: $table\n";

        $stmt = $pdo->prepare("
            SELECT schemaname, tablename
            FROM pg_tables
            WHERE tablename = :table
            ORDER BY schemaname
        ");
        $stmt->execute(['table' => $table]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            foreach ($results as $result) {
                echo "  ✓ Encontrada en: {$result['schemaname']}.{$result['tablename']}\n";

                // Obtener columnas clave
                $stmtCols = $pdo->prepare("
                    SELECT column_name
                    FROM information_schema.columns
                    WHERE table_schema = :schema
                    AND table_name = :table
                    ORDER BY ordinal_position
                    LIMIT 8
                ");
                $stmtCols->execute([
                    'schema' => $result['schemaname'],
                    'table' => $result['tablename']
                ]);
                $cols = $stmtCols->fetchAll(PDO::FETCH_COLUMN);
                echo "    Columnas: " . implode(', ', $cols) . "\n";
            }
        } else {
            echo "  ✗ NO ENCONTRADA\n";
        }
        echo "\n";
    }

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
