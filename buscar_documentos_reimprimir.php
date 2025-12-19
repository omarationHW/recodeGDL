<?php
// Script para buscar tablas relacionadas con documentos para reimprimir

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'folio'
    echo "=== BUSCANDO TABLAS CON 'folio' ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND column_name ILIKE '%folio%'
        ORDER BY table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['table_name']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 2000000) {
                // Ver columnas relevantes
                $stmt2 = $pdo->query("
                    SELECT column_name
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                    AND table_name = '{$table['table_name']}'
                    AND (
                        column_name ILIKE '%folio%'
                        OR column_name ILIKE '%fecha%'
                        OR column_name ILIKE '%contribuyente%'
                        OR column_name ILIKE '%importe%'
                        OR column_name ILIKE '%tipo%'
                        OR column_name ILIKE '%estatus%'
                        OR column_name ILIKE '%dependencia%'
                    )
                    ORDER BY ordinal_position
                ");
                $cols = $stmt2->fetchAll(PDO::FETCH_ASSOC);

                if (count($cols) >= 3) {
                    echo "  ✓ {$table['table_name']} (" . number_format($count['total']) . " registros)\n";
                    echo "    Campos relevantes: " . implode(', ', array_column($cols, 'column_name')) . "\n\n";
                }
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

    // Buscar tablas de pagos que podrían tener documentos
    echo "\n=== ANALIZANDO TABLAS DE PAGOS/RECIBOS ===\n\n";

    $tablas_pagos = [
        'pago_diversos',
        'pagos_400',
        'cheqpag',
        'pagotransm_400',
        'autpagoesp',
        'recauda_centros',
        'noadeudo'
    ];

    foreach ($tablas_pagos as $tabla) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.$tabla");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            echo "  ✓ $tabla (" . number_format($count['total']) . " registros)\n";

            // Ver estructura (primeros 15 campos)
            $stmt = $pdo->query("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = 'public'
                AND table_name = '$tabla'
                ORDER BY ordinal_position
                LIMIT 15
            ");
            $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($cols as $col) {
                echo "    - {$col['column_name']}: {$col['data_type']}\n";
            }
            echo "\n";
        } catch (PDOException $e) {
            echo "  ✗ $tabla (no existe o error)\n\n";
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
