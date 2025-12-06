-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public, comun;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: AutCargaPagos
-- Generado: 2025-08-26 22:46:42
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_autcargapag_list
-- Tipo: Catalog
-- Descripción: Lista todas las autorizaciones de carga de pagos, con datos de usuario y permisos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autcargapag_list(p_oficina integer DEFAULT NULL)
RETURNS TABLE (
    fecha_ingreso date,
    oficina smallint,
    autorizar char(1),
    fecha_limite date,
    id_usupermiso integer,
    comentarios text,
    id_usuario integer,
    actualizacion timestamp,
    nombre varchar,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.fecha_ingreso, a.oficina, a.autorizar, a.fecha_limite, a.id_usupermiso, a.comentarios, a.id_usuario, a.actualizacion, b.nombre, c.usuario
    FROM mercados.public.ta_11_autcargapag a
    JOIN comun.ta_12_passwords b ON b.id_usuario = a.id_usupermiso
    JOIN comun.ta_12_passwords c ON c.id_usuario = a.id_usuario
    WHERE (p_oficina IS NULL OR a.oficina = p_oficina)
    ORDER BY a.fecha_ingreso DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_autcargapag_create
-- Tipo: CRUD
-- Descripción: Crea una nueva autorización de carga de pagos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autcargapag_create(
    p_fecha_ingreso date,
    p_oficina smallint,
    p_autorizar char(1),
    p_fecha_limite date,
    p_id_usupermiso integer,
    p_comentarios text,
    p_id_usuario integer
) RETURNS TABLE (
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
    INSERT INTO mercados.public.ta_11_autcargapag (
        fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
    ) VALUES (
        p_fecha_ingreso, p_oficina, p_autorizar, p_fecha_limite, p_id_usupermiso, p_comentarios, p_id_usuario, NOW()
    );
    RETURN QUERY SELECT fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
    FROM mercados.public.ta_11_autcargapag
    WHERE fecha_ingreso = p_fecha_ingreso AND oficina = p_oficina;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_autcargapag_update
-- Tipo: CRUD
-- Descripción: Actualiza una autorización de carga de pagos existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autcargapag_update(
    p_fecha_ingreso date,
    p_oficina smallint,
    p_autorizar char(1),
    p_fecha_limite date,
    p_id_usupermiso integer,
    p_comentarios text,
    p_id_usuario integer
) RETURNS TABLE (
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
    UPDATE mercados.public.ta_11_autcargapag
    SET autorizar = p_autorizar,
        fecha_limite = p_fecha_limite,
        id_usupermiso = p_id_usupermiso,
        comentarios = p_comentarios,
        id_usuario = p_id_usuario,
        actualizacion = NOW()
    WHERE fecha_ingreso = p_fecha_ingreso AND oficina = p_oficina;
    RETURN QUERY SELECT fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
    FROM mercados.public.ta_11_autcargapag
    WHERE fecha_ingreso = p_fecha_ingreso AND oficina = p_oficina;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_autcargapag_show
-- Tipo: Catalog
-- Descripción: Devuelve el detalle de una autorización de carga de pagos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autcargapag_show(
    p_fecha_ingreso date,
    p_oficina smallint
) RETURNS TABLE (
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
    RETURN QUERY SELECT fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
    FROM mercados.public.ta_11_autcargapag
    WHERE fecha_ingreso = p_fecha_ingreso AND oficina = p_oficina;
END;
$$ LANGUAGE plpgsql;

-- ============================================