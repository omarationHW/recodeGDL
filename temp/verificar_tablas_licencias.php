<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "VERIFICACIÓN DE TABLAS LICENCIAS\n";
echo "========================================\n\n";

try {
    $dsn = "pgsql:host=$host;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa a PostgreSQL\n\n";

    // Buscar todas las tablas que contengan "licencia" en su nombre
    echo "Tablas relacionadas con licencias:\n";
    echo str_repeat("-", 60) . "\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE tablename ILIKE '%licencia%'
        ORDER BY schemaname, tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo sprintf("  %s.%s\n", $table['schemaname'], $table['tablename']);
        }
    } else {
        echo "  No se encontraron tablas relacionadas con licencias\n";
    }

    echo "\n" . str_repeat("-", 60) . "\n\n";

    // Buscar todas las tablas en el esquema public
    echo "Todas las tablas en schema 'public':\n";
    echo str_repeat("-", 60) . "\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename
        LIMIT 50
    ");

    $publicTables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($publicTables) > 0) {
        foreach ($publicTables as $table) {
            echo "  " . $table['tablename'] . "\n";
        }
    } else {
        echo "  No se encontraron tablas en el esquema public\n";
    }

    echo "\n" . str_repeat("-", 60) . "\n\n";

    // Verificar tabla c_giros
    echo "Verificando tabla c_giros:\n";
    $checkGiros = $pdo->query("
        SELECT EXISTS (
            SELECT 1 FROM information_schema.tables
            WHERE table_schema = 'public'
            AND table_name = 'c_giros'
        )
    ")->fetchColumn();

    if ($checkGiros) {
        echo "  ✓ Tabla c_giros existe\n";

        // Ver estructura de c_giros
        $stmt = $pdo->query("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'c_giros'
            ORDER BY ordinal_position
        ");

        echo "\n  Columnas en c_giros:\n";
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $col) {
            echo sprintf("    - %s (%s)\n", $col['column_name'], $col['data_type']);
        }
    } else {
        echo "  ✗ Tabla c_giros NO existe\n";
    }

} catch (PDOException $e) {
    echo "\n✗ Error de base de datos:\n";
    echo "  " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "\n✗ Error:\n";
    echo "  " . $e->getMessage() . "\n";
    exit(1);
}
