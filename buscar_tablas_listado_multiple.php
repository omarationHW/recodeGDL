<?php
// Buscar tablas relacionadas con listado múltiple en la BD multas_reglamentos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS RELACIONADAS CON MOVIMIENTOS/PAGOS ===\n\n";

    // Buscar tablas que contengan palabras relacionadas
    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('public', 'publico')
        AND (
            tablename ILIKE '%movimiento%'
            OR tablename ILIKE '%pago%'
            OR tablename ILIKE '%transaccion%'
            OR tablename ILIKE '%multiple%'
        )
        ORDER BY schemaname, tablename
    ");

    $tablas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tablas) > 0) {
        foreach ($tablas as $tabla) {
            echo "Tabla: {$tabla['schemaname']}.{$tabla['tablename']}\n";

            // Contar registros
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$tabla['schemaname']}.{$tabla['tablename']}");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                echo "  Registros: " . number_format($count['total']) . "\n";

                // Ver columnas solo si tiene registros
                if ($count['total'] > 0 && $count['total'] < 10000000) {
                    $col_stmt = $pdo->prepare("
                        SELECT column_name, data_type
                        FROM information_schema.columns
                        WHERE table_schema = ? AND table_name = ?
                        ORDER BY ordinal_position
                    ");
                    $col_stmt->execute([$tabla['schemaname'], $tabla['tablename']]);
                    $columnas = $col_stmt->fetchAll(PDO::FETCH_ASSOC);

                    echo "  Columnas:\n";
                    $count_cols = 0;
                    foreach ($columnas as $col) {
                        if ($count_cols < 20) {
                            echo "    - {$col['column_name']} ({$col['data_type']})\n";
                            $count_cols++;
                        }
                    }
                    if (count($columnas) > 20) {
                        echo "    ... y " . (count($columnas) - 20) . " columnas más\n";
                    }
                }
            } catch (Exception $e) {
                echo "  Error al leer tabla: {$e->getMessage()}\n";
            }

            echo "\n" . str_repeat("-", 60) . "\n\n";
        }
    } else {
        echo "No se encontraron tablas.\n\n";
    }

    // También buscar tablas de pagos que ya conocemos
    echo "\n=== VERIFICANDO TABLA DE PAGOS ===\n\n";

    $stmt_pagos = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename = 'pagos'
        AND schemaname IN ('public', 'publico')
    ");

    $tabla_pagos = $stmt_pagos->fetch(PDO::FETCH_ASSOC);

    if ($tabla_pagos) {
        echo "Tabla: {$tabla_pagos['schemaname']}.{$tabla_pagos['tablename']}\n";

        $count = $pdo->query("SELECT COUNT(*) as total FROM {$tabla_pagos['schemaname']}.{$tabla_pagos['tablename']}");
        $total = $count->fetch(PDO::FETCH_ASSOC);
        echo "  Registros: " . number_format($total['total']) . "\n";

        // Ver columnas
        $cols = $pdo->query("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = '{$tabla_pagos['schemaname']}'
            AND table_name = '{$tabla_pagos['tablename']}'
            ORDER BY ordinal_position
        ");

        echo "  Columnas:\n";
        $count_cols = 0;
        foreach ($cols->fetchAll(PDO::FETCH_ASSOC) as $col) {
            if ($count_cols < 25) {
                echo "    - {$col['column_name']} ({$col['data_type']})\n";
                $count_cols++;
            }
        }
        if ($count_cols == 25) {
            echo "    ... (mostrando primeras 25 columnas)\n";
        }
    }

    echo "\n✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
