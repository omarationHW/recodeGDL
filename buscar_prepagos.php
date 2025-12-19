<?php
// Script para buscar tablas relacionadas con prepagos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'prepago' o 'pre'
    echo "=== BUSCANDO TABLAS CON 'PREPAGO' O 'PRE' ===\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (tablename ILIKE '%prepago%' OR tablename ILIKE 'pre%')
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['tablename']}");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                echo "  ✓ {$table['tablename']} ({$count['total']} registros)\n";
            } catch (PDOException $e) {
                echo "  ✗ {$table['tablename']} (error al contar)\n";
            }
        }
    } else {
        echo "  No se encontraron tablas.\n";
    }

    // Buscar en tablas de pagos que ya conocemos
    echo "\n\n=== REVISANDO TABLAS DE PAGOS CONOCIDAS ===\n\n";

    $tablas_pagos = [
        'pagos_400',
        'pago_diversos',
        'pagoscan',
        'cheqpag',
        'pagotransm_400',
        'autpagoesp'
    ];

    foreach ($tablas_pagos as $tabla) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.$tabla");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
            echo "  ✓ $tabla (" . number_format($count['total']) . " registros)\n";
        } catch (PDOException $e) {
            echo "  ✗ $tabla (no existe)\n";
        }
    }

    // Buscar tablas con campo 'cvepago' que podrían servir
    echo "\n\n=== BUSCANDO TABLAS CON CAMPO 'cvepago' ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND column_name = 'cvepago'
        ORDER BY table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['table_name']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 10000000) {
                echo "  ✓ {$table['table_name']} (" . number_format($count['total']) . " registros)\n";
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
