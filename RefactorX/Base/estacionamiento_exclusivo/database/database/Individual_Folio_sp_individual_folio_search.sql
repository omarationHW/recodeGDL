-- Stored Procedure: sp_individual_folio_search
-- Tipo: CRUD
-- Descripción: Busca un folio individual por módulo, folio y recaudadora. Devuelve todos los datos del folio y descripciones auxiliares.
-- Generado para formulario: Individual_Folio
-- Fecha: 2025-08-27 13:54:03

CREATE OR REPLACE FUNCTION sp_individual_folio_search(p_modulo integer, p_folio integer, p_recaudadora integer)
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
    vig_descrip varchar,
    usu_descrip varchar,
    nombre_eje varchar,
    hora_practicado timestamp,
    importe_actualizacion numeric,
    modulo_desc varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.*, 
        (SELECT descrip FROM ta_15_claves WHERE clave=a.diligencia AND tipo_clave=4) AS dil_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_practicado AND tipo_clave=1) AS pra_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_secuestro::varchar AND tipo_clave=2) AS sec_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_remate AND tipo_clave=3) AS rem_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.vigencia AND tipo_clave=5) AS vig_descrip,
        (SELECT nombre FROM padron_licencias.comun.ta_12_passwords WHERE id_usuario=a.usuario) AS usu_descrip,
        (SELECT nombre FROM ta_15_ejecutores WHERE cve_eje=a.ejecutor AND id_rec=a.zona) AS nombre_eje,
        a.hora_practicado,
        a.importe_actualizacion,
        (SELECT descripcion FROM padron_licencias.comun.ta_12_modulos WHERE id_modulo=a.modulo) AS modulo_desc
    FROM ta_15_apremios a
    WHERE a.modulo = p_modulo AND a.folio = p_folio AND a.zona = p_recaudadora
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;