<?php
/**
 * Script para verificar tablas relacionadas con saldos a favor
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conectado a la base de datos: $dbname\n\n";

    // Buscar tablas relacionadas con saldos
    echo "🔍 BUSCANDO TABLAS RELACIONADAS CON SALDOS:\n";
    echo "============================================\n";

    $tables = $pdo->query("
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_type = 'BASE TABLE'
          AND (
            table_name LIKE '%sdo%' OR
            table_name LIKE '%saldo%' OR
            table_name LIKE '%favor%' OR
            table_name LIKE '%req%'
          )
        ORDER BY table_name
    ")->fetchAll(PDO::FETCH_COLUMN);

    foreach ($tables as $table) {
        echo "  ✅ $table\n";

        // Ver estructura de la tabla
        $columns = $pdo->query("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_name = '$table'
            ORDER BY ordinal_position
        ")->fetchAll(PDO::FETCH_ASSOC);

        echo "     Columnas: ";
        $col_names = array_column($columns, 'column_name');
        echo implode(', ', $col_names) . "\n";

        // Ver cantidad de registros
        $count = $pdo->query("SELECT COUNT(*) FROM $table")->fetchColumn();
        echo "     Registros: $count\n\n";
    }

    // Buscar específicamente tabla de saldos a favor
    echo "\n🔍 BUSCANDO ESTRUCTURA DE TABLA reqctasfavor:\n";
    echo "==============================================\n";

    $exists = $pdo->query("
        SELECT EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_name = 'reqctasfavor'
        )
    ")->fetchColumn();

    if ($exists) {
        echo "✅ Tabla reqctasfavor encontrada\n\n";

        // Ver estructura completa
        $columns = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_name = 'reqctasfavor'
            ORDER BY ordinal_position
        ")->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        // Ver algunos registros de ejemplo
        echo "\n📋 REGISTROS DE EJEMPLO:\n";
        echo "========================\n";
        $examples = $pdo->query("
            SELECT * FROM reqctasfavor LIMIT 5
        ")->fetchAll(PDO::FETCH_ASSOC);

        foreach ($examples as $i => $row) {
            echo "\nRegistro " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                if ($value !== null) {
                    echo "  - $key: $value\n";
                }
            }
        }

        // Estadísticas
        echo "\n📊 ESTADÍSTICAS:\n";
        echo "================\n";
        $total = $pdo->query("SELECT COUNT(*) FROM reqctasfavor")->fetchColumn();
        echo "  - Total de registros: $total\n";

    } else {
        echo "❌ Tabla reqctasfavor NO encontrada\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\n🔍 Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
