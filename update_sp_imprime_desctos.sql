-- Actualización del Stored Procedure para ImprimeDesctos
-- Usa tabla publico.aut_desctosotorgados en lugar de crear nuevas tablas

DROP FUNCTION IF EXISTS publico.recaudadora_imprime_desctos(character varying, integer) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_imprime_desctos(
    p_clave_cuenta VARCHAR,
    p_ejercicio INTEGER
)
RETURNS TABLE (
    status VARCHAR,
    mensaje TEXT,
    folio_reporte VARCHAR,
    fecha_generacion DATE,
    total_descuentos INTEGER,
    monto_total NUMERIC,
    porcentaje_promedio NUMERIC,
    detalles_descuentos TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_folio VARCHAR;
    v_count INTEGER := 0;
    v_monto_total NUMERIC := 0;
    v_porcentaje_prom NUMERIC := 0;
    v_detalles TEXT := '';
    v_encontrado BOOLEAN := FALSE;
BEGIN
    -- Validar entrada
    IF p_clave_cuenta IS NULL OR p_clave_cuenta = '' THEN
        RETURN QUERY SELECT
            'error'::VARCHAR,
            'La clave de cuenta es obligatoria'::TEXT,
            NULL::VARCHAR,
            NULL::DATE,
            NULL::INTEGER,
            NULL::NUMERIC,
            NULL::NUMERIC,
            NULL::TEXT;
        RETURN;
    END IF;

    IF p_ejercicio IS NULL OR p_ejercicio = 0 THEN
        RETURN QUERY SELECT
            'error'::VARCHAR,
            'El ejercicio (año) es obligatorio'::TEXT,
            NULL::VARCHAR,
            NULL::DATE,
            NULL::INTEGER,
            NULL::NUMERIC,
            NULL::NUMERIC,
            NULL::TEXT;
        RETURN;
    END IF;

    -- Buscar descuentos otorgados para la clave de cuenta y ejercicio
    -- Buscamos por id_multa (que puede contener la clave de cuenta) y por axo (ejercicio)
    BEGIN
        SELECT
            COUNT(*)::INTEGER,
            COALESCE(SUM(COALESCE(d.monto_aut, 0)), 0),
            COALESCE(AVG(COALESCE(d.por_aut, 0)), 0)
        INTO v_count, v_monto_total, v_porcentaje_prom
        FROM publico.aut_desctosotorgados d
        WHERE (
            TRIM(d.id_multa) ILIKE '%' || p_clave_cuenta || '%'
            OR CAST(d.folio_descto AS TEXT) = p_clave_cuenta
        )
        AND (p_ejercicio = 0 OR d.axo = p_ejercicio);

        v_encontrado := (v_count > 0);

        -- Generar detalles de los descuentos encontrados
        IF v_encontrado THEN
            SELECT STRING_AGG(
                'Folio: ' || d.folio_descto ||
                ', Multa: ' || TRIM(d.id_multa) ||
                ', Año: ' || d.axo ||
                ', % Aut: ' || COALESCE(d.por_aut, 0) ||
                ', Monto: $' || COALESCE(d.monto_aut, 0) ||
                ', Vigencia: ' || COALESCE(d.vigencia, 'N/A'),
                E'\n'
            )
            INTO v_detalles
            FROM publico.aut_desctosotorgados d
            WHERE (
                TRIM(d.id_multa) ILIKE '%' || p_clave_cuenta || '%'
                OR CAST(d.folio_descto AS TEXT) = p_clave_cuenta
            )
            AND (p_ejercicio = 0 OR d.axo = p_ejercicio)
            LIMIT 10;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            v_encontrado := FALSE;
    END;

    -- Generar folio único sin usar secuencia
    v_folio := 'RDESC-' || p_ejercicio || '-' ||
               TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS') || '-' ||
               LPAD(FLOOR(RANDOM() * 9999)::TEXT, 4, '0');

    -- Si no se encontraron descuentos
    IF NOT v_encontrado OR v_count = 0 THEN
        RETURN QUERY SELECT
            'error'::VARCHAR,
            ('No se encontraron descuentos para la cuenta ' || p_clave_cuenta ||
             ' en el ejercicio ' || p_ejercicio)::TEXT,
            NULL::VARCHAR,
            NULL::DATE,
            0::INTEGER,
            0::NUMERIC,
            0::NUMERIC,
            NULL::TEXT;
        RETURN;
    END IF;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        'success'::VARCHAR,
        ('Reporte de descuentos generado exitosamente. Se encontraron ' ||
         v_count || ' descuento(s).')::TEXT,
        v_folio,
        CURRENT_DATE,
        v_count,
        v_monto_total,
        ROUND(v_porcentaje_prom, 2),
        v_detalles;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            'error'::VARCHAR,
            ('Error al generar reporte: ' || SQLERRM)::TEXT,
            NULL::VARCHAR,
            NULL::DATE,
            NULL::INTEGER,
            NULL::NUMERIC,
            NULL::NUMERIC,
            NULL::TEXT;
END;
$$;

-- Comentarios sobre el mapeo:
-- publico.aut_desctosotorgados.folio_descto -> Folio del descuento
-- publico.aut_desctosotorgados.id_multa -> Clave de cuenta buscada
-- publico.aut_desctosotorgados.axo -> Ejercicio (año)
-- publico.aut_desctosotorgados.por_aut -> Porcentaje autorizado
-- publico.aut_desctosotorgados.monto_aut -> Monto del descuento
-- publico.aut_desctosotorgados.adeudo -> Monto del adeudo original
-- publico.aut_desctosotorgados.vigencia -> Estado de vigencia (B=Baja, V=Vigente, C=Cancelado)

-- Campos retornados:
-- status: 'success' o 'error'
-- mensaje: Descripción del resultado
-- folio_reporte: Folio único del reporte (RDESC-YYYY-TIMESTAMP-RANDOM)
-- fecha_generacion: Fecha actual
-- total_descuentos: Cantidad de descuentos encontrados
-- monto_total: Suma de los montos autorizados
-- porcentaje_promedio: Promedio de porcentajes autorizados
-- detalles_descuentos: Texto con el detalle de cada descuento (máximo 10)
