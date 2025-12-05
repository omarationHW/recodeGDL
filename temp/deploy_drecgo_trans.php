<?php
// Desplegar SP recaudadora_drecgo_trans
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;dbname=padron_licencias",
        "refact",
        "FF)-BQk2",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "=== DESPLEGANDO SP recaudadora_drecgo_trans ===\n\n";

    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_drecgo_trans.sql';
    $sql = file_get_contents($sqlFile);

    if ($sql === false) {
        throw new Exception("No se pudo leer el archivo SQL");
    }

    echo "Ejecutando SQL...\n";
    $pdo->exec($sql);
    echo "✅ SP desplegado exitosamente\n\n";

    // Verificar
    echo "=== VERIFICANDO SP ===\n\n";
    $sqlCheck = "
        SELECT
            n.nspname as schema_name,
            p.proname as sp_name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'multas_reglamentos'
        AND p.proname = 'recaudadora_drecgo_trans'
    ";

    $stmt = $pdo->query($sqlCheck);
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "✅ SP encontrado:\n";
        echo "Schema: {$sp['schema_name']}\n";
        echo "Nombre: {$sp['sp_name']}\n";
        echo "Argumentos: {$sp['arguments']}\n\n";
    }

    // Probar
    echo "=== PROBANDO SP ===\n\n";
    $sqlTest = "SELECT * FROM multas_reglamentos.recaudadora_drecgo_trans() LIMIT 3";
    $stmt = $pdo->query($sqlTest);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Registros encontrados: " . count($rows) . "\n\n";
    foreach ($rows as $i => $row) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  Cuenta: {$row['cve_contribuyente']}\n";
        echo "  Nombre: {$row['nombre_completo']}\n";
        echo "  RFC: {$row['rfc']}\n";
        echo "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
