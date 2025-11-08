<?php
/**
 * Ver estructura de tabla h_bloqueo_dom
 * Fecha: 2025-11-06
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "=== ESTRUCTURA DE public.h_bloqueo_dom ===\n\n";

    // Ver estructura de columnas
    $stmt = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'h_bloqueo_dom'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
        $default = $col['column_default'] ? " DEFAULT {$col['column_default']}" : "";
        echo sprintf("%-25s %-20s %-10s%s\n",
            $col['column_name'],
            $col['data_type'] . $length,
            $nullable,
            $default
        );
    }

    // Contar registros
    $stmt = $pdo->query("SELECT COUNT(*) FROM public.h_bloqueo_dom");
    $count = $stmt->fetchColumn();
    echo "\nTotal de registros: " . number_format($count) . "\n";

    // Ver muestra de datos
    echo "\n=== MUESTRA DE 5 REGISTROS ===\n";
    $stmt = $pdo->query("SELECT * FROM public.h_bloqueo_dom LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        foreach ($rows as $row) {
            echo "\nRegistro:\n";
            foreach ($row as $key => $value) {
                echo "  $key: " . ($value ?? 'NULL') . "\n";
            }
        }
    } else {
        echo "  No hay datos en la tabla\n";
    }

    echo "\n✓ Análisis completado\n";

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
