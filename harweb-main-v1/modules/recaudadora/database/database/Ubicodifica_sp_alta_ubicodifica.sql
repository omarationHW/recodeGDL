-- Stored Procedure: sp_alta_ubicodifica
-- Tipo: CRUD
-- Descripción: Da de alta un registro de codificación de ubicación (ubicacion_req).
-- Generado para formulario: Ubicodifica
-- Fecha: 2025-08-27 15:58:02

CREATE OR REPLACE FUNCTION sp_alta_ubicodifica(p_cvecuenta INTEGER, p_usuario TEXT)
RETURNS INTEGER AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO ubicacion_req (cvecuenta, fec_alta, usuario_alta, vigencia, fec_mov, usuario_mov)
    VALUES (p_cvecuenta, CURRENT_DATE, p_usuario, 'V', CURRENT_DATE, p_usuario)
    RETURNING id INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;