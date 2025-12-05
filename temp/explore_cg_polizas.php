<?php
/**
 * Script para explorar la tabla cg_polizas y su relación con movimientos
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== EXPLORANDO TABLA CG_POLIZAS ===\n\n";

    // Explorar cg_polizas
    echo "1. Estructura de db_ingresos.cg_polizas:\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'db_ingresos' AND table_name = 'cg_polizas'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($columns) {
        echo "   Columnas:\n";
        foreach ($columns as $col) {
            echo "     - {$col['column_name']} ({$col['data_type']})\n";
        }

        // Contar registros
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM db_ingresos.cg_polizas");
        $count = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "\n   Total de registros: {$count['total']}\n";

        // Datos de ejemplo
        $stmt = $pdo->query("SELECT * FROM db_ingresos.cg_polizas LIMIT 5");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($rows) {
            echo "\n   Datos de ejemplo:\n";
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

        // Buscar registros recientes
        echo "\n2. Pólizas recientes (últimos 30 días):\n";
        $stmt = $pdo->query("
            SELECT id_poliza, fecha, concepto
            FROM db_ingresos.cg_polizas
            WHERE fecha >= CURRENT_DATE - INTERVAL '365 days'
            ORDER BY fecha DESC
            LIMIT 10
        ");
        $recent = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($recent) {
            foreach ($recent as $row) {
                echo "   ID: {$row['id_poliza']}, Fecha: {$row['fecha']}, Concepto: {$row['concepto']}\n";
            }
        } else {
            echo "   No hay pólizas recientes\n";
        }

        // Contar pólizas por año
        echo "\n3. Pólizas por año:\n";
        $stmt = $pdo->query("
            SELECT EXTRACT(YEAR FROM fecha) as anio, COUNT(*) as total
            FROM db_ingresos.cg_polizas
            WHERE fecha IS NOT NULL
            GROUP BY EXTRACT(YEAR FROM fecha)
            ORDER BY anio DESC
            LIMIT 10
        ");
        $years = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($years as $row) {
            echo "   Año {$row['anio']}: {$row['total']} pólizas\n";
        }
    }

    // Probar un JOIN de ejemplo
    echo "\n4. Probando JOIN entre polizas y movimientos (ejemplo con fecha reciente):\n";

    $stmt = $pdo->query("
        SELECT
            p.id_poliza,
            p.fecha,
            p.concepto,
            m.cta_aplicacion,
            COUNT(*) as num_movimientos,
            SUM(m.cargo) as total_cargo,
            SUM(m.abono) as total_abono
        FROM db_ingresos.cg_polizas p
        INNER JOIN db_ingresos.cg_poliza_movimientos m ON p.id_poliza = m.id_poliza
        WHERE p.fecha >= '2023-01-01' AND p.fecha <= '2024-12-31'
        GROUP BY p.id_poliza, p.fecha, p.concepto, m.cta_aplicacion
        ORDER BY p.fecha DESC
        LIMIT 10
    ");
    $joined = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($joined) {
        foreach ($joined as $row) {
            echo "   Póliza {$row['id_poliza']} - Fecha: {$row['fecha']} - CuentaApl: {$row['cta_aplicacion']}\n";
            echo "     Movimientos: {$row['num_movimientos']}, Cargo: {$row['total_cargo']}, Abono: {$row['total_abono']}\n";
        }
    } else {
        echo "   No hay datos para el rango de fechas probado\n";
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
