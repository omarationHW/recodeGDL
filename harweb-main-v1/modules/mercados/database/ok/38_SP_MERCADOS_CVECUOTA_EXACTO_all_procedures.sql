-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CveCuota
-- Generado: 2025-08-26 23:37:19
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_cvecuota_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de cuota.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cvecuota_list()
RETURNS TABLE(clave_cuota smallint, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT clave_cuota, descripcion FROM public.ta_11_cve_cuota ORDER BY clave_cuota ASC;
END;$$;

-- ============================================

-- SP 2/5: sp_cvecuota_create
-- Tipo: CRUD
-- Descripción: Crea una nueva clave de cuota.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cvecuota_create(p_clave_cuota smallint, p_descripcion varchar)
RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO public.ta_11_cve_cuota (clave_cuota, descripcion)
  VALUES (p_clave_cuota, UPPER(TRIM(p_descripcion)));
END;$$;

-- ============================================

-- SP 3/5: sp_cvecuota_update
-- Tipo: CRUD
-- Descripción: Actualiza una clave de cuota existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cvecuota_update(p_clave_cuota smallint, p_descripcion varchar)
RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE public.ta_11_cve_cuota
  SET descripcion = UPPER(TRIM(p_descripcion))
  WHERE clave_cuota = p_clave_cuota;
END;$$;

-- ============================================

-- SP 4/5: sp_cvecuota_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de cuota.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cvecuota_delete(p_clave_cuota smallint)
RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  DELETE FROM public.ta_11_cve_cuota WHERE clave_cuota = p_clave_cuota;
END;$$;

-- ============================================

-- SP 5/5: sp_cvecuota_get
-- Tipo: Catalog
-- Descripción: Obtiene una clave de cuota específica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cvecuota_get(p_clave_cuota smallint)
RETURNS TABLE(clave_cuota smallint, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT clave_cuota, descripcion FROM public.ta_11_cve_cuota WHERE clave_cuota = p_clave_cuota;
END;$$;

-- ============================================

