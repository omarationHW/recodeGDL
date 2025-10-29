-- Stored Procedure: sp_get_passwords
-- Tipo: Catalog
-- Descripción: Obtiene datos de usuario por id_usuario
-- Generado para formulario: ConIndividual
-- Fecha: 2025-08-28 17:50:28

CREATE OR REPLACE PROCEDURE sp_get_passwords(IN usuario integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT * FROM ta_12_passwords WHERE id_usuario = usuario;
END;
$$;