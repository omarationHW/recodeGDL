-- Stored Procedure: sp_filter_h_bloqueo_dom
-- Tipo: Catalog
-- Descripción: Filtra el histórico de domicilios bloqueados por calle, num_ext, modifico, y orden.
-- Generado para formulario: h_bloqueoDomiciliosfrm
-- Fecha: 2025-08-26 16:58:17

CREATE OR REPLACE FUNCTION sp_filter_h_bloqueo_dom(
    p_calle TEXT DEFAULT NULL,
    p_num_ext INTEGER DEFAULT NULL,
    p_modifico TEXT DEFAULT NULL,
    p_order TEXT DEFAULT 'calle,num_ext'
)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecalle INTEGER,
    calle TEXT,
    num_ext INTEGER,
    let_ext TEXT,
    num_int INTEGER,
    let_int TEXT,
    folio INTEGER,
    fecha DATE,
    hora TIMESTAMP,
    vig TEXT,
    observacion TEXT,
    capturista TEXT,
    fecha_mov TIMESTAMP,
    motivo_mov TEXT,
    tipo_mov TEXT,
    modifico TEXT,
    procedenciamov TEXT
) AS $$
DECLARE
    v_sql TEXT;
    v_where TEXT := ''1=1'';
BEGIN
    IF p_calle IS NOT NULL AND p_calle <> '' THEN
        v_where := v_where || ' AND calle ILIKE %' || quote_literal(p_calle) || '%';
    END IF;
    IF p_num_ext IS NOT NULL THEN
        v_where := v_where || ' AND num_ext = ' || p_num_ext;
    END IF;
    IF p_modifico IS NOT NULL AND p_modifico <> '' THEN
        v_where := v_where || ' AND modifico ILIKE %' || quote_literal(p_modifico) || '%';
    END IF;
    v_sql := format('SELECT *,
        CASE tipo_mov
            WHEN ''EL'' THEN ''Eliminado al Desbloquear de Licencia''
            WHEN ''ED'' THEN ''Eliminado desde Bloqueo de Domicilios''
            WHEN ''MD'' THEN ''Modificado en bloqueo de Domicilio''
            ELSE tipo_mov
        END AS procedenciamov
        FROM h_bloqueo_dom WHERE %s ORDER BY %s', v_where, p_order);
    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;