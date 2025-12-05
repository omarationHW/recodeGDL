<?php
/**
 * Script para desplegar el stored procedure recaudadora_prepagofrm
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DESPLEGANDO SP: recaudadora_prepagofrm ===\n\n";

    $sqlFile = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_prepagofrm.sql';

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
        WHERE proname = 'recaudadora_prepagofrm'
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

    // Buscar cuentas de ejemplo
    echo "3. Buscando cuentas de ejemplo con pagos...\n";
    $stmt = $pdo->query("
        SELECT cvecuenta, COUNT(*) as total_pagos, MAX(fecha) as ultimo_pago
        FROM catastro_gdl.pagos
        WHERE fecha >= '2024-01-01'
        GROUP BY cvecuenta
        HAVING COUNT(*) >= 1
        ORDER BY MAX(fecha) DESC
        LIMIT 3
    ");
    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Cuentas encontradas con pagos en 2024:\n";
    foreach ($cuentas as $i => $cuenta) {
        echo "   " . ($i + 1) . ". Cuenta: {$cuenta['cvecuenta']}, Pagos: {$cuenta['total_pagos']}, Último pago: {$cuenta['ultimo_pago']}\n";
    }

    // Probar el SP con cada cuenta
    echo "\n4. Probando el SP con las cuentas encontradas:\n\n";

    foreach ($cuentas as $i => $cuenta) {
        $cvecuenta = $cuenta['cvecuenta'];

        echo "   Ejemplo " . ($i + 1) . " - Cuenta: $cvecuenta\n";
        $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_prepagofrm(:busqueda)");
        $stmt->execute(['busqueda' => $cvecuenta]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($results) {
            echo "   ✓ Consulta exitosa - " . count($results) . " pago(s) encontrado(s)\n";

            // Mostrar primer resultado
            $row = $results[0];
            echo "     CVE Pago: {$row['cvepago']}\n";
            echo "     Cuenta: {$row['cvecuenta']}\n";
            echo "     Folio: {$row['folio']}\n";
            echo "     Fecha: {$row['fecha_pago']}\n";
            echo "     Importe: $" . number_format($row['importe'], 2) . "\n";
            echo "     Cajero: {$row['cajero']}\n";
            echo "     Cancelado: {$row['cancelado']}\n";
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
