<?php
/**
 * Verificar y crear folios de prueba en catastro_gdl.reqdiftransmision
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

    // Verificar cuántos registros tiene la tabla
    echo "🔍 Verificando registros en catastro_gdl.reqdiftransmision...\n\n";
    $count = $pdo->query("SELECT COUNT(*) FROM catastro_gdl.reqdiftransmision")->fetchColumn();
    echo "  Total de registros: $count\n\n";

    // Verificar si existen los folios de prueba
    $foliosPrueba = [
        ['cuenta' => '123456789', 'folio' => 1001, 'anio' => 2023],
        ['cuenta' => '987654321', 'folio' => 1002, 'anio' => 2023],
        ['cuenta' => '111111111', 'folio' => 1003, 'anio' => 2024],
        ['cuenta' => '222222222', 'folio' => 1004, 'anio' => 2024],
        ['cuenta' => '333333333', 'folio' => 1005, 'anio' => 2025],
    ];

    $faltantes = [];

    foreach ($foliosPrueba as $folio) {
        $stmt = $pdo->prepare("
            SELECT COUNT(*) as count
            FROM catastro_gdl.reqdiftransmision
            WHERE cvecuenta::TEXT = ?
              AND folioreq = ?
              AND axoreq = ?
        ");
        $stmt->execute([$folio['cuenta'], $folio['folio'], $folio['anio']]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result['count'] == 0) {
            echo "  ❌ Folio {$folio['folio']} (Cuenta: {$folio['cuenta']}, Año: {$folio['anio']}) NO EXISTE\n";
            $faltantes[] = $folio;
        } else {
            echo "  ✅ Folio {$folio['folio']} (Cuenta: {$folio['cuenta']}, Año: {$folio['anio']}) existe\n";
        }
    }

    if (empty($faltantes)) {
        echo "\n✅ Todos los folios de prueba existen.\n";
        exit(0);
    }

    echo "\n⚠️ Faltan " . count($faltantes) . " folios. Creándolos automáticamente...\n\n";

    // Verificar estructura de la tabla
    echo "🔍 Verificando columnas de catastro_gdl.reqdiftransmision...\n";
    $columns = $pdo->query("
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
          AND table_name = 'reqdiftransmision'
        ORDER BY ordinal_position
    ");

    $columnsList = [];
    while ($col = $columns->fetch(PDO::FETCH_ASSOC)) {
        $columnsList[] = $col['column_name'];
        echo "  - {$col['column_name']} ({$col['data_type']}, nullable: {$col['is_nullable']})\n";
    }
    echo "\n";

    // Crear folios faltantes
    echo "📝 Insertando folios faltantes...\n\n";

    foreach ($faltantes as $folio) {
        try {
            // Insertar con campos mínimos necesarios
            $sql = "
                INSERT INTO catastro_gdl.reqdiftransmision (
                    cvecuenta, folioreq, axoreq,
                    vigencia, fecemiaut, totreq
                ) VALUES (
                    ?::INTEGER, ?, ?,
                    'V', CURRENT_DATE, 1400.00
                )
            ";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                $folio['cuenta'],
                $folio['folio'],
                $folio['anio']
            ]);

            echo "  ✅ Folio {$folio['folio']} insertado (Cuenta: {$folio['cuenta']}, Año: {$folio['anio']})\n";
        } catch (Exception $e) {
            echo "  ❌ Error insertando folio {$folio['folio']}: " . $e->getMessage() . "\n";
        }
    }

    echo "\n✅ ¡Proceso completado!\n";
    echo "\n📊 Resumen:\n";
    echo "  - Folios verificados: " . count($foliosPrueba) . "\n";
    echo "  - Folios existentes antes: " . (count($foliosPrueba) - count($faltantes)) . "\n";
    echo "  - Folios insertados: " . count($faltantes) . "\n";

    // Verificar total después de inserción
    $countFinal = $pdo->query("SELECT COUNT(*) FROM catastro_gdl.reqdiftransmision")->fetchColumn();
    echo "  - Total de registros final: $countFinal\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
