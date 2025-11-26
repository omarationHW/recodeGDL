<?php
/**
 * Verificar SP recaudadora_ligapago
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

    echo "🔍 Verificando SP recaudadora_ligapago...\n\n";

    // Verificar si el SP existe
    $stmt = $pdo->prepare("
        SELECT
            p.proname,
            pg_catalog.pg_get_function_arguments(p.oid) as args,
            pg_catalog.pg_get_function_result(p.oid) as result_type,
            pg_catalog.obj_description(p.oid, 'pg_proc') as description
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_ligapago'
        AND n.nspname = 'public'
    ");

    $stmt->execute();
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "✅ SP encontrado:\n";
        echo "  - Nombre: {$sp['proname']}\n";
        echo "  - Argumentos: {$sp['args']}\n";
        echo "  - Tipo retorno: {$sp['result_type']}\n";
        echo "  - Descripción: " . ($sp['description'] ?? 'N/A') . "\n\n";

        // Probar el SP sin parámetros
        echo "🧪 Probando SP sin parámetros...\n\n";

        try {
            $stmt = $pdo->query("SELECT * FROM recaudadora_ligapago()");
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "Resultado:\n";
            echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";
        } catch (Exception $e) {
            echo "❌ Error al ejecutar SP: " . $e->getMessage() . "\n\n";
        }

        // Probar con una cuenta
        echo "🧪 Probando SP con cuenta 358307...\n\n";

        try {
            $stmt = $pdo->prepare("SELECT * FROM recaudadora_ligapago(:cuenta)");
            $stmt->execute(['cuenta' => '358307']);
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "Resultado:\n";
            echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";
        } catch (Exception $e) {
            echo "ℹ️  SP no acepta parámetros o error: " . $e->getMessage() . "\n\n";
        }

    } else {
        echo "❌ SP no encontrado en la base de datos\n";
        echo "Necesita ser desplegado desde: RefactorX/Base/multas_reglamentos/database/generated/recaudadora_ligapago.sql\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
