-- Stored Procedure: sp_get_cons_his
-- Tipo: Report
-- Descripción: Obtiene la información principal del folio de apremios (historia) con descripciones relacionadas.
-- Generado para formulario: Cons_his
-- Fecha: 2025-08-27 13:42:45

CREATE OR REPLACE FUNCTION sp_get_cons_his(p_control integer)
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
    hora_practicado timestamp,
    dil_descrip varchar,
    pra_descrip varchar,
    sec_descrip varchar,
    rem_descrip varchar,
    vig_descrip varchar,
    usu_descrip varchar,
    nombre_eje varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.control, a.zona, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos, a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor, a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, a.importe_pago, a.vigencia, a.fecha_actualiz, a.usuario, a.clave_mov, a.hora_practicado,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.diligencia AND tipo_clave=4 LIMIT 1) AS dil_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_practicado AND tipo_clave=1 LIMIT 1) AS pra_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_secuestro::varchar AND tipo_clave=2 LIMIT 1) AS sec_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_remate AND tipo_clave=3 LIMIT 1) AS rem_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_mov AND tipo_clave=5 LIMIT 1) AS vig_descrip,
        (SELECT nombre FROM padron_licencias.comun.ta_12_passwords WHERE id_usuario=a.usuario LIMIT 1) AS usu_descrip,
        (SELECT nombre FROM ta_15_ejecutores WHERE cve_eje=a.ejecutor AND id_rec=a.zona LIMIT 1) AS nombre_eje
    FROM ta_15_historia a
    WHERE a.id_control = p_control
    ORDER BY a.control DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;