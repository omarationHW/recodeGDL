<?php
// Script para buscar más información sobre derechos y conceptos de licencias

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con "concepto" o "det" (detalle)
    echo "=== TABLAS CON 'concepto', 'detalle' o 'det' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (
            table_name ILIKE '%concepto%'
            OR table_name ILIKE '%detlic%'
            OR table_name ILIKE '%detalle%'
            OR table_name ILIKE '%desc%derecho%'
        )
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Ver estructura de detreqlic
    echo "\n\n=== ESTRUCTURA DE public.detreqlic (si existe) ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'detreqlic'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($columns) > 0) {
            foreach ($columns as $col) {
                $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
            }

            // Datos de ejemplo
            echo "\nDatos de ejemplo:\n";
            $stmt = $pdo->query("SELECT * FROM public.detreqlic LIMIT 3");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            foreach ($rows as $i => $row) {
                echo "  Registro " . ($i + 1) . ":\n";
                $keys = array_slice(array_keys($row), 0, 8);
                foreach ($keys as $key) {
                    $val = is_null($row[$key]) ? 'NULL' : substr(trim($row[$key]), 0, 30);
                    echo "    $key: $val\n";
                }
            }
        } else {
            echo "  (Tabla no existe)\n";
        }
    } catch (Exception $e) {
        echo "  (Tabla no existe o error: " . $e->getMessage() . ")\n";
    }

    // Ver estructura de ta_11_descderechos
    echo "\n\n=== ESTRUCTURA DE public.ta_11_descderechos ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'ta_11_descderechos'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        // Datos de ejemplo
        echo "\nDatos de ejemplo:\n";
        $stmt = $pdo->query("SELECT * FROM public.ta_11_descderechos LIMIT 5");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($rows as $i => $row) {
            echo "  Registro " . ($i + 1) . ":\n";
            foreach ($row as $key => $val) {
                $val = is_null($val) ? 'NULL' : substr(trim($val), 0, 40);
                echo "    $key: $val\n";
            }
            echo "\n";
        }
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }

    // Analizar estructura de reqbflicencias más a fondo
    echo "\n\n=== ANÁLISIS DETALLADO DE reqbflicencias ===\n";
    $stmt = $pdo->query("
        SELECT
            id_licencia,
            axoreq,
            formas, derechos, anuncios, hologramas,
            solicitudes, recargos, gastos, multas
        FROM public.reqbflicencias
        WHERE id_licencia IS NOT NULL
        LIMIT 3
    ");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Esta tabla tiene conceptos como columnas:\n";
    foreach ($rows as $i => $row) {
        echo "\n  Licencia {$row['id_licencia']} (Año {$row['axoreq']}):\n";
        echo "    - Formas: \${$row['formas']}\n";
        echo "    - Derechos: \${$row['derechos']}\n";
        echo "    - Anuncios: \${$row['anuncios']}\n";
        echo "    - Hologramas: \${$row['hologramas']}\n";
        echo "    - Solicitudes: \${$row['solicitudes']}\n";
        echo "    - Recargos: \${$row['recargos']}\n";
        echo "    - Gastos: \${$row['gastos']}\n";
        echo "    - Multas: \${$row['multas']}\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
