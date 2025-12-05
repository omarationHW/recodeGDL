<?php
/**
 * Script para buscar tablas relacionadas con periodo inicial
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS RELACIONADAS CON PERIODO INICIAL ===\n\n";

    // Buscar tablas que contengan "periodo" o "parametro" en el nombre
    echo "1. Tablas que contienen 'periodo' en el nombre:\n";
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename ILIKE '%periodo%'
        OR tablename ILIKE '%parametro%'
        OR tablename ILIKE '%param%'
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

    echo "\n2. Buscando tabla 'parametros' en schemas comunes:\n";

    $schemas = ['comun', 'comunX', 'catastro_gdl', 'db_ingresos', 'public'];

    foreach ($schemas as $schema) {
        $stmt = $pdo->prepare("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = ? AND table_name = 'parametros'
            ORDER BY ordinal_position
        ");
        $stmt->execute([$schema]);
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($columns) {
            echo "\n   Encontrada: {$schema}.parametros\n";
            echo "   Columnas:\n";
            foreach ($columns as $col) {
                echo "     - {$col['column_name']} ({$col['data_type']})\n";
            }

            // Obtener datos de ejemplo
            $stmt = $pdo->query("SELECT * FROM {$schema}.parametros LIMIT 3");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if ($rows) {
                echo "\n   Datos de ejemplo:\n";
                foreach ($rows as $i => $row) {
                    echo "   Registro " . ($i + 1) . ":\n";
                    foreach ($row as $key => $value) {
                        $val = $value ?? 'NULL';
                        if (strlen($val) > 50) $val = substr($val, 0, 50) . '...';
                        echo "     $key: $val\n";
                    }
                    echo "\n";
                }
            }
            break; // Solo mostrar el primero que encuentre
        }
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
