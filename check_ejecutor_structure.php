<?php
// Script para revisar la estructura de las tablas de ejecutores

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    $tables = [
        ['public', 'ejecutor'],
        ['publico', 'ejecutor'],
        ['publico', 'ta_15_ejecutores']
    ];

    foreach ($tables as $t) {
        $schema = $t[0];
        $table = $t[1];

        echo "=== ESTRUCTURA DE {$schema}.{$table} ===\n";

        try {
            // Estructura
            $stmt = $pdo->query("
                SELECT column_name, data_type, character_maximum_length, is_nullable
                FROM information_schema.columns
                WHERE table_schema = '$schema'
                AND table_name = '$table'
                ORDER BY ordinal_position
            ");
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "Columnas (" . count($columns) . " total):\n";
            foreach ($columns as $col) {
                $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                $nullable = $col['is_nullable'] == 'YES' ? 'NULL' : 'NOT NULL';
                echo "  - {$col['column_name']}: {$col['data_type']}{$length} {$nullable}\n";
            }

            // Contar registros
            $stmt = $pdo->query("SELECT COUNT(*) as total FROM {$schema}.{$table}");
            $total = $stmt->fetch(PDO::FETCH_ASSOC);
            echo "\nTotal registros: " . number_format($total['total']) . "\n";

            // Muestra de datos
            if ($total['total'] > 0) {
                $stmt = $pdo->query("SELECT * FROM {$schema}.{$table} LIMIT 5");
                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                echo "\nMuestra de datos (primeros 5 registros):\n";
                foreach ($rows as $j => $row) {
                    echo "\n  Registro " . ($j + 1) . ":\n";
                    foreach ($row as $key => $val) {
                        $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 50) : $val);
                        echo "    $key: $val\n";
                    }
                }
            }
        } catch (Exception $e) {
            echo "  Error: " . $e->getMessage() . "\n";
        }

        echo "\n" . str_repeat("=", 70) . "\n\n";
    }

    echo "✅ Revisión completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
