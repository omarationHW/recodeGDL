-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Individual
-- Generado: 2025-08-27 13:52:12
-- Total SPs: 4
-- ============================================

-- SP 1/4: get_individual_folio
-- Tipo: Report
-- Descripción: Obtiene los datos principales de un folio individual por id (folio)
-- --------------------------------------------

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
        (SELECT nombre FROM ta_12_passwords WHERE id_usuario=a.usuario) AS usu_descrip,
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

-- ============================================

-- SP 2/4: get_individual_folio_history
-- Tipo: Report
-- Descripción: Obtiene el historial de movimientos de un folio individual
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_individual_folio_history(id_control integer)
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
    SELECT * FROM ta_15_historia WHERE id_control = id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: get_individual_folio_periods
-- Tipo: Report
-- Descripción: Obtiene los periodos asociados a un folio individual
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_individual_folio_periods(id_control integer)
RETURNS TABLE (
    id_control integer,
    control_otr integer,
    ayo smallint,
    periodo integer,
    importe numeric,
    recargos numeric,
    cantidad numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_15_periodos WHERE control_otr = id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: get_module_details
-- Tipo: Catalog
-- Descripción: Obtiene el detalle de la aplicación asociada al folio según el módulo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_module_details(modulo integer, control_otr integer)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    IF modulo = 16 THEN
        SELECT row_to_json(t) INTO result FROM (
            SELECT * FROM ta_16_contratos WHERE control_contrato = control_otr
        ) t;
    ELSIF modulo = 11 THEN
        SELECT row_to_json(t) INTO result FROM (
            SELECT * FROM ta_11_locales WHERE id_local = control_otr
        ) t;
    ELSIF modulo = 24 THEN
        SELECT row_to_json(t) INTO result FROM (
            SELECT * FROM pubmain WHERE id = control_otr
        ) t;
    ELSIF modulo = 28 THEN
        SELECT row_to_json(t) INTO result FROM (
            SELECT * FROM ex_contrato WHERE id = control_otr
        ) t;
    ELSIF modulo = 14 THEN
        SELECT row_to_json(t) INTO result FROM (
            SELECT * FROM ta_padron WHERE id = control_otr
        ) t;
    ELSIF modulo = 13 THEN
        SELECT row_to_json(t) INTO result FROM (
            SELECT * FROM ta_13_datosrcm WHERE control_rcm = control_otr
        ) t;
    ELSE
        result := NULL;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

