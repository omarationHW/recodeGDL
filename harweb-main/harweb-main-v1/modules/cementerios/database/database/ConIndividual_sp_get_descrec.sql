-- Stored Procedure: sp_get_descrec
-- Tipo: Catalog
-- Descripción: Obtiene descuentos recurrentes y nombre de usuario
-- Generado para formulario: ConIndividual
-- Fecha: 2025-08-28 17:50:28

CREATE OR REPLACE PROCEDURE sp_get_descrec(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT d.*, p.nombre FROM ta_13_descrec d
  JOIN ta_12_passwords p ON d.usuario_alta = p.usuario
  WHERE d.id_folio = control_rcm;
END;
$$;