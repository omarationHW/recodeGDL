<?php
/**
 * Script para buscar tablas relacionadas con polcon / políticas y control
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS RELACIONADAS CON POLCON / POLÍTICAS ===\n\n";

    // Buscar tablas que contengan "pol" en el nombre
    echo "1. Tablas que contienen 'pol' en el nombre:\n";
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename ILIKE '%pol%'
        OR tablename ILIKE '%politic%'
        OR tablename ILIKE '%control%'
        ORDER BY schemaname, tablename
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($tables) {
        foreach ($tables as $table) {
            echo "   - {$table['schemaname']}.{$table['tablename']}\n";
        }
    } else {
        echo "   No se encontraron tablas\n";
    }

    echo "\n2. Buscando tablas específicas en schemas comunes:\n";

    $possible_names = ['polcon', 'politicas', 'control', 'ta_polcon', 'ta_pol'];
    $schemas = ['comun', 'comunX', 'catastro_gdl', 'db_ingresos', 'public', 'multas_reglamentos'];

    foreach ($schemas as $schema) {
        foreach ($possible_names as $name) {
            $stmt = $pdo->prepare("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = ? AND table_name = ?
                ORDER BY ordinal_position
            ");
            $stmt->execute([$schema, $name]);
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if ($columns) {
                echo "\n   ✓ Encontrada: {$schema}.{$name}\n";
                echo "   Columnas:\n";
                foreach ($columns as $col) {
                    echo "     - {$col['column_name']} ({$col['data_type']})\n";
                }

                // Obtener datos de ejemplo
                $stmt = $pdo->query("SELECT * FROM {$schema}.{$name} LIMIT 5");
                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                if ($rows) {
                    echo "\n   Datos de ejemplo:\n";
                    foreach ($rows as $i => $row) {
                        echo "   Registro " . ($i + 1) . ":\n";
                        foreach ($row as $key => $value) {
                            $val = $value ?? 'NULL';
                            if (strlen($val) > 80) $val = substr($val, 0, 80) . '...';
                            echo "     $key: $val\n";
                        }
                        echo "\n";
                    }
                }
                break 2; // Salir de ambos loops
            }
        }
    }

    echo "\n3. Contando registros en tablas encontradas:\n";
    $count_tables = ['catastro_gdl.politicas', 'catastro_gdl.control', 'comun.polcon', 'comunX.polcon'];

    foreach ($count_tables as $table) {
        try {
            $stmt = $pdo->query("SELECT COUNT(*) as total FROM {$table}");
            $count = $stmt->fetch(PDO::FETCH_ASSOC);
            echo "   {$table}: {$count['total']} registros\n";
        } catch (Exception $e) {
            // Tabla no existe, continuar
        }
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
