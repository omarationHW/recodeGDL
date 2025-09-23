-- Stored Procedure: report_multas
-- Tipo: Report
-- Descripción: Genera el reporte de multas municipales filtrando por dependencia, infracción, contribuyente, domicilio, fecha (única, rango o año) y estatus.
-- Generado para formulario: repmultampalfrm
-- Fecha: 2025-08-27 14:26:30

CREATE OR REPLACE FUNCTION report_multas(
    p_id_dependencia integer DEFAULT NULL,
    p_id_infraccion integer DEFAULT NULL,
    p_contribuyente text DEFAULT NULL,
    p_domicilio text DEFAULT NULL,
    p_fecha_tipo integer DEFAULT 0, -- 0: Todos, 1: Fecha, 2: Rango, 3: Año
    p_fecha1 date DEFAULT NULL,
    p_fecha2 date DEFAULT NULL,
    p_anio integer DEFAULT NULL,
    p_estatus integer DEFAULT 0 -- 0: Todos, 1: Vigente, 2: Pagado, 3: Cancelado
)
RETURNS TABLE (
    id_multa integer,
    id_dependencia integer,
    axo_acta integer,
    num_acta integer,
    fecha_acta date,
    fecha_recepcion date,
    fecha_cancelacion date,
    contribuyente text,
    domicilio text,
    recaud smallint,
    zona smallint,
    subzona smallint,
    num_licencia integer,
    giro text,
    id_ley smallint,
    id_infraccion smallint,
    expediente text,
    num_lote integer,
    num_remesa integer,
    calificacion numeric,
    multa numeric,
    gastos numeric,
    total numeric,
    cvepago integer,
    capturista text,
    user_baja text,
    observacion text,
    dependencia text
) AS $$
DECLARE
    v_sql text;
    v_where text := '';
BEGIN
    v_sql := 'SELECT m.*, d.abrevia AS dependencia FROM multas m LEFT JOIN c_dependencias d ON m.id_dependencia = d.id_dependencia';
    -- Dependencia
    IF p_id_dependencia IS NOT NULL THEN
        v_where := v_where || ' m.id_dependencia = ' || p_id_dependencia;
    END IF;
    -- Infracción
    IF p_id_infraccion IS NOT NULL THEN
        IF v_where <> '' THEN v_where := v_where || ' AND '; END IF;
        v_where := v_where || ' m.id_infraccion = ' || p_id_infraccion;
    END IF;
    -- Contribuyente
    IF p_contribuyente IS NOT NULL AND p_contribuyente <> '' THEN
        IF v_where <> '' THEN v_where := v_where || ' AND '; END IF;
        v_where := v_where || ' m.contribuyente ILIKE ' || quote_literal(p_contribuyente || '%');
    END IF;
    -- Domicilio
    IF p_domicilio IS NOT NULL AND p_domicilio <> '' THEN
        IF v_where <> '' THEN v_where ||=' AND '; END IF;
        v_where := v_where || ' m.domicilio ILIKE ' || quote_literal(p_domicilio || '%');
    END IF;
    -- Fecha
    IF p_fecha_tipo = 1 THEN -- Fecha única
        IF p_fecha1 IS NOT NULL THEN
            IF v_where <> '' THEN v_where := v_where || ' AND '; END IF;
            v_where := v_where || ' m.fecha_acta = ' || quote_literal(p_fecha1::text);
        END IF;
    ELSIF p_fecha_tipo = 2 THEN -- Rango
        IF p_fecha1 IS NOT NULL AND p_fecha2 IS NOT NULL THEN
            IF v_where <> '' THEN v_where := v_where || ' AND '; END IF;
            v_where := v_where || ' m.fecha_acta >= ' || quote_literal(p_fecha1::text) || ' AND m.fecha_acta <= ' || quote_literal(p_fecha2::text);
        END IF;
    ELSIF p_fecha_tipo = 3 THEN -- Año
        IF p_anio IS NOT NULL THEN
            IF v_where <> '' THEN v_where := v_where || ' AND '; END IF;
            v_where := v_where || ' m.axo_acta = ' || p_anio;
        END IF;
    END IF;
    -- Estatus
    IF p_estatus = 1 THEN -- Vigente
        IF v_where <> '' THEN v_where := v_where || ' AND '; END IF;
        v_where := v_where || ' m.fecha_cancelacion IS NULL';
    ELSIF p_estatus = 2 THEN -- Pagado (no implementado en Delphi, placeholder)
        IF v_where <> '' THEN v_where := v_where || ' AND '; END IF;
        v_where := v_where || ' FALSE'; -- No implementado
    ELSIF p_estatus = 3 THEN -- Cancelado
        IF v_where <> '' THEN v_where := v_where || ' AND '; END IF;
        v_where := v_where || ' m.fecha_cancelacion IS NOT NULL';
    END IF;
    IF v_where <> '' THEN
        v_sql := v_sql || ' WHERE ' || v_where;
    END IF;
    v_sql := v_sql || ' ORDER BY m.axo_acta, m.num_acta';
    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;