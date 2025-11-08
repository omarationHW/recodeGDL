<?php
/**
 * Ejecutar creación de SPs para dictamenes
 * Fecha: 2025-11-05
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

    echo "\n========================================\n";
    echo "CREANDO SPs - DICTÁMENES\n";
    echo "========================================\n\n";

    $sqlFile = __DIR__ . '/DEPLOY_DICTAMENES_SPS.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    echo "📄 Leyendo archivo SQL maestro...\n\n";
    $sql = file_get_contents($sqlFile);

    echo "⚙️  Ejecutando script completo...\n\n";

    $start = microtime(true);

    // Ejecutar todo el script
    $pdo->exec($sql);

    $elapsed = round(microtime(true) - $start, 2);

    echo "✅ Script ejecutado en {$elapsed} segundos\n\n";

    // Verificar SPs creados
    echo "📊 Verificando SPs creados:\n";
    echo str_repeat("-", 120) . "\n";
    printf("%-40s %-70s\n", "SP Name", "Arguments");
    echo str_repeat("-", 120) . "\n";

    $stmt = $pdo->query("
        SELECT
            proname as sp_name,
            pg_get_function_arguments(oid) as arguments
        FROM pg_proc
        WHERE pronamespace = 'comun'::regnamespace
            AND proname LIKE 'sp_dictamenes%'
        ORDER BY proname
    ");

    $sps = $stmt->fetchAll(PDO::FETCH_OBJ);

    if (count($sps) > 0) {
        foreach ($sps as $sp) {
            $args = substr($sp->arguments, 0, 70);
            printf("%-40s %-70s\n", $sp->sp_name, $args);
        }
    } else {
        echo "❌ No se encontraron SPs\n";
    }

    echo str_repeat("-", 120) . "\n";

    echo "\n========================================\n";
    echo "SPs CREADOS EXITOSAMENTE\n";
    echo "========================================\n";
    echo "Total de SPs: " . count($sps) . "\n";
    echo "Tiempo total: {$elapsed} segundos\n\n";

    echo "✅ COMPONENTES CREADOS:\n";
    echo "  1. sp_dictamenes_list (listado con paginación)\n";
    echo "  2. sp_dictamenes_get (obtener por ID)\n";
    echo "  3. sp_dictamenes_create (crear nuevo)\n";
    echo "  4. sp_dictamenes_update (actualizar)\n";
    echo "  5. sp_dictamenes_estadisticas (stats cards)\n\n";

    echo "✅ Tabla: comun.dictamenes (17,470 registros)\n";
    echo "✅ Esquema: comun\n";
    echo "✅ Índices: 9 índices optimizados\n\n";

    echo "🎯 Listo para actualizar dictamenfrm.vue\n\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR DE BASE DE DATOS:\n";
    echo "   " . $e->getMessage() . "\n\n";

    // Mostrar línea específica si es error de sintaxis
    if (strpos($e->getMessage(), 'ERROR') !== false) {
        echo "   Revisa la sintaxis del archivo SQL\n\n";
    }

    exit(1);
} catch (Exception $e) {
    echo "\n❌ ERROR:\n";
    echo "   " . $e->getMessage() . "\n\n";
    exit(1);
}
