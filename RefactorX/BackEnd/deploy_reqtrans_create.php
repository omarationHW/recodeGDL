<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== CREANDO STORED PROCEDURE REQTRANS_CREATE ===\n\n";

try {
    // 1. Verificar el máximo cvereq actual
    echo "1. Verificando último cvereq en la tabla...\n";

    $maxCvereq = DB::selectOne("
        SELECT MAX(cvereq) as max_id
        FROM catastro_gdl.reqdiftransmision
    ");

    echo "   Último cvereq: " . ($maxCvereq->max_id ?: 0) . "\n";

    // 2. Verificar si existe secuencia
    echo "\n2. Verificando secuencias disponibles...\n";

    $sequences = DB::select("
        SELECT sequence_name
        FROM information_schema.sequences
        WHERE sequence_schema = 'catastro_gdl'
        AND sequence_name ILIKE '%req%'
        LIMIT 5
    ");

    if (count($sequences) > 0) {
        echo "   Secuencias encontradas:\n";
        foreach ($sequences as $seq) {
            echo "      - {$seq->sequence_name}\n";
        }
    } else {
        echo "   No se encontraron secuencias relacionadas\n";
    }

    // 3. Crear el SP CREATE
    echo "\n3. Creando stored procedure recaudadora_reqtrans_create...\n";

    $sql = <<<'SQL'
    CREATE OR REPLACE FUNCTION recaudadora_reqtrans_create(
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
        v_max_cvereq INTEGER;
    BEGIN
        -- Extraer datos del JSON
        v_clave_cuenta := p_registro->>'clave_cuenta';
        v_folio := COALESCE((p_registro->>'folio')::INTEGER, 0);
        v_ejercicio := COALESCE((p_registro->>'ejercicio')::INTEGER, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);
        v_estatus := p_registro->>'estatus';

        -- Validar datos requeridos
        IF v_clave_cuenta IS NULL OR v_clave_cuenta = '' THEN
            RETURN json_build_object(
                'success', false,
                'message', 'La cuenta es requerida'
            );
        END IF;

        -- Verificar si ya existe un registro con la misma cuenta y ejercicio
        SELECT COUNT(*) INTO v_max_cvereq
        FROM catastro_gdl.reqdiftransmision
        WHERE cvecuenta::TEXT = v_clave_cuenta
          AND axoreq = v_ejercicio;

        IF v_max_cvereq > 0 THEN
            RETURN json_build_object(
                'success', false,
                'message', 'Ya existe un requerimiento para esta cuenta en el año ' || v_ejercicio::TEXT
            );
        END IF;

        -- Generar nuevo cvereq (MAX + 1)
        SELECT COALESCE(MAX(cvereq), 0) + 1 INTO v_cvereq
        FROM catastro_gdl.reqdiftransmision;

        -- Convertir estatus a vigencia
        v_vigencia := CASE
            WHEN v_estatus = 'Activo' THEN '1'
            WHEN v_estatus = 'Inactivo' THEN '0'
            ELSE 'V'
        END;

        -- Insertar el nuevo registro
        INSERT INTO catastro_gdl.reqdiftransmision (
            cvereq,
            cvecuenta,
            foliotransm,
            axoreq,
            vigencia,
            folioreq
        ) VALUES (
            v_cvereq,
            v_clave_cuenta::INTEGER,
            v_folio,
            v_ejercicio,
            v_vigencia,
            v_cvereq  -- folioreq = cvereq por defecto
        );

        RETURN json_build_object(
            'success', true,
            'message', 'Registro creado correctamente',
            'cvereq', v_cvereq
        );

    EXCEPTION
        WHEN OTHERS THEN
            RETURN json_build_object(
                'success', false,
                'message', 'Error al crear el registro: ' || SQLERRM
            );
    END;
    $BODY$ LANGUAGE plpgsql;
SQL;

    DB::statement("DROP FUNCTION IF EXISTS recaudadora_reqtrans_create(JSON) CASCADE");
    DB::statement($sql);

    echo "   ✓ Stored procedure creado exitosamente\n";

    // 4. Probar el SP
    echo "\n4. Probando stored procedure...\n";

    // Generar una cuenta única para prueba
    $testCuenta = '999' . rand(100000, 999999);

    $testData = [
        'clave_cuenta' => $testCuenta,
        'folio' => 0,
        'ejercicio' => 2025,
        'estatus' => 'Pendiente'
    ];

    $testJson = json_encode($testData);

    echo "   Datos de prueba: " . $testJson . "\n";
    echo "   Ejecutando INSERT de prueba...\n";

    $result = DB::selectOne("SELECT recaudadora_reqtrans_create(?::json) as result", [$testJson]);

    $resultData = json_decode($result->result);
    echo "\n   Resultado:\n";
    echo "      - Success: " . ($resultData->success ? '✓ true' : '✗ false') . "\n";
    echo "      - Message: {$resultData->message}\n";

    if (isset($resultData->cvereq)) {
        echo "      - Cvereq generado: {$resultData->cvereq}\n";

        // Verificar que se insertó
        $inserted = DB::selectOne("
            SELECT cvereq, cvecuenta, foliotransm, axoreq, vigencia
            FROM catastro_gdl.reqdiftransmision
            WHERE cvereq = ?
        ", [$resultData->cvereq]);

        if ($inserted) {
            echo "\n   Verificación del registro insertado:\n";
            echo "      - cvereq: {$inserted->cvereq}\n";
            echo "      - cvecuenta: {$inserted->cvecuenta}\n";
            echo "      - foliotransm: {$inserted->foliotransm}\n";
            echo "      - axoreq: {$inserted->axoreq}\n";
            echo "      - vigencia: {$inserted->vigencia}\n";

            // Eliminar el registro de prueba
            echo "\n   Eliminando registro de prueba...\n";
            DB::delete("DELETE FROM catastro_gdl.reqdiftransmision WHERE cvereq = ?", [$resultData->cvereq]);
            echo "      ✓ Registro de prueba eliminado\n";
        }
    }

    // 5. Probar validación de duplicados
    echo "\n5. Probando validación de duplicados...\n";

    // Obtener un registro existente
    $existing = DB::selectOne("
        SELECT cvecuenta, axoreq
        FROM catastro_gdl.reqdiftransmision
        LIMIT 1
    ");

    if ($existing) {
        $duplicateData = [
            'clave_cuenta' => (string)$existing->cvecuenta,
            'folio' => 0,
            'ejercicio' => $existing->axoreq,
            'estatus' => 'Pendiente'
        ];

        $duplicateJson = json_encode($duplicateData);
        echo "   Intentando crear duplicado: {$duplicateJson}\n";

        $dupResult = DB::selectOne("SELECT recaudadora_reqtrans_create(?::json) as result", [$duplicateJson]);
        $dupData = json_decode($dupResult->result);

        echo "   Resultado:\n";
        echo "      - Success: " . ($dupData->success ? '✓ true' : '✗ false') . "\n";
        echo "      - Message: {$dupData->message}\n";
    }

    echo "\n✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "\nFunción creada: recaudadora_reqtrans_create(JSON)\n";
    echo "Parámetro: JSON con {clave_cuenta, folio, ejercicio, estatus}\n";
    echo "Retorna: JSON con {success: boolean, message: string, cvereq: integer}\n";

    echo "\n📝 EJEMPLO DE USO:\n";
    echo "SELECT recaudadora_reqtrans_create('{\"clave_cuenta\":\"12345\",\"folio\":100,\"ejercicio\":2025,\"estatus\":\"Activo\"}'::json);\n";

    echo "\n✅ VALIDACIONES IMPLEMENTADAS:\n";
    echo "   - Cuenta es requerida\n";
    echo "   - No permite duplicados (misma cuenta + año)\n";
    echo "   - Genera cvereq automáticamente (MAX + 1)\n";
    echo "   - Convierte estatus a vigencia\n";
    echo "   - Manejo de excepciones\n";

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
}
