-- Stored Procedure: sp_individual_folio_history
-- Tipo: Report
-- Descripción: Devuelve la historia del folio (tabla ta_15_historia) para un id_control.
-- Generado para formulario: Individual_Folio
-- Fecha: 2025-08-27 13:54:03

CREATE OR REPLACE FUNCTION sp_individual_folio_history(p_id_control integer)
RETURNS TABLE (
    id_control integer,
    control integer,
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
    hora_practicado timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_15_historia WHERE id_control = p_id_control ORDER BY fecha_actualiz DESC;
END;
$$ LANGUAGE plpgsql;