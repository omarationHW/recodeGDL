-- Stored Procedure: cuotasmdo_insertar
-- Tipo: CRUD
-- Descripción: Inserta una nueva cuota de mercado por año
-- Generado para formulario: CuotasMdoMntto
-- Fecha: 2025-08-26 23:36:08

CREATE OR REPLACE FUNCTION cuotasmdo_insertar(
  p_axo integer,
  p_categoria integer,
  p_seccion varchar,
  p_clave_cuota integer,
  p_importe numeric,
  p_id_usuario integer
) RETURNS boolean AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_11_cuo_locales WHERE axo=p_axo AND categoria=p_categoria AND seccion=p_seccion AND clave_cuota=p_clave_cuota;
  IF v_exists > 0 THEN
    RETURN FALSE;
  END IF;
  INSERT INTO ta_11_cuo_locales (axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario)
    VALUES (p_axo, p_categoria, p_seccion, p_clave_cuota, p_importe, NOW(), p_id_usuario);
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;