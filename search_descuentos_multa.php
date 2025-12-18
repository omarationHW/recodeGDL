<?php
// Script para buscar tablas relacionadas con descuentos de multas municipales

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver el stored procedure actual
    echo "=== STORED PROCEDURE ACTUAL ===\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_descmultampalfrm'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($result) {
        echo substr($result['definition'], 0, 1200) . "...\n";
    }

    // Buscar tablas con "desc" y "multa"
    echo "\n\n=== TABLAS CON 'desc' Y 'multa' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%desc%multa%' OR table_name ILIKE '%multa%desc%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Buscar tablas relacionadas con "aut_desctos" que vimos antes
    echo "\n\n=== TABLAS CON 'descto' O 'descuento' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%descto%' OR table_name ILIKE '%descuento%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables2 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables2 as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Ver estructura de aut_desctosotorgados más a fondo
    echo "\n\n=== ESTRUCTURA DETALLADA DE public.aut_desctosotorgados ===\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'aut_desctosotorgados'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    // Ver datos de ejemplo
    echo "\nDatos de ejemplo (5 registros):\n";
    $stmt = $pdo->query("SELECT * FROM public.aut_desctosotorgados LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as $i => $row) {
        echo "\n  Registro " . ($i + 1) . ":\n";
        $keys = array_slice(array_keys($row), 0, 12);
        foreach ($keys as $key) {
            $val = is_null($row[$key]) ? 'NULL' : (is_string($row[$key]) ? substr(trim($row[$key]), 0, 40) : $row[$key]);
            echo "    $key: $val\n";
        }
    }

    // Buscar tabla ta_11_descmulta
    echo "\n\n=== ESTRUCTURA DE public.ta_11_descmulta (si existe) ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'ta_11_descmulta'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($columns) > 0) {
            foreach ($columns as $col) {
                $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
            }

            echo "\nDatos de ejemplo:\n";
            $stmt = $pdo->query("SELECT * FROM public.ta_11_descmulta LIMIT 5");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            foreach ($rows as $i => $row) {
                echo "\n  Registro " . ($i + 1) . ":\n";
                foreach ($row as $key => $val) {
                    $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                    echo "    $key: $val\n";
                }
            }
        }
    } catch (Exception $e) {
        echo "  (Tabla no existe o error)\n";
    }

    // Contar registros en aut_desctosotorgados
    echo "\n\n=== ANÁLISIS DE DATOS ===\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.aut_desctosotorgados");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total de registros en aut_desctosotorgados: " . number_format($total['total']) . "\n";

    // Ver tipos de descuento
    $stmt = $pdo->query("
        SELECT tipo_descto, COUNT(*) as cantidad
        FROM public.aut_desctosotorgados
        WHERE tipo_descto IS NOT NULL
        GROUP BY tipo_descto
        ORDER BY cantidad DESC
        LIMIT 10
    ");
    $tipos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "\nTipos de descuento encontrados:\n";
    foreach ($tipos as $tipo) {
        echo "  - {$tipo['tipo_descto']}: " . number_format($tipo['cantidad']) . " registros\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
