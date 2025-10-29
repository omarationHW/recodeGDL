-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Individual_Folio
-- Generado: 2025-08-27 13:54:03
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_individual_folio_search
-- Tipo: CRUD
-- Descripción: Busca un folio individual por módulo, folio y recaudadora. Devuelve todos los datos del folio y descripciones auxiliares.
-- --------------------------------------------

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
        (SELECT nombre FROM ta_12_passwords WHERE id_usuario=a.usuario) AS usu_descrip,
        (SELECT nombre FROM ta_15_ejecutores WHERE cve_eje=a.ejecutor AND id_rec=a.zona) AS nombre_eje,
        a.hora_practicado,
        a.importe_actualizacion,
        (SELECT descripcion FROM ta_12_modulos WHERE id_modulo=a.modulo) AS modulo_desc
    FROM ta_15_apremios a
    WHERE a.modulo = p_modulo AND a.folio = p_folio AND a.zona = p_recaudadora
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_individual_folio_history
-- Tipo: Report
-- Descripción: Devuelve la historia del folio (tabla ta_15_historia) para un id_control.
-- --------------------------------------------

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

-- ============================================

-- SP 3/5: sp_individual_folio_periods
-- Tipo: Report
-- Descripción: Devuelve los periodos asociados al folio (tabla ta_15_periodos) para un id_control.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_individual_folio_periods(p_id_control integer)
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
    SELECT * FROM ta_15_periodos WHERE control_otr = p_id_control ORDER BY ayo, periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_catalog_aplicaciones
-- Tipo: Catalog
-- Descripción: Catálogo de aplicaciones (modulos) disponibles para el formulario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalog_aplicaciones()
RETURNS TABLE (id integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY VALUES
        (11, 'Mercados'),
        (16, 'Aseo'),
        (24, 'Estacionamientos Publicos'),
        (28, 'Estacionamientos Exclusivos'),
        (14, 'Estacionometros'),
        (13, 'Cementerios');
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_catalog_recaudadoras
-- Tipo: Catalog
-- Descripción: Catálogo de recaudadoras disponibles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalog_recaudadoras()
RETURNS TABLE (id integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

