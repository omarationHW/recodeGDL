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

    echo "Buscando tablas similares...\n\n";

    $patterns = [
        '%locales%',
        '%adeudos%energia%',
        '%ade_ene%',
        '%passwords%',
        '%usuario%'
    ];

    foreach ($patterns as $pattern) {
        $sql = "
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name ILIKE :pattern
            AND table_schema NOT IN ('pg_catalog', 'information_schema')
            ORDER BY table_schema, table_name
            LIMIT 10
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['pattern' => $pattern]);
        $results = $stmt->fetchAll();

        echo "Patrón: $pattern\n";
        if (count($results) > 0) {
            foreach ($results as $row) {
                echo "  {$row['table_schema']}.{$row['table_name']}\n";
            }
        } else {
            echo "  NO ENCONTRADAS\n";
        }
        echo "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
