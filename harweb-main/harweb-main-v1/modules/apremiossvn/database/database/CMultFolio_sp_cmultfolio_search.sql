-- Stored Procedure: sp_cmultfolio_search
-- Tipo: Report
-- Descripción: Busca folios en ta_15_apremios por módulo, zona y folio inicial (devuelve hasta 100 consecutivos)
-- Generado para formulario: CMultFolio
-- Fecha: 2025-08-27 13:37:59

CREATE OR REPLACE FUNCTION sp_cmultfolio_search(p_modulo integer, p_zona integer, p_folio integer)
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
    SELECT * FROM ta_15_apremios
    WHERE modulo = p_modulo
      AND zona = p_zona
      AND folio BETWEEN p_folio AND (p_folio + 100)
    ORDER BY folio ASC;
END;
$$ LANGUAGE plpgsql;