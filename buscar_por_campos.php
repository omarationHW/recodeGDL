<?php
// Script para buscar tablas por nombres de campos específicos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas que tengan campos con estos nombres
    $campos_buscar = [
        'cvectaapl',
        'ctaaplicacion',
        'cta_aplicacion',
        'cuenta_aplicacion',
        'cveapl',
        'aplicacion'
    ];

    foreach ($campos_buscar as $campo) {
        echo "=== BUSCANDO TABLAS CON CAMPO '$campo' ===\n\n";

        $stmt = $pdo->prepare("
            SELECT DISTINCT table_name
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND column_name ILIKE ?
            ORDER BY table_name
        ");
        $stmt->execute(["%$campo%"]);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($tables) > 0) {
            foreach ($tables as $table) {
                try {
                    $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['table_name']}");
                    $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                    echo "  ✓ {$table['table_name']} ({$count['total']} registros)\n";
                } catch (PDOException $e) {
                    echo "  ✗ {$table['table_name']} (error)\n";
                }
            }
            echo "\n";
        } else {
            echo "  No se encontraron tablas.\n\n";
        }
    }

    // Buscar tablas con campos que contengan 'partida' o 'suma'
    echo "\n=== BUSCANDO TABLAS CON CAMPOS 'PARTIDA' O 'SUMA' ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND (column_name ILIKE '%partida%' OR column_name ILIKE '%suma%')
        ORDER BY table_name
        LIMIT 20
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['table_name']}");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

                // Mostrar campos de la tabla
                $cols_stmt = $pdo->query("
                    SELECT column_name
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                    AND table_name = '{$table['table_name']}'
                    AND (column_name ILIKE '%partida%' OR column_name ILIKE '%suma%')
                    ORDER BY ordinal_position
                ");
                $cols = $cols_stmt->fetchAll(PDO::FETCH_ASSOC);
                $col_names = array_map(function($c) { return $c['column_name']; }, $cols);

                echo "  ✓ {$table['table_name']} ({$count['total']} registros)\n";
                echo "    Campos: " . implode(', ', $col_names) . "\n\n";
            } catch (PDOException $e) {
                echo "  ✗ {$table['table_name']} (error)\n\n";
            }
        }
    } else {
        echo "  No se encontraron tablas.\n\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
