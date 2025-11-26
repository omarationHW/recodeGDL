<?php
/**
 * Script para desplegar SP recaudadora_parse_file
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

    // Crear el SP recaudadora_parse_file
    echo "📝 Desplegando recaudadora_parse_file...\n";

    $sp = "
-- Stored Procedure: recaudadora_parse_file
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
BEGIN
    -- Iterar sobre cada línea del archivo
    FOR v_line IN SELECT unnest(string_to_array(p_file_content, E'\\n'))
    LOOP
        -- Saltar líneas vacías
        IF trim(v_line) = '' THEN
            CONTINUE;
        END IF;

        -- Separar por delimitador '|'
        v_parts := string_to_array(v_line, '|');

        -- Validar que tenga al menos 3 campos
        IF array_length(v_parts, 1) >= 3 THEN
            v_clave_cuenta := trim(v_parts[1]);

            BEGIN
                v_folio := CAST(trim(v_parts[2]) AS INTEGER);
                v_anio_folio := CAST(trim(v_parts[3]) AS INTEGER);
            EXCEPTION WHEN OTHERS THEN
                -- Si hay error en la conversión, usar valores por defecto
                v_folio := 0;
                v_anio_folio := 0;
            END;

            -- Retornar el registro parseado
            -- Por ahora, retornamos los datos del archivo y valores por defecto para el resto
            -- TODO: Buscar datos reales en las tablas reqpredial, ctaempexterna, etc.
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

COMMENT ON FUNCTION recaudadora_parse_file(TEXT) IS 'Parsea archivo de texto con folios delimitados por | y retorna array de folios con sus datos';
";

    $pdo->exec($sp);
    echo "✅ SP recaudadora_parse_file desplegado correctamente\n\n";

    // Verificar que el SP exista
    echo "🔍 Verificando SP desplegado...\n";
    $check = $pdo->query("
        SELECT routine_name, routine_schema
        FROM information_schema.routines
        WHERE routine_name = 'recaudadora_parse_file'
    ");

    $row = $check->fetch(PDO::FETCH_ASSOC);
    if ($row) {
        echo "  ✅ {$row['routine_name']} - Schema: {$row['routine_schema']}\n";
    }

    // Probar el SP con datos de ejemplo
    echo "\n🧪 Probando recaudadora_parse_file con archivo de ejemplo...\n";

    $testFile = "12345|100|2023\n67890|200|2024\n11111|300|2025";

    $stmt = $pdo->prepare("SELECT * FROM recaudadora_parse_file(?)");
    $stmt->execute([$testFile]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "✅ SP funciona correctamente. Folios parseados: " . count($results) . "\n";

    if (count($results) > 0) {
        echo "\n📋 Folios parseados:\n";
        foreach ($results as $idx => $row) {
            echo "  " . ($idx + 1) . ". Cuenta: {$row['clave_cuenta']}, Folio: {$row['folio']}, Año: {$row['anio_folio']}\n";
        }
    }

    echo "\n✅ ¡Despliegue completado exitosamente!\n";
    echo "\n📝 Nota: El SP actualmente retorna valores por defecto para algunos campos.\n";
    echo "   Para obtener datos reales, se necesita implementar la búsqueda en las tablas correspondientes.\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\n🔍 Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
