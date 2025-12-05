<?php
// Desplegar SP recaudadora_drecgootrasobligaciones
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;dbname=padron_licencias",
        "refact",
        "FF)-BQk2",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "=== DESPLEGANDO SP recaudadora_drecgootrasobligaciones ===\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_drecgootrasobligaciones.sql';
    $sql = file_get_contents($sqlFile);

    if ($sql === false) {
        throw new Exception("No se pudo leer el archivo SQL: $sqlFile");
    }

    // Ejecutar el SQL
    echo "Ejecutando SQL...\n";
    $pdo->exec($sql);

    echo "✅ SP desplegado exitosamente\n\n";

    // Verificar que se creó correctamente
    echo "=== VERIFICANDO SP ===\n\n";

    $sqlCheck = "
        SELECT
            n.nspname as schema_name,
            p.proname as sp_name,
            pg_get_function_arguments(p.oid) as arguments,
            pg_get_function_result(p.oid) as result_type
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'multas_reglamentos'
        AND p.proname = 'recaudadora_drecgootrasobligaciones'
    ";

    $stmt = $pdo->query($sqlCheck);
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "✅ SP encontrado:\n";
        echo "Schema: {$sp['schema_name']}\n";
        echo "Nombre: {$sp['sp_name']}\n";
        echo "Argumentos: {$sp['arguments']}\n";
        echo "Retorna: " . substr($sp['result_type'], 0, 200) . "...\n\n";
    } else {
        echo "❌ No se encontró el SP después del despliegue\n\n";
    }

    // Probar el SP con datos de ejemplo
    echo "=== PROBANDO SP (sin parámetros) ===\n\n";

    $sqlTest = "SELECT * FROM multas_reglamentos.recaudadora_drecgootrasobligaciones() LIMIT 3";
    $stmt = $pdo->query($sqlTest);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Se encontraron " . count($rows) . " registros\n\n";

    foreach ($rows as $i => $row) {
        echo "Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: $value\n";
        }
        echo "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n";
    echo $e->getTraceAsString() . "\n";
}
