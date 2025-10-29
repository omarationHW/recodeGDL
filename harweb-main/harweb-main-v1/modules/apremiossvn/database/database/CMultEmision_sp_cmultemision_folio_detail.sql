-- Stored Procedure: sp_cmultemision_folio_detail
-- Tipo: Report
-- Descripción: Obtiene el detalle completo de un folio por id_control.
-- Generado para formulario: CMultEmision
-- Fecha: 2025-08-27 13:36:29

CREATE OR REPLACE FUNCTION sp_cmultemision_folio_detail(p_id_control integer)
RETURNS TABLE (
    id_control integer,
    zona smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_actualizacion numeric,
    importe_gastos numeric,
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado varchar,
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    clave_secuestro smallint,
    clave_remate varchar,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar,
    fecha_pago date,
    recaudadora smallint,
    caja varchar,
    operacion integer,
    importe_pago numeric,
    vigencia varchar,
    fecha_actualiz date,
    usuario integer,
    clave_mov varchar,
    hora_practicado timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_control, zona, modulo, control_otr, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_actualizacion, importe_gastos, zona_apremio, fecha_emision, clave_practicado, fecha_practicado, fecha_entrega1, fecha_entrega2, fecha_citatorio, hora, ejecutor, clave_secuestro, clave_remate, fecha_remate, porcentaje_multa, observaciones, fecha_pago, recaudadora, caja, operacion, importe_pago, vigencia, fecha_actualiz, usuario, clave_mov, hora_practicado
    FROM ta_15_apremios
    WHERE id_control = p_id_control;
END;
$$ LANGUAGE plpgsql;