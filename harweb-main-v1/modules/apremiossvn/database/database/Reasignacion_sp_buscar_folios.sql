-- Stored Procedure: sp_buscar_folios
-- Tipo: Report
-- Descripción: Busca folios por zona, módulo y rango de folios, solo los que tienen ejecutor asignado.
-- Generado para formulario: Reasignacion
-- Fecha: 2025-08-27 14:23:03

CREATE OR REPLACE FUNCTION sp_buscar_folios(
    p_zona INTEGER,
    p_modulo INTEGER,
    p_folio1 INTEGER,
    p_folio2 INTEGER,
    p_vigencia VARCHAR
) RETURNS TABLE (
    id_control INTEGER,
    zona INTEGER,
    modulo INTEGER,
    control_otr INTEGER,
    folio INTEGER,
    ejecutor INTEGER,
    fecha_entrega1 DATE,
    fecha_pago DATE,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    fecha_actualiz DATE,
    usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_control, zona, modulo, control_otr, folio, ejecutor, fecha_entrega1, fecha_pago, importe_global, importe_multa, importe_recargo, importe_gastos, fecha_actualiz, usuario
    FROM ta_15_apremios
    WHERE zona = p_zona AND modulo = p_modulo AND folio >= p_folio1 AND folio <= p_folio2 AND vigencia = p_vigencia AND ejecutor > 0;
END;
$$ LANGUAGE plpgsql;