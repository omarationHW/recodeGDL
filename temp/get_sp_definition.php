<?php
// Obtener definición de SP propuestatab_list
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    $sps = [
        'propuestatab_list',
        'propuestatab_obs400',
        'sp_propuestatab_list'
    ];

    foreach ($sps as $spName) {
        echo "=== DEFINICIÓN DE $spName ===\n\n";

        $sql = "
            SELECT pg_get_functiondef(oid) as definition
            FROM pg_proc
            WHERE proname = :spname
            AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
            LIMIT 1
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['spname' => $spName]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo $result['definition'];
            echo "\n\n" . str_repeat("=", 80) . "\n\n";
        } else {
            echo "No se encontró el SP\n\n";
        }
    }

    // Buscar tablas relacionadas con pagos y multas para el SP
    echo "=== TABLAS ÚTILES PARA PROPUESTATAB ===\n\n";

    $sql = "
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'comun'
        AND (
            tablename ILIKE '%pago%'
            OR tablename ILIKE '%multa%'
            OR tablename ILIKE '%contribuyente%'
            OR tablename ILIKE '%cuenta%'
        )
        ORDER BY tablename
        LIMIT 20
    ";

    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "comun.{$table['tablename']}\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
