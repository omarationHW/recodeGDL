-- Stored Procedure: sp_ligarequisitos_add
-- Tipo: CRUD
-- Descripción: Agrega un requisito a un giro si no existe.
-- Generado para formulario: LigaRequisitos
-- Fecha: 2025-08-26 17:13:30

CREATE OR REPLACE FUNCTION sp_ligarequisitos_add(p_id_giro INT, p_req INT)
RETURNS TEXT AS $$
DECLARE
  existe INT;
BEGIN
  SELECT 1 INTO existe FROM giro_req WHERE id_giro = p_id_giro AND req = p_req;
  IF existe IS NOT NULL THEN
    RETURN 'El requisito ya está asignado a este giro';
  END IF;
  INSERT INTO giro_req (id_giro, req) VALUES (p_id_giro, p_req);
  RETURN 'Requisito asignado correctamente';
END;
$$ LANGUAGE plpgsql;