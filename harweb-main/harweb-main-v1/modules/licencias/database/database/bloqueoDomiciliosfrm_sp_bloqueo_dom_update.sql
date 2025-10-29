-- Stored Procedure: sp_bloqueo_dom_update
-- Tipo: CRUD
-- Descripción: Actualiza un domicilio bloqueado existente.
-- Generado para formulario: bloqueoDomiciliosfrm
-- Fecha: 2025-08-26 14:44:52

CREATE OR REPLACE FUNCTION sp_bloqueo_dom_update(
    p_folio INTEGER,
    p_cvecalle INTEGER,
    p_calle VARCHAR,
    p_num_ext INTEGER,
    p_let_ext VARCHAR,
    p_num_int INTEGER,
    p_let_int VARCHAR,
    p_observacion VARCHAR,
    p_capturista VARCHAR,
    p_fecha DATE
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE bloqueo_dom
    SET cvecalle = p_cvecalle,
        calle = p_calle,
        num_ext = p_num_ext,
        let_ext = p_let_ext,
        num_int = p_num_int,
        let_int = p_let_int,
        observacion = p_observacion,
        capturista = p_capturista,
        fecha = p_fecha,
        hora = NOW()
    WHERE folio = p_folio;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;