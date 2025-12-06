-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CveDiferMntto
-- Generado: 2025-08-26 23:41:20
-- Actualizado: 2025-12-02
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_cve_diferencia_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de diferencias
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cve_diferencia_list()
RETURNS TABLE (
    clave_diferencia integer,
    descripcion text,
    cuenta_ingreso integer,
    fecha_actual timestamp,
    id_usuario integer,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.clave_diferencia,
        c.descripcion,
        c.cuenta_ingreso,
        c.fecha_actual,
        c.id_usuario,
        COALESCE(u.usuario, 'N/A') AS usuario
    FROM public.ta_11_catalogo_dif c
    LEFT JOIN padron_licencias.comun.ta_12_passwords u ON c.id_usuario = u.id_usuario
    ORDER BY c.clave_diferencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_cuentas_ingreso
-- Tipo: Catalog
-- Descripción: Lista el catálogo de cuentas de ingreso
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cuentas_ingreso()
RETURNS TABLE (
    cta_aplicacion integer,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cta_aplicacion, c.descripcion
    FROM public.ta_11_cuentas_ingresos c
    ORDER BY c.cta_aplicacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_insert_cve_diferencia
-- Tipo: CRUD
-- Descripción: Inserta una nueva clave de diferencia en ta_11_catalogo_dif
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_cve_diferencia(
    p_clave_diferencia integer,
    p_descripcion text,
    p_cuenta_ingreso integer,
    p_id_usuario integer
) RETURNS boolean AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_11_catalogo_dif WHERE clave_diferencia = p_clave_diferencia;
    IF v_exists > 0 THEN
        RETURN FALSE;
    END IF;
    INSERT INTO public.ta_11_catalogo_dif (clave_diferencia, descripcion, cuenta_ingreso, fecha_actual, id_usuario)
    VALUES (p_clave_diferencia, UPPER(p_descripcion), p_cuenta_ingreso, NOW(), p_id_usuario);
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_update_cve_diferencia
-- Tipo: CRUD
-- Descripción: Actualiza una clave de diferencia existente en ta_11_catalogo_dif
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_cve_diferencia(
    p_clave_diferencia integer,
    p_descripcion text,
    p_cuenta_ingreso integer,
    p_id_usuario integer
) RETURNS boolean AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_11_catalogo_dif WHERE clave_diferencia = p_clave_diferencia;
    IF v_exists = 0 THEN
        RETURN FALSE;
    END IF;
    UPDATE public.ta_11_catalogo_dif
    SET descripcion = UPPER(p_descripcion),
        cuenta_ingreso = p_cuenta_ingreso,
        fecha_actual = NOW(),
        id_usuario = p_id_usuario
    WHERE clave_diferencia = p_clave_diferencia;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_delete_cve_diferencia
-- Tipo: CRUD
-- Descripción: Elimina una clave de diferencia por clave_diferencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_cve_diferencia(
    p_clave_diferencia integer
) RETURNS boolean AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_11_catalogo_dif WHERE clave_diferencia = p_clave_diferencia;
    IF v_exists = 0 THEN
        RETURN FALSE;
    END IF;
    DELETE FROM public.ta_11_catalogo_dif WHERE clave_diferencia = p_clave_diferencia;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

