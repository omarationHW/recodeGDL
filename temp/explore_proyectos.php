<?php
// Explorar estructura de ta_proyectos
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== ESTRUCTURA DE comun.ta_proyectos ===\n\n";

    $colSql = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'ta_proyectos'
        ORDER BY ordinal_position
    ";

    $colStmt = $pdo->query($colSql);
    $columns = $colStmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        echo "{$col['column_name']}: {$type}\n";
    }

    echo "\n=== DATOS DE EJEMPLO (5 registros) ===\n\n";

    $sql = "SELECT * FROM comun.ta_proyectos LIMIT 5";
    $stmt = $pdo->query($sql);
    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($samples as $idx => $sample) {
        echo "Registro " . ($idx + 1) . ":\n";
        foreach ($sample as $key => $value) {
            if ($value !== null && $value !== '') {
                echo "  $key: $value\n";
            }
        }
        echo "\n";
    }

    echo "=== ESTRUCTURA DE comun.ta_proyecto_pres ===\n\n";

    $colSql = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'ta_proyecto_pres'
        ORDER BY ordinal_position
    ";

    $colStmt = $pdo->query($colSql);
    $columns = $colStmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        echo "{$col['column_name']}: {$type}\n";
    }

    echo "\n=== DATOS DE EJEMPLO ta_proyecto_pres (5 registros) ===\n\n";

    $sql = "SELECT * FROM comun.ta_proyecto_pres LIMIT 5";
    $stmt = $pdo->query($sql);
    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($samples as $idx => $sample) {
        echo "Registro " . ($idx + 1) . ":\n";
        foreach ($sample as $key => $value) {
            if ($value !== null && $value !== '') {
                echo "  $key: $value\n";
            }
        }
        echo "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
