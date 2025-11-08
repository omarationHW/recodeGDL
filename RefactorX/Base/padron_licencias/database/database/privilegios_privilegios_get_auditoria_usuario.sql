-- Stored Procedure: privilegios_get_auditoria_usuario
-- Tipo: Report
-- Descripción: Obtiene la bitácora de permisos de un usuario
-- Generado para formulario: privilegios
-- Fecha: 2025-08-26 17:28:26

CREATE OR REPLACE FUNCTION privilegios_get_auditoria_usuario(p_usuario TEXT)
RETURNS TABLE(num_tag INTEGER, descripcion TEXT, id INTEGER, fechahora TIMESTAMP, equipo TEXT, proc TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT p.num_tag, p.descripcion, a.id, a.fechahora, a.equipo,
    CASE a.proc
      WHEN 'I' THEN 'Asignado'
      WHEN 'D' THEN 'Eliminado'
      WHEN 'U' THEN 'Actualizado'
      ELSE a.proc
    END AS proc
  FROM c_programas p
  INNER JOIN aud_auto a ON a.num_tag = p.num_tag AND a.usuario = p_usuario
  WHERE p.num_tag BETWEEN 8000 AND 8999;
END;
$$ LANGUAGE plpgsql;