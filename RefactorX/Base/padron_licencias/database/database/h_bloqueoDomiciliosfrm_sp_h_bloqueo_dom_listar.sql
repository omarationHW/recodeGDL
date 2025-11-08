-- Stored Procedure: sp_h_bloqueo_dom_listar
-- Tipo: Report
-- Descripción: Lista todos los domicilios históricos bloqueados, ordenados por el campo especificado.
-- Generado para formulario: h_bloqueoDomiciliosfrm
-- Fecha: 2025-08-27 18:27:22

CREATE OR REPLACE FUNCTION sp_h_bloqueo_dom_listar(p_order TEXT DEFAULT 'calle,num_ext')
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
    RETURN QUERY EXECUTE format('SELECT * FROM h_bloqueo_dom ORDER BY %s', p_order);
END;
$$ LANGUAGE plpgsql;