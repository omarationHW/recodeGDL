<?php
$host = '192.168.20.31';
$port = '5432';
$dbname = 'ingresos';
$user = 'postgres';
$password = 'F3rnand0';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Buscando tabla ta_11_locales...\n\n";

    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename = 'ta_11_locales'
        ORDER BY schemaname
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "ENCONTRADA en:\n";
        foreach ($tables as $table) {
            echo "✓ {$table['schemaname']}.{$table['tablename']}\n";

            // Mostrar columnas
            $stmt2 = $pdo->prepare("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = :schema
                AND table_name = :table
                ORDER BY ordinal_position
            ");
            $stmt2->execute([
                'schema' => $table['schemaname'],
                'table' => $table['tablename']
            ]);

            $columns = $stmt2->fetchAll(PDO::FETCH_ASSOC);
            echo "\nColumnas:\n";
            foreach ($columns as $col) {
                echo "  - {$col['column_name']} ({$col['data_type']})\n";
            }
            echo "\n";
        }
    } else {
        echo "NO ENCONTRADA con nombre exacto. Buscando similares...\n\n";

        $stmt = $pdo->query("
            SELECT schemaname, tablename
            FROM pg_tables
            WHERE tablename LIKE '%locales%'
            AND tablename LIKE '%11%'
            ORDER BY schemaname, tablename
        ");

        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($tables) > 0) {
            echo "Tablas similares:\n";
            foreach ($tables as $table) {
                echo "  - {$table['schemaname']}.{$table['tablename']}\n";
            }
        } else {
            echo "Buscando cualquier tabla con 'locales'...\n";
            $stmt = $pdo->query("
                SELECT schemaname, tablename
                FROM pg_tables
                WHERE tablename LIKE '%locales%'
                ORDER BY schemaname, tablename
                LIMIT 20
            ");

            $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
            foreach ($tables as $table) {
                echo "  - {$table['schemaname']}.{$table['tablename']}\n";
            }
        }
    }
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
