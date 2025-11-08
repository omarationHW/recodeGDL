-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CuotasMdoMntto
-- Generado: 2025-08-26 23:36:08
-- Total SPs: 4
-- ============================================

-- SP 1/4: cuotasmdo_listar
-- Tipo: Catalog
-- Descripción: Lista todas las cuotas de mercado por año
-- --------------------------------------------

CREATE OR REPLACE FUNCTION cuotasmdo_listar() RETURNS TABLE (
  id_cuotas integer,
  axo integer,
  categoria integer,
  seccion varchar,
  clave_cuota integer,
  importe_cuota numeric,
  fecha_alta timestamp,
  id_usuario integer
) AS $$
BEGIN
  RETURN QUERY SELECT id_cuotas, axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario
    FROM public.ta_11_cuo_locales
    ORDER BY axo DESC, categoria, seccion, clave_cuota;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: cuotasmdo_insertar
-- Tipo: CRUD
-- Descripción: Inserta una nueva cuota de mercado por año
-- --------------------------------------------

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
  SELECT COUNT(*) INTO v_exists FROM public.ta_11_cuo_locales WHERE axo=p_axo AND categoria=p_categoria AND seccion=p_seccion AND clave_cuota=p_clave_cuota;
  IF v_exists > 0 THEN
    RETURN FALSE;
  END IF;
  INSERT INTO public.ta_11_cuo_locales (axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario)
    VALUES (p_axo, p_categoria, p_seccion, p_clave_cuota, p_importe, NOW(), p_id_usuario);
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: cuotasmdo_actualizar
-- Tipo: CRUD
-- Descripción: Actualiza una cuota de mercado existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION cuotasmdo_actualizar(
  p_id_cuotas integer,
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
  SELECT COUNT(*) INTO v_exists FROM public.ta_11_cuo_locales WHERE id_cuotas=p_id_cuotas;
  IF v_exists = 0 THEN
    RETURN FALSE;
  END IF;
  UPDATE public.ta_11_cuo_locales
    SET importe_cuota = p_importe,
        fecha_alta = NOW(),
        id_usuario = p_id_usuario
    WHERE id_cuotas = p_id_cuotas
      AND axo = p_axo
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND clave_cuota = p_clave_cuota;
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: cuotasmdo_eliminar
-- Tipo: CRUD
-- Descripción: Elimina una cuota de mercado por id
-- --------------------------------------------

CREATE OR REPLACE FUNCTION cuotasmdo_eliminar(
  p_id_cuotas integer
) RETURNS boolean AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM public.ta_11_cuo_locales WHERE id_cuotas=p_id_cuotas;
  IF v_exists = 0 THEN
    RETURN FALSE;
  END IF;
  DELETE FROM public.ta_11_cuo_locales WHERE id_cuotas=p_id_cuotas;
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

