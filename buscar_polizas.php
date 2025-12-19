<?php
// Script para buscar tablas relacionadas con pólizas en la BD multas_reglamentos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'poliza' o 'pol'
    echo "=== BUSCANDO TABLAS CON 'POLIZA' O 'POL' EN ESQUEMA PUBLIC ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (tablename ILIKE '%poliza%' OR tablename ILIKE '%pol%')
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "Tablas encontradas:\n";
        foreach ($tables as $table) {
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$table['schemaname']}.{$table['tablename']}");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                echo "  - {$table['schemaname']}.{$table['tablename']} ({$count['total']} registros)\n";
            } catch (PDOException $e) {
                echo "  - {$table['schemaname']}.{$table['tablename']} (error al contar)\n";
            }
        }
    } else {
        echo "No se encontraron tablas.\n";
    }

    // Buscar tablas con 'contab' o 'cuenta'
    echo "\n\n=== BUSCANDO TABLAS CON 'CONTAB' O 'CUENTA' ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (tablename ILIKE '%contab%' OR tablename ILIKE '%cuenta%')
        ORDER BY tablename
        LIMIT 20
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "Tablas encontradas (primeras 20):\n";
        foreach ($tables as $table) {
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$table['schemaname']}.{$table['tablename']}");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                echo "  - {$table['schemaname']}.{$table['tablename']} ({$count['total']} registros)\n";
            } catch (PDOException $e) {
                echo "  - {$table['schemaname']}.{$table['tablename']} (error al contar)\n";
            }
        }
    } else {
        echo "No se encontraron tablas.\n";
    }

    // Buscar tablas con 'movimiento' o 'aplicacion'
    echo "\n\n=== BUSCANDO TABLAS CON 'MOVIMIENTO' O 'APLICACION' ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (tablename ILIKE '%movimiento%' OR tablename ILIKE '%aplicacion%' OR tablename ILIKE '%apl%')
        ORDER BY tablename
        LIMIT 20
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "Tablas encontradas (primeras 20):\n";
        foreach ($tables as $table) {
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$table['schemaname']}.{$table['tablename']}");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                echo "  - {$table['schemaname']}.{$table['tablename']} ({$count['total']} registros)\n";
            } catch (PDOException $e) {
                echo "  - {$table['schemaname']}.{$table['tablename']} (error al contar)\n";
            }
        }
    } else {
        echo "No se encontraron tablas.\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
