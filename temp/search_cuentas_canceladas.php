<?php
// Buscar tablas relacionadas con cuentas canceladas
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BUSCANDO TABLAS RELACIONADAS CON CUENTAS CANCELADAS ===\n\n";

    // Buscar tablas con "cuenta" o "cancel" en el nombre
    $schemas = ['comun', 'comunX', 'db_ingresos', 'public', 'catastro_gdl'];

    foreach ($schemas as $schema) {
        echo "--- Schema: $schema ---\n";
        $stmt = $pdo->prepare("
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = ?
            AND (
                table_name LIKE '%cuenta%'
                OR table_name LIKE '%cancel%'
                OR table_name LIKE '%req%'
                OR table_name LIKE '%requer%'
            )
            ORDER BY table_name
            LIMIT 20
        ");
        $stmt->execute([$schema]);
        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);

        if (count($tables) > 0) {
            foreach ($tables as $table) {
                echo "  - $schema.$table\n";
            }
        }
        echo "\n";
    }

    // Buscar en comun.multas si tiene información de cuentas
    echo "\n=== EXPLORANDO comun.multas (columnas con 'cuenta' o 'clave') ===\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'multas'
        AND (
            column_name LIKE '%cuenta%'
            OR column_name LIKE '%clave%'
            OR column_name LIKE '%cancel%'
        )
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        echo sprintf("  %-30s %s\n", $col['column_name'], $col['data_type']);
    }

    // Buscar valores distintos de alguna columna que pueda ser "cuenta"
    echo "\n=== BUSCANDO DATOS DE EJEMPLO ===\n\n";

    // Intentar con clave_catastral o similar
    $stmt = $pdo->query("
        SELECT DISTINCT clave_catastral
        FROM comun.multas
        WHERE clave_catastral IS NOT NULL
        AND clave_catastral != ''
        LIMIT 10
    ");

    echo "Ejemplos de clave_catastral en comun.multas:\n";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  - " . $row['clave_catastral'] . "\n";
    }

    // Buscar en otras tablas de db_ingresos
    echo "\n=== EXPLORANDO db_ingresos ===\n";
    $stmt = $pdo->query("
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'db_ingresos'
        AND (
            table_name LIKE '%cuenta%'
            OR table_name LIKE '%predial%'
            OR table_name LIKE '%contrib%'
        )
        ORDER BY table_name
        LIMIT 15
    ");

    while ($row = $stmt->fetch(PDO::FETCH_COLUMN)) {
        echo "  - db_ingresos.$row\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
