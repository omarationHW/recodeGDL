-- Stored Procedure: sp_get_datosrcmhis
-- Tipo: Catalog
-- Descripción: Obtiene histórico de datos RCM y nombre de usuario
-- Generado para formulario: ConIndividual
-- Fecha: 2025-08-28 17:50:28

CREATE OR REPLACE PROCEDURE sp_get_datosrcmhis(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT d.*, p.nombre AS usuari FROM ta_13_datosrcmhis d
  LEFT JOIN ta_12_passwords p ON d.usuario = p.id_usuario
  WHERE d.control_rcm = control_rcm;
END;
$$;