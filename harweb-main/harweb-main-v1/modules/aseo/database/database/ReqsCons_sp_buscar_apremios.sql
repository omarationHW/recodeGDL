-- Stored Procedure: sp_buscar_apremios
-- Tipo: CRUD
-- Descripción: Busca los apremios de un contrato.
-- Generado para formulario: ReqsCons
-- Fecha: 2025-08-27 20:45:14

CREATE OR REPLACE FUNCTION sp_buscar_apremios(p_control_contrato INTEGER)
RETURNS TABLE(id_control INTEGER, folio INTEGER, importe_multa NUMERIC, importe_recargo NUMERIC, importe_gastos NUMERIC, fecha_emision DATE, fecha_practicado DATE, vigencia VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_control, folio, importe_multa, importe_recargo, importe_gastos, fecha_emision, fecha_practicado, vigencia FROM ta_15_apremios WHERE modulo = 16 AND control_otr = p_control_contrato AND vigencia = '1' AND clave_practicado = 'P' ORDER BY folio;
END;
$$ LANGUAGE plpgsql;