<?php
// Script para buscar tablas alternativas para pólizas consolidadas

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Buscar tablas con términos contables
    echo "=== BUSCANDO TABLAS CONTABLES ===\n\n";

    $terminos = [
        'contab', 'contabil', 'cuenta', 'poliza', 'pol',
        'movim', 'transacc', 'asiento', 'diario', 'mayor',
        'partida', 'aplicac', 'concentr', 'consolid'
    ];

    foreach ($terminos as $termino) {
        echo "Buscando '$termino'...\n";

        $stmt = $pdo->prepare("
            SELECT
                schemaname,
                tablename
            FROM pg_tables
            WHERE schemaname = 'public'
            AND tablename ILIKE ?
            ORDER BY tablename
        ");
        $stmt->execute(["%$termino%"]);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($tables) > 0) {
            foreach ($tables as $table) {
                try {
                    $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$table['schemaname']}.{$table['tablename']}");
                    $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                    echo "  ✓ {$table['tablename']} ({$count['total']} registros)\n";
                } catch (PDOException $e) {
                    echo "  ✗ {$table['tablename']} (error al contar)\n";
                }
            }
        }
    }

    // 2. Buscar todas las tablas y mostrar las que tienen más registros
    echo "\n\n=== TOP 50 TABLAS CON MÁS REGISTROS ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $table_counts = [];

    foreach ($tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$table['schemaname']}.{$table['tablename']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
            $table_counts[$table['tablename']] = $count['total'];
        } catch (PDOException $e) {
            // Ignorar errores
        }
    }

    arsort($table_counts);
    $top_tables = array_slice($table_counts, 0, 50, true);

    foreach ($top_tables as $name => $count) {
        if ($count > 0) {
            echo "  - {$name} (" . number_format($count) . " registros)\n";
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
