-- Stored Procedure: sp_get_requerimientos_local
-- Tipo: Catalog
-- Descripción: Obtiene los requerimientos de un local
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

CREATE OR REPLACE FUNCTION sp_get_requerimientos_local(p_id_local INTEGER)
RETURNS TABLE (
    id_control INTEGER,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR(1),
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    fecha_emision DATE,
    clave_practicado VARCHAR(1),
    vigencia VARCHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id_control, r.modulo, r.control_otr, r.folio, r.diligencia, r.importe_global, r.importe_multa, r.importe_recargo, r.importe_gastos, r.fecha_emision, r.clave_practicado, r.vigencia
    FROM ta_15_apremios r
    WHERE r.control_otr = p_id_local AND r.vigencia = '1' AND r.clave_practicado = 'P'
    ORDER BY r.fecha_emision, r.folio;
END;
$$ LANGUAGE plpgsql;