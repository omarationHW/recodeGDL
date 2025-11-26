<?php
/**
 * Script para verificar la estructura de las tablas multas y reqmultas
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $tablas = [
        ['schema' => 'catastro_gdl', 'tabla' => 'multas'],
        ['schema' => 'catastro_gdl', 'tabla' => 'reqmultas'],
        ['schema' => 'catastro_gdl', 'tabla' => 'bloqueo']
    ];

    foreach ($tablas as $t) {
        echo "=== {$t['schema']}.{$t['tabla']} ===\n\n";

        // Verificar si existe
        $sql = "
            SELECT COUNT(*) as count
            FROM pg_tables
            WHERE schemaname = :schema
              AND tablename = :tabla;
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['schema' => $t['schema'], 'tabla' => $t['tabla']]);
        $exists = $stmt->fetch(PDO::FETCH_ASSOC)['count'] > 0;

        if (!$exists) {
            echo "❌ No existe\n\n";
            continue;
        }

        echo "✅ Existe\n\n";

        // Obtener estructura
        $sql2 = "
            SELECT
                column_name,
                data_type,
                character_maximum_length,
                is_nullable
            FROM information_schema.columns
            WHERE table_schema = :schema
              AND table_name = :tabla
            ORDER BY ordinal_position
            LIMIT 20;
        ";

        $stmt2 = $pdo->prepare($sql2);
        $stmt2->execute(['schema' => $t['schema'], 'tabla' => $t['tabla']]);
        $columns = $stmt2->fetchAll(PDO::FETCH_ASSOC);

        echo "Columnas (primeras 20):\n";
        echo str_repeat("-", 80) . "\n";
        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
            echo "{$col['column_name']}: {$col['data_type']}{$length} {$nullable}\n";
        }

        // Obtener conteo
        $countSql = "SELECT COUNT(*) as count FROM {$t['schema']}.{$t['tabla']}";
        $countStmt = $pdo->query($countSql);
        $count = $countStmt->fetch(PDO::FETCH_ASSOC)['count'];
        echo "\nTotal de registros: $count\n";

        // Ejemplo
        if ($count > 0) {
            echo "\nEjemplo (primer registro):\n";
            echo str_repeat("-", 80) . "\n";

            $exampleSql = "SELECT * FROM {$t['schema']}.{$t['tabla']} LIMIT 1";
            $exampleStmt = $pdo->query($exampleSql);
            $example = $exampleStmt->fetch(PDO::FETCH_ASSOC);

            foreach ($example as $key => $value) {
                if ($value !== null) {
                    $value = is_string($value) ? trim($value) : $value;
                    if ($value !== '') {
                        echo "  $key: $value\n";
                    }
                }
            }
        }

        echo "\n" . str_repeat("=", 80) . "\n\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
