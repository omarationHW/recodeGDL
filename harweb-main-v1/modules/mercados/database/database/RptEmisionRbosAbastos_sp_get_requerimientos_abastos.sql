-- Stored Procedure: sp_get_requerimientos_abastos
-- Tipo: Report
-- Descripción: Obtiene los requerimientos (apremios) asociados a un local para abastos.
-- Generado para formulario: RptEmisionRbosAbastos
-- Fecha: 2025-08-27 00:59:26

CREATE OR REPLACE FUNCTION sp_get_requerimientos_abastos(
    p_id_local integer
) RETURNS TABLE (
    id_control integer,
    modulo integer,
    control_otr integer,
    folio integer,
    diligencia text,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    fecha_emision date,
    clave_practicado text,
    vigencia text,
    fecha_actualiz date,
    usuario integer,
    observaciones text
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_control, modulo, control_otr, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos,
           fecha_emision, clave_practicado, vigencia, fecha_actualiz, usuario, observaciones
    FROM ta_15_apremios
    WHERE modulo = 11 AND control_otr = p_id_local AND vigencia = '1' AND clave_practicado = 'P'
    ORDER BY folio;
END;
$$ LANGUAGE plpgsql;