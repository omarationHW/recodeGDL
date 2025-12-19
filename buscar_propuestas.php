<?php
// Script para buscar tablas relacionadas con propuestas de pago

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'propuesta'
    echo "=== BUSCANDO TABLAS CON 'PROPUESTA' ===\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename ILIKE '%propuesta%'
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

    // Buscar tablas de pagos que ya conocemos y ver si alguna tiene los campos necesarios
    echo "\n\n=== REVISANDO TABLAS DE PAGOS EXISTENTES ===\n\n";

    $tablas_pagos = [
        'pagos_400',
        'pago_diversos',
        'lic_pago_alt',
        'recauda_centros',
        'pagoscan',
        'cheqpag',
        'pagotransm_400',
        'autpagoesp'
    ];

    foreach ($tablas_pagos as $tabla) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.$tabla");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            // Ver si tiene campos relevantes
            $stmt = $pdo->query("
                SELECT column_name
                FROM information_schema.columns
                WHERE table_schema = 'public'
                AND table_name = '$tabla'
                AND column_name IN ('fecha', 'hora', 'importe', 'cajero', 'folio', 'cvepago', 'cvecuenta')
                ORDER BY ordinal_position
            ");
            $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($cols) > 3) {
                echo "  ✓ $tabla (" . number_format($count['total']) . " registros)\n";
                echo "    Campos relevantes: " . implode(', ', array_column($cols, 'column_name')) . "\n";
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

    // Buscar tablas que tengan hora como campo (indica transacción detallada)
    echo "\n\n=== BUSCANDO TABLAS CON CAMPO 'hora' ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND column_name ILIKE '%hora%'
        ORDER BY table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['table_name']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 1000000) {
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
