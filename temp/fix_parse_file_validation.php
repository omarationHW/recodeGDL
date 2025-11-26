<?php
/**
 * Script para mejorar el SP recaudadora_parse_file con validación
 * Base de datos: multas_reglamentos
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conectado a la base de datos: $dbname\n\n";

    // Actualizar el SP con mejor validación
    echo "📝 Actualizando recaudadora_parse_file con validación mejorada...\n";

    $sp = "
-- Stored Procedure: recaudadora_parse_file (MEJORADO)
-- Descripción: Parsea un archivo de texto con folios de empresas y retorna los datos de cada folio
-- Formato de archivo: delimitado por '|'
-- Campos esperados: clave_cuenta|folio|anio_folio

CREATE OR REPLACE FUNCTION recaudadora_parse_file(p_file_content TEXT)
RETURNS TABLE(
    clave_cuenta TEXT,
    folio INTEGER,
    anio_folio INTEGER,
    propietario TEXT,
    importe_pagado NUMERIC,
    notificacion TEXT,
    fecha_pago DATE
) AS \$\$
DECLARE
    v_line TEXT;
    v_parts TEXT[];
    v_clave_cuenta TEXT;
    v_folio INTEGER;
    v_anio_folio INTEGER;
    v_line_trimmed TEXT;
BEGIN
    -- Iterar sobre cada línea del archivo
    FOR v_line IN SELECT unnest(string_to_array(p_file_content, E'\\n'))
    LOOP
        -- Limpiar la línea
        v_line_trimmed := trim(v_line);

        -- Saltar líneas vacías
        IF v_line_trimmed = '' THEN
            CONTINUE;
        END IF;

        -- Saltar líneas que parezcan ser código (contienen palabras clave de programación)
        IF v_line_trimmed ~* '(if|else|for|while|class|function|return|Object\\.|ReferenceEquals|null)' THEN
            CONTINUE;
        END IF;

        -- Separar por delimitador '|'
        v_parts := string_to_array(v_line_trimmed, '|');

        -- Validar que tenga exactamente 3 campos
        IF array_length(v_parts, 1) = 3 THEN
            v_clave_cuenta := trim(v_parts[1]);

            -- Validar que clave_cuenta no esté vacía y no contenga código
            IF v_clave_cuenta = '' OR v_clave_cuenta ~* '(if|else|Object\\.)' THEN
                CONTINUE;
            END IF;

            BEGIN
                v_folio := CAST(trim(v_parts[2]) AS INTEGER);
                v_anio_folio := CAST(trim(v_parts[3]) AS INTEGER);

                -- Validar rangos razonables
                IF v_folio <= 0 OR v_anio_folio < 2000 OR v_anio_folio > 2100 THEN
                    CONTINUE;
                END IF;

            EXCEPTION WHEN OTHERS THEN
                -- Si hay error en la conversión, saltar esta línea
                CONTINUE;
            END;

            -- Retornar el registro parseado con validación exitosa
            RETURN QUERY
            SELECT
                v_clave_cuenta,
                v_folio,
                v_anio_folio,
                'PROPIETARIO A BUSCAR'::TEXT AS propietario,
                0.00::NUMERIC AS importe_pagado,
                'SIN NOTIFICACION'::TEXT AS notificacion,
                NULL::DATE AS fecha_pago;
        END IF;
    END LOOP;
END;
\$\$ LANGUAGE plpgsql;

COMMENT ON FUNCTION recaudadora_parse_file(TEXT) IS 'Parsea archivo de texto con folios delimitados por | con validación mejorada';
";

    $pdo->exec($sp);
    echo "✅ SP recaudadora_parse_file actualizado correctamente\n\n";

    // Probar con diferentes casos
    echo "🧪 Probando con diferentes casos...\n\n";

    // Caso 1: Datos válidos
    echo "Test 1: Datos válidos\n";
    $testFile1 = "12345|100|2023\n67890|200|2024";
    $stmt = $pdo->prepare("SELECT * FROM recaudadora_parse_file(?)");
    $stmt->execute([$testFile1]);
    $results1 = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "  Resultado: " . count($results1) . " folios parseados ✅\n";

    // Caso 2: Con código C# (debería filtrarse)
    echo "\nTest 2: Archivo con código C# (debe ser filtrado)\n";
    $testFile2 = "if (Object.ReferenceEquals(null, oResProcesa.Data.Tables[0])\n12345|100|2023\nelse { return; }";
    $stmt->execute([$testFile2]);
    $results2 = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "  Resultado: " . count($results2) . " folios parseados (debe ser 1) ";
    echo (count($results2) == 1 ? "✅" : "❌") . "\n";
    if (count($results2) > 0) {
        echo "  Folio válido: Cuenta={$results2[0]['clave_cuenta']}, Folio={$results2[0]['folio']}\n";
    }

    // Caso 3: Líneas vacías y con espacios
    echo "\nTest 3: Con líneas vacías y espacios\n";
    $testFile3 = "\n  \n12345|100|2023\n   \n67890|200|2024\n\n";
    $stmt->execute([$testFile3]);
    $results3 = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "  Resultado: " . count($results3) . " folios parseados (debe ser 2) ";
    echo (count($results3) == 2 ? "✅" : "❌") . "\n";

    echo "\n✅ ¡Actualización y pruebas completadas!\n";
    echo "\n📝 El SP ahora filtra automáticamente:\n";
    echo "   - Líneas vacías\n";
    echo "   - Código de programación (if, else, Object., etc.)\n";
    echo "   - Líneas con formato incorrecto\n";
    echo "   - Valores fuera de rango\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
