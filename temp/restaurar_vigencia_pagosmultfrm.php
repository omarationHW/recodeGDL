<?php
/**
 * Script para restaurar la vigencia de requerimientos a 'V'
 * para poder volver a probar el formulario pagosmultfrm
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

    echo "=== RESTAURAR VIGENCIA PARA PAGOSMULTFRM ===\n\n";

    // Datos a restaurar
    $registros = [
        ['cuenta' => 319628, 'folio' => 1],
        ['cuenta' => 358307, 'folio' => 2]
    ];

    echo "Registros a restaurar:\n";
    foreach ($registros as $reg) {
        echo "  - Cuenta: {$reg['cuenta']}, Folio: {$reg['folio']}\n";
    }
    echo "\n";

    // Verificar estado actual
    echo "Estado ACTUAL de los registros:\n";
    echo str_repeat("-", 80) . "\n";

    foreach ($registros as $reg) {
        $sql = "SELECT cvecuenta, folioreq, vigencia, total, feccan
                FROM catastro_gdl.reqdiftransmision
                WHERE cvecuenta = :cuenta AND folioreq = :folio";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            'cuenta' => $reg['cuenta'],
            'folio' => $reg['folio']
        ]);

        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row) {
            echo "Cuenta: {$row['cvecuenta']}, Folio: {$row['folioreq']}\n";
            echo "  Vigencia: {$row['vigencia']}\n";
            echo "  Total: {$row['total']}\n";
            echo "  Fecha Cancelación: " . ($row['feccan'] ?? 'NULL') . "\n";
        } else {
            echo "Cuenta: {$reg['cuenta']}, Folio: {$reg['folio']} - NO ENCONTRADO\n";
        }
        echo "\n";
    }

    // Preguntar confirmación
    echo "\n¿Desea restaurar la vigencia a 'V' para estos registros? (s/n): ";
    $handle = fopen("php://stdin", "r");
    $line = fgets($handle);

    if (trim($line) != 's') {
        echo "Operación cancelada.\n";
        exit(0);
    }

    echo "\nRestaurando vigencia...\n";
    echo str_repeat("-", 80) . "\n";

    // Restaurar vigencia
    $sql_update = "UPDATE catastro_gdl.reqdiftransmision
                   SET vigencia = 'V', feccan = NULL
                   WHERE cvecuenta = :cuenta AND folioreq = :folio";

    $stmt_update = $pdo->prepare($sql_update);

    foreach ($registros as $reg) {
        $stmt_update->execute([
            'cuenta' => $reg['cuenta'],
            'folio' => $reg['folio']
        ]);

        $affected = $stmt_update->rowCount();
        echo "Cuenta: {$reg['cuenta']}, Folio: {$reg['folio']} - ";

        if ($affected > 0) {
            echo "✓ RESTAURADO\n";
        } else {
            echo "✗ No se actualizó (posiblemente ya está en V)\n";
        }
    }

    // Verificar estado final
    echo "\nEstado FINAL de los registros:\n";
    echo str_repeat("-", 80) . "\n";

    foreach ($registros as $reg) {
        $sql = "SELECT cvecuenta, folioreq, vigencia, total, feccan
                FROM catastro_gdl.reqdiftransmision
                WHERE cvecuenta = :cuenta AND folioreq = :folio";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            'cuenta' => $reg['cuenta'],
            'folio' => $reg['folio']
        ]);

        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row) {
            echo "Cuenta: {$row['cvecuenta']}, Folio: {$row['folioreq']}\n";
            echo "  Vigencia: {$row['vigencia']}\n";
            echo "  Total: {$row['total']}\n";
            echo "  Fecha Cancelación: " . ($row['feccan'] ?? 'NULL') . "\n";
        }
        echo "\n";
    }

    echo "✓ Proceso completado exitosamente.\n";
    echo "\nAhora puedes probar nuevamente el formulario pagosmultfrm con estos datos:\n";
    echo json_encode($registros, JSON_PRETTY_PRINT) . "\n";

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
