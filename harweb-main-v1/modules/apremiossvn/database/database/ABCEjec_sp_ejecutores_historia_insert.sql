-- Stored Procedure: sp_ejecutores_historia_insert
-- Tipo: CRUD
-- Descripción: Registra un cambio en el historial de ejecutores (opcional, para auditoría)
-- Generado para formulario: ABCEjec
-- Fecha: 2025-08-27 13:29:40

CREATE OR REPLACE FUNCTION sp_ejecutores_historia_insert(
  p_cve_eje integer,
  p_id_rec smallint,
  p_usuario integer,
  p_accion varchar(20),
  p_fecha timestamp
) RETURNS void AS $$
BEGIN
  INSERT INTO ta_15_ejecutores_historia (cve_eje, id_rec, usuario, accion, fecha)
  VALUES (p_cve_eje, p_id_rec, p_usuario, p_accion, p_fecha);
END;
$$ LANGUAGE plpgsql;