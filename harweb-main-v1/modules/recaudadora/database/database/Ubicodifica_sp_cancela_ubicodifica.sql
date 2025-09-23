-- Stored Procedure: sp_cancela_ubicodifica
-- Tipo: CRUD
-- Descripción: Cancela (da de baja lógica) un registro de codificación de ubicación.
-- Generado para formulario: Ubicodifica
-- Fecha: 2025-08-27 15:58:02

CREATE OR REPLACE FUNCTION sp_cancela_ubicodifica(p_cvecuenta INTEGER, p_usuario TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE ubicacion_req
    SET fec_baja = CURRENT_DATE,
        vigencia = 'C',
        fec_mov = CURRENT_DATE,
        usuario_mov = p_usuario
    WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;