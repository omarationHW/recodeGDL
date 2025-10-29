-- Stored Procedure: sp_get_energia_by_local
-- Tipo: Catalog
-- Descripción: Obtiene los datos de energía eléctrica para un local dado
-- Generado para formulario: ConsultaDatosEnergia
-- Fecha: 2025-08-26 23:25:04

CREATE OR REPLACE FUNCTION sp_get_energia_by_local(p_id_local INT)
RETURNS TABLE (
  id_energia INT,
  id_local INT,
  cve_consumo VARCHAR(1),
  local_adicional VARCHAR(50),
  cantidad NUMERIC,
  vigencia VARCHAR(1),
  fecha_alta DATE,
  fecha_baja DATE,
  fecha_modificacion TIMESTAMP,
  id_usuario INT,
  usuario VARCHAR(50)
) AS $$
BEGIN
  RETURN QUERY
    SELECT e.id_energia, e.id_local, e.cve_consumo, e.local_adicional, e.cantidad, e.vigencia, e.fecha_alta, e.fecha_baja, e.fecha_modificacion, e.id_usuario, u.usuario
    FROM ta_11_energia e
    LEFT JOIN ta_12_passwords u ON e.id_usuario = u.id_usuario
    WHERE e.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;