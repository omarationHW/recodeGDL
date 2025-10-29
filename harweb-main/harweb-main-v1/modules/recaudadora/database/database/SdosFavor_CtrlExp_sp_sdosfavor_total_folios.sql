-- Stored Procedure: sp_sdosfavor_total_folios
-- Tipo: Report
-- Descripción: Cuenta el total de folios por status.
-- Generado para formulario: SdosFavor_CtrlExp
-- Fecha: 2025-08-27 15:38:42

CREATE OR REPLACE FUNCTION sp_sdosfavor_total_folios(p_status TEXT DEFAULT NULL)
RETURNS INTEGER AS $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total
  FROM solic_sdosfavor
  WHERE (p_status IS NULL OR p_status = '' OR status = p_status);
  RETURN v_total;
END;
$$ LANGUAGE plpgsql;