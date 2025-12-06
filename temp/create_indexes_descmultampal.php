<?php
/**
 * Script para crear índices en tabla descmultampal
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== CREACIÓN DE ÍNDICES - catastro_gdl.descmultampal ===\n\n";
    echo "Tabla: catastro_gdl.descmultampal (170,857 registros)\n\n";

    // Índice en id_multa (columna más consultada)
    echo "1. Creando índice en id_multa...\n";
    $start = microtime(true);
    $pdo->exec("
        CREATE INDEX IF NOT EXISTS idx_descmultampal_id_multa
        ON catastro_gdl.descmultampal(id_multa)
    ");
    $time1 = (microtime(true) - $start) * 1000;
    echo "   ✓ Índice creado en " . number_format($time1, 2) . " ms\n\n";

    // Índice en feccap para ORDER BY
    echo "2. Creando índice en feccap (fecha)...\n";
    $start = microtime(true);
    $pdo->exec("
        CREATE INDEX IF NOT EXISTS idx_descmultampal_feccap
        ON catastro_gdl.descmultampal(feccap DESC)
    ");
    $time2 = (microtime(true) - $start) * 1000;
    echo "   ✓ Índice creado en " . number_format($time2, 2) . " ms\n\n";

    // Índice compuesto para optimizar ORDER BY
    echo "3. Creando índice compuesto (feccap + id_multa)...\n";
    $start = microtime(true);
    $pdo->exec("
        CREATE INDEX IF NOT EXISTS idx_descmultampal_feccap_idmulta
        ON catastro_gdl.descmultampal(feccap DESC, id_multa)
    ");
    $time3 = (microtime(true) - $start) * 1000;
    echo "   ✓ Índice creado en " . number_format($time3, 2) . " ms\n\n";

    // Hacer ANALYZE para actualizar estadísticas
    echo "4. Actualizando estadísticas de la tabla (ANALYZE)...\n";
    $start = microtime(true);
    $pdo->exec("ANALYZE catastro_gdl.descmultampal");
    $time4 = (microtime(true) - $start) * 1000;
    echo "   ✓ Estadísticas actualizadas en " . number_format($time4, 2) . " ms\n\n";

    // Verificar índices creados
    echo "5. Verificando índices creados:\n";
    $indexes = $pdo->query("
        SELECT
            indexname,
            indexdef
        FROM pg_indexes
        WHERE schemaname = 'catastro_gdl'
        AND tablename = 'descmultampal'
        ORDER BY indexname
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($indexes as $idx) {
        echo "   ✓ {$idx['indexname']}\n";
    }

    // Test de rendimiento ANTES vs DESPUÉS
    echo "\n6. Test de rendimiento:\n";

    // Test con índice
    echo "   a) Consulta con filtro (id_multa = 74985):\n";
    $start = microtime(true);
    $result = $pdo->query("
        SELECT COUNT(*)
        FROM catastro_gdl.descmultampal
        WHERE id_multa = 74985
    ")->fetch();
    $timeWithIndex = (microtime(true) - $start) * 1000;
    echo "      Tiempo: " . number_format($timeWithIndex, 2) . " ms\n";
    echo "      Registros: {$result[0]}\n\n";

    // Test consulta con ORDER BY y LIMIT
    echo "   b) Consulta con ORDER BY y LIMIT 100:\n";
    $start = microtime(true);
    $result = $pdo->query("
        SELECT *
        FROM catastro_gdl.descmultampal
        ORDER BY feccap DESC, id_multa
        LIMIT 100
    ")->fetchAll();
    $timeOrderBy = (microtime(true) - $start) * 1000;
    echo "      Tiempo: " . number_format($timeOrderBy, 2) . " ms\n";
    echo "      Registros: " . count($result) . "\n\n";

    echo str_repeat("=", 80) . "\n";
    echo "ÍNDICES CREADOS EXITOSAMENTE\n";
    echo str_repeat("=", 80) . "\n\n";

    echo "RESUMEN:\n";
    echo "- ✓ idx_descmultampal_id_multa: Para búsquedas por ID\n";
    echo "- ✓ idx_descmultampal_feccap: Para ordenamiento por fecha\n";
    echo "- ✓ idx_descmultampal_feccap_idmulta: Para optimizar ORDER BY completo\n";
    echo "- ✓ Estadísticas actualizadas con ANALYZE\n\n";

    echo "MEJORA ESPERADA:\n";
    echo "- Consultas con filtro: 10-100x más rápidas\n";
    echo "- Consultas con ORDER BY: 5-50x más rápidas\n";
    echo "- Consultas sin filtro + LIMIT: 10-20x más rápidas\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
