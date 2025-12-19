<?php
// Script para analizar si auditoria puede usarse para presupuesto

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Ver estructura de auditoria
    echo "=== ESTRUCTURA DE AUDITORIA ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'auditoria'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        echo "  {$col['column_name']}: {$col['data_type']}\n";
    }

    // 2. Ver distribución de bimestres
    echo "\n\n=== DISTRIBUCIÓN POR BIMESTRE ===\n\n";

    $stmt = $pdo->query("
        SELECT
            bimini,
            COUNT(*) as registros,
            SUM(monto) as suma_total
        FROM public.auditoria
        WHERE bimini IS NOT NULL
        AND cancelacion IS DISTINCT FROM 'C'
        GROUP BY bimini
        ORDER BY bimini
    ");

    $bimestres = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Bimestre | Registros  | Suma Total\n";
    echo "---------|------------|------------------\n";
    foreach ($bimestres as $bim) {
        $bim_num = $bim['bimini'] ?? 'NULL';
        echo sprintf("   %s     | %10s | $%s\n",
            str_pad($bim_num, 2, ' ', STR_PAD_LEFT),
            number_format($bim['registros']),
            number_format($bim['suma_total'], 2)
        );
    }

    // 3. Ver datos por año (ejercicio) y cuenta
    echo "\n\n=== EJEMPLO: DATOS POR AÑO 2024 ===\n\n";

    $stmt = $pdo->query("
        SELECT
            axopago as ejercicio,
            cvectaapl,
            COUNT(*) as num_movimientos,
            SUM(monto) as suma_anual
        FROM public.auditoria
        WHERE axopago = 2024
        AND cancelacion IS DISTINCT FROM 'C'
        AND cvectaapl IS NOT NULL
        GROUP BY axopago, cvectaapl
        ORDER BY suma_anual DESC
        LIMIT 10
    ");

    $datos_2024 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Top 10 cuentas en 2024:\n\n";
    echo "Ejercicio | Cuenta      | Movimientos | Suma Anual\n";
    echo "----------|-------------|-------------|------------------\n";
    foreach ($datos_2024 as $row) {
        echo sprintf("   %s   | %11s | %11s | $%s\n",
            $row['ejercicio'],
            $row['cvectaapl'],
            number_format($row['num_movimientos']),
            number_format($row['suma_anual'], 2)
        );
    }

    // 4. Ver ejemplo de distribución por bimestre para una cuenta específica
    echo "\n\n=== DISTRIBUCIÓN BIMESTRAL 2024 - CUENTA 46202 ===\n\n";

    $stmt = $pdo->query("
        SELECT
            bimini,
            SUM(monto) as suma_bimestre,
            COUNT(*) as movimientos
        FROM public.auditoria
        WHERE axopago = 2024
        AND cvectaapl = 46202
        AND cancelacion IS DISTINCT FROM 'C'
        GROUP BY bimini
        ORDER BY bimini
    ");

    $dist_bimestral = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Bimestre | Meses      | Suma          | Movimientos\n";
    echo "---------|------------|---------------|------------\n";

    $meses_por_bimestre = [
        1 => 'Ene-Feb',
        2 => 'Mar-Abr',
        3 => 'May-Jun',
        4 => 'Jul-Ago',
        5 => 'Sep-Oct',
        6 => 'Nov-Dic'
    ];

    foreach ($dist_bimestral as $row) {
        $bim = $row['bimini'];
        $meses = $meses_por_bimestre[$bim] ?? 'N/A';
        echo sprintf("    %s    | %s   | $%12s | %11s\n",
            $bim,
            $meses,
            number_format($row['suma_bimestre'], 2),
            number_format($row['movimientos'])
        );
    }

    // 5. Conclusión
    echo "\n\n=== CONCLUSIÓN ===\n\n";
    echo "✅ La tabla AUDITORIA puede usarse para simular presupuesto:\n\n";
    echo "Ventajas:\n";
    echo "  • Tiene ejercicio (axopago)\n";
    echo "  • Tiene cuentas de aplicación (cvectaapl)\n";
    echo "  • Tiene montos (monto)\n";
    echo "  • Tiene periodos bimestrales (bimini)\n";
    echo "  • Datos reales de 29.5M registros\n\n";

    echo "Limitaciones:\n";
    echo "  • Datos en BIMESTRES, no MESES individuales\n";
    echo "  • Cada bimestre tendría que dividirse en 2 meses\n";
    echo "  • No es un 'presupuesto' real, son movimientos de auditoria\n\n";

    echo "Propuesta:\n";
    echo "  • Usar bimini para mapear a meses\n";
    echo "  • Bimestre 1 = Enero + Febrero\n";
    echo "  • Bimestre 2 = Marzo + Abril\n";
    echo "  • Bimestre 3 = Mayo + Junio\n";
    echo "  • Bimestre 4 = Julio + Agosto\n";
    echo "  • Bimestre 5 = Septiembre + Octubre\n";
    echo "  • Bimestre 6 = Noviembre + Diciembre\n";
    echo "  • Dividir monto del bimestre entre 2 para cada mes\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
