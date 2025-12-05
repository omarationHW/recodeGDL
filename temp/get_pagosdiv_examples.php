<?php
/**
 * Script para buscar ejemplos de pagos diversos
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO EJEMPLOS DE PAGOS DIVERSOS ===\n\n";

    // 1. Buscar en tabla pagos con cveconcepto = 4
    echo "1. Buscando en tabla 'pagos' con cveconcepto = 4...\n";
    $stmt = $pdo->query("
        SELECT fecha, recaud, caja, folio, cvepago, importe, cveconcepto
        FROM comun.pagos
        WHERE cveconcepto = 4
        LIMIT 5
    ");
    $pagos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($pagos) {
        echo "   Encontrados " . count($pagos) . " pagos diversos:\n";
        foreach ($pagos as $pago) {
            echo "   - Folio: {$pago['folio']}, Fecha: {$pago['fecha']}, Importe: {$pago['importe']}\n";
        }
    } else {
        echo "   No se encontraron pagos con cveconcepto = 4\n";
    }

    echo "\n";

    // 2. Buscar en tabla pago_diversos (catastro_gdl)
    echo "2. Buscando en tabla 'catastro_gdl.pago_diversos'...\n";
    $stmt = $pdo->query("
        SELECT cvepago, contribuyente, clave_cuenta
        FROM catastro_gdl.pago_diversos
        WHERE clave_cuenta IS NOT NULL
        LIMIT 5
    ");
    $pagos_div = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($pagos_div) {
        echo "   Encontrados " . count($pagos_div) . " registros:\n";
        foreach ($pagos_div as $pd) {
            echo "   - Cuenta: {$pd['clave_cuenta']}, Contribuyente: {$pd['contribuyente']}\n";
        }
    } else {
        echo "   No se encontraron registros en pago_diversos\n";
    }

    echo "\n";

    // 3. Buscar cuentas con más pagos
    echo "3. Buscando cuentas con más pagos diversos...\n";
    $stmt = $pdo->query("
        SELECT pd.clave_cuenta, COUNT(*) as total_pagos,
               MAX(p.fecha) as ultima_fecha,
               SUM(p.importe) as total_importe
        FROM catastro_gdl.pago_diversos pd
        JOIN comun.pagos p ON pd.cvepago = p.cvepago
        WHERE pd.clave_cuenta IS NOT NULL
        AND p.cveconcepto = 4
        GROUP BY pd.clave_cuenta
        ORDER BY total_pagos DESC
        LIMIT 3
    ");
    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($cuentas) {
        echo "   Encontradas " . count($cuentas) . " cuentas con pagos:\n";
        foreach ($cuentas as $cuenta) {
            echo "   - Cuenta: {$cuenta['clave_cuenta']}\n";
            echo "     Total pagos: {$cuenta['total_pagos']}\n";
            echo "     Última fecha: {$cuenta['ultima_fecha']}\n";
            echo "     Total importe: \${$cuenta['total_importe']}\n";
            echo "\n";
        }
    } else {
        echo "   No se encontraron cuentas con pagos\n";
    }

    echo "\n=== EJEMPLOS PARA PROBAR ===\n\n";

    if ($cuentas) {
        echo "Puedes probar con estas cuentas:\n";
        foreach ($cuentas as $i => $cuenta) {
            echo ($i + 1) . ". Cuenta: {$cuenta['clave_cuenta']}\n";
        }
    } else {
        echo "No se encontraron ejemplos disponibles.\n";
        echo "Verifica que existan datos en las tablas:\n";
        echo "- comun.pagos (con cveconcepto = 4)\n";
        echo "- comun.pago_diversos (con clave_cuenta)\n";
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "\nIntentando buscar las tablas en otros schemas...\n";

    try {
        // Buscar tablas en diferentes schemas
        $stmt = $pdo->query("
            SELECT schemaname, tablename
            FROM pg_tables
            WHERE tablename IN ('pagos', 'pago_diversos', 'pagosdiv')
            ORDER BY schemaname, tablename
        ");
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($tables) {
            echo "Tablas encontradas:\n";
            foreach ($tables as $table) {
                echo "- {$table['schemaname']}.{$table['tablename']}\n";
            }
        }
    } catch (Exception $e2) {
        echo "Error al buscar tablas: " . $e2->getMessage() . "\n";
    }
}
