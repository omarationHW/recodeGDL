<?php
// Verificar que el SP existe en la base de datos
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;dbname=padron_licencias",
        "refact",
        "FF)-BQk2",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "=== VERIFICANDO SP EN BASE DE DATOS ===\n\n";

    // Buscar el SP en todos los schemas
    $sql = "
        SELECT
            n.nspname as schema_name,
            p.proname as sp_name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE LOWER(p.proname) = LOWER('recaudadora_drecgootrasobligaciones')
        ORDER BY n.nspname
    ";

    $stmt = $pdo->query($sql);
    $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($sps) > 0) {
        echo "✅ SP encontrado en los siguientes schemas:\n\n";
        foreach ($sps as $sp) {
            echo "Schema: {$sp['schema_name']}\n";
            echo "Nombre: {$sp['sp_name']}\n";
            echo "Argumentos: {$sp['arguments']}\n";
            echo "---\n\n";
        }
    } else {
        echo "❌ SP NO ENCONTRADO en ningún schema\n\n";
    }

    // Probar el SP
    if (count($sps) > 0) {
        echo "=== PROBANDO SP ===\n\n";
        $schema = $sps[0]['schema_name'];
        $sqlTest = "SELECT * FROM {$schema}.recaudadora_drecgootrasobligaciones('1792830') LIMIT 1";

        try {
            $stmt = $pdo->query($sqlTest);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($result) {
                echo "✅ SP funciona correctamente\n";
                echo "Datos retornados:\n";
                foreach ($result as $key => $value) {
                    echo "  $key: $value\n";
                }
            } else {
                echo "⚠️ SP ejecutado pero no retornó datos\n";
            }
        } catch (Exception $e) {
            echo "❌ Error al ejecutar SP: " . $e->getMessage() . "\n";
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
