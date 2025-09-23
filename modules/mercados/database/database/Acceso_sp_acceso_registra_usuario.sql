-- Stored Procedure: sp_acceso_registra_usuario
-- Tipo: CRUD
-- Descripción: Registra el usuario en la bitácora de acceso (opcional, para auditoría).
-- Generado para formulario: Acceso
-- Fecha: 2025-08-26 19:29:27

CREATE OR REPLACE FUNCTION sp_acceso_registra_usuario(p_usuario TEXT, p_contrasena TEXT)
RETURNS VOID AS $$
BEGIN
  INSERT INTO bitacora_acceso(usuario, clave, fecha_acceso)
  VALUES (p_usuario, p_contrasena, NOW());
END;
$$ LANGUAGE plpgsql;