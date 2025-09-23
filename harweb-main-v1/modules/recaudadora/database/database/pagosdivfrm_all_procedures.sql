-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: pagosdivfrm
-- Generado: 2025-08-27 14:03:11
-- Total SPs: 1
-- ============================================

-- SP 1/1: pagosdiv_buscar
-- Tipo: Report
-- Descripción: Busca pagos diversos según los filtros recibidos (fecha, recaud, caja, folio, contribuyente). Devuelve todos los campos de la tabla pagos donde cveconcepto=4 y los filtros aplicados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagosdiv_buscar(
    p_fecha DATE DEFAULT NULL,
    p_recaud SMALLINT DEFAULT NULL,
    p_caja VARCHAR DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_contribuyente VARCHAR DEFAULT NULL
)
RETURNS SETOF pagos AS $$
DECLARE
    v_sql TEXT;
    v_where TEXT := 'WHERE cveconcepto = 4';
BEGIN
    IF p_fecha IS NOT NULL THEN
        v_where := v_where || ' AND fecha = ' || quote_literal(p_fecha);
    END IF;
    IF p_recaud IS NOT NULL AND p_recaud <> '' THEN
        v_where := v_where || ' AND recaud = ' || quote_literal(p_recaud);
    END IF;
    IF p_caja IS NOT NULL AND p_caja <> '' THEN
        v_where := v_where || ' AND caja = ' || quote_literal(p_caja);
    END IF;
    IF p_folio IS NOT NULL AND p_folio <> '' THEN
        v_where := v_where || ' AND folio = ' || quote_literal(p_folio);
    END IF;
    IF p_contribuyente IS NOT NULL AND p_contribuyente <> '' THEN
        v_where := v_where || ' AND cvepago IN (SELECT cvepago FROM pago_diversos WHERE contribuyente ILIKE '%' || p_contribuyente || '%')';
    END IF;
    v_sql := 'SELECT * FROM pagos ' || v_where || ' ORDER BY fecha, recaud, caja, folio';
    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================

