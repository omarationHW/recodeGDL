-- Stored Procedure: sp_get_descpens
-- Tipo: Catalog
-- Descripción: Obtiene descuentos pensionados y nombre de usuario
-- Generado para formulario: ConIndividual
-- Fecha: 2025-08-28 17:50:28

CREATE OR REPLACE PROCEDURE sp_get_descpens(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT a.*, b.nombre FROM ta_13_descpens a
  JOIN ta_12_passwords b ON a.usuario = b.id_usuario
  WHERE a.control_rcm = control_rcm;
END;
$$;