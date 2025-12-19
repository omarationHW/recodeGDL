<?php
// Script para buscar tablas de cuentas o conceptos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar todas las tablas y mostrar las que tienen pocos registros (probablemente catálogos)
    echo "=== BUSCANDO TABLAS TIPO CATÁLOGO (< 2000 registros) ===\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $catalogs = [];

    foreach ($tables as $table) {
        $name = $table['tablename'];

        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.$name");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 2000) {
                // Ver estructura
                $cols_stmt = $pdo->query("
                    SELECT column_name, data_type
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                    AND table_name = '$name'
                    ORDER BY ordinal_position
                ");
                $cols = $cols_stmt->fetchAll(PDO::FETCH_ASSOC);

                // Buscar si tiene campos de ID/clave y descripción/nombre
                $has_id = false;
                $has_desc = false;
                $id_field = '';
                $desc_field = '';

                foreach ($cols as $col) {
                    if (preg_match('/^(cve|id|codigo|clave)/i', $col['column_name'])) {
                        $has_id = true;
                        $id_field = $col['column_name'];
                    }
                    if (preg_match('/(descripcion|nombre|desc|name)/i', $col['column_name'])) {
                        $has_desc = true;
                        $desc_field = $col['column_name'];
                    }
                }

                if ($has_id && $has_desc) {
                    $catalogs[] = [
                        'name' => $name,
                        'count' => $count['total'],
                        'id_field' => $id_field,
                        'desc_field' => $desc_field
                    ];
                }
            }
        } catch (PDOException $e) {
            // Ignorar errores
        }
    }

    foreach ($catalogs as $cat) {
        echo "  ✓ {$cat['name']} ({$cat['count']} registros)\n";
        echo "    ID: {$cat['id_field']}, Descripción: {$cat['desc_field']}\n";

        // Ver primeros 3 registros
        try {
            $result = $pdo->query("SELECT * FROM public.{$cat['name']} LIMIT 3")->fetchAll(PDO::FETCH_ASSOC);
            foreach ($result as $i => $row) {
                $id_val = $row[$cat['id_field']] ?? 'NULL';
                $desc_val = isset($row[$cat['desc_field']]) ? substr($row[$cat['desc_field']], 0, 50) : 'NULL';
                echo "      " . ($i+1) . ". {$cat['id_field']}: $id_val, {$cat['desc_field']}: $desc_val\n";
            }
        } catch (PDOException $e) {
            // Ignorar
        }
        echo "\n";
    }

    echo "\n=== TOTAL DE CATÁLOGOS ENCONTRADOS: " . count($catalogs) . " ===\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
