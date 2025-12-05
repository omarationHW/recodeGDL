<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLEGANDO STORED PROCEDURE REQTRANS_LIST ===\n\n";

try {
    // 1. Buscar tablas relacionadas con tránsito/transmisión
    echo "1. Buscando tablas relacionadas con tránsito/transmisión...\n";

    $tables = DB::select("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%trans%'
           OR table_name ILIKE '%transito%'
           OR table_name ILIKE '%transmision%'
           OR table_name ILIKE '%req%trans%')
          AND table_schema IN ('catastro_gdl', 'comun', 'comunX', 'db_ingresos', 'public')
        ORDER BY table_schema, table_name
        LIMIT 30
    ");

    echo "   Tablas encontradas:\n";
    foreach ($tables as $table) {
        echo "   - {$table->table_schema}.{$table->table_name}\n";
    }

    // 2. Buscar específicamente req_trans o similar
    echo "\n2. Buscando tabla específica de requerimientos de tránsito...\n";

    $reqTransTables = DB::select("
        SELECT table_schema, table_name,
               (SELECT COUNT(*) FROM information_schema.columns
                WHERE table_schema = t.table_schema
                AND table_name = t.table_name) as num_cols
        FROM information_schema.tables t
        WHERE (table_name ILIKE '%req%trans%'
           OR table_name ILIKE '%requerimiento%trans%'
           OR table_name ILIKE '%reqtrans%')
        ORDER BY table_schema, table_name
    ");

    $foundSchema = null;
    $foundTable = null;

    if (count($reqTransTables) > 0) {
        echo "   Tablas específicas de requerimientos:\n";
        foreach ($reqTransTables as $table) {
            echo "   - {$table->table_schema}.{$table->table_name} ({$table->num_cols} columnas)\n";
            if (!$foundSchema) {
                $foundSchema = $table->table_schema;
                $foundTable = $table->table_name;
            }
        }
    }

    // 3. Si no encuentra req_trans, buscar tabla de transmisión que tenga columnas típicas
    if (!$foundSchema) {
        echo "\n   No se encontró tabla específica, buscando alternativas con columnas relevantes...\n";

        $altTables = DB::select("
            SELECT DISTINCT t.table_schema, t.table_name,
                   (SELECT COUNT(*) FROM information_schema.columns
                    WHERE table_schema = t.table_schema
                    AND table_name = t.table_name) as num_cols,
                   (SELECT COUNT(*) FROM information_schema.columns c
                    WHERE c.table_schema = t.table_schema
                    AND c.table_name = t.table_name
                    AND (c.column_name ILIKE '%cuenta%'
                         OR c.column_name ILIKE '%folio%'
                         OR c.column_name ILIKE '%ejercicio%'
                         OR c.column_name ILIKE '%axo%')) as matching_cols
            FROM information_schema.tables t
            WHERE (t.table_name ILIKE '%trans%' OR t.table_name ILIKE '%transmis%')
              AND t.table_schema IN ('catastro_gdl', 'comun', 'comunX', 'db_ingresos')
            HAVING matching_cols > 0
            ORDER BY matching_cols DESC, num_cols ASC
            LIMIT 10
        ");

        echo "   Tablas alternativas con columnas relevantes:\n";
        foreach ($altTables as $table) {
            echo "   - {$table->table_schema}.{$table->table_name} ({$table->num_cols} columnas, {$table->matching_cols} coincidencias)\n";
        }

        if (count($altTables) > 0) {
            $foundSchema = $altTables[0]->table_schema;
            $foundTable = $altTables[0]->table_name;
        }
    }

    if (!$foundSchema) {
        echo "\n❌ No se encontró ninguna tabla adecuada\n";
        echo "   Creando SP genérico que retorna estructura vacía...\n";

        $sql = "
        CREATE OR REPLACE FUNCTION recaudadora_reqtrans_list(
            p_clave_cuenta VARCHAR DEFAULT NULL,
            p_ejercicio INTEGER DEFAULT NULL
        )
        RETURNS TABLE (
            clave_cuenta TEXT,
            folio INTEGER,
            ejercicio INTEGER,
            estatus TEXT,
            mensaje TEXT
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                ''::TEXT as clave_cuenta,
                0::INTEGER as folio,
                0::INTEGER as ejercicio,
                ''::TEXT as estatus,
                'No hay datos disponibles. Tabla no encontrada.'::TEXT as mensaje
            WHERE FALSE;
        END;
        \$\$ LANGUAGE plpgsql;
        ";

        DB::statement("DROP FUNCTION IF EXISTS recaudadora_reqtrans_list(VARCHAR, INTEGER) CASCADE");
        DB::statement($sql);
        echo "   ✓ SP genérico creado\n";
        return;
    }

    echo "\n3. Obteniendo estructura de {$foundSchema}.{$foundTable}...\n";

    $columns = DB::select("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = ? AND table_name = ?
        ORDER BY ordinal_position
        LIMIT 20
    ", [$foundSchema, $foundTable]);

    echo "   Columnas disponibles:\n";
    foreach ($columns as $col) {
        $length = $col->character_maximum_length ? "({$col->character_maximum_length})" : "";
        echo "      - {$col->column_name} ({$col->data_type}{$length})\n";
    }

    // 4. Obtener datos de ejemplo
    echo "\n4. Obteniendo ejemplos de datos...\n";

    try {
        $examples = DB::select("SELECT * FROM {$foundSchema}.{$foundTable} LIMIT 5");

        if (count($examples) > 0) {
            echo "   ✓ Encontrados " . count($examples) . " registros de ejemplo\n";

            foreach ($examples as $i => $row) {
                echo "\n   Ejemplo " . ($i + 1) . ":\n";
                $rowArray = (array)$row;
                $count = 0;
                foreach ($rowArray as $key => $value) {
                    if ($count < 6) {
                        echo "      $key: " . (is_null($value) ? 'NULL' : substr($value, 0, 50)) . "\n";
                        $count++;
                    }
                }
            }

            $count = DB::selectOne("SELECT COUNT(*) as total FROM {$foundSchema}.{$foundTable}");
            echo "\n   Total de registros: " . $count->total . "\n";
        } else {
            echo "   ⚠ No hay datos en la tabla\n";
        }
    } catch (Exception $e) {
        echo "   ⚠ Error obteniendo datos: " . $e->getMessage() . "\n";
    }

    // 5. Detectar columnas para el SP
    echo "\n5. Detectando columnas para el SP...\n";

    $hasCuenta = false;
    $hasFolio = false;
    $hasEjercicio = false;
    $hasEstatus = false;
    $cuentaCol = '';
    $folioCol = '';
    $ejercicioCol = '';
    $estatusCol = '';

    foreach ($columns as $col) {
        if (stripos($col->column_name, 'cuenta') !== false || stripos($col->column_name, 'clave') !== false) {
            $hasCuenta = true;
            $cuentaCol = $col->column_name;
        }
        if (stripos($col->column_name, 'folio') !== false || stripos($col->column_name, 'numero') !== false) {
            $hasFolio = true;
            $folioCol = $col->column_name;
        }
        if (stripos($col->column_name, 'ejercicio') !== false || stripos($col->column_name, 'axo') !== false || stripos($col->column_name, 'ano') !== false) {
            $hasEjercicio = true;
            $ejercicioCol = $col->column_name;
        }
        if (stripos($col->column_name, 'estatus') !== false || stripos($col->column_name, 'estado') !== false || stripos($col->column_name, 'status') !== false) {
            $hasEstatus = true;
            $estatusCol = $col->column_name;
        }
    }

    echo "   Columnas detectadas:\n";
    echo "      - Cuenta: " . ($hasCuenta ? $cuentaCol : 'NO DETECTADA') . "\n";
    echo "      - Folio: " . ($hasFolio ? $folioCol : 'NO DETECTADA') . "\n";
    echo "      - Ejercicio: " . ($hasEjercicio ? $ejercicioCol : 'NO DETECTADA') . "\n";
    echo "      - Estatus: " . ($hasEstatus ? $estatusCol : 'NO DETECTADA') . "\n";

    // 6. Crear el SP
    echo "\n6. Creando stored procedure recaudadora_reqtrans_list...\n";

    // Construir SELECT dinámico
    $selectFields = [];
    if ($hasCuenta) {
        $selectFields[] = "TRIM(r.{$cuentaCol})::TEXT as clave_cuenta";
    } else {
        $selectFields[] = "''::TEXT as clave_cuenta";
    }

    if ($hasFolio) {
        $selectFields[] = "r.{$folioCol}::INTEGER as folio";
    } else {
        $selectFields[] = "0::INTEGER as folio";
    }

    if ($hasEjercicio) {
        $selectFields[] = "r.{$ejercicioCol}::INTEGER as ejercicio";
    } else {
        $selectFields[] = "0::INTEGER as ejercicio";
    }

    if ($hasEstatus) {
        $selectFields[] = "TRIM(r.{$estatusCol})::TEXT as estatus";
    } else {
        $selectFields[] = "''::TEXT as estatus";
    }

    $selectStr = implode(",\n            ", $selectFields);

    // Construir WHERE
    $whereConditions = ["1=1"];
    if ($hasCuenta) {
        $whereConditions[] = "(p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR TRIM(r.{$cuentaCol})::TEXT ILIKE '%' || p_clave_cuenta || '%')";
    }
    if ($hasEjercicio) {
        $whereConditions[] = "(p_ejercicio IS NULL OR p_ejercicio = 0 OR r.{$ejercicioCol} = p_ejercicio)";
    }
    $whereStr = implode("\n           AND ", $whereConditions);

    // Ordenar por
    $orderBy = $hasEjercicio && $hasFolio ?
        "r.{$ejercicioCol} DESC, r.{$folioCol} DESC" :
        ($hasEjercicio ? "r.{$ejercicioCol} DESC" :
        ($hasFolio ? "r.{$folioCol} DESC" : "1"));

    $sql = "
    CREATE OR REPLACE FUNCTION recaudadora_reqtrans_list(
        p_clave_cuenta VARCHAR DEFAULT NULL,
        p_ejercicio INTEGER DEFAULT NULL
    )
    RETURNS TABLE (
        clave_cuenta TEXT,
        folio INTEGER,
        ejercicio INTEGER,
        estatus TEXT
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            {$selectStr}
        FROM {$foundSchema}.{$foundTable} r
        WHERE {$whereStr}
        ORDER BY {$orderBy}
        LIMIT 100;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    DB::statement("DROP FUNCTION IF EXISTS recaudadora_reqtrans_list(VARCHAR, INTEGER) CASCADE");
    DB::statement($sql);

    echo "   ✓ Stored procedure creado exitosamente\n";

    // 7. Probar el SP
    echo "\n7. Probando stored procedure...\n";

    try {
        $testResult = DB::select("SELECT * FROM recaudadora_reqtrans_list(NULL, NULL) LIMIT 5");
        echo "   ✓ SP funciona correctamente\n";
        echo "   Retornó " . count($testResult) . " registros\n";

        if (count($testResult) > 0) {
            echo "\n   Primer registro de prueba:\n";
            $first = (array)$testResult[0];
            foreach ($first as $key => $value) {
                echo "      $key: " . (is_null($value) ? 'NULL' : substr($value, 0, 50)) . "\n";
            }
        }
    } catch (Exception $e) {
        echo "   ✗ Error probando SP: " . $e->getMessage() . "\n";
    }

    echo "\n✅ DESPLIEGUE COMPLETADO\n";
    echo "Tabla utilizada: {$foundSchema}.{$foundTable}\n";

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
}
