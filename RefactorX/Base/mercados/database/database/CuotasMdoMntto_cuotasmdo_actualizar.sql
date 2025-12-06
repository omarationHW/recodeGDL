-- Stored Procedure: cuotasmdo_actualizar
-- Tipo: CRUD
-- Descripción: Actualiza una cuota de mercado existente
-- Generado para formulario: CuotasMdoMntto
-- Fecha: 2025-08-26 23:36:08

DROP FUNCTION IF EXISTS cuotasmdo_actualizar(integer, integer, integer, varchar, integer, numeric, integer);

CREATE OR REPLACE FUNCTION cuotasmdo_actualizar(
  p_id_cuotas integer,
  p_axo smallint,
  p_categoria smallint,
  p_seccion char(2),
  p_clave_cuota smallint,
  p_importe numeric(16,2),
  p_id_usuario integer
) RETURNS TABLE(actualizar boolean) AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_11_cuo_locales WHERE id_cuotas=p_id_cuotas;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT false;
    RETURN;
  END IF;

  UPDATE ta_11_cuo_locales
    SET importe_cuota = p_importe,
        fecha_alta = NOW(),
        id_usuario = p_id_usuario
    WHERE id_cuotas = p_id_cuotas
      AND axo = p_axo
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND clave_cuota = p_clave_cuota;

  RETURN QUERY SELECT true;
END;
$$ LANGUAGE plpgsql;