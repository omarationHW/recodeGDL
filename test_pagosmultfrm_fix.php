<?php
// Script para crear recaudadora_pagosmultfrm con procesamiento de pagos múltiples

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Eliminar función existente si existe
    echo "1. Eliminando función existente si existe...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_pagosmultfrm(TEXT) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Recrear tabla de pagos múltiples (si no existe)
    echo "2. Recreando tabla publico.pagos_multiples...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.pagos_multiples CASCADE");

    $sql = "
    CREATE TABLE publico.pagos_multiples (
        id_pago SERIAL PRIMARY KEY,
        cuenta VARCHAR(50) NOT NULL,
        folio VARCHAR(50) NOT NULL,
        importe NUMERIC(12,2) NOT NULL,
        fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        estado VARCHAR(20) DEFAULT 'PROCESADO',
        usuario VARCHAR(100),
        observaciones TEXT
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla recreada exitosamente.\n\n";

    // 3. Insertar algunos registros de ejemplo
    echo "3. Insertando 10 registros de ejemplo...\n";
    $stmt = $pdo->prepare("
        INSERT INTO publico.pagos_multiples (cuenta, folio, importe, estado, usuario)
        VALUES (?, ?, ?, ?, ?)
    ");

    for ($i = 1; $i <= 10; $i++) {
        $stmt->execute([
            "CTA-MULT-" . str_pad($i, 3, '0', STR_PAD_LEFT),
            "FOL-" . str_pad($i * 100, 5, '0', STR_PAD_LEFT),
            1000.00 + ($i * 250.50),
            'PROCESADO',
            'SISTEMA'
        ]);
    }
    echo "   ✓ 10 registros de ejemplo insertados.\n\n";

    // 4. Crear el stored procedure
    echo "4. Creando stored procedure publico.recaudadora_pagosmultfrm...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_pagosmultfrm(
        p_registros TEXT
    )
    RETURNS TABLE (
        success BOOLEAN,
        mensaje TEXT,
        procesados INTEGER,
        errores INTEGER,
        detalles JSON
    )
    LANGUAGE plpgsql
    AS \$\$
    DECLARE
        v_registros JSON;
        v_registro JSON;
        v_cuenta VARCHAR;
        v_folio VARCHAR;
        v_importe NUMERIC;
        v_procesados INTEGER := 0;
        v_errores INTEGER := 0;
        v_detalles JSON[] := ARRAY[]::JSON[];
        v_detalle JSON;
    BEGIN
        -- Validar que se haya proporcionado el parámetro
        IF p_registros IS NULL OR p_registros = '' THEN
            RETURN QUERY SELECT
                false,
                'Error: No se proporcionaron registros para procesar'::TEXT,
                0,
                0,
                '[]'::JSON;
            RETURN;
        END IF;

        -- Intentar parsear el JSON
        BEGIN
            v_registros := p_registros::JSON;
        EXCEPTION WHEN OTHERS THEN
            RETURN QUERY SELECT
                false,
                'Error: El formato JSON no es válido'::TEXT,
                0,
                0,
                '[]'::JSON;
            RETURN;
        END;

        -- Procesar cada registro del array JSON
        FOR v_registro IN SELECT * FROM json_array_elements(v_registros)
        LOOP
            BEGIN
                -- Extraer campos del registro
                v_cuenta := v_registro->>'cuenta';
                v_folio := v_registro->>'folio';
                v_importe := (v_registro->>'importe')::NUMERIC;

                -- Validaciones básicas
                IF v_cuenta IS NULL OR v_cuenta = '' THEN
                    v_errores := v_errores + 1;
                    v_detalle := json_build_object(
                        'status', 'error',
                        'cuenta', v_cuenta,
                        'folio', v_folio,
                        'importe', v_importe,
                        'mensaje', 'La cuenta es requerida'
                    );
                    v_detalles := array_append(v_detalles, v_detalle);
                    CONTINUE;
                END IF;

                IF v_folio IS NULL OR v_folio = '' THEN
                    v_errores := v_errores + 1;
                    v_detalle := json_build_object(
                        'status', 'error',
                        'cuenta', v_cuenta,
                        'folio', v_folio,
                        'importe', v_importe,
                        'mensaje', 'El folio es requerido'
                    );
                    v_detalles := array_append(v_detalles, v_detalle);
                    CONTINUE;
                END IF;

                IF v_importe IS NULL OR v_importe <= 0 THEN
                    v_errores := v_errores + 1;
                    v_detalle := json_build_object(
                        'status', 'error',
                        'cuenta', v_cuenta,
                        'folio', v_folio,
                        'importe', v_importe,
                        'mensaje', 'El importe debe ser mayor a cero'
                    );
                    v_detalles := array_append(v_detalles, v_detalle);
                    CONTINUE;
                END IF;

                -- Insertar el pago en la tabla
                INSERT INTO publico.pagos_multiples (cuenta, folio, importe, estado, usuario)
                VALUES (v_cuenta, v_folio, v_importe, 'PROCESADO', 'SISTEMA');

                v_procesados := v_procesados + 1;
                v_detalle := json_build_object(
                    'status', 'success',
                    'cuenta', v_cuenta,
                    'folio', v_folio,
                    'importe', v_importe,
                    'mensaje', 'Pago aplicado correctamente'
                );
                v_detalles := array_append(v_detalles, v_detalle);

            EXCEPTION WHEN OTHERS THEN
                v_errores := v_errores + 1;
                v_detalle := json_build_object(
                    'status', 'error',
                    'cuenta', v_cuenta,
                    'folio', v_folio,
                    'importe', v_importe,
                    'mensaje', 'Error al procesar: ' || SQLERRM
                );
                v_detalles := array_append(v_detalles, v_detalle);
            END;
        END LOOP;

        -- Retornar el resumen de la operación
        RETURN QUERY SELECT
            (v_errores = 0),
            CASE
                WHEN v_errores = 0 THEN format('Se procesaron correctamente %s pagos', v_procesados)
                WHEN v_procesados = 0 THEN format('No se procesó ningún pago. %s errores encontrados', v_errores)
                ELSE format('Se procesaron %s pagos. %s con errores', v_procesados, v_errores)
            END::TEXT,
            v_procesados,
            v_errores,
            array_to_json(v_detalles)::JSON;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 5. Probar el SP con varios ejemplos
    echo "5. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Prueba 1: Procesar 3 pagos válidos',
            'json' => json_encode([
                ['cuenta' => 'TEST-001', 'folio' => 'FOL-001', 'importe' => 1500.00],
                ['cuenta' => 'TEST-002', 'folio' => 'FOL-002', 'importe' => 2000.00],
                ['cuenta' => 'TEST-003', 'folio' => 'FOL-003', 'importe' => 2500.00]
            ])
        ],
        [
            'nombre' => 'Prueba 2: Procesar con 1 error (importe cero)',
            'json' => json_encode([
                ['cuenta' => 'TEST-004', 'folio' => 'FOL-004', 'importe' => 1000.00],
                ['cuenta' => 'TEST-005', 'folio' => 'FOL-005', 'importe' => 0],
                ['cuenta' => 'TEST-006', 'folio' => 'FOL-006', 'importe' => 3000.00]
            ])
        ],
        [
            'nombre' => 'Prueba 3: Procesar con error (cuenta vacía)',
            'json' => json_encode([
                ['cuenta' => '', 'folio' => 'FOL-007', 'importe' => 1500.00],
                ['cuenta' => 'TEST-007', 'folio' => 'FOL-007', 'importe' => 1800.00]
            ])
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagosmultfrm(?)");
        $stmt->execute([$test['json']]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "   Success: " . ($result['success'] ? 'true' : 'false') . "\n";
        echo "   Mensaje: " . $result['mensaje'] . "\n";
        echo "   Procesados: " . $result['procesados'] . "\n";
        echo "   Errores: " . $result['errores'] . "\n";

        $detalles = json_decode($result['detalles'], true);
        if (!empty($detalles)) {
            echo "   Detalles:\n";
            foreach ($detalles as $detalle) {
                echo "      - [" . strtoupper($detalle['status']) . "] Cuenta: " . $detalle['cuenta'] .
                     ", Folio: " . $detalle['folio'] .
                     ", Importe: $" . number_format($detalle['importe'], 2) .
                     " => " . $detalle['mensaje'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla pagos_multiples creada\n";
    echo "   - SP recaudadora_pagosmultfrm creado\n";
    echo "   - Acepta JSON con array de pagos: [{cuenta, folio, importe}]\n";
    echo "   - Valida cada registro antes de procesarlo\n";
    echo "   - Retorna resumen detallado de la operación\n";
    echo "   - Incluye detalles individuales de cada pago (éxito o error)\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
