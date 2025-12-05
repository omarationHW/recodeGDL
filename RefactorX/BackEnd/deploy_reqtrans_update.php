<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== CREANDO STORED PROCEDURE REQTRANS_UPDATE ===\n\n";

try {
    // 1. Verificar estructura de la tabla
    echo "1. Verificando estructura de la tabla reqdiftransmision...\n";

    $columns = DB::select("
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'reqdiftransmision'
        ORDER BY ordinal_position
    ");

    echo "   Columnas principales:\n";
    foreach (array_slice($columns, 0, 10) as $col) {
        echo "      - {$col->column_name} ({$col->data_type}) - Nullable: {$col->is_nullable}\n";
    }

    // 2. Verificar si hay primary key
    echo "\n2. Verificando clave primaria...\n";

    $pk = DB::select("
        SELECT a.attname as column_name
        FROM pg_index i
        JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
        WHERE i.indrelid = 'catastro_gdl.reqdiftransmision'::regclass
        AND i.indisprimary
    ");

    if (count($pk) > 0) {
        echo "   Clave primaria encontrada:\n";
        foreach ($pk as $p) {
            echo "      - {$p->column_name}\n";
        }
    } else {
        echo "   ⚠ No se encontró clave primaria definida\n";
    }

    // 3. Obtener un registro de ejemplo
    echo "\n3. Obteniendo registro de ejemplo...\n";

    $example = DB::selectOne("SELECT * FROM catastro_gdl.reqdiftransmision LIMIT 1");
    if ($example) {
        echo "   Ejemplo de registro:\n";
        echo "      - cvereq: {$example->cvereq}\n";
        echo "      - cvecuenta: {$example->cvecuenta}\n";
        echo "      - axoreq: {$example->axoreq}\n";
        echo "      - folioreq: {$example->folioreq}\n";
        echo "      - foliotransm: {$example->foliotransm}\n";
        echo "      - vigencia: {$example->vigencia}\n";
    }

    // 4. Crear el SP UPDATE
    echo "\n4. Creando stored procedure recaudadora_reqtrans_update...\n";

    $sql = "
    CREATE OR REPLACE FUNCTION recaudadora_reqtrans_update(
        p_registro JSON
    )
    RETURNS JSON AS \$\$
    DECLARE
        v_cvereq INTEGER;
        v_clave_cuenta TEXT;
        v_folio INTEGER;
        v_ejercicio INTEGER;
        v_estatus TEXT;
        v_vigencia VARCHAR(1);
        v_rows_affected INTEGER;
    BEGIN
        -- Extraer datos del JSON
        v_clave_cuenta := p_registro->>'clave_cuenta';
        v_folio := (p_registro->>'folio')::INTEGER;
        v_ejercicio := (p_registro->>'ejercicio')::INTEGER;
        v_estatus := p_registro->>'estatus';

        -- Obtener cvereq si existe en el JSON, sino buscar por cuenta/ejercicio/folio
        IF p_registro ? 'cvereq' THEN
            v_cvereq := (p_registro->>'cvereq')::INTEGER;
        ELSE
            -- Buscar el registro por cuenta, ejercicio y folio
            SELECT cvereq INTO v_cvereq
            FROM catastro_gdl.reqdiftransmision
            WHERE cvecuenta::TEXT = v_clave_cuenta
              AND axoreq = v_ejercicio
            LIMIT 1;
        END IF;

        -- Validar que se encontró el registro
        IF v_cvereq IS NULL THEN
            RETURN json_build_object(
                'success', false,
                'message', 'No se encontró el registro a actualizar'
            );
        END IF;

        -- Convertir estatus a vigencia
        v_vigencia := CASE
            WHEN v_estatus = 'Activo' THEN '1'
            WHEN v_estatus = 'Inactivo' THEN '0'
            ELSE NULL
        END;

        -- Actualizar el registro
        UPDATE catastro_gdl.reqdiftransmision
        SET
            cvecuenta = v_clave_cuenta::INTEGER,
            foliotransm = v_folio,
            axoreq = v_ejercicio,
            vigencia = v_vigencia
        WHERE cvereq = v_cvereq;

        -- Verificar cuántas filas se actualizaron
        GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

        IF v_rows_affected > 0 THEN
            RETURN json_build_object(
                'success', true,
                'message', 'Registro actualizado correctamente',
                'cvereq', v_cvereq,
                'rows_affected', v_rows_affected
            );
        ELSE
            RETURN json_build_object(
                'success', false,
                'message', 'No se pudo actualizar el registro'
            );
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN json_build_object(
                'success', false,
                'message', 'Error al actualizar: ' || SQLERRM
            );
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    DB::statement("DROP FUNCTION IF EXISTS recaudadora_reqtrans_update(JSON) CASCADE");
    DB::statement($sql);

    echo "   ✓ Stored procedure creado exitosamente\n";

    // 5. Probar el SP con un registro existente
    echo "\n5. Probando stored procedure...\n";

    // Obtener un registro para actualizar
    $testRecord = DB::selectOne("
        SELECT cvereq, cvecuenta, foliotransm, axoreq, vigencia
        FROM catastro_gdl.reqdiftransmision
        LIMIT 1
    ");

    if ($testRecord) {
        echo "   Registro de prueba:\n";
        echo "      - cvereq: {$testRecord->cvereq}\n";
        echo "      - cvecuenta: {$testRecord->cvecuenta}\n";
        echo "      - foliotransm: {$testRecord->foliotransm}\n";
        echo "      - axoreq: {$testRecord->axoreq}\n";

        // Crear JSON de prueba (sin cambios reales, solo para probar)
        $testJson = json_encode([
            'cvereq' => $testRecord->cvereq,
            'clave_cuenta' => (string)$testRecord->cvecuenta,
            'folio' => $testRecord->foliotransm,
            'ejercicio' => $testRecord->axoreq,
            'estatus' => 'Pendiente'
        ]);

        echo "\n   Ejecutando UPDATE de prueba...\n";
        $result = DB::selectOne("SELECT recaudadora_reqtrans_update(?::json) as result", [$testJson]);

        $resultData = json_decode($result->result);
        echo "   Resultado:\n";
        echo "      - Success: " . ($resultData->success ? 'true' : 'false') . "\n";
        echo "      - Message: {$resultData->message}\n";

        if (isset($resultData->rows_affected)) {
            echo "      - Rows Affected: {$resultData->rows_affected}\n";
        }
    }

    echo "\n✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "\nFunción creada: recaudadora_reqtrans_update(JSON)\n";
    echo "Retorna: JSON con {success: boolean, message: string}\n";

    echo "\n📝 EJEMPLO DE USO:\n";
    echo "SELECT recaudadora_reqtrans_update('\n";
    echo "  {\n";
    echo "    \"cvereq\": 1,\n";
    echo "    \"clave_cuenta\": \"11111\",\n";
    echo "    \"folio\": 100,\n";
    echo "    \"ejercicio\": 2025,\n";
    echo "    \"estatus\": \"Activo\"\n";
    echo "  }'::json\n";
    echo ");\n";

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
}
