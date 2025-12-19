<?php
// Verificar la estructura de la tabla public.pago_diversos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ESTRUCTURA DE public.pago_diversos ===\n\n";

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
        AND table_name = 'pago_diversos'
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
    echo "\n\n=== REGISTROS DE EJEMPLO (primeros 5) ===\n\n";

    $stmt = $pdo->query("SELECT * FROM public.pago_diversos ORDER BY cvepago DESC LIMIT 5");
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Total de registros: " . count($records) . "\n\n";

    if (count($records) > 0) {
        foreach ($records as $i => $record) {
            echo "Registro " . ($i + 1) . ":\n";
            foreach ($record as $key => $value) {
                if ($value !== null && strlen($value) > 100) {
                    $value = substr($value, 0, 100) . '...';
                }
                echo "  {$key}: " . ($value !== null ? $value : 'NULL') . "\n";
            }
            echo "\n";
        }
    }

    // Verificar campos clave
    echo "\n=== VERIFICANDO CAMPOS CLAVE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'pago_diversos'
        AND (
            column_name ILIKE '%clave%'
            OR column_name ILIKE '%cuenta%'
            OR column_name ILIKE '%folio%'
            OR column_name ILIKE '%contribuyente%'
            OR column_name ILIKE '%fecha%'
            OR column_name ILIKE '%concepto%'
            OR column_name ILIKE '%monto%'
            OR column_name ILIKE '%importe%'
        )
    ");

    $key_columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($key_columns) > 0) {
        echo "Campos relacionados con búsqueda:\n";
        foreach ($key_columns as $col) {
            echo "  - {$col['column_name']}\n";
        }
    }

    // Contar total de registros
    echo "\n\n=== ESTADÍSTICAS ===\n\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.pago_diversos");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total de registros: " . number_format($total['total']) . "\n";

    // Ver distribución por años (usando axoini)
    echo "\n   Distribución por años iniciales (últimos 5):\n";
    $stmt_years = $pdo->query("
        SELECT
            axoini AS anio,
            COUNT(*) as total
        FROM public.pago_diversos
        WHERE axoini IS NOT NULL AND axoini > 0
        GROUP BY axoini
        ORDER BY anio DESC
        LIMIT 5
    ");
    $years = $stmt_years->fetchAll(PDO::FETCH_ASSOC);
    foreach ($years as $year) {
        echo "   - Año {$year['anio']}: " . number_format($year['total']) . " pagos\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
