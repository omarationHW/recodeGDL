<?php
// Script para buscar tablas relacionadas con pagos diversos en la BD multas_reglamentos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'pago' en el nombre
    echo "=== BUSCANDO TABLAS CON 'PAGO' EN ESQUEMA PUBLIC ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename ILIKE '%pago%'
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "Tablas encontradas con 'pago':\n";
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
        echo "No se encontraron tablas con 'pago' en su nombre.\n";
    }

    // Buscar tablas con 'div' (diversos)
    echo "\n\n=== BUSCANDO TABLAS CON 'DIV' EN ESQUEMA PUBLIC ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename ILIKE '%div%'
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "Tablas encontradas con 'div':\n";
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
        echo "No se encontraron tablas con 'div' en su nombre.\n";
    }

    // Buscar tablas con 'otros' o 'vario'
    echo "\n\n=== BUSCANDO TABLAS CON 'OTROS' O 'VARIO' ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (tablename ILIKE '%otros%' OR tablename ILIKE '%vario%')
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
        echo "No se encontraron tablas con 'otros' o 'vario'.\n";
    }

    // Buscar tablas con 'recauda' o 'ingreso'
    echo "\n\n=== BUSCANDO TABLAS CON 'RECAUDA' O 'INGRESO' ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (tablename ILIKE '%recauda%' OR tablename ILIKE '%ingreso%')
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
        echo "No se encontraron tablas con 'recauda' o 'ingreso'.\n";
    }

    // Listar algunas tablas del esquema public para referencia
    echo "\n\n=== ALGUNAS TABLAS EN ESQUEMA PUBLIC (primeras 40) ===\n\n";

    $stmt = $pdo->query("
        SELECT
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename
        LIMIT 40
    ");

    $all_tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($all_tables as $table) {
        echo "  - {$table['tablename']}\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
