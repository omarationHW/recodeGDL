<?php
// Script para ver estructura de tablas de cementerios

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver estructura de ta_13_datosrcm en public
    echo "=== ESTRUCTURA DE public.ta_13_datosrcm ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'ta_13_datosrcm'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        echo "\nDatos de ejemplo (5 registros):\n";
        $stmt = $pdo->query("SELECT * FROM public.ta_13_datosrcm LIMIT 5");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($rows as $i => $row) {
            echo "\n  Registro " . ($i + 1) . ":\n";
            foreach ($row as $key => $val) {
                $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                echo "    $key: $val\n";
            }
        }

        // Contar registros
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.ta_13_datosrcm");
        $total = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "\nTotal de registros: " . number_format($total['total']) . "\n";
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }

    // Ver estructura de publico.ta_13_datosrcm
    echo "\n\n=== ESTRUCTURA DE publico.ta_13_datosrcm ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'publico'
            AND table_name = 'ta_13_datosrcm'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($columns) > 0) {
            foreach ($columns as $col) {
                $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
            }

            echo "\nDatos de ejemplo:\n";
            $stmt = $pdo->query("SELECT * FROM publico.ta_13_datosrcm LIMIT 3");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($rows as $i => $row) {
                echo "\n  Registro " . ($i + 1) . ":\n";
                foreach ($row as $key => $val) {
                    $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                    echo "    $key: $val\n";
                }
            }
        } else {
            echo "  (No existe en esquema publico)\n";
        }
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }

    // Ver estructura de tc_13_cementerios
    echo "\n\n=== ESTRUCTURA DE publico.tc_13_cementerios ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'publico'
            AND table_name = 'tc_13_cementerios'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        echo "\nDatos de ejemplo:\n";
        $stmt = $pdo->query("SELECT * FROM publico.tc_13_cementerios LIMIT 5");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($rows as $i => $row) {
            echo "\n  Registro " . ($i + 1) . ":\n";
            foreach ($row as $key => $val) {
                $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                echo "    $key: $val\n";
            }
        }
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }

    // Ver estructura de ta_13_pagosrcm
    echo "\n\n=== ESTRUCTURA DE public.ta_13_pagosrcm ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'ta_13_pagosrcm'
            ORDER BY ordinal_position
            LIMIT 20
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        echo "\nDatos de ejemplo:\n";
        $stmt = $pdo->query("SELECT * FROM public.ta_13_pagosrcm LIMIT 2");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($rows as $i => $row) {
            echo "\n  Registro " . ($i + 1) . ":\n";
            $keys = array_slice(array_keys($row), 0, 12);
            foreach ($keys as $key) {
                $val = is_null($row[$key]) ? 'NULL' : (is_string($row[$key]) ? substr(trim($row[$key]), 0, 30) : $row[$key]);
                echo "    $key: $val\n";
            }
        }
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
