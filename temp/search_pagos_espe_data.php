<?php
/**
 * Script para buscar datos de pagos especiales
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO DATOS DE PAGOS ESPECIALES ===\n\n";

    // 1. Buscar tabla autpagoesp en diferentes schemas
    echo "1. Buscando tabla 'autpagoesp' en schemas...\n";
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename = 'autpagoesp'
        ORDER BY schemaname
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($tables) {
        echo "   Tablas encontradas:\n";
        foreach ($tables as $table) {
            echo "   - {$table['schemaname']}.{$table['tablename']}\n";
        }
        echo "\n";

        // Usar el primer schema encontrado
        $schema = $tables[0]['schemaname'];

        // 2. Ver estructura de la tabla
        echo "2. Estructura de la tabla '{$schema}.autpagoesp':\n";
        $stmt = $pdo->query("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = '$schema'
            AND table_name = 'autpagoesp'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            echo "   - {$col['column_name']} ({$col['data_type']})\n";
        }
        echo "\n";

        // 3. Obtener datos de ejemplo
        echo "3. Datos de ejemplo de '{$schema}.autpagoesp':\n";
        $stmt = $pdo->query("
            SELECT *
            FROM {$schema}.autpagoesp
            LIMIT 5
        ");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($rows) {
            echo "   Encontrados " . count($rows) . " registros:\n\n";
            foreach ($rows as $i => $row) {
                echo "   Registro " . ($i + 1) . ":\n";
                foreach ($row as $key => $value) {
                    echo "     $key: $value\n";
                }
                echo "\n";
            }
        } else {
            echo "   No hay datos en la tabla\n\n";
        }

        // 4. Buscar cuentas con más pagos especiales
        echo "4. Cuentas con más pagos especiales autorizados:\n";
        $stmt = $pdo->query("
            SELECT cvecuenta, COUNT(*) as total,
                   MIN(fecaut) as primera_fecha,
                   MAX(fecaut) as ultima_fecha
            FROM {$schema}.autpagoesp
            WHERE cvecuenta IS NOT NULL
            GROUP BY cvecuenta
            HAVING COUNT(*) > 0
            ORDER BY total DESC
            LIMIT 5
        ");
        $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($cuentas) {
            foreach ($cuentas as $i => $cuenta) {
                echo "   " . ($i + 1) . ". Cuenta: {$cuenta['cvecuenta']}\n";
                echo "      Total autorizaciones: {$cuenta['total']}\n";
                echo "      Primera fecha: {$cuenta['primera_fecha']}\n";
                echo "      Última fecha: {$cuenta['ultima_fecha']}\n";
                echo "\n";
            }
        } else {
            echo "   No se encontraron cuentas\n";
        }

    } else {
        echo "   No se encontró la tabla 'autpagoesp' en ningún schema\n";
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
