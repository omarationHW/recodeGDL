<?php
/**
 * Script para ver la estructura de la tabla descpred
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Estructura de la tabla catastro_gdl.descpred ===\n\n";

    $sql = "
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
          AND table_name = 'descpred'
        ORDER BY ordinal_position;
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
        echo "{$col['column_name']}: {$col['data_type']}{$length} {$nullable}\n";
    }

    echo "\n=== Estructura de la tabla catastro_gdl.c_descpred ===\n\n";

    $sql2 = "
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
          AND table_name = 'c_descpred'
        ORDER BY ordinal_position;
    ";

    $stmt2 = $pdo->query($sql2);
    $columns2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns2 as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
        echo "{$col['column_name']}: {$col['data_type']}{$length} {$nullable}\n";
    }

    // Ver algunos ejemplos de datos
    echo "\n=== Ejemplos de datos en descpred ===\n\n";

    $sql3 = "SELECT * FROM catastro_gdl.descpred LIMIT 3";
    $stmt3 = $pdo->query($sql3);
    $examples = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($examples)) {
        foreach ($examples[0] as $key => $value) {
            echo "$key: $value\n";
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
