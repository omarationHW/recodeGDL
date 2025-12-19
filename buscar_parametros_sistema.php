<?php
// Script para buscar tablas relacionadas con parámetros del sistema en la BD multas_reglamentos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'param' o 'sistema' o 'config'
    echo "=== BUSCANDO TABLAS CON 'PARAM', 'SISTEMA' O 'CONFIG' EN ESQUEMA PUBLIC ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (
            tablename ILIKE '%param%'
            OR tablename ILIKE '%sistema%'
            OR tablename ILIKE '%config%'
        )
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

    // Buscar tablas con 'periodo' o 'ejercicio'
    echo "\n\n=== BUSCANDO TABLAS CON 'PERIODO' O 'EJERCICIO' ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (tablename ILIKE '%periodo%' OR tablename ILIKE '%ejercicio%')
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

    // Buscar tablas que puedan contener información administrativa
    echo "\n\n=== BUSCANDO TABLAS ADMINISTRATIVAS ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (
            tablename ILIKE '%administr%'
            OR tablename ILIKE '%general%'
            OR tablename ILIKE '%global%'
            OR tablename ILIKE '%mpal%'
            OR tablename ILIKE '%munic%'
        )
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
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
