-- Stored Procedure: get_contrato_by_numero_tipoaseo
-- Tipo: CRUD
-- Descripción: Obtiene el contrato por número y tipo de aseo.
-- Generado para formulario: Rep_AdeudCond
-- Fecha: 2025-08-27 15:05:40

CREATE OR REPLACE FUNCTION get_contrato_by_numero_tipoaseo(
    p_num_contrato integer,
    p_ctrol_aseo integer
)
RETURNS TABLE (
    control_contrato integer,
    num_contrato integer,
    ctrol_aseo integer,
    ctrol_recolec integer,
    costo_unidad numeric,
    aso_mes_oblig date
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec, b.costo_unidad, a.aso_mes_oblig
    FROM ta_16_contratos a
    JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
    WHERE a.num_contrato = p_num_contrato
      AND a.ctrol_aseo = p_ctrol_aseo;
END;
$$ LANGUAGE plpgsql;