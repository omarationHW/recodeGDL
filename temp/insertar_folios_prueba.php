<?php
/**
 * Script para insertar folios de prueba en reqdiftransmision
 * Esto permitirá probar el módulo ActualizaFechaEmpresas con el archivo de ejemplo
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conectado a la base de datos: $dbname\n\n";

    // Folios de prueba (ajustados para caber en INTEGER)
    // Nota: cvecuenta en la tabla es INTEGER, máximo 2,147,483,647
    $folios = [
        ['clave_cuenta' => '123456789', 'folio' => 1001, 'anio' => 2023],
        ['clave_cuenta' => '987654321', 'folio' => 1002, 'anio' => 2023],
        ['clave_cuenta' => '111111111', 'folio' => 1003, 'anio' => 2024],
        ['clave_cuenta' => '222222222', 'folio' => 1004, 'anio' => 2024],
        ['clave_cuenta' => '333333333', 'folio' => 1005, 'anio' => 2025],
    ];

    echo "📝 Insertando folios de prueba en reqdiftransmision...\n";
    echo "======================================================\n\n";

    $insertados = 0;
    $ya_existen = 0;

    foreach ($folios as $f) {
        // Verificar si ya existe
        $check = $pdo->prepare("
            SELECT COUNT(*) FROM reqdiftransmision
            WHERE cvecuenta::TEXT = :cuenta
              AND folioreq = :folio
              AND axoreq = :anio
        ");
        $check->execute([
            'cuenta' => $f['clave_cuenta'],
            'folio' => $f['folio'],
            'anio' => $f['anio']
        ]);

        if ($check->fetchColumn() > 0) {
            echo "  ⚠️  Folio {$f['folio']}/{$f['anio']} ya existe\n";
            $ya_existen++;
            continue;
        }

        // Insertar folio de prueba
        $insert = $pdo->prepare("
            INSERT INTO reqdiftransmision (
                cvereq,
                recaud,
                axoreq,
                folioreq,
                cveproceso,
                cvecuenta,
                impuesto,
                recargos,
                multa_imp,
                multa_ext,
                actualizacion,
                gastos,
                multa,
                gastos_req,
                total,
                vigencia,
                fecemi,
                feccap,
                capturista
            ) VALUES (
                nextval('reqdiftransmision_cvereq_seq'),
                1,
                :anio,
                :folio,
                'P',
                :cuenta::INTEGER,
                1000.00,
                100.00,
                50.00,
                50.00,
                20.00,
                30.00,
                100.00,
                50.00,
                1400.00,
                'V',
                CURRENT_DATE,
                CURRENT_DATE,
                'TEST'
            )
        ");

        try {
            $insert->execute([
                'cuenta' => $f['clave_cuenta'],
                'folio' => $f['folio'],
                'anio' => $f['anio']
            ]);

            echo "  ✅ Folio {$f['folio']}/{$f['anio']} - Cuenta {$f['clave_cuenta']} insertado\n";
            $insertados++;

        } catch (Exception $e) {
            echo "  ❌ Error insertando folio {$f['folio']}/{$f['anio']}: " . $e->getMessage() . "\n";
        }
    }

    echo "\n";
    echo "📊 RESUMEN:\n";
    echo "==========\n";
    echo "  - Folios insertados: $insertados\n";
    echo "  - Folios ya existentes: $ya_existen\n";
    echo "  - Total de folios procesados: " . count($folios) . "\n";

    // Verificar registros en la tabla
    echo "\n";
    echo "🔍 Verificando registros insertados:\n";
    echo "====================================\n";

    $verify = $pdo->query("
        SELECT cvereq, cvecuenta, folioreq, axoreq, total, vigencia, fecemi
        FROM reqdiftransmision
        WHERE folioreq >= 1001
        ORDER BY folioreq
    ");

    while ($row = $verify->fetch(PDO::FETCH_ASSOC)) {
        echo "  ✅ ID: {$row['cvereq']} | Cuenta: {$row['cvecuenta']} | Folio: {$row['folioreq']}/{$row['axoreq']} | Total: \${$row['total']} | Vigencia: {$row['vigencia']} | Emisión: {$row['fecemi']}\n";
    }

    echo "\n✅ ¡Proceso completado!\n";
    echo "\n📝 Notas:\n";
    echo "  - Los folios insertados corresponden al archivo temp/ejemplo_folios.txt\n";
    echo "  - Ahora puedes probar el módulo ActualizaFechaEmpresas con el archivo de ejemplo\n";
    echo "  - Los valores de impuestos son ficticios para pruebas\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\n🔍 Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
