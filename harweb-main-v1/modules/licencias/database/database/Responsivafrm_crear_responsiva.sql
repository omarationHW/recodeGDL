-- Stored Procedure: crear_responsiva
-- Tipo: CRUD
-- Descripción: Crea una nueva responsiva o supervisión, asignando folio y año automáticamente.
-- Generado para formulario: Responsivafrm
-- Fecha: 2025-08-27 19:29:54

CREATE OR REPLACE FUNCTION crear_responsiva(
    p_id_licencia INTEGER,
    p_tipo TEXT, -- 'R' o 'S'
    p_usuario TEXT,
    p_observacion TEXT DEFAULT NULL
) RETURNS TABLE (axo INTEGER, folio INTEGER, id_licencia INTEGER, tipo TEXT, vigente TEXT, feccap DATE, capturista TEXT) AS $$
DECLARE
    v_folio INTEGER;
    v_axo INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
    v_param_col TEXT;
BEGIN
    IF p_tipo = 'R' THEN
        v_param_col := 'responsiva';
    ELSE
        v_param_col := 'supervision';
    END IF;
    -- Obtener folio actual
    EXECUTE format('SELECT %I FROM parametros_lic', v_param_col) INTO v_folio;
    v_folio := v_folio + 1;
    -- Actualizar folio en parametros_lic
    EXECUTE format('UPDATE parametros_lic SET %I = $1', v_param_col) USING v_folio;
    -- Insertar responsiva
    INSERT INTO responsivas(axo, folio, id_licencia, tipo, observacion, vigente, feccap, capturista)
    VALUES (v_axo, v_folio, p_id_licencia, p_tipo, p_observacion, 'V', CURRENT_DATE, p_usuario);
    RETURN QUERY SELECT v_axo, v_folio, p_id_licencia, p_tipo, 'V', CURRENT_DATE, p_usuario;
END;
$$ LANGUAGE plpgsql;