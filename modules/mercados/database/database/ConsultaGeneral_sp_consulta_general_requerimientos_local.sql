-- Stored Procedure: sp_consulta_general_requerimientos_local
-- Tipo: CRUD
-- Descripción: Obtiene requerimientos de un local
-- Generado para formulario: ConsultaGeneral
-- Fecha: 2025-08-27 20:45:14

CREATE OR REPLACE FUNCTION sp_consulta_general_requerimientos_local(
    p_id_local integer
) RETURNS TABLE(
    folio integer,
    fecha_emision date,
    importe_multa numeric,
    importe_gastos numeric,
    vigencia varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.folio, r.fecha_emision, r.importe_multa, r.importe_gastos, r.vigencia
    FROM ta_15_apremios r
    WHERE r.control_otr = p_id_local
    ORDER BY r.folio;
END;
$$ LANGUAGE plpgsql;