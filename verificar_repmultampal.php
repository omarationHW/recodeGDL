<?php
$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Verificando estructura de h_multasnvo para reporte de multas municipales...\n\n";

    // Ver campos disponibles en la tabla primero
    echo "Campos disponibles en h_multasnvo:\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'h_multasnvo'
        ORDER BY ordinal_position
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  {$row['column_name']}: {$row['data_type']}\n";
    }

    // Ver algunos registros de ejemplo
    echo "\n\nRegistros de ejemplo (2024):\n";
    $stmt = $pdo->query("
        SELECT *
        FROM public.h_multasnvo
        WHERE fecha_acta IS NOT NULL
        AND EXTRACT(YEAR FROM fecha_acta) = 2024
        ORDER BY fecha_acta DESC
        LIMIT 3
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "Registro:\n";
        foreach ($row as $key => $value) {
            echo "  $key: $value\n";
        }
        echo "\n";
    }

    // Ver estadísticas por mes en 2024
    echo "\n\nEstadísticas mensuales 2024:\n";
    $stmt = $pdo->query("
        SELECT
            EXTRACT(MONTH FROM fecha_acta) as mes,
            COUNT(*) as cantidad,
            SUM(multa) as total_multas,
            SUM(gastos) as total_gastos,
            SUM(total) as total_general
        FROM public.h_multasnvo
        WHERE EXTRACT(YEAR FROM fecha_acta) = 2024
        AND fecha_acta IS NOT NULL
        GROUP BY EXTRACT(MONTH FROM fecha_acta)
        ORDER BY mes
        LIMIT 12
    ");

    echo "Mes | Cantidad | Total Multas  | Total Gastos | Total General\n";
    echo "----------------------------------------------------------------\n";

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        printf("%3d | %8d | $%12.2f | $%11.2f | $%12.2f\n",
            $row['mes'],
            $row['cantidad'],
            $row['total_multas'],
            $row['total_gastos'],
            $row['total_general']
        );
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
