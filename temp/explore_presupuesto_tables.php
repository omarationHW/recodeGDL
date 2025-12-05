<?php
/**
 * Script para explorar tablas de presupuesto
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== EXPLORANDO TABLAS DE PRESUPUESTO ===\n\n";

    // Explorar ta12_presup
    echo "1. Explorando comun.ta12_presup:\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'ta12_presup'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($columns) {
        echo "   Columnas:\n";
        foreach ($columns as $col) {
            echo "     - {$col['column_name']} ({$col['data_type']})\n";
        }

        // Contar registros
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM comun.ta12_presup");
        $count = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "\n   Total de registros: {$count['total']}\n";

        // Obtener datos de ejemplo
        if ($count['total'] > 0) {
            $stmt = $pdo->query("SELECT * FROM comun.ta12_presup LIMIT 5");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

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

    // Explorar ta_pres_dev_ing
    echo "\n2. Explorando comun.ta_pres_dev_ing (Presupuesto Devengado Ingresos):\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'ta_pres_dev_ing'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($columns) {
        echo "   Columnas:\n";
        foreach ($columns as $col) {
            echo "     - {$col['column_name']} ({$col['data_type']})\n";
        }

        // Contar registros
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM comun.ta_pres_dev_ing");
        $count = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "\n   Total de registros: {$count['total']}\n";

        // Obtener datos de ejemplo
        if ($count['total'] > 0) {
            $stmt = $pdo->query("SELECT * FROM comun.ta_pres_dev_ing ORDER BY ejercicio DESC LIMIT 5");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

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

    // Explorar prescripcion
    echo "\n3. Explorando catastro_gdl.prescripcion:\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl' AND table_name = 'prescripcion'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($columns) {
        echo "   Columnas:\n";
        foreach ($columns as $col) {
            echo "     - {$col['column_name']} ({$col['data_type']})\n";
        }

        // Contar registros
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM catastro_gdl.prescripcion");
        $count = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "\n   Total de registros: {$count['total']}\n";

        // Obtener datos de ejemplo
        if ($count['total'] > 0) {
            $stmt = $pdo->query("SELECT * FROM catastro_gdl.prescripcion LIMIT 5");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

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

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
