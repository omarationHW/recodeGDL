-- Stored Procedure: spd_updasigna
-- Tipo: CRUD
-- Descripción: Asigna folios a ejecutor en un rango y tipo de requerimiento
-- Generado para formulario: canc
-- Fecha: 2025-08-26 23:03:45

CREATE OR REPLACE FUNCTION spd_updasigna(
    p_rec INTEGER,
    p_folini INTEGER,
    p_folfin INTEGER,
    p_eje INTEGER,
    p_fecasig DATE,
    p_opc INTEGER
) RETURNS TABLE(sbien INTEGER, mensage TEXT) AS $$
DECLARE
    v_table TEXT;
    v_sql TEXT;
    v_sbien INTEGER := 0;
    v_msg TEXT := ''Asignación realizada'';
BEGIN
    CASE p_opc
        WHEN 1 THEN v_table := 'reqpredial';
        WHEN 2 THEN v_table := 'reqmultas';
        WHEN 3 THEN v_table := 'reqlicencias';
        WHEN 4 THEN v_table := 'reqanuncios';
        WHEN 5 THEN v_table := 'reqdiftransmision';
        ELSE RAISE EXCEPTION 'Opción inválida';
    END CASE;
    v_sql := format('UPDATE %I SET cveejecut = $1, fecejec = $2 WHERE recaud = $3 AND folioreq BETWEEN $4 AND $5 AND (cveejecut IS NULL OR cveejecut = 0) AND vigencia = ''V''', v_table);
    EXECUTE v_sql USING p_eje, p_fecasig, p_rec, p_folini, p_folfin;
    GET DIAGNOSTICS v_sbien = ROW_COUNT;
    RETURN QUERY SELECT v_sbien, v_msg;
END;
$$ LANGUAGE plpgsql;