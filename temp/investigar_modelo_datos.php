<?php
/**
 * Script para investigar el modelo de datos de licencias y adeudos
 */

$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== INVESTIGACIÓN MODELO DE DATOS ===\n\n";

    // 1. Buscar tabla de giros
    echo "1. Buscando tabla de GIROS:\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name LIKE '%giro%'
          AND table_schema = 'comun'
        ORDER BY table_name
    ");
    $giros_tables = $stmt->fetchAll();
    foreach ($giros_tables as $t) {
        echo "   - {$t['table_schema']}.{$t['table_name']}\n";
    }

    // 2. Ver estructura de tabla giros
    echo "\n2. Estructura de comun.giros:\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'giros'
        ORDER BY ordinal_position
        LIMIT 15
    ");
    $cols = $stmt->fetchAll();
    foreach ($cols as $col) {
        echo "   {$col['column_name']} ({$col['data_type']})\n";
    }

    // 3. Buscar tablas relacionadas con adeudos/saldos
    echo "\n3. Tablas relacionadas con ADEUDOS/SALDOS:\n";
    $stmt = $pdo->query("
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'comun'
          AND (table_name LIKE '%adeud%' OR table_name LIKE '%saldo%' OR table_name LIKE '%cuenta%')
        ORDER BY table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    foreach ($tables as $t) {
        echo "   - $t\n";
    }

    // 4. Verificar si adeudos tiene una columna que relacione con licencias
    echo "\n4. Columnas de comun.adeudos:\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'adeudos'
        ORDER BY ordinal_position
    ");
    $cols = $stmt->fetchAll();
    foreach ($cols as $col) {
        echo "   {$col['column_name']} ({$col['data_type']})\n";
    }

    // 5. Contar registros para entender los datos
    echo "\n5. Conteo de registros:\n";
    $stmt = $pdo->query("SELECT COUNT(*) FROM comun.licencias");
    $count = $stmt->fetchColumn();
    echo "   Licencias: " . number_format($count) . "\n";

    $stmt = $pdo->query("SELECT COUNT(*) FROM comun.giros");
    $count = $stmt->fetchColumn();
    echo "   Giros: " . number_format($count) . "\n";

    $stmt = $pdo->query("SELECT COUNT(*) FROM comun.adeudos");
    $count = $stmt->fetchColumn();
    echo "   Adeudos: " . number_format($count) . "\n";

    // 6. Sample de datos de giros
    echo "\n6. Sample de giros (primeros 5):\n";
    $stmt = $pdo->query("SELECT * FROM comun.giros LIMIT 5");
    $samples = $stmt->fetchAll();
    foreach ($samples as $idx => $row) {
        echo "   Giro " . ($idx+1) . ":\n";
        foreach ($row as $key => $val) {
            if (!is_numeric($key)) {
                echo "     $key: " . (strlen($val) > 50 ? substr($val, 0, 50).'...' : $val) . "\n";
            }
        }
    }

    // 7. Sample de licencias con id_giro
    echo "\n7. Sample de licencias con id_giro (primeros 3):\n";
    $stmt = $pdo->query("
        SELECT l.licencia, l.id_giro, l.propietario, l.actividad
        FROM comun.licencias l
        WHERE l.id_giro IS NOT NULL
        LIMIT 3
    ");
    $samples = $stmt->fetchAll();
    foreach ($samples as $idx => $row) {
        echo "   Licencia {$row['licencia']}: id_giro={$row['id_giro']}, prop={$row['propietario']}\n";
    }

    // 8. Ver si hay join posible entre licencias y adeudos
    echo "\n8. Explorando relación licencias-adeudos:\n";
    echo "   Buscando columnas comunes...\n";

    $stmt = $pdo->query("
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'licencias'
        ORDER BY column_name
    ");
    $lic_cols = $stmt->fetchAll(PDO::FETCH_COLUMN);

    $stmt = $pdo->query("
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'adeudos'
        ORDER BY column_name
    ");
    $ade_cols = $stmt->fetchAll(PDO::FETCH_COLUMN);

    $common = array_intersect($lic_cols, $ade_cols);
    if (count($common) > 0) {
        echo "   Columnas comunes: " . implode(', ', $common) . "\n";
    } else {
        echo "   No hay columnas comunes directas\n";
    }

} catch (PDOException $e) {
    echo "\nError: " . $e->getMessage() . "\n";
}
