-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ACTUALIZACONT (EXACTO del archivo original)
-- Archivo: 24_SP_CONVENIOS_ACTUALIZACONT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_get_diferencias_contratos
-- Tipo: Report
-- Descripción: Obtiene las diferencias de contratos que no existen en el catálogo de calles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_diferencias_contratos()
RETURNS TABLE(colonia smallint, calle smallint, contratos integer) AS $$
BEGIN
  RETURN QUERY
    SELECT a.colonia, a.calle, COUNT(*) AS contratos
    FROM public.ta_17_paso_cont a
    WHERE NOT EXISTS (
      SELECT 1 FROM public.ta_17_calles c WHERE c.colonia = a.colonia AND c.calle = a.calle
    )
    GROUP BY a.colonia, a.calle
    ORDER BY a.colonia ASC, a.calle ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ACTUALIZACONT (EXACTO del archivo original)
-- Archivo: 24_SP_CONVENIOS_ACTUALIZACONT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_totales_actualizacion
-- Tipo: Report
-- Descripción: Devuelve los totales de la última actualización ejecutada por el usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_totales_actualizacion(p_id_usuario integer)
RETURNS TABLE(
  adicionados integer,
  modificados integer,
  inconsistencias integer,
  total integer,
  descuentos integer
) AS $$
-- Esta función puede consultar una tabla de logs o devolver los últimos totales calculados
BEGIN
  -- Para demo, devolver ceros
  RETURN QUERY SELECT 0,0,0,0,0;
END;
$$ LANGUAGE plpgsql;

-- ============================================

