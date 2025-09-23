-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RConsulta
-- Generado: 2025-08-28 13:38:15
-- Total SPs: 5
-- ============================================

-- SP 1/5: get_concesion_by_control
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la concesión/local por su control (clave).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_concesion_by_control(p_control TEXT)
RETURNS TABLE(
    id_34_datos INTEGER,
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie NUMERIC,
    fecha_inicio DATE,
    id_recaudadora INTEGER,
    sector TEXT,
    id_zona INTEGER,
    licencia INTEGER,
    descrip_unidad TEXT,
    cve_stat TEXT,
    descrip_stat TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.superficie, a.fecha_inicio,
           a.id_recaudadora, a.sector, a.id_zona, a.licencia, b.descripcion AS descrip_unidad,
           c.cve_stat, c.descripcion AS descrip_stat
    FROM t34_datos a
    JOIN t34_unidades b ON b.id_34_unidad = a.id_unidad
    JOIN t34_status c ON c.id_34_stat = a.id_stat
    WHERE a.cve_tab = 3 AND a.control = p_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: get_adeudos_by_concesion
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de un local/concesión hasta un periodo (año/mes).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_adeudos_by_concesion(p_id_34_datos INTEGER, p_aso INTEGER, p_mes INTEGER)
RETURNS TABLE(
    concepto TEXT,
    axo INTEGER,
    mes INTEGER,
    importe_pagar NUMERIC,
    recargos_pagar NUMERIC,
    dscto_importe NUMERIC,
    dscto_recargos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, axo, mes, importe_pagar, recargos_pagar, dscto_importe, dscto_recargos
    FROM cob34_rdetade_01(p_id_34_datos, p_aso, p_mes);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: get_totales_by_concesion
-- Tipo: Report
-- Descripción: Obtiene los totales de adeudos agrupados por concepto para un local/concesión.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_totales_by_concesion(p_id_34_datos INTEGER, p_aso INTEGER, p_mes INTEGER)
RETURNS TABLE(
    cuenta INTEGER,
    obliga TEXT,
    concepto TEXT,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT cuenta, obliga, concepto, importe
    FROM cob34_rtotade_01(p_id_34_datos, p_aso, p_mes);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: get_pagados_by_concesion
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados (status P) para un local/concesión.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_pagados_by_concesion(p_id_34_datos INTEGER)
RETURNS TABLE(
    id_34_pagos INTEGER,
    id_datos INTEGER,
    periodo DATE,
    importe NUMERIC,
    recargo NUMERIC,
    fecha_hora_pago TIMESTAMP,
    id_recaudadora INTEGER,
    caja TEXT,
    operacion INTEGER,
    folio_recibo TEXT,
    usuario TEXT,
    id_stat INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago,
           a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos AND b.cve_stat = 'P';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: get_fecha_limite
-- Tipo: Catalog
-- Descripción: Obtiene la fecha límite del periodo actual.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_fecha_limite()
RETURNS TABLE(fechalimite DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT fechalimite
    FROM t34_fechalimite
    WHERE EXTRACT(YEAR FROM fechalimite) = EXTRACT(YEAR FROM CURRENT_DATE)
      AND EXTRACT(MONTH FROM fechalimite) = EXTRACT(MONTH FROM CURRENT_DATE)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

