<?php
// Script para verificar el SP actual y buscar la tabla ta_11_secciones

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Verificando SP actual en BD ===\n\n";

    // Ver la definición actual del SP
    $sql = "
        SELECT pg_get_functiondef(oid)
        FROM pg_proc
        WHERE proname = 'sp_get_secciones'
    ";

    $stmt = $pdo->query($sql);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "Definición actual del SP:\n";
        echo $result['pg_get_functiondef'] . "\n\n";
    } else {
        echo "No se encontró el SP\n\n";
    }

    // Buscar la tabla ta_11_secciones en diferentes schemas
    echo "=== Buscando tabla ta_11_secciones ===\n\n";

    $sql = "
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name = 'ta_11_secciones'
        ORDER BY table_schema
    ";

    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "Tabla encontrada en los siguientes schemas:\n";
        foreach ($tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }
        echo "\n";

        // Verificar estructura de la primera tabla encontrada
        $firstSchema = $tables[0]['table_schema'];
        echo "Estructura de {$firstSchema}.ta_11_secciones:\n";

        $sql = "
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_name = 'ta_11_secciones'
            AND table_schema = '$firstSchema'
            ORDER BY ordinal_position
        ";

        $stmt = $pdo->query($sql);
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) {
                $type .= "({$col['character_maximum_length']})";
            }
            echo "  {$col['column_name']}: {$type}\n";
        }
    } else {
        echo "No se encontró la tabla ta_11_secciones\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
