-- Stored Procedure: sp_actualiza_ubicodifica
-- Tipo: CRUD
-- Descripción: Actualiza un registro de codificación de ubicación (reactiva o actualiza).
-- Generado para formulario: Ubicodifica
-- Fecha: 2025-08-27 15:58:02

CREATE OR REPLACE FUNCTION sp_actualiza_ubicodifica(p_cvecuenta INTEGER, p_usuario TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE ubicacion_req
    SET fec_alta = CURRENT_DATE,
        usuario_alta = p_usuario,
        vigencia = 'V',
        fec_mov = CURRENT_DATE,
        fec_baja = NULL,
        usuario_mov = p_usuario
    WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;