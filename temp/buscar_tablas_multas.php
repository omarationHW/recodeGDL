<?php
/**
 * Script para buscar tablas relacionadas con multas/infracciones
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Buscando tablas relacionadas con multas ===\n\n";

    // Buscar tablas que contengan "infraccion", "multa", "folio"
    $keywords = ['infraccion', 'multa', 'folio', 'bloqueo'];

    foreach ($keywords as $keyword) {
        echo "Buscando tablas con '$keyword':\n";
        echo str_repeat("-", 80) . "\n";

        $sql = "
            SELECT
                schemaname,
                tablename
            FROM pg_tables
            WHERE tablename ILIKE :keyword
            ORDER BY schemaname, tablename;
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['keyword' => "%$keyword%"]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (empty($results)) {
            echo "  No se encontraron tablas\n\n";
        } else {
            foreach ($results as $row) {
                echo "  ✅ {$row['schemaname']}.{$row['tablename']}\n";
            }
            echo "\n";
        }
    }

    // Buscar específicamente tabla infraccion en catastro_gdl
    echo str_repeat("=", 80) . "\n";
    echo "=== Verificando tabla infraccion en catastro_gdl ===\n\n";

    $schemas = ['catastro_gdl', 'informix', 'comun', 'public'];

    foreach ($schemas as $schema) {
        $sql = "
            SELECT COUNT(*) as count
            FROM pg_tables
            WHERE schemaname = :schema
              AND tablename = 'infraccion';
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['schema' => $schema]);
        $exists = $stmt->fetch(PDO::FETCH_ASSOC)['count'] > 0;

        if ($exists) {
            echo "✅ $schema.infraccion existe\n";

            // Obtener estructura
            $sql2 = "
                SELECT
                    column_name,
                    data_type,
                    character_maximum_length
                FROM information_schema.columns
                WHERE table_schema = :schema
                  AND table_name = 'infraccion'
                ORDER BY ordinal_position
                LIMIT 15;
            ";

            $stmt2 = $pdo->prepare($sql2);
            $stmt2->execute(['schema' => $schema]);
            $columns = $stmt2->fetchAll(PDO::FETCH_ASSOC);

            echo "\nPrimeras columnas:\n";
            foreach ($columns as $col) {
                $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
            }

            // Obtener conteo
            $countSql = "SELECT COUNT(*) as count FROM $schema.infraccion";
            $countStmt = $pdo->query($countSql);
            $count = $countStmt->fetch(PDO::FETCH_ASSOC)['count'];
            echo "\nTotal de registros: $count\n";

            // Ejemplos
            if ($count > 0) {
                echo "\nEjemplo de datos (primer registro):\n";
                $exampleSql = "SELECT * FROM $schema.infraccion LIMIT 1";
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

            echo "\n" . str_repeat("-", 80) . "\n\n";
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
