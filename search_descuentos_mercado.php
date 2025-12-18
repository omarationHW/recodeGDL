<?php
// Script para buscar tablas relacionadas con descuentos de mercado

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
        WHERE p.proname = 'recaudadora_descderechos_merc'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($result) {
        echo substr($result['definition'], 0, 1200) . "...\n";
    }

    // Buscar tablas con "mercado" o "merc"
    echo "\n\n=== TABLAS CON 'mercado' O 'merc' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%mercado%' OR table_name ILIKE '%merc%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Buscar tablas con "descuento" y "derecho"
    echo "\n\n=== TABLAS CON 'desc' Y 'derecho' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%desc%derecho%' OR table_name ILIKE '%derecho%desc%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables2 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables2 as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Buscar tablas con "local" (mercados/locales comerciales)
    echo "\n\n=== TABLAS CON 'local' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%local%'
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables3 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables3 as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Examinar ta_11_descderechos más a fondo
    echo "\n\n=== ESTRUCTURA DETALLADA DE public.ta_11_descderechos ===\n";
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

    // Ver datos de ejemplo
    echo "\nDatos de ejemplo (5 registros):\n";
    $stmt = $pdo->query("SELECT * FROM public.ta_11_descderechos LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as $i => $row) {
        echo "\n  Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $val) {
            $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
            echo "    $key: $val\n";
        }
    }

    // Buscar si hay tabla de locales comerciales
    echo "\n\n=== BUSCANDO RELACIÓN id_local ===\n";
    $stmt = $pdo->query("
        SELECT table_name, column_name
        FROM information_schema.columns
        WHERE column_name = 'id_local'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_name
    ");
    $localTables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Tablas con campo id_local:\n";
    foreach ($localTables as $lt) {
        echo "  - {$lt['table_name']}.{$lt['column_name']}\n";
    }

    // Si existe tabla de locales, ver su estructura
    if (count($localTables) > 0) {
        echo "\n=== ESTRUCTURA DE publico.locales (si existe) ===\n";
        try {
            $stmt = $pdo->query("
                SELECT column_name, data_type, character_maximum_length
                FROM information_schema.columns
                WHERE table_schema = 'publico'
                AND table_name = 'locales'
                ORDER BY ordinal_position
                LIMIT 15
            ");
            $localCols = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($localCols) > 0) {
                foreach ($localCols as $col) {
                    $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                    echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
                }

                echo "\nDatos de ejemplo:\n";
                $stmt = $pdo->query("SELECT * FROM publico.locales LIMIT 2");
                $localRows = $stmt->fetchAll(PDO::FETCH_ASSOC);
                foreach ($localRows as $i => $row) {
                    echo "  Registro " . ($i + 1) . ":\n";
                    $keys = array_slice(array_keys($row), 0, 8);
                    foreach ($keys as $key) {
                        $val = is_null($row[$key]) ? 'NULL' : substr(trim($row[$key]), 0, 30);
                        echo "    $key: $val\n";
                    }
                }
            }
        } catch (Exception $e) {
            echo "  (Tabla publico.locales no existe)\n";
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
