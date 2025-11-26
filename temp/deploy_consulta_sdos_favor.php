<?php
/**
 * Desplegar recaudadora_consulta_sdos_favor en la base de datos
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

$sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_consulta_sdos_favor.sql';

try {
    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "📄 Desplegando SP recaudadora_consulta_sdos_favor...\n\n";

    $pdo->exec($sql);

    echo "✅ SP desplegado correctamente\n\n";

    // Verificar que el SP fue creado
    $stmt = $pdo->prepare("
        SELECT
            p.proname,
            pg_catalog.pg_get_function_arguments(p.oid) as args,
            pg_catalog.obj_description(p.oid, 'pg_proc') as description
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_consulta_sdos_favor'
        AND n.nspname = 'public'
    ");

    $stmt->execute();
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "📊 Información del SP:\n";
        echo "  - Nombre: {$sp['proname']}\n";
        echo "  - Argumentos: {$sp['args']}\n";
        echo "  - Descripción: {$sp['description']}\n\n";
    } else {
        throw new Exception("El SP no fue encontrado después del despliegue");
    }

    // Probar el SP con una cuenta de ejemplo
    echo "🧪 Probando SP con cuenta de ejemplo...\n\n";

    // Primero, buscar una cuenta que tenga saldos a favor
    echo "🔍 Buscando cuentas con saldos a favor en la BD...\n\n";
    $stmt = $pdo->query("
        SELECT DISTINCT s.cvecuenta, s.folio, s.axofol, s.id_solic
        FROM catastro_gdl.solic_sdosfavor s
        WHERE s.cvecuenta IS NOT NULL
        ORDER BY s.id_solic DESC
        LIMIT 5
    ");
    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($cuentas) > 0) {
        echo "📋 Cuentas encontradas:\n";
        foreach ($cuentas as $c) {
            echo sprintf("  - Cuenta: %d | Folio: %d | Ejercicio: %d\n",
                $c['cvecuenta'],
                $c['folio'] ?? 0,
                $c['axofol'] ?? 0
            );
        }
        echo "\n";

        // Probar con la primera cuenta
        $testCuenta = $cuentas[0];
        echo "🧪 Probando SP con cuenta: {$testCuenta['cvecuenta']}\n\n";

        $stmt = $pdo->prepare("SELECT * FROM recaudadora_consulta_sdos_favor(:cuenta, NULL, NULL)");
        $stmt->execute(['cuenta' => (string)$testCuenta['cvecuenta']]);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($result) > 0) {
            echo "✅ SP funcional - Retornó " . count($result) . " saldo(s) a favor\n\n";
            echo "📋 Primer resultado:\n";
            foreach ($result[0] as $key => $value) {
                if ($key === 'aplicable') {
                    $value = $value === 't' ? 'true' : 'false';
                }
                echo "  $key: " . ($value ?? 'NULL') . "\n";
            }
        } else {
            echo "⚠️ SP funcional pero no retornó saldos para la cuenta {$testCuenta['cvecuenta']}\n";
        }
    } else {
        echo "⚠️ No se encontraron cuentas en solic_sdosfavor\n";
    }

    echo "\n✅ ¡Despliegue completado exitosamente!\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
