<?php
// Script para buscar tablas relacionadas con pagos especiales en la BD multas_reglamentos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'pago' y 'esp' o 'especial'
    echo "=== BUSCANDO TABLAS CON 'PAGO' Y 'ESP' EN ESQUEMA PUBLIC ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename ILIKE '%pago%'
        AND (tablename ILIKE '%esp%' OR tablename ILIKE '%especial%')
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

    // Buscar tablas con 'aut' (autorizaciones) y 'pago'
    echo "\n\n=== BUSCANDO TABLAS CON 'AUT' Y 'PAGO' ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename ILIKE '%aut%'
        AND tablename ILIKE '%pago%'
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

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
