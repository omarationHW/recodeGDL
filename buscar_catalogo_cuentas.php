<?php
// Script para buscar catálogo de cuentas de aplicación

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'catalogo' o 'cat_' o 'c_'
    echo "=== BUSCANDO TABLAS DE CATÁLOGO ===\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (tablename ILIKE 'c_%' OR tablename ILIKE 'cat_%' OR tablename ILIKE '%catalogo%')
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        $name = $table['tablename'];

        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.$name");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            // Ver si tiene campos relacionados con cuenta aplicación
            $cols_stmt = $pdo->query("
                SELECT column_name
                FROM information_schema.columns
                WHERE table_schema = 'public'
                AND table_name = '$name'
                AND (
                    column_name ILIKE '%cvectaapl%' OR
                    column_name ILIKE '%cveapl%' OR
                    column_name ILIKE '%aplicacion%' OR
                    column_name ILIKE '%descripcion%' OR
                    column_name ILIKE '%nombre%'
                )
                ORDER BY ordinal_position
            ");
            $cols = $cols_stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($cols) > 0) {
                echo "  ✓ $name ({$count['total']} registros)\n";
                foreach ($cols as $col) {
                    echo "    - {$col['column_name']}\n";
                }
                echo "\n";
            }
        } catch (PDOException $e) {
            // Ignorar errores
        }
    }

    // Buscar específicamente un cvectaapl=110110000 (el más común) en todas las tablas de catálogo
    echo "\n=== BUSCANDO CVECTAAPL 110110000 EN CATÁLOGOS ===\n\n";

    foreach ($tables as $table) {
        $name = $table['tablename'];

        try {
            // Verificar si la tabla tiene el campo cvectaapl o similar
            $has_field = $pdo->query("
                SELECT COUNT(*) as total
                FROM information_schema.columns
                WHERE table_schema = 'public'
                AND table_name = '$name'
                AND column_name ILIKE '%cvectaapl%'
            ")->fetch(PDO::FETCH_ASSOC);

            if ($has_field['total'] > 0) {
                // Buscar el registro
                $result = $pdo->query("
                    SELECT * FROM public.$name WHERE cvectaapl = 110110000 LIMIT 1
                ")->fetchAll(PDO::FETCH_ASSOC);

                if (count($result) > 0) {
                    echo "  ✓ Encontrado en: $name\n";
                    foreach ($result[0] as $key => $value) {
                        echo "    $key: " . substr($value, 0, 100) . "\n";
                    }
                    echo "\n";
                }
            }
        } catch (PDOException $e) {
            // Ignorar errores
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
