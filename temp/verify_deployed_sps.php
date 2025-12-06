<?php
/**
 * Verificar detalles de los SPs desplegados
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

    echo "\n=============================================================\n";
    echo "VERIFICACIÓN DETALLADA DE SPs DESPLEGADOS\n";
    echo "=============================================================\n\n";

    // Obtener información detallada de cada SP
    $sps = [
        'sp_pasomdos_insert_tianguis',
        'sp_pasomdos_verificar_local',
        'sp_get_tianguis_locales',
        'sp_insertar_adeudo_local'
    ];

    foreach ($sps as $spName) {
        echo "SP: $spName\n";
        echo str_repeat('-', 70) . "\n";

        // Obtener parámetros del SP
        $stmt = $pdo->prepare("
            SELECT
                p.parameter_name,
                p.data_type,
                p.parameter_mode
            FROM information_schema.parameters p
            WHERE p.specific_schema = 'public'
            AND p.specific_name LIKE ?
            ORDER BY p.ordinal_position
        ");
        $stmt->execute([$spName . '%']);
        $params = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($params) > 0) {
            echo "Parámetros:\n";
            foreach ($params as $param) {
                $mode = $param['parameter_mode'] ?: 'IN';
                echo "  - {$param['parameter_name']} ({$param['data_type']}) [$mode]\n";
            }
        } else {
            echo "  Sin parámetros de entrada\n";
        }

        // Obtener tipo de retorno
        $stmt = $pdo->prepare("
            SELECT
                r.routine_type,
                r.data_type,
                r.type_udt_name
            FROM information_schema.routines r
            WHERE r.routine_schema = 'public'
            AND r.routine_name = ?
        ");
        $stmt->execute([$spName]);
        $routine = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($routine) {
            echo "Tipo: {$routine['routine_type']}\n";
            if ($routine['data_type']) {
                echo "Retorna: {$routine['data_type']}\n";
            }
        }

        echo "\n";
    }

    // Verificar tablas necesarias
    echo "=============================================================\n";
    echo "VERIFICACIÓN DE TABLAS RELACIONADAS\n";
    echo "=============================================================\n\n";

    $tablas = [
        ['comun', 'ta_11_locales', 'Locales (compartida)'],
        ['comun', 'ta_11_adeudo_local', 'Adeudos locales (compartida)']
    ];

    foreach ($tablas as list($schema, $tabla, $descripcion)) {
        $stmt = $pdo->prepare("
            SELECT COUNT(*) as count
            FROM information_schema.tables
            WHERE table_schema = ?
            AND table_name = ?
        ");
        $stmt->execute([$schema, $tabla]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        $status = $result['count'] > 0 ? '✓' : '✗';
        echo "$status $schema.$tabla - $descripcion\n";

        if ($result['count'] > 0) {
            // Contar registros
            try {
                $count = $pdo->query("SELECT COUNT(*) FROM $schema.$tabla")->fetchColumn();
                echo "  Registros: " . number_format($count) . "\n";
            } catch (Exception $e) {
                echo "  (No se pudo contar registros)\n";
            }
        }
    }

    // Verificar tabla en mercados
    echo "\nVerificando tabla en base de datos mercados...\n";
    $pdoMercados = new PDO("pgsql:host=$host;port=$port;dbname=mercados", $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    $stmt = $pdoMercados->query("
        SELECT COUNT(*) as count
        FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'ta_11_cuo_locales'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    $status = $result['count'] > 0 ? '✓' : '✗';
    echo "$status mercados.public.ta_11_cuo_locales - Cuotas locales\n";

    if ($result['count'] > 0) {
        $count = $pdoMercados->query("SELECT COUNT(*) FROM public.ta_11_cuo_locales")->fetchColumn();
        echo "  Registros: " . number_format($count) . "\n";
    }

    echo "\n";
    echo str_repeat('=', 70) . "\n";
    echo "✓ VERIFICACIÓN COMPLETADA\n";
    echo str_repeat('=', 70) . "\n\n";

} catch (PDOException $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
