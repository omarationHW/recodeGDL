<?php
/**
 * Script para explorar la estructura de tablas de pagos
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== EXPLORANDO ESTRUCTURA DE PAGOS ===\n\n";

    // Explorar tabla pagos en catastro_gdl
    echo "1. Explorando catastro_gdl.pagos:\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl' AND table_name = 'pagos'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($columns) {
        echo "   Columnas:\n";
        foreach ($columns as $col) {
            echo "     - {$col['column_name']} ({$col['data_type']})\n";
        }

        // Contar registros
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM catastro_gdl.pagos");
        $count = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "\n   Total de registros: {$count['total']}\n";

        // Obtener datos de ejemplo
        $stmt = $pdo->query("
            SELECT * FROM catastro_gdl.pagos
            ORDER BY cvepago DESC
            LIMIT 5
        ");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($rows) {
            echo "\n   Datos de ejemplo (más recientes):\n";
            foreach ($rows as $i => $row) {
                echo "   Registro " . ($i + 1) . ":\n";
                foreach ($row as $key => $value) {
                    $val = $value ?? 'NULL';
                    if (strlen($val) > 80) $val = substr($val, 0, 80) . '...';
                    echo "     $key: $val\n";
                }
                echo "\n";
            }
        }

        // Buscar pagos con fecha reciente
        echo "\n2. Pagos de los últimos 12 meses:\n";
        $stmt = $pdo->query("
            SELECT cvepago, cvecuenta, fecpago, impopago, tipo
            FROM catastro_gdl.pagos
            WHERE fecpago >= CURRENT_DATE - INTERVAL '12 months'
            ORDER BY fecpago DESC
            LIMIT 10
        ");
        $recent = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($recent) {
            foreach ($recent as $row) {
                echo "   CVE Pago: {$row['cvepago']}, Cuenta: {$row['cvecuenta']}, Fecha: {$row['fecpago']}, Importe: {$row['impopago']}, Tipo: {$row['tipo']}\n";
            }
        } else {
            echo "   No hay pagos recientes en los últimos 12 meses\n";
        }

        // Buscar pagos del 2024
        echo "\n3. Pagos del 2024:\n";
        $stmt = $pdo->query("
            SELECT cvepago, cvecuenta, fecpago, impopago
            FROM catastro_gdl.pagos
            WHERE EXTRACT(YEAR FROM fecpago) = 2024
            ORDER BY fecpago DESC
            LIMIT 10
        ");
        $pagos2024 = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($pagos2024) {
            foreach ($pagos2024 as $row) {
                echo "   CVE Pago: {$row['cvepago']}, Cuenta: {$row['cvecuenta']}, Fecha: {$row['fecpago']}, Importe: {$row['impopago']}\n";
            }
        } else {
            echo "   No hay pagos del 2024\n";
        }

        // Contar pagos por año
        echo "\n4. Distribución de pagos por año:\n";
        $stmt = $pdo->query("
            SELECT EXTRACT(YEAR FROM fecpago) as anio, COUNT(*) as total
            FROM catastro_gdl.pagos
            WHERE fecpago IS NOT NULL
            GROUP BY EXTRACT(YEAR FROM fecpago)
            ORDER BY anio DESC
            LIMIT 10
        ");
        $years = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($years as $row) {
            echo "   Año {$row['anio']}: " . number_format($row['total']) . " pagos\n";
        }
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
