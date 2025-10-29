-- Stored Procedure: sp_get_requerimientos_energia
-- Tipo: Report
-- Descripción: Obtiene los requerimientos de energía para un local
-- Generado para formulario: RptCaratulaEnergia
-- Fecha: 2025-08-27 00:46:24

CREATE OR REPLACE FUNCTION sp_get_requerimientos_energia(p_id_local INTEGER)
RETURNS TABLE (
    id_control INTEGER,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_gastos NUMERIC,
    fecha_emision DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_control,
        r.modulo,
        r.control_otr,
        r.folio,
        r.importe_global,
        r.importe_multa,
        r.importe_gastos,
        r.fecha_emision
    FROM ta_15_apremios r
    WHERE r.modulo = 33 AND r.control_otr = p_id_local;
END;
$$ LANGUAGE plpgsql;