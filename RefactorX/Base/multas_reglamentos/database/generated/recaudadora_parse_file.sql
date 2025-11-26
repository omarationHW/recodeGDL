-- ================================================================
-- SP: recaudadora_parse_file
-- Módulo: multas_reglamentos
-- Descripción: Parsea un archivo de texto con folios de empresas
-- Formato de archivo: delimitado por '|'
-- Campos esperados: clave_cuenta|folio|anio_folio
-- ================================================================

CREATE OR REPLACE FUNCTION recaudadora_parse_file(p_file_content TEXT)
RETURNS TABLE(
    clave_cuenta TEXT,
    folio INTEGER,
    anio_folio INTEGER,
    propietario TEXT,
    importe_pagado NUMERIC,
    notificacion TEXT,
    fecha_pago DATE
) AS $$
DECLARE
    v_line TEXT;
    v_parts TEXT[];
    v_clave_cuenta TEXT;
    v_folio INTEGER;
    v_anio_folio INTEGER;
    v_line_trimmed TEXT;
BEGIN
    -- Iterar sobre cada línea del archivo
    FOR v_line IN SELECT unnest(string_to_array(p_file_content, E'\n'))
    LOOP
        -- Limpiar la línea
        v_line_trimmed := trim(v_line);

        -- Saltar líneas vacías
        IF v_line_trimmed = '' THEN
            CONTINUE;
        END IF;

        -- Saltar líneas que parezcan ser código (contienen palabras clave de programación)
        IF v_line_trimmed ~* '(if|else|for|while|class|function|return|Object\.|ReferenceEquals|null)' THEN
            CONTINUE;
        END IF;

        -- Separar por delimitador '|'
        v_parts := string_to_array(v_line_trimmed, '|');

        -- Validar que tenga exactamente 3 campos
        IF array_length(v_parts, 1) = 3 THEN
            v_clave_cuenta := trim(v_parts[1]);

            -- Validar que clave_cuenta no esté vacía y no contenga código
            IF v_clave_cuenta = '' OR v_clave_cuenta ~* '(if|else|Object\.)' THEN
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

            -- Retornar el registro parseado
            -- Por ahora, retorna valores por defecto para algunos campos
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
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION recaudadora_parse_file(TEXT) IS
'Parsea archivo de texto con folios delimitados por | (formato: clave_cuenta|folio|anio_folio).
Filtra automáticamente líneas vacías, código y valores inválidos';
