<?php
// Script para verificar estructura de tablas de cuentas

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Verificar estructura de cuentas_bloq
    echo "=== ESTRUCTURA DE public.cuentas_bloq ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'cuentas_bloq'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    // Ver algunos registros de ejemplo
    echo "\n=== REGISTROS DE EJEMPLO (primeros 5) ===\n\n";

    $stmt = $pdo->query("SELECT * FROM public.cuentas_bloq LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  {$key}: " . (is_null($value) ? 'NULL' : $value) . "\n";
        }
        echo "\n";
    }

    // Ver estadísticas
    echo "=== ESTADÍSTICAS ===\n\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.cuentas_bloq");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total registros: {$total['total']}\n";

    // Ahora verificar cuentas_bloq_h
    echo "\n\n=== ESTRUCTURA DE public.cuentas_bloq_h ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'cuentas_bloq_h'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    // Ver algunos registros de ejemplo
    echo "\n=== REGISTROS DE EJEMPLO (primeros 5) ===\n\n";

    $stmt = $pdo->query("SELECT * FROM public.cuentas_bloq_h LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  {$key}: " . (is_null($value) ? 'NULL' : $value) . "\n";
        }
        echo "\n";
    }

    echo "=== ESTADÍSTICAS ===\n\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.cuentas_bloq_h");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total registros: {$total['total']}\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
