<?php
// Obtener ejemplos de multas canceladas
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== ESTRUCTURA COMPLETA DE comun.multas ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'multas'
        ORDER BY ordinal_position
        LIMIT 30
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo sprintf("  %-30s %s\n", $row['column_name'], $row['data_type']);
    }

    echo "\n=== PRIMEROS 5 REGISTROS CON CANCELACIÓN ===\n\n";
    $stmt = $pdo->query("
        SELECT *
        FROM comun.multas
        WHERE fecha_cancelacion IS NOT NULL
        ORDER BY fecha_cancelacion DESC
        LIMIT 5
    ");

    $first_records = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($first_records as $idx => $record) {
        echo "Registro " . ($idx + 1) . ":\n";
        $important_fields = ['id', 'axo_acta', 'num_acta', 'fecha_acta', 'fecha_cancelacion', 'multa', 'total', 'id_dependencia'];
        foreach ($important_fields as $field) {
            if (isset($record[$field]) && $record[$field] !== null) {
                echo "  $field: {$record[$field]}\n";
            }
        }
        echo "\n";
    }

    // Buscar num_acta para usar como "cuenta" en ejemplos
    echo "\n=== OBTENIENDO 10 EJEMPLOS DE MULTAS CANCELADAS ===\n\n";
    $stmt = $pdo->query("
        SELECT
            CONCAT(axo_acta, '-', num_acta) as cuenta,
            axo_acta,
            num_acta,
            fecha_acta,
            fecha_cancelacion,
            multa,
            gastos,
            total,
            id_dependencia
        FROM comun.multas
        WHERE fecha_cancelacion IS NOT NULL
        AND num_acta IS NOT NULL
        ORDER BY fecha_cancelacion DESC
        LIMIT 10
    ");

    $ejemplos = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $ejemplos[] = $row['cuenta'];
        echo sprintf("Cuenta: %-15s | Cancelado: %s | Total: $%.2f | Dep: %d\n",
            $row['cuenta'],
            $row['fecha_cancelacion'],
            $row['total'],
            $row['id_dependencia']
        );
    }

    // Para 3 ejemplos específicos, obtener más detalles
    echo "\n=== 3 EJEMPLOS SELECCIONADOS PARA PRUEBAS ===\n\n";

    $cuentas_ejemplo = array_slice($ejemplos, 0, 3);

    foreach ($cuentas_ejemplo as $idx => $cuenta_str) {
        list($axo, $num) = explode('-', $cuenta_str);

        echo "EJEMPLO " . ($idx + 1) . ": Cuenta '$cuenta_str'\n";

        $stmt = $pdo->prepare("
            SELECT COUNT(*) as total
            FROM comun.multas
            WHERE axo_acta = ?
            AND num_acta = ?
            AND fecha_cancelacion IS NOT NULL
        ");
        $stmt->execute([$axo, $num]);
        $count = $stmt->fetchColumn();

        echo "  Registros encontrados: $count\n";

        // Obtener detalles del primer registro
        $stmt = $pdo->prepare("
            SELECT *
            FROM comun.multas
            WHERE axo_acta = ?
            AND num_acta = ?
            AND fecha_cancelacion IS NOT NULL
            LIMIT 1
        ");
        $stmt->execute([$axo, $num]);
        $multa = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($multa) {
            echo "  Año Acta: {$multa['axo_acta']}\n";
            echo "  Núm Acta: {$multa['num_acta']}\n";
            echo "  Fecha Acta: {$multa['fecha_acta']}\n";
            echo "  Fecha Cancelación: {$multa['fecha_cancelacion']}\n";
            echo "  Multa: \${$multa['multa']}\n";
            echo "  Gastos: \${$multa['gastos']}\n";
            echo "  Total: \${$multa['total']}\n";
            echo "  Dependencia: {$multa['id_dependencia']}\n";
        }
        echo "\n";
    }

    echo "\n=== RESUMEN ===\n";
    echo "Usar como clave_cuenta: axo_acta + '-' + num_acta\n";
    echo "Ejemplos para probar:\n";
    foreach ($cuentas_ejemplo as $idx => $cuenta) {
        echo "  " . ($idx + 1) . ". $cuenta\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
