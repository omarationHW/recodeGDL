-- Stored Procedure: sp_get_requerimientos_by_local
-- Tipo: Report
-- Descripción: Obtiene los requerimientos (apremios) de un local
-- Generado para formulario: AdeGlobalLocales
-- Fecha: 2025-08-26 19:32:46

CREATE OR REPLACE FUNCTION sp_get_requerimientos_by_local(p_id_local integer)
RETURNS TABLE(
    id_control integer,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    fecha_emision date,
    clave_practicado varchar,
    vigencia varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_control, modulo, control_otr, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos, fecha_emision, clave_practicado, vigencia
    FROM ta_15_apremios
    WHERE modulo = 11 AND control_otr = p_id_local;
END;
$$ LANGUAGE plpgsql;