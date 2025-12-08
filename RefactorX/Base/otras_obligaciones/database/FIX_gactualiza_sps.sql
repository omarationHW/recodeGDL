-- FIX: Corregir SPs de GActualiza para usar tablas reales
-- Fecha: 2025-12-04
-- Problema: Los SPs referenciaban tablas inexistentes (t34_multas, t34_suspension)
-- Solución: Usar tablas reales (t34_descmul, t34_suspensiones)

-- Corregir sp_gactualiza_multas_get para usar tabla correcta (t34_descmul = descuentos de multas)
DROP FUNCTION IF EXISTS sp_gactualiza_multas_get(integer);

CREATE OR REPLACE FUNCTION sp_gactualiza_multas_get(p_id_34_datos integer)
RETURNS TABLE (
    id_multa integer,
    id_34_datos integer,
    fecha_multa date,
    monto numeric,
    descripcion varchar,
    pagado boolean
) AS $func$
BEGIN
    -- t34_descmul contiene descuentos/multas, id_contrato = id_34_datos
    RETURN QUERY
    SELECT
        m.id_descto::integer AS id_multa,
        m.id_contrato::integer AS id_34_datos,
        COALESCE(m.fecha_alta::date, CURRENT_DATE) AS fecha_multa,
        COALESCE(m.porcentaje::numeric, 0) AS monto,
        COALESCE('Descuento ' || m.porcentaje || '%', '')::varchar AS descripcion,
        CASE WHEN m.vigencia = 'P' THEN true ELSE false END AS pagado
    FROM t34_descmul m
    WHERE m.id_contrato = p_id_34_datos
    ORDER BY m.fecha_alta DESC;
END;
$func$ LANGUAGE plpgsql;

-- Corregir sp_gactualiza_suspension_get para usar tabla correcta (t34_suspensiones)
DROP FUNCTION IF EXISTS sp_gactualiza_suspension_get(integer);

CREATE OR REPLACE FUNCTION sp_gactualiza_suspension_get(p_id_34_datos integer)
RETURNS TABLE (
    id_suspension integer,
    id_34_datos integer,
    fecha_suspension date,
    motivo varchar,
    activa boolean
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        s.id_suspension::integer,
        s.id_contrato::integer AS id_34_datos,
        COALESCE(s.fecha_suspension, s.fecha_alta)::date AS fecha_suspension,
        COALESCE(s.descripcion, '')::varchar AS motivo,
        CASE WHEN s.estado = 'S' THEN true ELSE false END AS activa
    FROM t34_suspensiones s
    WHERE s.id_contrato = p_id_34_datos
    ORDER BY s.fecha_suspension DESC;
END;
$func$ LANGUAGE plpgsql;
