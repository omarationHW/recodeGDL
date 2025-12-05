<?php
/**
 * Script para explorar tablas de movimientos de pólizas
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== EXPLORANDO TABLAS DE MOVIMIENTOS DE PÓLIZAS ===\n\n";

    // Explorar cg_poliza_movimientos
    echo "1. Explorando db_ingresos.cg_poliza_movimientos:\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'db_ingresos' AND table_name = 'cg_poliza_movimientos'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($columns) {
        echo "   Columnas:\n";
        foreach ($columns as $col) {
            echo "     - {$col['column_name']} ({$col['data_type']})\n";
        }

        // Contar registros
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM db_ingresos.cg_poliza_movimientos");
        $count = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "\n   Total de registros: {$count['total']}\n";

        // Datos de ejemplo
        $stmt = $pdo->query("SELECT * FROM db_ingresos.cg_poliza_movimientos LIMIT 5");
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
    }

    // Buscar otras tablas de movimientos
    echo "\n2. Buscando otras tablas con 'movimiento' o 'partida':\n";
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE (tablename ILIKE '%movimient%' OR tablename ILIKE '%partida%')
        AND (tablename ILIKE '%poliza%' OR tablename ILIKE '%pol%')
        ORDER BY schemaname, tablename
        LIMIT 10
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "   - {$table['schemaname']}.{$table['tablename']}\n";
    }

    // Buscar tablas con "recaudadora" en el nombre
    echo "\n3. Buscando tablas con 'recaudadora':\n";
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename ILIKE '%recaudadora%'
        OR tablename ILIKE '%recauda%'
        ORDER BY schemaname, tablename
        LIMIT 20
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "   - {$table['schemaname']}.{$table['tablename']}\n";
    }

    // Buscar tablas con conceptos de cuentas
    echo "\n4. Buscando tablas con 'pago' y 'cuenta':\n";
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE (tablename ILIKE '%pago%' AND tablename ILIKE '%cuenta%')
        OR tablename ILIKE '%ctaapl%'
        OR tablename ILIKE '%aplicacion%'
        ORDER BY schemaname, tablename
        LIMIT 15
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "   - {$table['schemaname']}.{$table['tablename']}\n";
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
