<?php
$host = '192.168.20.31';
$port = '5432';
$dbname = 'ingresos';
$user = 'postgres';
$password = 'F3rnand0';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname;connect_timeout=5", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Buscando tabla correcta para locales...\n\n";

    // Campos que necesitamos
    $needed_fields = ['id_local', 'oficina', 'num_mercado', 'categoria', 'seccion', 'letra_local', 'bloque', 'nombre'];

    $tables_to_check = [
        'ta_11_cuo_locales',
        'ta_11_localpaso',
        'ta_11_local',
        'ta_11_mercados_locales',
        'ta_11_padron_locales'
    ];

    foreach ($tables_to_check as $table) {
        echo "========================================\n";
        echo "Verificando: $table\n";
        echo "========================================\n";

        // Buscar en todos los schemas
        $stmt = $pdo->query("
            SELECT schemaname, tablename
            FROM pg_tables
            WHERE tablename = '$table'
            ORDER BY schemaname
        ");

        $found_tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($found_tables) == 0) {
            echo "❌ No existe\n\n";
            continue;
        }

        foreach ($found_tables as $t) {
            $schema = $t['schemaname'];
            $tname = $t['tablename'];

            echo "✓ Encontrada: $schema.$tname\n\n";

            // Obtener columnas
            $stmt2 = $pdo->prepare("
                SELECT column_name, data_type, character_maximum_length
                FROM information_schema.columns
                WHERE table_schema = :schema
                AND table_name = :table
                ORDER BY ordinal_position
            ");
            $stmt2->execute(['schema' => $schema, 'table' => $tname]);
            $columns = $stmt2->fetchAll(PDO::FETCH_ASSOC);

            echo "Columnas encontradas:\n";
            $col_names = [];
            foreach ($columns as $col) {
                $col_names[] = $col['column_name'];
                echo "  - {$col['column_name']} ({$col['data_type']}";
                if ($col['character_maximum_length']) {
                    echo "({$col['character_maximum_length']})";
                }
                echo ")\n";
            }

            // Verificar coincidencias
            $matches = array_intersect($needed_fields, $col_names);
            echo "\nCampos necesarios presentes: " . count($matches) . "/" . count($needed_fields) . "\n";

            if (count($matches) >= 6) {
                echo "✓✓✓ TABLA CANDIDATA ✓✓✓\n";

                // Contar registros
                $stmt3 = $pdo->query("SELECT COUNT(*) as total FROM $schema.$tname");
                $count = $stmt3->fetch(PDO::FETCH_ASSOC);
                echo "Registros: {$count['total']}\n";
            }

            echo "\n";
        }
    }

    // Buscar cualquier tabla con 'local' que tenga id_local
    echo "========================================\n";
    echo "Buscando todas las tablas con 'local' e 'id_local'\n";
    echo "========================================\n";

    $stmt = $pdo->query("
        SELECT DISTINCT t.schemaname, t.tablename
        FROM pg_tables t
        WHERE t.tablename LIKE '%local%'
        AND EXISTS (
            SELECT 1 FROM information_schema.columns c
            WHERE c.table_schema = t.schemaname
            AND c.table_name = t.tablename
            AND c.column_name = 'id_local'
        )
        ORDER BY t.schemaname, t.tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Tablas encontradas con 'local' e 'id_local':\n\n";

    foreach ($tables as $table) {
        echo "{$table['schemaname']}.{$table['tablename']}\n";

        // Verificar campos necesarios
        $stmt2 = $pdo->prepare("
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = :schema
            AND table_name = :table
            AND column_name IN ('id_local', 'oficina', 'num_mercado', 'categoria', 'seccion', 'letra_local', 'bloque', 'nombre')
            ORDER BY ordinal_position
        ");
        $stmt2->execute(['schema' => $table['schemaname'], 'table' => $table['tablename']]);
        $cols = $stmt2->fetchAll(PDO::FETCH_COLUMN);

        if (count($cols) > 0) {
            echo "  Campos: " . implode(', ', $cols) . "\n";

            if (count($cols) >= 6) {
                echo "  ✓✓✓ CANDIDATA FUERTE ✓✓✓\n";
            }
        }
        echo "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
