-- Stored Procedure: sp_bloqueo_dom_add
-- Tipo: CRUD
-- Descripción: Agrega un domicilio bloqueado y regresa el folio generado.
-- Generado para formulario: bloqueoDomiciliosfrm
-- Fecha: 2025-08-26 14:44:52

CREATE OR REPLACE FUNCTION sp_bloqueo_dom_add(
    p_cvecalle INTEGER,
    p_calle VARCHAR,
    p_num_ext INTEGER,
    p_let_ext VARCHAR,
    p_num_int INTEGER,
    p_let_int VARCHAR,
    p_observacion VARCHAR,
    p_capturista VARCHAR,
    p_fecha DATE
) RETURNS INTEGER AS $$
DECLARE
    v_folio INTEGER;
BEGIN
    INSERT INTO bloqueo_dom (cvecalle, calle, num_ext, let_ext, num_int, let_int, observacion, capturista, fecha, hora, vig)
    VALUES (p_cvecalle, p_calle, p_num_ext, p_let_ext, p_num_int, p_let_int, p_observacion, p_capturista, p_fecha, NOW(), 'V')
    RETURNING folio INTO v_folio;
    RETURN v_folio;
END;
$$ LANGUAGE plpgsql;