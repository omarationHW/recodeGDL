-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: srfrm_conci_banorte
-- Generado: 2025-08-27 15:02:35
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_conciliados_by_folio
-- Tipo: Report
-- Descripción: Obtiene los registros conciliados por año y folio, con estatus calculado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_conciliados_by_folio(p_axo integer, p_folio integer)
RETURNS TABLE (
    rowid integer,
    axo smallint,
    folio integer,
    fecha_folio date,
    placa varchar(7),
    infraccion smallint,
    fec_pago date,
    folio_pago varchar(21),
    medio_pago varchar(2),
    forma_pago varchar(2),
    importe_bruto numeric,
    importe_neto numeric,
    fecha_venci date,
    sucursal integer,
    hora_banco varchar(6),
    estatus_banco varchar(1),
    usu_carga integer,
    fecha_afectacion date,
    status_mpio smallint,
    placa_cambio varchar(7),
    fec_placa_cambio date,
    fec_carga_ascii date,
    fec_caja date,
    operacion integer,
    caja_ingre varchar(1),
    reca smallint,
    stat varchar(30)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.rowid, a.axo, a.folio, a.fecha_folio, a.placa, a.infraccion, a.fec_pago, a.folio_pago, a.medio_pago, a.forma_pago, a.importe_bruto, a.importe_neto, a.fecha_venci, a.sucursal, a.hora_banco, a.estatus_banco, a.usu_carga, a.fecha_afectacion, a.status_mpio, a.placa_cambio, a.fec_placa_cambio, a.fec_carga_ascii, a.fec_caja, a.operacion, a.caja_ingre, a.reca,
        CASE 
            WHEN a.status_mpio = 0 THEN 'OK'
            WHEN a.status_mpio = 1 THEN 'Doble'
            WHEN a.status_mpio = 9 THEN 'Alta'
            WHEN a.status_mpio = 4 THEN 'Er. placa'
            WHEN a.status_mpio = 5 THEN 'Histo Er. placa'
            WHEN a.status_mpio = 6 THEN 'Banorte Er. placa'
            WHEN a.status_mpio = 10 THEN 'Banorte anterioridad'
            ELSE 'Sin Afect'
        END AS stat
    FROM ta14_fol_banorte a
    WHERE a.status_mpio <> 0 AND a.axo = p_axo AND a.folio = p_folio
    ORDER BY a.status_mpio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_conciliados_by_fecha
-- Tipo: Report
-- Descripción: Obtiene los registros conciliados por fecha de afectación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_conciliados_by_fecha(p_fecha date)
RETURNS TABLE (
    rowid integer,
    axo smallint,
    folio integer,
    fecha_folio date,
    placa varchar(7),
    infraccion smallint,
    fec_pago date,
    folio_pago varchar(21),
    medio_pago varchar(2),
    forma_pago varchar(2),
    importe_bruto numeric,
    importe_neto numeric,
    fecha_venci date,
    sucursal integer,
    hora_banco varchar(6),
    estatus_banco varchar(1),
    usu_carga integer,
    fecha_afectacion date,
    status_mpio smallint,
    placa_cambio varchar(7),
    fec_placa_cambio date,
    fec_carga_ascii date,
    fec_caja date,
    operacion integer,
    caja_ingre varchar(1),
    reca smallint,
    stat varchar(30)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.rowid, a.axo, a.folio, a.fecha_folio, a.placa, a.infraccion, a.fec_pago, a.folio_pago, a.medio_pago, a.forma_pago, a.importe_bruto, a.importe_neto, a.fecha_venci, a.sucursal, a.hora_banco, a.estatus_banco, a.usu_carga, a.fecha_afectacion, a.status_mpio, a.placa_cambio, a.fec_placa_cambio, a.fec_carga_ascii, a.fec_caja, a.operacion, a.caja_ingre, a.reca,
        CASE 
            WHEN a.status_mpio = 0 THEN 'OK'
            WHEN a.status_mpio = 1 THEN 'Doble'
            WHEN a.status_mpio = 9 THEN 'Alta'
            WHEN a.status_mpio = 4 THEN 'Er. placa'
            WHEN a.status_mpio = 5 THEN 'Histo Er. placa'
            WHEN a.status_mpio = 6 THEN 'Banorte Er. placa'
            WHEN a.status_mpio = 10 THEN 'Banorte anterioridad'
            ELSE 'Sin Afect'
        END AS stat
    FROM ta14_fol_banorte a
    WHERE a.status_mpio <> 0 AND a.fecha_afectacion = p_fecha
    ORDER BY a.status_mpio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_histo_by_axo_folio
-- Tipo: Report
-- Descripción: Obtiene el historial de folios por año y folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_histo_by_axo_folio(p_axo integer, p_folio integer)
RETURNS TABLE (
    control integer,
    fecha_movto date,
    axo smallint,
    folio integer,
    fecha_folio date,
    placa varchar(7),
    infraccion smallint,
    estado smallint,
    vigilante integer,
    num_acuerdo integer,
    fec_cap date,
    usu_inicial integer,
    codigo_movto smallint,
    usu_bajaauto smallint,
    zona smallint,
    espacio smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.control, b.fecha_movto, b.axo, b.folio, b.fecha_folio, b.placa, b.infraccion, b.estado, b.vigilante, b.num_acuerdo, b.fec_cap, b.usu_inicial, b.codigo_movto, b.usu_bajaauto, b.zona, b.espacio
    FROM ta14_folios_histo b
    WHERE b.axo = p_axo AND b.folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: spd_chg_conci
-- Tipo: CRUD
-- Descripción: Realiza el cambio de placa o folio en la conciliación Banorte. Opción 1: cambiar placa, Opción 2/3: cambiar folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spd_chg_conci(
    p_control integer,
    p_idbanco integer,
    p_axo smallint,
    p_folio integer,
    p_placa varchar(7),
    p_id_usuario integer,
    p_opcion smallint
) RETURNS TABLE (clave smallint) AS $$
DECLARE
    v_clave smallint := 0;
BEGIN
    -- Opción 1: Cambiar placa
    IF p_opcion = 1 THEN
        UPDATE ta14_fol_banorte
        SET placa_cambio = upper(trim(p_placa)),
            fec_placa_cambio = now(),
            usu_carga = p_id_usuario
        WHERE rowid = p_idbanco;
        v_clave := 0;
    -- Opción 2: Cambiar folio (existe folio)
    ELSIF p_opcion = 2 THEN
        UPDATE ta14_fol_banorte
        SET axo = p_axo, folio = p_folio, usu_carga = p_id_usuario
        WHERE rowid = p_idbanco;
        v_clave := 0;
    -- Opción 3: Cambiar folio (no existe folio)
    ELSIF p_opcion = 3 THEN
        UPDATE ta14_fol_banorte
        SET axo = p_axo, folio = p_folio, usu_carga = p_id_usuario
        WHERE rowid = p_idbanco;
        v_clave := 0;
    ELSE
        v_clave := 1;
    END IF;
    RETURN QUERY SELECT v_clave;
END;
$$ LANGUAGE plpgsql;

-- ============================================

