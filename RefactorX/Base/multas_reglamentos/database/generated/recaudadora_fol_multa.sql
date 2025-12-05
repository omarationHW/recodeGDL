-- ================================================================
-- SP: recaudadora_fol_multa
-- Módulo: multas_reglamentos
-- Descripción: Consulta/genera folio de multa por número de acta y año
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-01
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_fol_multa(VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_fol_multa(
    p_clave_cuenta VARCHAR,
    p_ejercicio INTEGER
)
RETURNS TABLE (
    folio INTEGER,
    id_control INTEGER,
    axo_acta INTEGER,
    numero_acta INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    actividad_giro VARCHAR,
    importe_inicial NUMERIC,
    importe_pagar NUMERIC,
    vigencia CHAR,
    fecha_recepcion DATE,
    fecha_alta DATE,
    fecha_pago DATE,
    numero_licencia INTEGER,
    sector CHAR,
    numero_zona SMALLINT,
    sub_zona SMALLINT,
    recaudadora SMALLINT,
    operacion INTEGER,
    importe_pago NUMERIC,
    estado VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Buscar multa por número de acta y año
    -- p_clave_cuenta se interpreta como numero_acta
    -- p_ejercicio es el año del acta

    RETURN QUERY
    SELECT
        m.id_control AS folio,
        m.id_control,
        m.axo_acta,
        m.numero_acta,
        m.nombre,
        m.domicilio,
        m.actividad_giro,
        m.importe_inicial,
        m.importe_pagar,
        m.vigencia,
        m.fecha_recepcion,
        m.fecha_alta,
        m.fecha_pago,
        m.numero_licencia,
        m.sector,
        m.numero_zona,
        m.sub_zona,
        m.recaudadora,
        m.operacion,
        m.importe_pago,
        CASE
            WHEN m.fecha_pago IS NOT NULL THEN 'PAGADO'::VARCHAR
            WHEN m.fecha_baja IS NOT NULL THEN 'CANCELADO'::VARCHAR
            WHEN m.vigencia = 'A' THEN 'ACTIVO'::VARCHAR
            WHEN m.vigencia = 'P' THEN 'PENDIENTE'::VARCHAR
            ELSE 'DESCONOCIDO'::VARCHAR
        END AS estado
    FROM db_ingresos.ta_08_multas m
    WHERE m.numero_acta = CAST(p_clave_cuenta AS INTEGER)
      AND m.axo_acta = p_ejercicio
    ORDER BY m.id_control DESC
    LIMIT 1;

    -- Si no se encuentra, devolver mensaje
    IF NOT FOUND THEN
        RAISE NOTICE 'No se encontró multa con acta % del año %', p_clave_cuenta, p_ejercicio;
    END IF;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_fol_multa(VARCHAR, INTEGER) IS
'Consulta folio de multa por número de acta y año. Retorna información completa de la multa incluyendo folio (id_control), datos del contribuyente, importes y estado.';
