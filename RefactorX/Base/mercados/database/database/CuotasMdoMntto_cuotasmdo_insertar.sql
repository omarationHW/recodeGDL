-- Stored Procedure: cuotasmdo_insertar
-- Tipo: CRUD
-- Descripción: Inserta una nueva cuota de mercado por año
-- Generado para formulario: CuotasMdoMntto
-- Fecha: 2025-08-26 23:36:08

DROP FUNCTION IF EXISTS cuotasmdo_insertar(integer, integer, varchar, integer, numeric, integer);

CREATE OR REPLACE FUNCTION cuotasmdo_insertar(
  p_axo smallint,
  p_categoria smallint,
  p_seccion char(2),
  p_clave_cuota smallint,
  p_importe numeric(16,2),
  p_id_usuario integer
) RETURNS TABLE(insertar boolean) AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_11_cuo_locales
  WHERE axo=p_axo AND categoria=p_categoria AND seccion=p_seccion AND clave_cuota=p_clave_cuota;

  IF v_exists > 0 THEN
    RETURN QUERY SELECT false;
    RETURN;
  END IF;

  INSERT INTO ta_11_cuo_locales (axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario)
    VALUES (p_axo, p_categoria, p_seccion, p_clave_cuota, p_importe, NOW(), p_id_usuario);

  RETURN QUERY SELECT true;
END;
$$ LANGUAGE plpgsql;