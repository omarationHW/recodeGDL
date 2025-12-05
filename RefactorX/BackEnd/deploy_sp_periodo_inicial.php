<?php
/**
 * Script para desplegar el stored procedure recaudadora_periodo_inicial
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DESPLEGANDO SP: recaudadora_periodo_inicial ===\n\n";

    $sqlFile = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_periodo_inicial.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    echo "1. Ejecutando SQL...\n";
    $pdo->exec($sql);
    echo "   ✓ SQL ejecutado correctamente\n\n";

    echo "2. Verificando creación del SP...\n";
    $stmt = $pdo->query("
        SELECT proname, pronargs, pg_get_function_arguments(oid) as args
        FROM pg_proc
        WHERE proname = 'recaudadora_periodo_inicial'
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

    echo "3. Probando el SP con ejercicio 2024...\n";
    $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_periodo_inicial(:ejercicio)");
    $stmt->execute(['ejercicio' => 2024]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($results) {
        echo "   ✓ Consulta exitosa - " . count($results) . " registro(s) encontrado(s)\n";
        echo "\n   Registro:\n";
        foreach ($results[0] as $key => $value) {
            $val = $value ?? 'NULL';
            if (strlen($val) > 50) $val = substr($val, 0, 50) . '...';
            echo "     $key: $val\n";
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
