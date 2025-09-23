-- Stored Procedure: sp_registro_usuario_set
-- Tipo: Catalog
-- Descripción: Guarda el usuario en la tabla de registro (simula el registro de Windows).
-- Generado para formulario: Acceso
-- Fecha: 2025-08-26 20:16:48

CREATE TABLE IF NOT EXISTS registro_usuario (
  clave TEXT PRIMARY KEY,
  valor TEXT
);

CREATE OR REPLACE FUNCTION sp_registro_usuario_set(p_clave TEXT, p_valor TEXT)
RETURNS VOID AS $$
BEGIN
  INSERT INTO registro_usuario (clave, valor) VALUES (p_clave, p_valor)
    ON CONFLICT (clave) DO UPDATE SET valor = EXCLUDED.valor;
END;
$$ LANGUAGE plpgsql;