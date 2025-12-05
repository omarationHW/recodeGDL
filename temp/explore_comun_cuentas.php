<?php
// Explorar tabla comun.cuentas
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== ESTRUCTURA DE comun.cuentas ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'cuentas'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        echo sprintf("  %-30s %-20s %s\n",
            $col['column_name'],
            $col['data_type'],
            $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : ""
        );
    }

    echo "\n=== CONTEO DE REGISTROS ===\n";
    $stmt = $pdo->query("SELECT COUNT(*) FROM comun.cuentas");
    $count = $stmt->fetchColumn();
    echo "Total de registros: " . number_format($count) . "\n";

    echo "\n=== PRIMEROS 5 REGISTROS ===\n\n";
    $stmt = $pdo->query("
        SELECT *
        FROM comun.cuentas
        LIMIT 5
    ");

    $first_records = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($first_records as $idx => $record) {
        echo "Registro " . ($idx + 1) . ":\n";
        foreach ($record as $key => $value) {
            if ($value !== null && $value !== '') {
                echo "  $key: $value\n";
            }
        }
        echo "\n";
    }

    // Buscar columnas que indiquen cancelación o estado
    echo "\n=== COLUMNAS CON 'CANCEL', 'ESTADO', 'VIGENTE' ===\n\n";
    foreach ($columns as $col) {
        if (stripos($col['column_name'], 'cancel') !== false ||
            stripos($col['column_name'], 'estado') !== false ||
            stripos($col['column_name'], 'vigent') !== false ||
            stripos($col['column_name'], 'activ') !== false) {

            echo "Columna: {$col['column_name']}\n";

            // Ver valores distintos
            try {
                $stmt = $pdo->query("
                    SELECT DISTINCT {$col['column_name']}, COUNT(*) as count
                    FROM comun.cuentas
                    WHERE {$col['column_name']} IS NOT NULL
                    GROUP BY {$col['column_name']}
                    ORDER BY count DESC
                    LIMIT 10
                ");

                while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                    echo "  '{$row[$col['column_name']]}' -> {$row['count']} registros\n";
                }
            } catch (Exception $e) {
                echo "  (No se pudo consultar)\n";
            }
            echo "\n";
        }
    }

    // Buscar ejemplos de cuentas (usar columna 'cuenta' si existe)
    echo "\n=== OBTENIENDO CUENTAS DE EJEMPLO ===\n\n";

    // Intentar con diferentes nombres de columna
    $possible_key_columns = ['cuenta', 'clave_cuenta', 'cve_cuenta', 'id_cuenta', 'num_cuenta'];

    foreach ($possible_key_columns as $key_col) {
        $column_exists = false;
        foreach ($columns as $col) {
            if ($col['column_name'] === $key_col) {
                $column_exists = true;
                break;
            }
        }

        if ($column_exists) {
            echo "Usando columna: $key_col\n\n";

            $stmt = $pdo->query("
                SELECT $key_col
                FROM comun.cuentas
                WHERE $key_col IS NOT NULL
                LIMIT 10
            ");

            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                echo "  - {$row[$key_col]}\n";
            }
            break;
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
