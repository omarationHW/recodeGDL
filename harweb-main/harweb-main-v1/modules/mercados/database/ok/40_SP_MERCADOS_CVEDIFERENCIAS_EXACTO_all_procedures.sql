-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CveDiferencias
-- Generado: 2025-08-26 23:39:54
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_cve_diferencias
-- Tipo: Catalog
-- Descripción: Obtiene todas las claves de diferencias con información de usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cve_diferencias()
RETURNS TABLE (
    clave_diferencia smallint,
    descripcion varchar(60),
    cuenta_ingreso integer,
    fecha_actual timestamp,
    id_usuario integer,
    usuario varchar(20),
    nombre varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.clave_diferencia, a.descripcion, a.cuenta_ingreso, a.fecha_actual, a.id_usuario, b.usuario, b.nombre
    FROM public.ta_11_catalogo_dif a
    JOIN public.ta_12_passwords b ON b.id_usuario = a.id_usuario
    ORDER BY a.clave_diferencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_add_cve_diferencia
-- Tipo: CRUD
-- Descripción: Agrega una nueva clave de diferencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_cve_diferencia(
    p_descripcion varchar(60),
    p_cuenta_ingreso integer,
    p_id_usuario integer
) RETURNS TABLE (clave_diferencia smallint) AS $$
DECLARE
    new_clave smallint;
BEGIN
    SELECT COALESCE(MAX(clave_diferencia), 0) + 1 INTO new_clave FROM public.ta_11_catalogo_dif;
    INSERT INTO public.ta_11_catalogo_dif (clave_diferencia, descripcion, cuenta_ingreso, fecha_actual, id_usuario)
    VALUES (new_clave, UPPER(p_descripcion), p_cuenta_ingreso, NOW(), p_id_usuario);
    RETURN QUERY SELECT new_clave;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_update_cve_diferencia
-- Tipo: CRUD
-- Descripción: Actualiza una clave de diferencia existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_cve_diferencia(
    p_clave_diferencia smallint,
    p_descripcion varchar(60),
    p_cuenta_ingreso integer,
    p_id_usuario integer
) RETURNS void AS $$
BEGIN
    UPDATE public.ta_11_catalogo_dif
    SET descripcion = UPPER(p_descripcion),
        cuenta_ingreso = p_cuenta_ingreso,
        fecha_actual = NOW(),
        id_usuario = p_id_usuario
    WHERE clave_diferencia = p_clave_diferencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_get_cuentas_ingreso
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de cuentas de ingreso para selección.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cuentas_ingreso()
RETURNS TABLE (
    cta_aplicacion integer,
    descripcion varchar(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cta_aplicacion, descripcion FROM public.ta_12_cuentas_aplicacion ORDER BY cta_aplicacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

