<?php
$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICANDO TABLA h_multasnvo ===\n\n";

    // Ver campos de fecha y valores monetarios
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'h_multasnvo'
        AND (column_name ILIKE '%fecha%' OR column_name ILIKE '%multa%'
             OR column_name ILIKE '%gasto%' OR column_name ILIKE '%total%'
             OR column_name ILIKE '%depend%')
        ORDER BY ordinal_position
    ");

    echo "Campos relevantes de h_multasnvo:\n";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  {$row['column_name']}: {$row['data_type']}\n";
    }

    // Ver registro de ejemplo
    echo "\n--- Registro de ejemplo ---\n";
    $stmt = $pdo->query("
        SELECT id_dependencia, fecha_acta, multa, gastos, total
        FROM public.h_multasnvo
        WHERE fecha_acta IS NOT NULL
        AND id_dependencia IS NOT NULL
        ORDER BY fecha_acta DESC
        LIMIT 3
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "Dep: {$row['id_dependencia']}, Fecha: {$row['fecha_acta']}, ";
        echo "Multa: \${$row['multa']}, Gastos: \${$row['gastos']}, Total: \${$row['total']}\n";
    }

    // Probar agregación por mes
    echo "\n--- Prueba de agregación por mes (2024) ---\n";
    $stmt = $pdo->query("
        SELECT
            id_dependencia,
            EXTRACT(YEAR FROM fecha_acta) as anio,
            EXTRACT(MONTH FROM fecha_acta) as mes,
            COUNT(*) as cantidad,
            SUM(multa) as total_multas,
            SUM(gastos) as total_gastos,
            SUM(total) as total_general
        FROM public.h_multasnvo
        WHERE EXTRACT(YEAR FROM fecha_acta) = 2024
        AND id_dependencia IS NOT NULL
        GROUP BY id_dependencia, EXTRACT(YEAR FROM fecha_acta), EXTRACT(MONTH FROM fecha_acta)
        ORDER BY id_dependencia, mes
        LIMIT 10
    ");

    echo "Dep | Año  | Mes | Cantidad | Tot.Multas | Tot.Gastos | Tot.General\n";
    echo "--------------------------------------------------------------------\n";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        printf("%3d | %4d | %3d | %8d | %10.2f | %10.2f | %11.2f\n",
            $row['id_dependencia'], $row['anio'], $row['mes'],
            $row['cantidad'], $row['total_multas'], $row['total_gastos'],
            $row['total_general']);
    }

    echo "\n✅ h_multasnvo es adecuada para relación mensual!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
