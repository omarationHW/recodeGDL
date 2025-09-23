-- Stored Procedure: sp_get_usuarios
-- Tipo: Catalog
-- Descripción: Obtiene la lista de usuarios del sistema.
-- Generado para formulario: sfrm_rep_folio
-- Fecha: 2025-08-27 14:30:56

CREATE OR REPLACE FUNCTION sp_get_usuarios()
RETURNS TABLE(
  id_usuario INTEGER,
  usuario TEXT,
  nombre TEXT,
  estado TEXT,
  id_rec SMALLINT,
  nivel SMALLINT
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec, nivel
      FROM ta_12_passwords;
END;
$$ LANGUAGE plpgsql;