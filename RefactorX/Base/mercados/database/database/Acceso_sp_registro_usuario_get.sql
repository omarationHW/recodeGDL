-- Stored Procedure: sp_registro_usuario_get
-- Tipo: Catalog
-- Descripción: Obtiene el valor del usuario guardado en el registro.
-- Generado para formulario: Acceso
-- Fecha: 2025-08-26 20:16:48

CREATE OR REPLACE FUNCTION sp_registro_usuario_get(p_clave TEXT)
RETURNS TEXT AS $$
DECLARE
  v_valor TEXT;
BEGIN
  SELECT valor INTO v_valor FROM registro_usuario WHERE clave = p_clave;
  RETURN v_valor;
END;
$$ LANGUAGE plpgsql;