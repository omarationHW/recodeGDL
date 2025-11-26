<?php
/**
 * Desplegar recaudadora_sdosfavor_ctrlexp en la base de datos
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

$sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_sdosfavor_ctrlexp.sql';

try {
    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "📄 Desplegando SP recaudadora_sdosfavor_ctrlexp...\n\n";

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
        WHERE p.proname = 'recaudadora_sdosfavor_ctrlexp'
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

    $stmt = $pdo->prepare("SELECT * FROM recaudadora_sdosfavor_ctrlexp(:cuenta)");
    $stmt->execute(['cuenta' => '295685']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($result) > 0) {
        echo "✅ SP funcional - Retornó " . count($result) . " expediente(s)\n\n";
        echo "📋 Primer expediente:\n";
        foreach ($result[0] as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
    } else {
        echo "⚠️ SP funcional pero no retornó expedientes para la cuenta 295685\n";
    }

    echo "\n✅ ¡Despliegue completado exitosamente!\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
