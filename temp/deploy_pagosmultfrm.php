<?php
/**
 * Desplegar recaudadora_pagosmultfrm en la base de datos
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

$sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_pagosmultfrm.sql';

try {
    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conectado a la base de datos: $dbname\n\n";
    echo "📄 Desplegando SP recaudadora_pagosmultfrm...\n\n";

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
        WHERE p.proname = 'recaudadora_pagosmultfrm'
        AND n.nspname = 'public'
    ");

    $stmt->execute();
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "📊 Información del SP:\n";
        echo "  - Nombre: {$sp['proname']}\n";
        echo "  - Argumentos: {$sp['args']}\n";
        echo "  - Descripción: {$sp['description']}\n\n";

        // Probar con un registro
        echo "🧪 Probando con 2 registros...\n\n";

        $json = json_encode([
            ['cuenta' => 333333333, 'folio' => 1005, 'importe' => 1400],
            ['cuenta' => 222222222, 'folio' => 1004, 'importe' => 1400]
        ]);

        echo "JSON: $json\n\n";

        $stmt = $pdo->prepare("SELECT * FROM recaudadora_pagosmultfrm(:registros)");
        $stmt->execute(['registros' => $json]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "Resultado:\n";
            foreach ($result as $key => $value) {
                if ($key === 'detalles') {
                    echo "  $key: " . json_encode(json_decode($value), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
                } else {
                    echo "  $key: " . ($value ?? 'NULL') . "\n";
                }
            }
        }

    } else {
        throw new Exception("El SP no fue encontrado después del despliegue");
    }

    echo "\n✅ ¡Despliegue completado exitosamente!\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
