<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== VERIFICANDO SP pagos_individual_get ===\n\n";

    // Verify SP exists
    $query = "
        SELECT proname, pg_get_function_identity_arguments(oid) as args
        FROM pg_proc
        WHERE proname = 'pagos_individual_get'
        AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    ";

    $stmt = $pdo->query($query);
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "✓ SP encontrado: {$sp['proname']}({$sp['args']})\n\n";

        // Check return structure
        echo "=== ESTRUCTURA DE RETORNO ===\n";
        $structQuery = "
            SELECT
                a.attname as column_name,
                t.typname as data_type,
                a.atttypmod as type_modifier
            FROM pg_proc p
            JOIN pg_type pt ON p.prorettype = pt.oid
            JOIN pg_class c ON pt.typrelid = c.oid
            JOIN pg_attribute a ON c.oid = a.attrelid
            JOIN pg_type t ON a.atttypid = t.oid
            WHERE p.proname = 'pagos_individual_get'
            AND a.attnum > 0
            AND NOT a.attisdropped
            ORDER BY a.attnum
        ";

        $stmt = $pdo->query($structQuery);
        $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($cols as $col) {
            $typeStr = $col['data_type'];
            if ($col['type_modifier'] > 0 && in_array($col['data_type'], ['bpchar', 'varchar'])) {
                $len = $col['type_modifier'] - 4;
                $typeStr .= "($len)";
            }
            echo "  {$col['column_name']}: $typeStr\n";
        }
    } else {
        echo "✗ SP no encontrado\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
