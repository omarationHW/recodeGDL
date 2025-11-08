-- Stored Procedure: sp_h_bloqueo_dom_detalle
-- Tipo: Catalog
-- Descripción: Obtiene el detalle de un domicilio histórico bloqueado por ID.
-- Generado para formulario: h_bloqueoDomiciliosfrm
-- Fecha: 2025-08-27 18:27:22

CREATE OR REPLACE FUNCTION sp_h_bloqueo_dom_detalle(p_id INTEGER)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvecalle INTEGER,
    calle VARCHAR,
    num_ext INTEGER,
    let_ext VARCHAR,
    num_int INTEGER,
    let_int VARCHAR,
    folio INTEGER,
    fecha DATE,
    hora TIMESTAMP,
    vig VARCHAR,
    observacion VARCHAR,
    capturista VARCHAR,
    fecha_mov TIMESTAMP,
    motivo_mov VARCHAR,
    tipo_mov VARCHAR,
    modifico VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM h_bloqueo_dom WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;