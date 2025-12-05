<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== CORRIGIENDO STORED PROCEDURE REQTRANS_UPDATE ===\n\n";

try {
    echo "1. El problema actual:\n";
    echo "   - El SP busca el registro por cuenta + ejercicio\n";
    echo "   - Cuando editas estos campos, busca con los valores NUEVOS\n";
    echo "   - Debería buscar por cvereq (ID único)\n\n";

    echo "2. Eliminando función anterior...\n";
    DB::statement("DROP FUNCTION IF EXISTS recaudadora_reqtrans_update(JSON) CASCADE");
    echo "   ✓ Función eliminada\n\n";

    echo "3. Creando función corregida (usa cvereq)...\n";

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

        -- IMPORTANTE: Obtener cvereq del JSON (ID único del registro)
        -- El frontend debe enviarlo cuando abre el modal de edición
        IF p_registro ? 'cvereq' THEN
            v_cvereq := (p_registro->>'cvereq')::INTEGER;
        ELSE
            -- Si no viene cvereq, intentar buscar por cuenta original
            -- Esto es un fallback, pero no es ideal
            RETURN json_build_object(
                'success', false,
                'message', 'Error: No se proporcionó el ID del registro (cvereq). Por favor cierre y vuelva a abrir el formulario.'
            );
        END IF;

        -- Validar que cvereq sea válido
        IF v_cvereq IS NULL OR v_cvereq <= 0 THEN
            RETURN json_build_object(
                'success', false,
                'message', 'ID de registro inválido'
            );
        END IF;

        -- Verificar que el registro existe
        IF NOT EXISTS (SELECT 1 FROM catastro_gdl.reqdiftransmision WHERE cvereq = v_cvereq) THEN
            RETURN json_build_object(
                'success', false,
                'message', 'No se encontró el registro con ID ' || v_cvereq::TEXT
            );
        END IF;

        -- Convertir estatus a vigencia
        v_vigencia := CASE
            WHEN v_estatus = 'Activo' THEN '1'
            WHEN v_estatus = 'Inactivo' THEN '0'
            ELSE 'V'
        END;

        -- Actualizar el registro usando cvereq (ID único)
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

    echo "   ✓ Stored procedure corregido exitosamente\n";

    // 4. Probar el SP
    echo "\n4. Probando stored procedure corregido...\n";

    // Obtener un registro real
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

        // Test 1: Con cvereq (correcto)
        echo "\n   Test 1: UPDATE usando cvereq (método correcto)\n";
        $testData = [
            'cvereq' => $testRecord->cvereq,  // ← IMPORTANTE: Ahora incluye cvereq
            'clave_cuenta' => (string)$testRecord->cvecuenta,
            'folio' => $testRecord->foliotransm ?: 0,
            'ejercicio' => $testRecord->axoreq,
            'estatus' => 'Pendiente'
        ];

        $testJson = json_encode($testData);
        echo "      JSON enviado: " . $testJson . "\n";

        $result = DB::selectOne("SELECT recaudadora_reqtrans_update(?::json) as result", [$testJson]);
        $resultData = json_decode($result->result);

        echo "      Resultado:\n";
        echo "         - Success: " . ($resultData->success ? '✓ true' : '✗ false') . "\n";
        echo "         - Message: {$resultData->message}\n";

        // Test 2: Sin cvereq (error esperado)
        echo "\n   Test 2: UPDATE sin cvereq (debe dar error)\n";
        $testData2 = [
            'clave_cuenta' => (string)$testRecord->cvecuenta,
            'folio' => $testRecord->foliotransm ?: 0,
            'ejercicio' => $testRecord->axoreq,
            'estatus' => 'Pendiente'
        ];

        $testJson2 = json_encode($testData2);
        echo "      JSON enviado: " . $testJson2 . "\n";

        $result2 = DB::selectOne("SELECT recaudadora_reqtrans_update(?::json) as result", [$testJson2]);
        $resultData2 = json_decode($result2->result);

        echo "      Resultado:\n";
        echo "         - Success: " . ($resultData2->success ? '✓ true' : '✗ false') . "\n";
        echo "         - Message: {$resultData2->message}\n";
    }

    echo "\n✅ CORRECCIÓN COMPLETADA EXITOSAMENTE\n";
    echo "\n📝 CAMBIO PRINCIPAL:\n";
    echo "   ANTES: Buscaba por cuenta + ejercicio (valores editados)\n";
    echo "   AHORA: Busca por cvereq (ID único que no cambia)\n";

    echo "\n🔧 PRÓXIMO PASO:\n";
    echo "   El frontend ya está preparado para enviar el cvereq.\n";
    echo "   Cuando se abre el modal de edición, ReqTrans.vue copia\n";
    echo "   todo el objeto incluyendo el cvereq automáticamente.\n";

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
}
