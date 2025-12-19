<?php
// Script para probar filtros de fecha del stored procedure recaudadora_polcon

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_polcon...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_polcon.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar SIN fechas (todos los registros)
    echo "2. Probando SIN fechas (todos los registros históricos)...\n";
    $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM publico.recaudadora_polcon(NULL, NULL)");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total cuentas: {$result['total']}\n\n";

    // 3. Probar diferentes años
    $anios_prueba = [
        ['2024-01-01', '2024-12-31', '2024'],
        ['2023-01-01', '2023-12-31', '2023'],
        ['2022-01-01', '2022-12-31', '2022'],
        ['2021-01-01', '2021-12-31', '2021'],
        ['2020-01-01', '2020-12-31', '2020'],
        ['2015-01-01', '2015-12-31', '2015'],
        ['2010-01-01', '2010-12-31', '2010'],
        ['2000-01-01', '2000-12-31', '2000'],
        ['1995-01-01', '1995-12-31', '1995'],
    ];

    echo "3. Probando filtros por año individual...\n\n";

    foreach ($anios_prueba as $prueba) {
        $desde = $prueba[0];
        $hasta = $prueba[1];
        $anio = $prueba[2];

        $stmt = $pdo->prepare("
            SELECT
                COUNT(*) as total_cuentas,
                SUM(num_movimientos) as total_movimientos,
                SUM(suma) as suma_total
            FROM publico.recaudadora_polcon(?, ?)
        ");
        $stmt->execute([$desde, $hasta]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Año $anio:\n";
        echo "     Cuentas: " . number_format($result['total_cuentas']) . "\n";
        echo "     Movimientos: " . number_format($result['total_movimientos']) . "\n";
        echo "     Suma: $" . number_format($result['suma_total'], 2) . "\n\n";
    }

    // 4. Probar rangos de años
    echo "4. Probando rangos de años...\n\n";

    $rangos = [
        ['2020-01-01', '2024-12-31', '2020-2024'],
        ['2015-01-01', '2019-12-31', '2015-2019'],
        ['2010-01-01', '2014-12-31', '2010-2014'],
        ['2000-01-01', '2009-12-31', '2000-2009'],
        ['1990-01-01', '1999-12-31', '1990-1999'],
    ];

    foreach ($rangos as $rango) {
        $desde = $rango[0];
        $hasta = $rango[1];
        $periodo = $rango[2];

        $stmt = $pdo->prepare("
            SELECT
                COUNT(*) as total_cuentas,
                SUM(num_movimientos) as total_movimientos
            FROM publico.recaudadora_polcon(?, ?)
        ");
        $stmt->execute([$desde, $hasta]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Periodo $periodo:\n";
        echo "     Cuentas: " . number_format($result['total_cuentas']) . "\n";
        echo "     Movimientos: " . number_format($result['total_movimientos']) . "\n\n";
    }

    // 5. Probar con fecha desde sin fecha hasta
    echo "5. Probando con fecha desde (sin fecha hasta)...\n\n";

    $fechas_desde = ['2024-01-01', '2020-01-01', '2015-01-01', '2010-01-01'];

    foreach ($fechas_desde as $desde) {
        $anio = substr($desde, 0, 4);

        $stmt = $pdo->prepare("
            SELECT COUNT(*) as total_cuentas
            FROM publico.recaudadora_polcon(?, NULL)
        ");
        $stmt->execute([$desde]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Desde $anio: " . number_format($result['total_cuentas']) . " cuentas\n";
    }

    // 6. Verificar que los resultados sean diferentes
    echo "\n\n6. Verificación: Los filtros deben retornar cantidades diferentes...\n\n";

    $stmt1 = $pdo->prepare("SELECT COUNT(*) as total FROM publico.recaudadora_polcon(NULL, NULL)");
    $stmt1->execute();
    $total_sin_filtro = $stmt1->fetch(PDO::FETCH_ASSOC)['total'];

    $stmt2 = $pdo->prepare("SELECT COUNT(*) as total FROM publico.recaudadora_polcon('2024-01-01', '2024-12-31')");
    $stmt2->execute();
    $total_2024 = $stmt2->fetch(PDO::FETCH_ASSOC)['total'];

    $stmt3 = $pdo->prepare("SELECT COUNT(*) as total FROM publico.recaudadora_polcon('2010-01-01', '2010-12-31')");
    $stmt3->execute();
    $total_2010 = $stmt3->fetch(PDO::FETCH_ASSOC)['total'];

    echo "   Sin filtro: $total_sin_filtro cuentas\n";
    echo "   Año 2024: $total_2024 cuentas\n";
    echo "   Año 2010: $total_2010 cuentas\n\n";

    if ($total_sin_filtro > $total_2024 && $total_sin_filtro > $total_2010 && $total_2024 != $total_2010) {
        echo "   ✅ ¡FILTROS FUNCIONANDO CORRECTAMENTE!\n";
        echo "      Los diferentes filtros retornan cantidades diferentes.\n";
    } else {
        echo "   ⚠️  ADVERTENCIA: Los filtros parecen retornar los mismos resultados.\n";
        echo "      Sin filtro: $total_sin_filtro\n";
        echo "      2024: $total_2024\n";
        echo "      2010: $total_2010\n";
    }

    echo "\n\n✅ Pruebas completadas!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
