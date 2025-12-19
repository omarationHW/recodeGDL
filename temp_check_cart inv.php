<?php
$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== INVESTIGANDO CARTAINVPREDIAL ===\n\n";

    // 1. Ver estructura completa
    echo "1. Estructura de cartainvpredial...\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'cartainvpredial'
        ORDER BY ordinal_position
    ");

    echo "   Columnas:\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $col) {
        $tipo = $col['data_type'];
        if ($col['character_maximum_length']) {
            $tipo .= '(' . $col['character_maximum_length'] . ')';
        }
        echo "      - " . str_pad($col['column_name'], 25) . ": $tipo\n";
    }

    // Contar registros
    $count = $pdo->query("SELECT COUNT(*) as total FROM public.cartainvpredial")->fetch(PDO::FETCH_ASSOC);
    echo "\n   Total registros: " . number_format($count['total']) . "\n";

    // 2. Ver muestra de datos
    echo "\n\n2. Muestra de datos de cartainvpredial...\n\n";

    $stmt = $pdo->query("SELECT * FROM public.cartainvpredial LIMIT 2");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $idx => $reg) {
        echo "   Registro " . ($idx + 1) . ":\n";
        foreach ($reg as $key => $value) {
            echo "      " . str_pad($key, 25) . ": " . ($value !== null ? substr($value, 0, 50) : 'NULL') . "\n";
        }
        echo "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
