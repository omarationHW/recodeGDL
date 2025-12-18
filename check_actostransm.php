<?php
// Script para revisar la tabla actostransm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver estructura de actostransm
    echo "=== ESTRUCTURA DE public.actostransm ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'actostransm'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Columnas (" . count($columns) . " total):\n";
    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    // Total de registros
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.actostransm");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "\nTotal registros: " . number_format($total['total']) . "\n";

    // Muestra de datos
    echo "\nMuestra de datos (3 registros):\n";
    $stmt = $pdo->query("SELECT * FROM public.actostransm LIMIT 3");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "\n  Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $val) {
            $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
            echo "    $key: $val\n";
        }
    }

    // Verificar si public.firmas_electronicas ya existía antes
    echo "\n\n=== VERIFICAR public.firmas_electronicas ===\n";

    // Ver cuando se creó
    $stmt = $pdo->query("
        SELECT obj_description('public.firmas_electronicas'::regclass) as descripcion
    ");
    $desc = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($desc && $desc['descripcion']) {
        echo "Descripción: {$desc['descripcion']}\n";
    }

    // Ver registros
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.firmas_electronicas");
    $total_firmas = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total registros en firmas_electronicas: {$total_firmas['total']}\n";

    echo "\n✅ Revisión completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
