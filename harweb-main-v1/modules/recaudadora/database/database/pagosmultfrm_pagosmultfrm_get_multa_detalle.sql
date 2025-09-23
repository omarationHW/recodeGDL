-- Stored Procedure: pagosmultfrm_get_multa_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de una multa, incluyendo campos calculados de estatus y descuento.
-- Generado para formulario: pagosmultfrm
-- Fecha: 2025-08-27 14:09:11

CREATE OR REPLACE FUNCTION pagosmultfrm_get_multa_detalle(
    p_id_multa INTEGER
)
RETURNS TABLE (
    id_multa INTEGER,
    axo_acta SMALLINT,
    num_acta INTEGER,
    fecha_acta DATE,
    fecha_recepcion DATE,
    fecha_cancelacion DATE,
    contribuyente TEXT,
    domicilio TEXT,
    recaud SMALLINT,
    zona SMALLINT,
    subzona SMALLINT,
    num_licencia INTEGER,
    giro TEXT,
    expediente TEXT,
    num_lote INTEGER,
    num_remesa INTEGER,
    calificacion NUMERIC,
    multa NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    cvepago INTEGER,
    capturista TEXT,
    user_baja TEXT,
    observacion TEXT,
    descuento NUMERIC,
    estatus TEXT,
    dependencia TEXT,
    ley TEXT,
    infraccion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id_multa,
        m.axo_acta,
        m.num_acta,
        m.fecha_acta,
        m.fecha_recepcion,
        m.fecha_cancelacion,
        m.contribuyente,
        m.domicilio,
        m.recaud,
        m.zona,
        m.subzona,
        m.num_licencia,
        m.giro,
        m.expediente,
        m.num_lote,
        m.num_remesa,
        m.calificacion,
        m.multa,
        m.gastos,
        m.total,
        m.cvepago,
        m.capturista,
        m.user_baja,
        m.observacion,
        (m.calificacion - m.multa) AS descuento,
        CASE 
            WHEN m.fecha_cancelacion IS NOT NULL AND m.fecha_cancelacion > '1900-01-01' THEN 'CANCELADO'
            WHEN m.cvepago > 0 THEN 'PAGADO'
            ELSE 'VIGENTE'
        END AS estatus,
        d.descripcion AS dependencia,
        l.descripcion AS ley,
        i.descripcion AS infraccion
    FROM multas m
    LEFT JOIN c_dependencias d ON m.id_dependencia = d.id_dependencia
    LEFT JOIN c_leyes l ON m.id_dependencia = l.id_dependencia AND m.id_ley = l.id_ley
    LEFT JOIN c_infracciones i ON m.id_dependencia = i.id_dependencia AND m.id_infraccion = i.id_infraccion
    WHERE m.id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;