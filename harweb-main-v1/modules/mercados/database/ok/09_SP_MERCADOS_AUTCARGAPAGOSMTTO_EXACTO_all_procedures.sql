-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: AutCargaPagosMtto
-- Generado: 2025-08-26 22:48:05
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_get_users_with_permission
-- Tipo: Catalog
-- Descripción: Obtiene los usuarios con permiso para autorizar fechas de ingreso en una oficina.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_users_with_permission(p_oficina integer)
RETURNS TABLE(id_usuario integer, usuario text, nombre text) AS $$
BEGIN
  RETURN QUERY
    SELECT a.id_usuario, a.usuario, a.nombre
    FROM public.ta_12_passwords a
    JOIN public.ta_autoriza b ON b.id_usuario = a.id_usuario
    WHERE a.id_rec = p_oficina
      AND a.estado = 'A'
      AND b.id_modulo = 11
      AND b.tag IN (202,203,204)
    ORDER BY a.id_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_autcargapag_by_fecha
-- Tipo: CRUD
-- Descripción: Obtiene el registro de autorización de carga de pagos por fecha de ingreso.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_autcargapag_by_fecha(p_fecha date)
RETURNS TABLE(
  fecha_ingreso date,
  oficina smallint,
  autorizar char(1),
  fecha_limite date,
  id_usupermiso integer,
  comentarios text,
  id_usuario integer,
  actualizacion timestamp
) AS $$
BEGIN
  RETURN QUERY
    SELECT fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
    FROM public.ta_11_autcargapag
    WHERE fecha_ingreso = p_fecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_insert_autcargapag
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de autorización de carga de pagos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_autcargapag(
  p_fecha_ingreso date,
  p_oficina smallint,
  p_autorizar char(1),
  p_fecha_limite date,
  p_id_usupermiso integer,
  p_comentarios text,
  p_id_usuario integer,
  p_actualizacion timestamp
) RETURNS TABLE(result text) AS $$
BEGIN
  INSERT INTO public.ta_11_autcargapag (
    fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
  ) VALUES (
    p_fecha_ingreso, p_oficina, p_autorizar, p_fecha_limite, p_id_usupermiso, p_comentarios, p_id_usuario, p_actualizacion
  );
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_update_autcargapag
-- Tipo: CRUD
-- Descripción: Actualiza un registro de autorización de carga de pagos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_autcargapag(
  p_fecha_ingreso date,
  p_oficina smallint,
  p_autorizar char(1),
  p_fecha_limite date,
  p_id_usupermiso integer,
  p_comentarios text,
  p_id_usuario integer,
  p_actualizacion timestamp
) RETURNS TABLE(result text) AS $$
BEGIN
  UPDATE public.ta_11_autcargapag
  SET autorizar = p_autorizar,
      fecha_limite = p_fecha_limite,
      id_usupermiso = p_id_usupermiso,
      comentarios = p_comentarios,
      id_usuario = p_id_usuario,
      actualizacion = p_actualizacion
  WHERE fecha_ingreso = p_fecha_ingreso AND oficina = p_oficina;
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_list_autcargapag
-- Tipo: Catalog
-- Descripción: Lista todas las fechas de autorización de carga de pagos para una oficina.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_list_autcargapag(p_oficina integer)
RETURNS TABLE(
  fecha_ingreso date,
  oficina smallint,
  autorizar char(1),
  fecha_limite date,
  id_usupermiso integer,
  comentarios text,
  id_usuario integer,
  actualizacion timestamp,
  nombre text
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.fecha_ingreso, a.oficina, a.autorizar, a.fecha_limite, a.id_usupermiso, a.comentarios, a.id_usuario, a.actualizacion, b.nombre
    FROM public.ta_11_autcargapag a
    JOIN public.ta_12_passwords b ON b.id_usuario = a.id_usupermiso
    WHERE a.oficina = p_oficina
    ORDER BY a.fecha_ingreso DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================