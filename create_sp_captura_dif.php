<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== CREANDO STORED PROCEDURE recaudadora_captura_dif ===\n\n";

$sql = "
CREATE OR REPLACE FUNCTION public.recaudadora_captura_dif(
    p_datos TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_insertado INTEGER
)
LANGUAGE plpgsql AS \$\$
DECLARE
    v_json_data JSONB;
    v_axo INTEGER;
    v_cvecuenta INTEGER;
    v_monto NUMERIC;
    v_status VARCHAR(1);
    v_id INTEGER;
BEGIN
    -- Convertir el texto JSON a JSONB
    BEGIN
        v_json_data := p_datos::JSONB;
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'JSON inválido: ' || SQLERRM, NULL::INTEGER;
        RETURN;
    END;

    -- Extraer y validar campos requeridos
    v_axo := (v_json_data->>'axo')::INTEGER;
    v_cvecuenta := (v_json_data->>'cvecuenta')::INTEGER;
    v_monto := (v_json_data->>'monto')::NUMERIC;
    v_status := COALESCE(v_json_data->>'status', 'A');

    -- Validaciones
    IF v_axo IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El campo \"axo\" es requerido', NULL::INTEGER;
        RETURN;
    END IF;

    IF v_cvecuenta IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El campo \"cvecuenta\" es requerido', NULL::INTEGER;
        RETURN;
    END IF;

    IF v_monto IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El campo \"monto\" es requerido', NULL::INTEGER;
        RETURN;
    END IF;

    IF v_axo < 2000 OR v_axo > 2050 THEN
        RETURN QUERY SELECT FALSE, 'El año debe estar entre 2000 y 2050', NULL::INTEGER;
        RETURN;
    END IF;

    IF v_monto <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El monto debe ser mayor a cero', NULL::INTEGER;
        RETURN;
    END IF;

    IF v_status NOT IN ('A', 'I') THEN
        RETURN QUERY SELECT FALSE, 'El status debe ser \"A\" (Activo) o \"I\" (Inactivo)', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el registro
    BEGIN
        INSERT INTO public.diferencias_prediales (axo, cvecuenta, monto, status)
        VALUES (v_axo, v_cvecuenta, v_monto, v_status)
        RETURNING id INTO v_id;

        RETURN QUERY SELECT
            TRUE,
            'Diferencia guardada exitosamente. ID: ' || v_id::TEXT,
            v_id;
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            'Error al insertar: ' || SQLERRM,
            NULL::INTEGER;
    END;
END; \$\$;
";

try {
    $pdo->exec($sql);
    echo "✅ Stored Procedure 'recaudadora_captura_dif' creado exitosamente\n\n";

    // Verificar que el SP existe
    $check = $pdo->query("
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'public'
        AND routine_name = 'recaudadora_captura_dif'
    ")->fetch(PDO::FETCH_ASSOC);

    if ($check) {
        echo "✅ Verificación: SP existe en el esquema public\n";
        echo "   Nombre: {$check['routine_name']}\n";
        echo "   Tipo: {$check['routine_type']}\n\n";
    }

    // Pruebas del SP
    echo "=== PRUEBAS DEL STORED PROCEDURE ===\n\n";

    // Prueba 1: Inserción exitosa
    echo "Prueba 1: Inserción de diferencia válida\n";
    $json1 = json_encode([
        'axo' => 2025,
        'cvecuenta' => 999001,
        'monto' => 1500.75,
        'status' => 'A'
    ]);

    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
    $stmt->execute(['p_datos' => $json1]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "  Success: " . ($result['success'] ? 'Sí' : 'No') . "\n";
    echo "  Message: {$result['message']}\n\n";

    // Prueba 2: Sin campo requerido
    echo "Prueba 2: JSON sin campo requerido (cvecuenta)\n";
    $json2 = json_encode([
        'axo' => 2025,
        'monto' => 2000.00
    ]);

    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
    $stmt->execute(['p_datos' => $json2]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "  Success: " . ($result['success'] ? 'Sí' : 'No') . "\n";
    echo "  Message: {$result['message']}\n\n";

    // Prueba 3: Año fuera de rango
    echo "Prueba 3: Año fuera de rango\n";
    $json3 = json_encode([
        'axo' => 1999,
        'cvecuenta' => 999002,
        'monto' => 1000.00
    ]);

    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
    $stmt->execute(['p_datos' => $json3]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "  Success: " . ($result['success'] ? 'Sí' : 'No') . "\n";
    echo "  Message: {$result['message']}\n\n";

    // Prueba 4: Status por defecto
    echo "Prueba 4: Sin especificar status (debe usar 'A' por defecto)\n";
    $json4 = json_encode([
        'axo' => 2025,
        'cvecuenta' => 999003,
        'monto' => 750.25
    ]);

    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
    $stmt->execute(['p_datos' => $json4]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "  Success: " . ($result['success'] ? 'Sí' : 'No') . "\n";
    echo "  Message: {$result['message']}\n\n";

    // Prueba 5: JSON inválido
    echo "Prueba 5: JSON mal formado\n";
    $json5 = '{axo: 2025, cvecuenta: 999004}'; // JSON inválido

    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
    $stmt->execute(['p_datos' => $json5]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "  Success: " . ($result['success'] ? 'Sí' : 'No') . "\n";
    echo "  Message: {$result['message']}\n\n";

    echo "✅ Todas las pruebas completadas!\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
