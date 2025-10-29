-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: pagosmultfrm
-- Generado: 2025-08-27 14:09:11
-- Total SPs: 7
-- ============================================

-- SP 1/7: pagosmultfrm_search_pagos_multas
-- Tipo: Report
-- Descripción: Busca pagos de multas según los filtros proporcionados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagosmultfrm_search_pagos_multas(
    p_fecha DATE DEFAULT NULL,
    p_recaud SMALLINT DEFAULT NULL,
    p_caja TEXT DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_nombre TEXT DEFAULT NULL,
    p_num_acta INTEGER DEFAULT NULL
)
RETURNS TABLE (
    cvepago INTEGER,
    cvecuenta INTEGER,
    recaud SMALLINT,
    caja TEXT,
    folio INTEGER,
    fecha DATE,
    hora TIME,
    importe NUMERIC,
    cajero TEXT,
    cvecanc INTEGER,
    cveconcepto INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.cvepago, p.cvecuenta, p.recaud, p.caja, p.folio, p.fecha, p.hora, p.importe, p.cajero, p.cvecanc, p.cveconcepto
    FROM pagos p
    WHERE p.cveconcepto = 6
      AND (p_fecha IS NULL OR p.fecha = p_fecha)
      AND (p_recaud IS NULL OR p.recaud = p_recaud)
      AND (p_caja IS NULL OR p.caja = p_caja)
      AND (p_folio IS NULL OR p.folio = p_folio)
      AND (
        p_nombre IS NULL OR p.cvepago IN (
          SELECT m.cvepago FROM multas m WHERE m.contribuyente ILIKE '%' || p_nombre || '%'
        )
      )
      AND (
        p_num_acta IS NULL OR p.cvepago IN (
          SELECT m.cvepago FROM multas m WHERE m.num_acta = p_num_acta
        )
      )
    ORDER BY p.fecha, p.recaud, p.caja, p.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: pagosmultfrm_get_multa_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de una multa, incluyendo campos calculados de estatus y descuento.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagosmultfrm_get_multa_detalle(
    p_id_multa INTEGER
)
RETURNS TABLE (
    id_multa INTEGER,
    axo_acta SMALLINT,
    num_acta INTEGER,
    fecha_acta DATE,
    fecha_recepcion DATE,
    fecha_cancelacion DATE,
    contribuyente TEXT,
    domicilio TEXT,
    recaud SMALLINT,
    zona SMALLINT,
    subzona SMALLINT,
    num_licencia INTEGER,
    giro TEXT,
    expediente TEXT,
    num_lote INTEGER,
    num_remesa INTEGER,
    calificacion NUMERIC,
    multa NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    cvepago INTEGER,
    capturista TEXT,
    user_baja TEXT,
    observacion TEXT,
    descuento NUMERIC,
    estatus TEXT,
    dependencia TEXT,
    ley TEXT,
    infraccion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id_multa,
        m.axo_acta,
        m.num_acta,
        m.fecha_acta,
        m.fecha_recepcion,
        m.fecha_cancelacion,
        m.contribuyente,
        m.domicilio,
        m.recaud,
        m.zona,
        m.subzona,
        m.num_licencia,
        m.giro,
        m.expediente,
        m.num_lote,
        m.num_remesa,
        m.calificacion,
        m.multa,
        m.gastos,
        m.total,
        m.cvepago,
        m.capturista,
        m.user_baja,
        m.observacion,
        (m.calificacion - m.multa) AS descuento,
        CASE 
            WHEN m.fecha_cancelacion IS NOT NULL AND m.fecha_cancelacion > '1900-01-01' THEN 'CANCELADO'
            WHEN m.cvepago > 0 THEN 'PAGADO'
            ELSE 'VIGENTE'
        END AS estatus,
        d.descripcion AS dependencia,
        l.descripcion AS ley,
        i.descripcion AS infraccion
    FROM multas m
    LEFT JOIN c_dependencias d ON m.id_dependencia = d.id_dependencia
    LEFT JOIN c_leyes l ON m.id_dependencia = l.id_dependencia AND m.id_ley = l.id_ley
    LEFT JOIN c_infracciones i ON m.id_dependencia = i.id_dependencia AND m.id_infraccion = i.id_infraccion
    WHERE m.id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: pagosmultfrm_get_pagoscan
-- Tipo: Report
-- Descripción: Obtiene los registros de pagos cancelados para un pago específico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagosmultfrm_get_pagoscan(
    p_cvepago INTEGER
)
RETURNS TABLE (
    cvecanc INTEGER,
    cvepago INTEGER,
    autorizo TEXT,
    fechacan DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecanc, cvepago, autorizo, fechacan
    FROM pagoscan
    WHERE cvepago = p_cvepago;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: pagosmultfrm_get_descuentos
-- Tipo: Report
-- Descripción: Obtiene los descuentos aplicados a una multa.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagosmultfrm_get_descuentos(
    p_id_multa INTEGER
)
RETURNS TABLE (
    id_descuento INTEGER,
    tipo_descto TEXT,
    valor NUMERIC,
    feccap DATE,
    capturista TEXT,
    observacion TEXT,
    autoriza TEXT,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id_descuento, d.tipo_descto, d.valor, d.feccap, d.capturista, d.observacion, d.autoriza, c.descripcion
    FROM descmultampal d
    LEFT JOIN c_autdescmul c ON d.autoriza = c.cveautoriza
    WHERE d.id_multa = p_id_multa AND d.estado <> 'C';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: pagosmultfrm_get_ley
-- Tipo: Catalog
-- Descripción: Obtiene la descripción de la ley para una dependencia y ley dada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagosmultfrm_get_ley(
    p_id_dependencia SMALLINT,
    p_id_ley SMALLINT
)
RETURNS TABLE (
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT descripcion
    FROM c_leyes
    WHERE id_dependencia = p_id_dependencia AND id_ley = p_id_ley;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: pagosmultfrm_get_infraccion
-- Tipo: Catalog
-- Descripción: Obtiene la descripción de la infracción para una dependencia e infracción dada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagosmultfrm_get_infraccion(
    p_id_dependencia SMALLINT,
    p_id_infraccion SMALLINT
)
RETURNS TABLE (
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT descripcion
    FROM c_infracciones
    WHERE id_dependencia = p_id_dependencia AND id_infraccion = p_id_infraccion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: pagosmultfrm_get_dependencia
-- Tipo: Catalog
-- Descripción: Obtiene la descripción de la dependencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagosmultfrm_get_dependencia(
    p_id_dependencia SMALLINT
)
RETURNS TABLE (
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT descripcion
    FROM c_dependencias
    WHERE id_dependencia = p_id_dependencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

