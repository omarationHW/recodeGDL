-- Stored Procedure: sp_sdosfavor_assign_folios
-- Tipo: CRUD
-- Descripción: Asigna un nuevo status a una lista de folios.
-- Generado para formulario: SdosFavor_CtrlExp
-- Fecha: 2025-08-27 15:38:42

CREATE OR REPLACE FUNCTION sp_sdosfavor_assign_folios(p_folios INTEGER[], p_new_status TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE solic_sdosfavor
  SET status = p_new_status
  WHERE folio = ANY(p_folios);
END;
$$ LANGUAGE plpgsql;