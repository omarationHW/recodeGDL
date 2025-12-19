<?php
// Verificar la estructura de la tabla public.pagos_400

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ESTRUCTURA DE public.pagos_400 ===\n\n";

    // Obtener estructura de la tabla
    $stmt = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            numeric_precision,
            numeric_scale,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'pagos_400'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Campos de la tabla:\n";
    foreach ($columns as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        } elseif ($col['numeric_precision']) {
            $type .= "({$col['numeric_precision']}";
            if ($col['numeric_scale']) {
                $type .= ",{$col['numeric_scale']}";
            }
            $type .= ")";
        }
        $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
        echo "  - {$col['column_name']}: {$type} {$nullable}\n";
    }

    // Obtener algunos registros de ejemplo
    echo "\n\n=== REGISTROS DE EJEMPLO (primeros 3) ===\n\n";

    $stmt = $pdo->query("SELECT * FROM public.pagos_400 LIMIT 3");
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Total de registros obtenidos: " . count($records) . "\n\n";

    if (count($records) > 0) {
        foreach ($records as $i => $record) {
            echo "Registro " . ($i + 1) . ":\n";
            foreach ($record as $key => $value) {
                if ($value !== null && is_string($value) && strlen($value) > 80) {
                    $value = substr($value, 0, 80) . '...';
                }
                echo "  {$key}: " . ($value !== null ? $value : 'NULL') . "\n";
            }
            echo "\n";
        }
    }

    // Contar total de registros
    echo "\n=== ESTADÍSTICAS ===\n\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.pagos_400");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total de registros: " . number_format($total['total']) . "\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
