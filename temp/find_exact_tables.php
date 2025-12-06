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

    echo "Buscando tablas específicas...\n\n";

    $tables = [
        'ta_11_locales',
        'ta_11_energia',
        'ta_11_adeudo_energ',
        'ta_11_adeudos_energia',
        'ta_11_ade_ene_canc',
        'ta_11_passwords',
        'ta_12_passwords',
        'usuarios'
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

        if (count($results) > 0) {
            foreach ($results as $row) {
                echo "✓ {$row['table_schema']}.{$row['table_name']}\n";
            }
        } else {
            echo "✗ $table - NO ENCONTRADA\n";
        }
    }

    // Buscar también con LIKE en db_ingresos y comun
    echo "\n\nBuscando en schemas específicos (db_ingresos, comun, comunX)...\n\n";

    $schemas = ['db_ingresos', 'comun', 'comunx'];
    $patterns = ['locales', 'energia', 'adeudo', 'password', 'usuario'];

    foreach ($schemas as $schema) {
        echo "Schema: $schema\n";
        foreach ($patterns as $pattern) {
            $sql = "
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = :schema
                AND table_name ILIKE '%$pattern%'
                LIMIT 5
            ";

            $stmt = $pdo->prepare($sql);
            $stmt->execute(['schema' => $schema]);
            $results = $stmt->fetchAll();

            if (count($results) > 0) {
                echo "  Patrón '$pattern':\n";
                foreach ($results as $row) {
                    echo "    - {$row['table_name']}\n";
                }
            }
        }
        echo "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
