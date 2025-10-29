-- Stored Procedure: sp_consultareg_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de requerimientos para un módulo y control dado.
-- Generado para formulario: ConsultaReg
-- Fecha: 2025-08-27 13:40:42

CREATE OR REPLACE FUNCTION sp_consultareg_detalle(
    p_modulo integer,
    p_contro integer
) RETURNS TABLE (
    id_control integer,
    zona smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
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
    hora_practicado timestamp,
    importe_actualizacion numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_15_apremios WHERE modulo = p_modulo AND control_otr = p_contro;
END;
$$ LANGUAGE plpgsql;