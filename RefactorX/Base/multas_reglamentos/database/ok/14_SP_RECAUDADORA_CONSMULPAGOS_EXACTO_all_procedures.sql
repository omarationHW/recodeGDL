-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: consmulpagos
-- Generado: 2025-08-26 23:30:27
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_list_pagos_multas
-- Tipo: Report
-- Descripción: Lista todos los pagos de multas con datos de multa y pago.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_list_pagos_multas()
RETURNS TABLE(
    cvepago integer,
    fecha date,
    recaud integer,
    caja varchar,
    folio integer,
    importe numeric,
    cajero varchar,
    contribuyente varchar,
    domicilio varchar,
    num_acta integer,
    axo_acta integer,
    id_dependencia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.cvepago, p.fecha, p.recaud, p.caja, p.folio, p.importe, p.cajero, m.contribuyente, m.domicilio, m.num_acta, m.axo_acta, m.id_dependencia
    FROM public.pagos p
    INNER JOIN public.multas m ON p.cvepago = m.cvepago
    WHERE p.cveconcepto = 6
    ORDER BY p.fecha DESC, p.recaud, p.caja, p.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_filter_pagos_multas
-- Tipo: Report
-- Descripción: Filtra pagos de multas por fecha, recaudadora, caja, folio, nombre, num_acta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_filter_pagos_multas(
    p_fecha date DEFAULT NULL,
    p_recaud integer DEFAULT NULL,
    p_caja varchar DEFAULT NULL,
    p_folio integer DEFAULT NULL,
    p_nombre varchar DEFAULT NULL,
    p_num_acta integer DEFAULT NULL
)
RETURNS TABLE(
    cvepago integer,
    fecha date,
    recaud integer,
    caja varchar,
    folio integer,
    importe numeric,
    cajero varchar,
    contribuyente varchar,
    domicilio varchar,
    num_acta integer,
    axo_acta integer,
    id_dependencia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.cvepago, p.fecha, p.recaud, p.caja, p.folio, p.importe, p.cajero, m.contribuyente, m.domicilio, m.num_acta, m.axo_acta, m.id_dependencia
    FROM public.pagos p
    INNER JOIN public.multas m ON p.cvepago = m.cvepago
    WHERE p.cveconcepto = 6
      AND (p_fecha IS NULL OR p.fecha = p_fecha)
      AND (p_recaud IS NULL OR p.recaud = p_recaud)
      AND (p_caja IS NULL OR p.caja = p_caja)
      AND (p_folio IS NULL OR p.folio = p_folio)
      AND (p_nombre IS NULL OR m.contribuyente ILIKE '%' || p_nombre || '%')
      AND (p_num_acta IS NULL OR m.num_acta = p_num_acta)
    ORDER BY p.fecha DESC, p.recaud, p.caja, p.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_detail_pago_multa
-- Tipo: Report
-- Descripción: Devuelve el detalle completo de un pago de multa.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_detail_pago_multa(p_cvepago integer)
RETURNS TABLE(
    cvepago integer,
    fecha date,
    recaud integer,
    caja varchar,
    folio integer,
    importe numeric,
    cajero varchar,
    cveconcepto integer,
    contribuyente varchar,
    domicilio varchar,
    num_acta integer,
    axo_acta integer,
    id_dependencia integer,
    multa numeric,
    calificacion numeric,
    total numeric,
    observacion text
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.cvepago, p.fecha, p.recaud, p.caja, p.folio, p.importe, p.cajero, p.cveconcepto, m.contribuyente, m.domicilio, m.num_acta, m.axo_acta, m.id_dependencia, m.multa, m.calificacion, m.total, m.observacion
    FROM public.pagos p
    INNER JOIN public.multas m ON p.cvepago = m.cvepago
    WHERE p.cvepago = p_cvepago;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_report_pagos_multas
-- Tipo: Report
-- Descripción: Reporte de pagos de multas agrupados por fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_report_pagos_multas(p_fecha_ini date, p_fecha_fin date)
RETURNS TABLE(
    fecha date,
    total_pagos integer,
    total_importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.fecha, COUNT(*) as total_pagos, SUM(p.importe) as total_importe
    FROM public.pagos p
    WHERE p.cveconcepto = 6
      AND p.fecha BETWEEN p_fecha_ini AND p_fecha_fin
    GROUP BY p.fecha
    ORDER BY p.fecha DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================