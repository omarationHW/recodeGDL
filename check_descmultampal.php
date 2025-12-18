<?php
// Script para ver estructura de descmultampal

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver estructura de descmultampal en public
    echo "=== ESTRUCTURA DE public.descmultampal ===\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'descmultampal'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    echo "\nDatos de ejemplo (5 registros):\n";
    $stmt = $pdo->query("SELECT * FROM public.descmultampal LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "\n  Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $val) {
            $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
            echo "    $key: $val\n";
        }
    }

    // Contar registros
    echo "\n\n=== ANÁLISIS ===\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.descmultampal");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total de registros en descmultampal: " . number_format($total['total']) . "\n";

    // Ver estructura de publico.descmultampal
    echo "\n\n=== ESTRUCTURA DE publico.descmultampal ===\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'publico'
        AND table_name = 'descmultampal'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($columns) > 0) {
        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        echo "\nDatos de ejemplo:\n";
        $stmt = $pdo->query("SELECT * FROM publico.descmultampal LIMIT 3");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($rows as $i => $row) {
            echo "\n  Registro " . ($i + 1) . ":\n";
            foreach ($row as $key => $val) {
                $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                echo "    $key: $val\n";
            }
        }
    } else {
        echo "  (Tabla no existe en esquema publico)\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
