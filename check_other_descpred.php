<?php
// Script para ver otras tablas de descuentos prediales

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver estructura de c_descpred
    echo "=== ESTRUCTURA DE public.c_descpred ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'c_descpred'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        echo "\nDatos de ejemplo:\n";
        $stmt = $pdo->query("SELECT * FROM public.c_descpred LIMIT 5");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($rows as $i => $row) {
            echo "\n  Registro " . ($i + 1) . ":\n";
            foreach ($row as $key => $val) {
                $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                echo "    $key: $val\n";
            }
        }

        $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.c_descpred");
        $total = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "\nTotal: " . number_format($total['total']) . "\n";
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }

    // Ver estructura de descpred
    echo "\n\n=== ESTRUCTURA DE public.descpred ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'descpred'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        echo "\nDatos de ejemplo:\n";
        $stmt = $pdo->query("SELECT * FROM public.descpred LIMIT 5");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($rows as $i => $row) {
            echo "\n  Registro " . ($i + 1) . ":\n";
            foreach ($row as $key => $val) {
                $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                echo "    $key: $val\n";
            }
        }

        $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.descpred");
        $total = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "\nTotal: " . number_format($total['total']) . "\n";
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }

    // Ver estructura de descpred_reactiva
    echo "\n\n=== ESTRUCTURA DE public.descpred_reactiva ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'descpred_reactiva'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        echo "\nDatos de ejemplo:\n";
        $stmt = $pdo->query("SELECT * FROM public.descpred_reactiva LIMIT 3");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($rows as $i => $row) {
            echo "\n  Registro " . ($i + 1) . ":\n";
            $keys = array_slice(array_keys($row), 0, 10);
            foreach ($keys as $key) {
                $val = is_null($row[$key]) ? 'NULL' : (is_string($row[$key]) ? substr(trim($row[$key]), 0, 30) : $row[$key]);
                echo "    $key: $val\n";
            }
        }

        $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.descpred_reactiva");
        $total = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "\nTotal: " . number_format($total['total']) . "\n";
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
