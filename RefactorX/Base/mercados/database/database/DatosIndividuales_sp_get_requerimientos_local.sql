-- Stored Procedure: sp_get_requerimientos_local
-- Tipo: Catalog
-- Descripción: Obtiene los requerimientos de un local
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

DROP FUNCTION IF EXISTS sp_get_requerimientos_local(INTEGER);

CREATE OR REPLACE FUNCTION sp_get_requerimientos_local(p_id_local INTEGER)
RETURNS TABLE (
    id_control INTEGER,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia CHAR(1),
    importe_global NUMERIC(16,2),
    importe_multa NUMERIC(16,2),
    importe_recargo NUMERIC(16,2),
    importe_gastos NUMERIC(16,2),
    fecha_emision DATE,
    clave_practicado CHAR(1),
    vigencia CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id_control, r.modulo, r.control_otr, r.folio, r.diligencia, r.importe_global, r.importe_multa, r.importe_recargo, r.importe_gastos, r.fecha_emision, r.clave_practicado, r.vigencia
    FROM publico.ta_15_apremios r
    WHERE r.control_otr = p_id_local AND r.vigencia = '1' AND r.clave_practicado = 'P'
    ORDER BY r.fecha_emision, r.folio;
END;
$$ LANGUAGE plpgsql;