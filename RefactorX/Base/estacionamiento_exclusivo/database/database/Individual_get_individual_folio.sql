-- Stored Procedure: get_individual_folio
-- Tipo: Report
-- Descripción: Obtiene los datos principales de un folio individual por id (folio)
-- Generado para formulario: Individual
-- Fecha: 2025-08-27 13:52:12

CREATE OR REPLACE FUNCTION get_individual_folio(folio integer)
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
    dil_descrip varchar,
    pra_descrip varchar,
    sec_descrip varchar,
    rem_descrip varchar,
    usu_descrip varchar,
    clave_mov varchar,
    vig_descrip varchar,
    nombre_eje varchar,
    hora_practicado timestamp,
    mod_desc varchar,
    datos varchar,
    importe_actualizacion numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.*, 
        (SELECT descrip FROM ta_15_claves WHERE clave=a.diligencia AND tipo_clave=4) AS dil_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_practicado AND tipo_clave=1) AS pra_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_secuestro AND tipo_clave=2) AS sec_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_remate AND tipo_clave=3) AS rem_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.vigencia AND tipo_clave=5) AS vig_descrip,
        (SELECT nombre FROM padron_licencias.comun.ta_12_passwords WHERE id_usuario=a.usuario) AS usu_descrip,
        (SELECT nombre FROM ta_15_ejecutores WHERE cve_eje=a.ejecutor AND id_rec=a.zona) AS nombre_eje,
        a.hora_practicado,
        -- Calculated fields:
        CASE a.modulo
            WHEN 16 THEN 'Aseo'
            WHEN 11 THEN 'Mercado'
            WHEN 24 THEN 'Estacionamientos Publicos'
            WHEN 28 THEN 'Estacionamientos Exclusivos'
            WHEN 14 THEN 'Estacionometros'
            WHEN 13 THEN 'Cementerios'
            ELSE 'Otro'
        END AS mod_desc,
        '' AS datos,
        a.importe_actualizacion
    FROM ta_15_apremios a
    WHERE a.folio = folio;
END;
$$ LANGUAGE plpgsql;