<?php
/**
 * Crear folios de prueba en catastro_gdl.reqdiftransmision (versión corregida)
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conectado a la base de datos: $dbname\n\n";

    // Obtener el máximo cvereq actual
    $maxCvereq = $pdo->query("SELECT COALESCE(MAX(cvereq), 0) as max FROM catastro_gdl.reqdiftransmision")->fetchColumn();
    echo "🔍 Máximo cvereq actual: $maxCvereq\n\n";

    $foliosPrueba = [
        ['cuenta' => '123456789', 'folio' => 1001, 'anio' => 2023],
        ['cuenta' => '987654321', 'folio' => 1002, 'anio' => 2023],
        ['cuenta' => '111111111', 'folio' => 1003, 'anio' => 2024],
        ['cuenta' => '222222222', 'folio' => 1004, 'anio' => 2024],
        ['cuenta' => '333333333', 'folio' => 1005, 'anio' => 2025],
    ];

    echo "📝 Insertando folios de prueba...\n\n";

    $insertados = 0;
    foreach ($foliosPrueba as $idx => $folio) {
        try {
            $cvereq = $maxCvereq + $idx + 1;

            // Verificar si ya existe
            $stmt = $pdo->prepare("
                SELECT COUNT(*) FROM catastro_gdl.reqdiftransmision
                WHERE cvecuenta::TEXT = ? AND folioreq = ? AND axoreq = ?
            ");
            $stmt->execute([$folio['cuenta'], $folio['folio'], $folio['anio']]);

            if ($stmt->fetchColumn() > 0) {
                echo "  ⏭️ Folio {$folio['folio']} ya existe, saltando...\n";
                continue;
            }

            // Insertar con nombres de columnas correctos
            $sql = "
                INSERT INTO catastro_gdl.reqdiftransmision (
                    cvereq, cvecuenta, folioreq, axoreq,
                    vigencia, fecemi, total
                ) VALUES (
                    ?, ?::INTEGER, ?, ?,
                    'V', CURRENT_DATE, 1400.00
                )
            ";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                $cvereq,
                $folio['cuenta'],
                $folio['folio'],
                $folio['anio']
            ]);

            echo "  ✅ Folio {$folio['folio']} insertado (Cuenta: {$folio['cuenta']}, Año: {$folio['anio']}, cvereq: $cvereq)\n";
            $insertados++;

        } catch (Exception $e) {
            echo "  ❌ Error insertando folio {$folio['folio']}: " . $e->getMessage() . "\n";
        }
    }

    echo "\n✅ ¡Proceso completado!\n";
    echo "\n📊 Resumen:\n";
    echo "  - Folios a insertar: " . count($foliosPrueba) . "\n";
    echo "  - Folios insertados: $insertados\n";

    // Verificar total después de inserción
    $countFinal = $pdo->query("SELECT COUNT(*) FROM catastro_gdl.reqdiftransmision")->fetchColumn();
    echo "  - Total de registros en tabla: $countFinal\n\n";

    // Mostrar los folios insertados
    if ($insertados > 0) {
        echo "🔍 Verificando folios insertados:\n\n";
        foreach ($foliosPrueba as $folio) {
            $stmt = $pdo->prepare("
                SELECT cvereq, cvecuenta, folioreq, axoreq, vigencia, total, fecemi
                FROM catastro_gdl.reqdiftransmision
                WHERE cvecuenta::TEXT = ? AND folioreq = ? AND axoreq = ?
            ");
            $stmt->execute([$folio['cuenta'], $folio['folio'], $folio['anio']]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($row) {
                echo sprintf(
                    "  ✅ cvereq: %d | Cuenta: %s | Folio: %d | Año: %d | Total: $%s\n",
                    $row['cvereq'],
                    $row['cvecuenta'],
                    $row['folioreq'],
                    $row['axoreq'],
                    number_format($row['total'], 2)
                );
            }
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
