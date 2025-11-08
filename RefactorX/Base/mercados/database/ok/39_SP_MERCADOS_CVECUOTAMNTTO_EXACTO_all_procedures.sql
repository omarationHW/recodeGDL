-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CveCuotaMntto
-- Generado: 2025-08-26 23:38:43
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_cve_cuota_insert
-- Tipo: CRUD
-- Descripción: Inserta una nueva clave de cuota en ta_11_cve_cuota
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_cve_cuota_insert(
    p_clave_cuota INTEGER,
    p_descripcion VARCHAR(60)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.ta_11_cve_cuota (clave_cuota, descripcion)
    VALUES (p_clave_cuota, p_descripcion);
END;
$$;

-- ============================================

-- SP 2/3: sp_cve_cuota_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una clave de cuota
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_cve_cuota_update(
    p_clave_cuota INTEGER,
    p_descripcion VARCHAR(60)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.ta_11_cve_cuota
    SET descripcion = p_descripcion
    WHERE clave_cuota = p_clave_cuota;
END;
$$;

-- ============================================

-- SP 3/3: sp_cve_cuota_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de cuota por clave_cuota
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_cve_cuota_delete(
    p_clave_cuota INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public.ta_11_cve_cuota WHERE clave_cuota = p_clave_cuota;
END;
$$;

-- ============================================

