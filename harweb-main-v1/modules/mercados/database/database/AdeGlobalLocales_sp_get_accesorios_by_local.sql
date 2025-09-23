-- Stored Procedure: sp_get_accesorios_by_local
-- Tipo: Report
-- Descripción: Obtiene los accesorios (multas/gastos) de un local
-- Generado para formulario: AdeGlobalLocales
-- Fecha: 2025-08-26 19:32:46

CREATE OR REPLACE FUNCTION sp_get_accesorios_by_local(p_id_local integer)
RETURNS TABLE(
    id_control integer,
    modulo smallint,
    control_otr integer,
    folio integer,
    importe_multa numeric,
    importe_gastos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_control, modulo, control_otr, folio, importe_multa, importe_gastos
    FROM ta_15_apremios
    WHERE modulo = 11 AND control_otr = p_id_local AND vigencia = '1' AND clave_practicado = 'P';
END;
$$ LANGUAGE plpgsql;