<?php
/**
 * Script para verificar la estructura de la tabla norequeribles
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Buscando tabla norequeribles ===\n\n";

    // Buscar la tabla en todos los esquemas
    $sql = "
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE tablename = 'norequeribles'
        ORDER BY schemaname;
    ";

    $stmt = $pdo->query($sql);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($results)) {
        echo "❌ No se encontró la tabla norequeribles en ningún esquema\n";
        exit(1);
    }

    foreach ($results as $row) {
        echo "✅ Encontrada: {$row['schemaname']}.{$row['tablename']}\n";

        // Obtener estructura de la tabla
        $sql2 = "
            SELECT
                column_name,
                data_type,
                character_maximum_length,
                is_nullable
            FROM information_schema.columns
            WHERE table_schema = :schema
              AND table_name = 'norequeribles'
            ORDER BY ordinal_position;
        ";

        $stmt2 = $pdo->prepare($sql2);
        $stmt2->execute(['schema' => $row['schemaname']]);
        $columns = $stmt2->fetchAll(PDO::FETCH_ASSOC);

        echo "\nEstructura de {$row['schemaname']}.norequeribles:\n";
        echo str_repeat("-", 80) . "\n";

        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
            echo "{$col['column_name']}: {$col['data_type']}{$length} {$nullable}\n";
        }

        // Obtener conteo de registros
        try {
            $countSql = "SELECT COUNT(*) as count FROM {$row['schemaname']}.norequeribles";
            $countStmt = $pdo->query($countSql);
            $count = $countStmt->fetch(PDO::FETCH_ASSOC)['count'];
            echo "\nTotal de registros: $count\n";

            // Obtener algunos ejemplos
            if ($count > 0) {
                echo "\nEjemplos de datos (primeros 2 registros):\n";
                echo str_repeat("-", 80) . "\n";

                $exampleSql = "SELECT * FROM {$row['schemaname']}.norequeribles LIMIT 2";
                $exampleStmt = $pdo->query($exampleSql);
                $examples = $exampleStmt->fetchAll(PDO::FETCH_ASSOC);

                foreach ($examples as $idx => $example) {
                    echo "\nRegistro " . ($idx + 1) . ":\n";
                    foreach ($example as $key => $value) {
                        echo "  $key: $value\n";
                    }
                }
            }
        } catch (Exception $e) {
            echo "\nError al consultar datos: {$e->getMessage()}\n";
        }

        echo "\n" . str_repeat("=", 80) . "\n\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
