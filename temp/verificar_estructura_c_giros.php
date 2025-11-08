<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "\n========================================\n";
    echo "ESTRUCTURA DE LA TABLA comun.c_giros\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'comun'
            AND table_name = 'c_giros'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_OBJ);

    echo str_repeat("-", 100) . "\n";
    printf("%-25s %-25s %-15s %-10s\n", "Column Name", "Data Type", "Max Length", "Nullable");
    echo str_repeat("-", 100) . "\n";

    foreach ($columns as $col) {
        printf("%-25s %-25s %-15s %-10s\n",
            $col->column_name,
            $col->data_type,
            $col->character_maximum_length ?? 'N/A',
            $col->is_nullable
        );
    }
    echo str_repeat("-", 100) . "\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n\n";
    exit(1);
}
