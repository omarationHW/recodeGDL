<?php
// Configuración de la base de datos
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "Buscando tablas necesarias...\n\n";

    $tables = [
        'ta_11_locales',
        'ta_11_adeudos_energia',
        'ta_11_ade_ene_canc',
        'ta_12_passwords'
    ];

    foreach ($tables as $table) {
        $sql = "
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name = :table_name
            AND table_schema NOT IN ('pg_catalog', 'information_schema')
            ORDER BY table_schema
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['table_name' => $table]);
        $results = $stmt->fetchAll();

        echo "Tabla: $table\n";
        if (count($results) > 0) {
            foreach ($results as $row) {
                echo "  ✓ Encontrada en schema: {$row['table_schema']}\n";
            }
        } else {
            echo "  ✗ NO ENCONTRADA\n";
        }
        echo "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
