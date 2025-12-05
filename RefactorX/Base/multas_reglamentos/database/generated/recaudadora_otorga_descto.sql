-- ================================================================
-- SP: recaudadora_otorga_descto
-- Módulo: multas_reglamentos
-- Descripción: Consulta de descuentos otorgados en multas con paginación
-- Tabla principal: comun.h_descmultampal (101,794 registros)
-- Join: comun.multas
-- ================================================================
-- Parámetros:
--   p_clave_cuenta (VARCHAR): Clave de pago (cvepago) para filtrar
--   p_ejercicio (INTEGER): Año (ejercicio) para filtrar
--   p_offset (INTEGER): Offset para paginación (default: 0)
--   p_limit (INTEGER): Límite de registros por página (default: 10)
-- ================================================================
-- Retorna:
--   id_multa: ID de la multa
--   folio: Número de acta
--   anio: Año del acta
--   contribuyente: Nombre del contribuyente
--   domicilio: Domicilio
--   monto_multa: Total de la multa
--   tipo_descto: Tipo de descuento (P=Porcentaje, M=Monto)
--   porcentaje_descto: Porcentaje del descuento
--   importe_descto: Importe del descuento (calculado)
--   fecha_captura: Fecha de captura del descuento
--   capturista: Usuario que capturó
--   observacion: Observaciones
--   autoriza: ID de quien autorizó
--   estado: Estado del descuento (V=Vigente, P=Pagado, C=Cancelado)
--   total_registros: Total de registros que cumplen los criterios
-- ================================================================

CREATE OR REPLACE FUNCTION comun.recaudadora_otorga_descto(
    p_clave_cuenta VARCHAR DEFAULT '',
    p_ejercicio INTEGER DEFAULT 0,
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    id_multa INTEGER,
    folio INTEGER,
    anio INTEGER,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    monto_multa NUMERIC,
    tipo_descto VARCHAR,
    porcentaje_descto NUMERIC,
    importe_descto NUMERIC,
    fecha_captura DATE,
    capturista VARCHAR,
    observacion TEXT,
    autoriza SMALLINT,
    estado VARCHAR,
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total BIGINT;
BEGIN
    -- Calcular el total de registros que cumplen los criterios
    SELECT COUNT(*) INTO v_total
    FROM comun.h_descmultampal d
    INNER JOIN comun.multas m ON d.id_multa = m.id_multa
    WHERE
        (p_clave_cuenta = '' OR d.cvepago::VARCHAR = p_clave_cuenta)
        AND (p_ejercicio = 0 OR EXTRACT(YEAR FROM m.fecha_acta) = p_ejercicio);

    -- Retornar los registros paginados
    RETURN QUERY
    SELECT
        d.id_multa,
        m.num_acta AS folio,
        m.axo_acta::INTEGER AS anio,
        COALESCE(m.contribuyente, 'N/A') AS contribuyente,
        COALESCE(m.domicilio, 'N/A') AS domicilio,
        COALESCE(m.total, 0.00) AS monto_multa,
        CAST(CASE
            WHEN d.tipo_descto = 'P' THEN 'Porcentaje'
            WHEN d.tipo_descto = 'M' THEN 'Monto'
            ELSE d.tipo_descto
        END AS VARCHAR) AS tipo_descto,
        COALESCE(d.valor, 0.00) AS porcentaje_descto,
        COALESCE((m.total * d.valor / 100), 0.00) AS importe_descto,
        d.feccap AS fecha_captura,
        CAST(COALESCE(d.capturista, 'N/A') AS VARCHAR) AS capturista,
        COALESCE(d.observacion, '') AS observacion,
        d.autoriza,
        CAST(CASE
            WHEN d.estado = 'V' THEN 'Vigente'
            WHEN d.estado = 'P' THEN 'Pagado'
            WHEN d.estado = 'C' THEN 'Cancelado'
            ELSE 'Desconocido'
        END AS VARCHAR) AS estado,
        v_total AS total_registros
    FROM comun.h_descmultampal d
    INNER JOIN comun.multas m ON d.id_multa = m.id_multa
    WHERE
        (p_clave_cuenta = '' OR d.cvepago::VARCHAR = p_clave_cuenta)
        AND (p_ejercicio = 0 OR EXTRACT(YEAR FROM m.fecha_acta) = p_ejercicio)
    ORDER BY d.feccap DESC, d.id_multa DESC
    OFFSET p_offset
    LIMIT p_limit;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION comun.recaudadora_otorga_descto IS 'Consulta de descuentos otorgados en multas con filtros por cuenta y ejercicio, con paginación';
