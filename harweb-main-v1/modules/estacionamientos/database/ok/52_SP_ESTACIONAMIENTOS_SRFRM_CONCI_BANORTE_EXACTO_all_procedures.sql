-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SRFRM_CONCI_BANORTE (EXACTO del archivo original)
-- Archivo: 52_SP_ESTACIONAMIENTOS_SRFRM_CONCI_BANORTE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SRFRM_CONCI_BANORTE (EXACTO del archivo original)
-- Archivo: 52_SP_ESTACIONAMIENTOS_SRFRM_CONCI_BANORTE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SRFRM_CONCI_BANORTE (EXACTO del archivo original)
-- Archivo: 52_SP_ESTACIONAMIENTOS_SRFRM_CONCI_BANORTE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

