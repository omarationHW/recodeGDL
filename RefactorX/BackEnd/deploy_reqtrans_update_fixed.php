<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== CREANDO STORED PROCEDURE REQTRANS_UPDATE ===\n\n";

try {
    echo "1. Eliminando función anterior si existe...\n";
    DB::statement("DROP FUNCTION IF EXISTS recaudadora_reqtrans_update(JSON) CASCADE");
    echo "   ✓ Función eliminada\n\n";

    echo "2. Creando stored procedure recaudadora_reqtrans_update...\n";

    // Usar \$\$ para escapar los delimitadores en PostgreSQL
    $sql = <<<'SQL'
    CREATE OR REPLACE FUNCTION recaudadora_reqtrans_update(
        p_registro JSON
    )
    RETURNS JSON AS $BODY$
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
        v_folio := COALESCE((p_registro->>'folio')::INTEGER, 0);
        v_ejercicio := COALESCE((p_registro->>'ejercicio')::INTEGER, 0);
        v_estatus := p_registro->>'estatus';

        -- Obtener cvereq - buscar por cuenta y ejercicio
        BEGIN
            SELECT cvereq INTO v_cvereq
            FROM catastro_gdl.reqdiftransmision
            WHERE cvecuenta::TEXT = v_clave_cuenta
              AND axoreq = v_ejercicio
            LIMIT 1;
        EXCEPTION
            WHEN OTHERS THEN
                v_cvereq := NULL;
        END;

        -- Validar que se encontró el registro
        IF v_cvereq IS NULL THEN
            RETURN json_build_object(
                'success', false,
                'message', 'No se encontró el registro a actualizar. Cuenta: ' || v_clave_cuenta || ', Año: ' || v_ejercicio::TEXT
            );
        END IF;

        -- Convertir estatus a vigencia
        v_vigencia := CASE
            WHEN v_estatus = 'Activo' THEN '1'
            WHEN v_estatus = 'Inactivo' THEN '0'
            ELSE 'V'
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
    $BODY$ LANGUAGE plpgsql;
SQL;

    DB::statement($sql);

    echo "   ✓ Stored procedure creado exitosamente\n";

    // 3. Probar el SP con un registro existente
    echo "\n3. Probando stored procedure...\n";

    // Obtener un registro para actualizar
    $testRecord = DB::selectOne("
        SELECT cvereq, cvecuenta, foliotransm, axoreq, vigencia
        FROM catastro_gdl.reqdiftransmision
        WHERE cvecuenta IS NOT NULL AND axoreq IS NOT NULL
        LIMIT 1
    ");

    if ($testRecord) {
        echo "   Registro de prueba:\n";
        echo "      - cvereq: {$testRecord->cvereq}\n";
        echo "      - cvecuenta: {$testRecord->cvecuenta}\n";
        echo "      - foliotransm: " . ($testRecord->foliotransm ?: '0') . "\n";
        echo "      - axoreq: {$testRecord->axoreq}\n";
        echo "      - vigencia actual: " . ($testRecord->vigencia ?: 'NULL') . "\n";

        // Crear JSON de prueba (sin cambios reales, solo para probar)
        $testData = [
            'clave_cuenta' => (string)$testRecord->cvecuenta,
            'folio' => $testRecord->foliotransm ?: 0,
            'ejercicio' => $testRecord->axoreq,
            'estatus' => 'Pendiente'
        ];

        $testJson = json_encode($testData);

        echo "\n   Datos de prueba: " . $testJson . "\n";
        echo "   Ejecutando UPDATE de prueba...\n";

        $result = DB::selectOne("SELECT recaudadora_reqtrans_update(?::json) as result", [$testJson]);

        $resultData = json_decode($result->result);
        echo "\n   Resultado:\n";
        echo "      - Success: " . ($resultData->success ? '✓ true' : '✗ false') . "\n";
        echo "      - Message: {$resultData->message}\n";

        if (isset($resultData->rows_affected)) {
            echo "      - Rows Affected: {$resultData->rows_affected}\n";
        }
        if (isset($resultData->cvereq)) {
            echo "      - Cvereq: {$resultData->cvereq}\n";
        }
    } else {
        echo "   ⚠ No se encontraron registros para probar\n";
    }

    echo "\n✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "\nFunción creada: recaudadora_reqtrans_update(JSON)\n";
    echo "Parámetro: JSON con {clave_cuenta, folio, ejercicio, estatus}\n";
    echo "Retorna: JSON con {success: boolean, message: string}\n";

    echo "\n📝 EJEMPLO DE USO:\n";
    echo "SELECT recaudadora_reqtrans_update('{\"clave_cuenta\":\"11111\",\"folio\":100,\"ejercicio\":2025,\"estatus\":\"Activo\"}'::json);\n";

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
}
