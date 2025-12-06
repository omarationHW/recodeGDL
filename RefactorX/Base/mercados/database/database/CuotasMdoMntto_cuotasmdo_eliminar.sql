-- Stored Procedure: cuotasmdo_eliminar
-- Tipo: CRUD
-- Descripción: Elimina una cuota de mercado por id
-- Generado para formulario: CuotasMdoMntto
-- Fecha: 2025-08-26 23:36:08

DROP FUNCTION IF EXISTS cuotasmdo_eliminar(integer);

CREATE OR REPLACE FUNCTION cuotasmdo_eliminar(
  p_id_cuotas integer
) RETURNS TABLE(eliminar boolean) AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_11_cuo_locales WHERE id_cuotas=p_id_cuotas;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT false;
    RETURN;
  END IF;

  DELETE FROM ta_11_cuo_locales WHERE id_cuotas=p_id_cuotas;

  RETURN QUERY SELECT true;
END;
$$ LANGUAGE plpgsql;