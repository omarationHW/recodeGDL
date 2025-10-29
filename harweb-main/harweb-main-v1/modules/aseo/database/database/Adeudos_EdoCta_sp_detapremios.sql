-- Stored Procedure: sp_detapremios
-- Tipo: CRUD
-- Descripción: Genera el detalle de apremios para un contrato
-- Generado para formulario: Adeudos_EdoCta
-- Fecha: 2025-08-27 13:42:14

CREATE OR REPLACE PROCEDURE sp_detapremios(
  IN p_control_contrato INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Aquí se puede poblar una tabla temporal de apremios si es necesario
  -- Ejemplo: INSERT INTO det_apremios ...
  -- O simplemente actualizar datos relacionados
  -- ...
END;
$$;