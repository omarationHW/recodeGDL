-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: RPagados (EXACTO del archivo original)
-- Archivo: 24_SP_OTRASOBLIG_RPAGADOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_rpagados_get_pagados_by_control
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados (pagados) para un id_datos específico, filtrando por los status válidos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rpagados_get_pagados_by_control(p_control integer)
RETURNS TABLE (
    id_34_pagos integer,
    id_datos integer,
    periodo date,
    importe numeric,
    recargo numeric,
    fecha_hora_pago timestamp,
    id_recaudadora integer,
    caja varchar(2),
    operacion integer,
    folio_recibo varchar(15),
    usuario varchar(10),
    id_stat integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago, a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
    FROM otrasoblig.t34_pagos a
    JOIN otrasoblig.t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_control
      AND b.cve_stat IN ('P','S','R','D')
    ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================