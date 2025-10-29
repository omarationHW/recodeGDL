-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_REPORT_PAGOS (EXACTO del archivo original)
-- Archivo: 39_SP_ESTACIONAMIENTOS_SFRM_REPORT_PAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: report_folios_pagados
-- Tipo: Report
-- Descripción: Devuelve los folios pagados en recaudadora para una fecha y recaudadora específica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION report_folios_pagados(p_reca integer, p_fechora date)
RETURNS TABLE (
    reca smallint,
    caja varchar(10),
    operacion integer,
    axo smallint,
    folio integer,
    placa varchar(10),
    fecha_folio date,
    estado smallint,
    infraccion smallint,
    tarifa numeric(12,2),
    codigo_movto smallint
) AS $$
BEGIN
    IF p_reca <> 9 THEN
        RETURN QUERY
        SELECT rp.reca, rp.caja, rp.operacion, a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa, a.codigo_movto
        FROM ta14_refrecibo rp
        JOIN ta14_folios_histo a ON rp.control = a.control
        JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
        WHERE rp.reca = p_reca AND rp.fecha_recibo = p_fechora
        ORDER BY 1,2,3,5,4;
    ELSE
        RETURN QUERY
        SELECT rp.reca, rp.caja, rp.operacion, a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa, a.codigo_movto
        FROM ta14_refrecibo rp
        JOIN ta14_folios_histo a ON rp.control = a.control
        JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
        WHERE rp.fecha_recibo = p_fechora
        ORDER BY 1,2,3,5,4;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_REPORT_PAGOS (EXACTO del archivo original)
-- Archivo: 39_SP_ESTACIONAMIENTOS_SFRM_REPORT_PAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: report_folios_adeudo_por_inspector
-- Tipo: Report
-- Descripción: Devuelve el conteo de folios de adeudo por inspector para una fecha dada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION report_folios_adeudo_por_inspector(p_fechora date)
RETURNS TABLE (
    vigilante integer,
    inspector varchar(100),
    folios integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.vigilante,
           TRIM(COALESCE(c.ap_pater, '.')) || ' ' || TRIM(COALESCE(c.ap_mater, '.')) || ' ' || TRIM(COALESCE(c.nombre, '.')) AS inspector,
           COUNT(a.folio) AS folios
    FROM ta14_folios_adeudo a
    JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
    WHERE a.fecha_folio = p_fechora
    GROUP BY a.vigilante, inspector
    ORDER BY inspector;
END;
$$ LANGUAGE plpgsql;

-- ============================================

