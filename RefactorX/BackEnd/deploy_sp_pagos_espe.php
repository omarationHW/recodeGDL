<?php
/**
 * Script para desplegar el stored procedure recaudadora_pagos_espe
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DESPLEGANDO SP: recaudadora_pagos_espe ===\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_pagos_espe.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    echo "1. Ejecutando SQL...\n";
    $pdo->exec($sql);
    echo "   ✓ SQL ejecutado correctamente\n\n";

    // Verificar que el SP fue creado
    echo "2. Verificando creación del SP...\n";
    $stmt = $pdo->query("
        SELECT proname, pronargs, pg_get_function_arguments(oid) as args
        FROM pg_proc
        WHERE proname = 'recaudadora_pagos_espe'
        AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'db_ingresos')
    ");
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "   ✓ SP creado correctamente:\n";
        echo "     Nombre: {$sp['proname']}\n";
        echo "     Argumentos: {$sp['args']}\n\n";
    } else {
        throw new Exception("El SP no fue creado");
    }

    // Probar el SP con una cuenta de ejemplo
    echo "3. Probando el SP con cuenta 281048...\n";
    $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_pagos_espe(:cuenta, :ejercicio)");
    $stmt->execute([
        'cuenta' => '281048',
        'ejercicio' => null
    ]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($results) {
        echo "   ✓ Consulta exitosa - " . count($results) . " registros encontrados\n";
        echo "\n   Primer registro:\n";
        foreach ($results[0] as $key => $value) {
            echo "     $key: $value\n";
        }
    } else {
        echo "   ⚠ Consulta ejecutada pero sin resultados\n";
    }

    echo "\n=== DESPLIEGUE COMPLETADO EXITOSAMENTE ===\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR PDO: " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
