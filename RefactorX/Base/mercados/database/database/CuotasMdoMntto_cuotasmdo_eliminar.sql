-- Stored Procedure: cuotasmdo_eliminar
-- Tipo: CRUD
-- Descripción: Elimina una cuota de mercado por id
-- Generado para formulario: CuotasMdoMntto
-- Fecha: 2025-08-26 23:36:08

CREATE OR REPLACE FUNCTION cuotasmdo_eliminar(
  p_id_cuotas integer
) RETURNS boolean AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_11_cuo_locales WHERE id_cuotas=p_id_cuotas;
  IF v_exists = 0 THEN
    RETURN FALSE;
  END IF;
  DELETE FROM ta_11_cuo_locales WHERE id_cuotas=p_id_cuotas;
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;