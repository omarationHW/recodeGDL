-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CveCuotaMntto
-- Generado: 2025-08-26 23:38:43
-- Actualizado: 2025-12-02
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_cve_cuota_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de cuota
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cve_cuota_list()
RETURNS TABLE (
    clave_cuota integer,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.clave_cuota, c.descripcion
    FROM public.ta_11_cve_cuota c
    ORDER BY c.clave_cuota;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_cve_cuota_insert
-- Tipo: CRUD
-- Descripción: Inserta una nueva clave de cuota en ta_11_cve_cuota
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cve_cuota_insert(
    p_clave_cuota integer,
    p_descripcion varchar
)
RETURNS boolean AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_11_cve_cuota WHERE clave_cuota = p_clave_cuota;
    IF v_exists > 0 THEN
        RETURN FALSE;
    END IF;
    INSERT INTO public.ta_11_cve_cuota (clave_cuota, descripcion)
    VALUES (p_clave_cuota, p_descripcion);
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_cve_cuota_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una clave de cuota
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cve_cuota_update(
    p_clave_cuota integer,
    p_descripcion varchar
)
RETURNS boolean AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_11_cve_cuota WHERE clave_cuota = p_clave_cuota;
    IF v_exists = 0 THEN
        RETURN FALSE;
    END IF;
    UPDATE public.ta_11_cve_cuota
    SET descripcion = p_descripcion
    WHERE clave_cuota = p_clave_cuota;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_cve_cuota_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de cuota por clave_cuota
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cve_cuota_delete(
    p_clave_cuota integer
)
RETURNS boolean AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_11_cve_cuota WHERE clave_cuota = p_clave_cuota;
    IF v_exists = 0 THEN
        RETURN FALSE;
    END IF;
    DELETE FROM public.ta_11_cve_cuota WHERE clave_cuota = p_clave_cuota;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================
