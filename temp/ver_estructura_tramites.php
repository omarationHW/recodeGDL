<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "ESTRUCTURA DE TABLA: comun.tramites\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Ver estructura de la tabla tramites
    $stmt = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'tramites'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($columns) {
        echo "Columnas de comun.tramites:\n";
        echo "========================================\n";
        foreach ($columns as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) {
                $type .= "({$col['character_maximum_length']})";
            }
            $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
            $default = $col['column_default'] ? " DEFAULT {$col['column_default']}" : '';

            echo sprintf(
                "  %-25s %-25s %-10s %s\n",
                $col['column_name'],
                $type,
                $nullable,
                $default
            );
        }

        echo "\n";
        echo "Total columnas: " . count($columns) . "\n";

        // Ver la clave primaria
        echo "\nClave primaria:\n";
        echo "========================================\n";
        $stmt = $pdo->query("
            SELECT a.attname
            FROM   pg_index i
            JOIN   pg_attribute a ON a.attrelid = i.indrelid
                                 AND a.attnum = ANY(i.indkey)
            WHERE  i.indrelid = 'comun.tramites'::regclass
            AND    i.indisprimary
        ");
        $pk = $stmt->fetchAll(PDO::FETCH_COLUMN);
        if ($pk) {
            foreach ($pk as $colname) {
                echo "  • {$colname}\n";
            }
        } else {
            echo "  (sin clave primaria)\n";
        }

        // Ver registros de ejemplo
        echo "\nPrimeros 3 registros (si existen):\n";
        echo "========================================\n";
        $stmt = $pdo->query("SELECT * FROM comun.tramites LIMIT 3");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if ($rows) {
            foreach ($rows as $i => $row) {
                echo "\nRegistro " . ($i + 1) . ":\n";
                foreach ($row as $key => $value) {
                    echo "  {$key}: " . (is_null($value) ? '(null)' : substr($value, 0, 50)) . "\n";
                }
            }
        } else {
            echo "  (tabla vacía)\n";
        }
    } else {
        echo "❌ No se pudo obtener la estructura de la tabla\n";
    }

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
