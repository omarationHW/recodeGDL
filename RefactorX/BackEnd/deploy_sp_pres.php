<?php
/**
 * Script para desplegar el stored procedure recaudadora_pres
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DESPLEGANDO SP: recaudadora_pres ===\n\n";

    $sqlFile = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_pres.sql';

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
        WHERE proname = 'recaudadora_pres'
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

    // Buscar ejercicios disponibles
    echo "3. Buscando ejercicios disponibles en ta_pres_dev_ing...\n";
    $stmt = $pdo->query("
        SELECT ejercicio, COUNT(*) as total_registros
        FROM comun.ta_pres_dev_ing
        GROUP BY ejercicio
        ORDER BY ejercicio DESC
    ");
    $ejercicios = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Ejercicios encontrados:\n";
    foreach ($ejercicios as $ej) {
        echo "   - Año {$ej['ejercicio']}: {$ej['total_registros']} registros\n";
    }

    // Probar el SP con diferentes ejercicios
    echo "\n4. Probando el SP con los ejercicios encontrados:\n\n";

    foreach (array_slice($ejercicios, 0, 3) as $i => $ej) {
        $ejercicio = $ej['ejercicio'];

        echo "   Ejemplo " . ($i + 1) . " - Ejercicio: $ejercicio\n";
        $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_pres(:filtro)");
        $stmt->execute(['filtro' => (string)$ejercicio]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($results) {
            echo "   ✓ Consulta exitosa - " . count($results) . " registro(s) encontrado(s)\n";

            // Mostrar primer resultado
            $row = $results[0];
            echo "     Ejercicio: {$row['ejercicio']}\n";
            echo "     Título: {$row['titulo']}, Capítulo: {$row['capitulo']}\n";
            echo "     Cuenta Aplicación: {$row['cta_aplicacion']}\n";
            echo "     Fecha Ingreso: {$row['fecha_ingreso']}\n";
            echo "     Presupuesto Anual: $" . number_format($row['presup_anual'], 2) . "\n";
            echo "     Ingreso Total: $" . number_format($row['ingreso_total'], 2) . "\n";
            echo "     Enero: $" . number_format($row['enero'], 2) . "\n";
        } else {
            echo "   ⚠ Sin resultados\n";
        }
        echo "\n";
    }

    echo "=== DESPLIEGUE COMPLETADO EXITOSAMENTE ===\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR PDO: " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
