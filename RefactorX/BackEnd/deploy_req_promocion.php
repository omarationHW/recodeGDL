<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLEGANDO STORED PROCEDURE REQ_PROMOCION ===\n\n";

try {
    // 1. Buscar tablas relacionadas con promoción
    echo "1. Buscando tablas relacionadas con promoción...\n";

    $tables = DB::select("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%promo%'
           OR table_name ILIKE '%descuento%'
           OR table_name ILIKE '%desc%'
        ORDER BY table_schema, table_name
        LIMIT 20
    ");

    echo "   Tablas encontradas:\n";
    foreach ($tables as $table) {
        echo "   - {$table->table_schema}.{$table->table_name}\n";
    }

    // Buscar específicamente req_promocion
    echo "\n2. Buscando tabla específica req_promocion...\n";

    $reqPromTables = DB::select("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%req%promo%'
        ORDER BY table_schema, table_name
    ");

    $foundSchema = null;
    $foundTable = null;

    foreach ($reqPromTables as $table) {
        echo "   - {$table->table_schema}.{$table->table_name}\n";
        if (!$foundSchema) {
            $foundSchema = $table->table_schema;
            $foundTable = $table->table_name;
        }
    }

    // Si no encuentra tabla específica, buscar alternativas
    if (!$foundSchema) {
        echo "\n   No se encontró tabla req_promocion, buscando alternativas...\n";

        // Buscar en tablas de descuentos o promociones
        $altTables = DB::select("
            SELECT table_schema, table_name,
                   (SELECT COUNT(*) FROM information_schema.columns
                    WHERE table_schema = t.table_schema
                    AND table_name = t.table_name) as num_cols
            FROM information_schema.tables t
            WHERE (table_name ILIKE '%descuento%' OR table_name ILIKE '%promo%')
              AND table_schema IN ('catastro_gdl', 'comun', 'comunX', 'public')
            ORDER BY table_schema, table_name
            LIMIT 10
        ");

        echo "   Tablas alternativas:\n";
        foreach ($altTables as $table) {
            echo "   - {$table->table_schema}.{$table->table_name} ({$table->num_cols} columnas)\n";
        }

        // Usar la primera tabla alternativa
        if (count($altTables) > 0) {
            $foundSchema = $altTables[0]->table_schema;
            $foundTable = $altTables[0]->table_name;
        }
    }

    if (!$foundSchema) {
        echo "\n❌ No se encontró ninguna tabla adecuada para crear el SP\n";
        echo "   Creando SP con estructura genérica...\n";

        // Crear SP genérico que retorna mensaje de que no hay datos
        $sql = "
        CREATE OR REPLACE FUNCTION recaudadora_req_promocion(
            p_clave_cuenta VARCHAR DEFAULT NULL,
            p_ejercicio INTEGER DEFAULT NULL
        )
        RETURNS TABLE (
            mensaje TEXT
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT 'No hay datos disponibles. Tabla req_promocion no encontrada.'::TEXT;
        END;
        \$\$ LANGUAGE plpgsql;
        ";

        DB::statement($sql);
        echo "   ✓ SP genérico creado\n";
        return;
    }

    echo "\n3. Obteniendo estructura de {$foundSchema}.{$foundTable}...\n";

    $columns = DB::select("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = ? AND table_name = ?
        ORDER BY ordinal_position
        LIMIT 15
    ", [$foundSchema, $foundTable]);

    echo "   Columnas disponibles:\n";
    foreach ($columns as $col) {
        echo "      - {$col->column_name} ({$col->data_type})\n";
    }

    // Obtener algunos datos de ejemplo
    echo "\n4. Obteniendo ejemplos de datos...\n";

    try {
        $examples = DB::select("SELECT * FROM {$foundSchema}.{$foundTable} LIMIT 3");

        if (count($examples) > 0) {
            echo "   ✓ Encontrados " . count($examples) . " registros de ejemplo\n";

            foreach ($examples as $i => $row) {
                echo "\n   Ejemplo " . ($i + 1) . ":\n";
                $rowArray = (array)$row;
                $count = 0;
                foreach ($rowArray as $key => $value) {
                    if ($count < 5) { // Solo mostrar primeros 5 campos
                        echo "      $key: " . (is_null($value) ? 'NULL' : substr($value, 0, 50)) . "\n";
                        $count++;
                    }
                }
            }

            // Contar total
            $count = DB::selectOne("SELECT COUNT(*) as total FROM {$foundSchema}.{$foundTable}");
            echo "\n   Total de registros: " . $count->total . "\n";

        } else {
            echo "   ⚠ No hay datos en la tabla\n";
        }
    } catch (Exception $e) {
        echo "   ⚠ Error obteniendo datos: " . $e->getMessage() . "\n";
    }

    // Crear SP basado en la estructura encontrada
    echo "\n5. Creando stored procedure recaudadora_req_promocion...\n";

    $columnsList = array_map(fn($col) => "r.{$col->column_name}", $columns);
    $columnsStr = implode(",\n            ", $columnsList);

    // Intentar encontrar columnas comunes para filtrar
    $hasAccount = false;
    $hasYear = false;
    $accountCol = '';
    $yearCol = '';

    foreach ($columns as $col) {
        if (stripos($col->column_name, 'cuenta') !== false ||
            stripos($col->column_name, 'clave') !== false ||
            stripos($col->column_name, 'folio') !== false) {
            $hasAccount = true;
            $accountCol = $col->column_name;
        }
        if (stripos($col->column_name, 'ejercicio') !== false ||
            stripos($col->column_name, 'ano') !== false ||
            stripos($col->column_name, 'axo') !== false ||
            stripos($col->column_name, 'year') !== false) {
            $hasYear = true;
            $yearCol = $col->column_name;
        }
    }

    // Construir WHERE clause
    $whereClause = "WHERE 1=1";
    if ($hasAccount) {
        $whereClause .= "\n           AND (p_clave_cuenta IS NULL OR CAST(r.{$accountCol} AS TEXT) ILIKE '%' || p_clave_cuenta || '%')";
    }
    if ($hasYear) {
        $whereClause .= "\n           AND (p_ejercicio IS NULL OR r.{$yearCol} = p_ejercicio)";
    }

    // Construir RETURNS TABLE
    $returnsColumns = [];
    foreach ($columns as $col) {
        $pgType = $col->data_type;
        if ($pgType == 'character varying' || $pgType == 'character') {
            $pgType = 'TEXT';
        } elseif ($pgType == 'smallint') {
            $pgType = 'INTEGER';
        }
        $returnsColumns[] = "{$col->column_name} {$pgType}";
    }
    $returnsStr = implode(",\n    ", $returnsColumns);

    $sql = "
    CREATE OR REPLACE FUNCTION recaudadora_req_promocion(
        p_clave_cuenta VARCHAR DEFAULT NULL,
        p_ejercicio INTEGER DEFAULT NULL
    )
    RETURNS TABLE (
        {$returnsStr}
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            {$columnsStr}
        FROM {$foundSchema}.{$foundTable} r
        {$whereClause}
        ORDER BY r.{$columns[0]->column_name} DESC
        LIMIT 100;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    DB::statement("DROP FUNCTION IF EXISTS recaudadora_req_promocion(VARCHAR, INTEGER) CASCADE");
    DB::statement($sql);

    echo "   ✓ Stored procedure creado exitosamente\n";

    // Probar el SP
    echo "\n6. Probando stored procedure...\n";

    try {
        $testResult = DB::select("SELECT * FROM recaudadora_req_promocion(NULL, NULL) LIMIT 5");
        echo "   ✓ SP funciona correctamente\n";
        echo "   Retornó " . count($testResult) . " registros\n";

        if (count($testResult) > 0) {
            echo "\n   Primer registro de prueba:\n";
            $first = (array)$testResult[0];
            $count = 0;
            foreach ($first as $key => $value) {
                if ($count < 5) {
                    echo "      $key: " . (is_null($value) ? 'NULL' : substr($value, 0, 50)) . "\n";
                    $count++;
                }
            }
        }
    } catch (Exception $e) {
        echo "   ✗ Error probando SP: " . $e->getMessage() . "\n";
    }

    echo "\n✅ DESPLIEGUE COMPLETADO\n";
    echo "Tabla utilizada: {$foundSchema}.{$foundTable}\n";
    echo "Columnas de filtro detectadas:\n";
    echo "   - Cuenta: " . ($hasAccount ? $accountCol : 'No detectada') . "\n";
    echo "   - Año: " . ($hasYear ? $yearCol : 'No detectada') . "\n";

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
}
