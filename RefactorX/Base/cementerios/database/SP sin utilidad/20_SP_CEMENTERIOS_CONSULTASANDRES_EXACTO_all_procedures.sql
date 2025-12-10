-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: CONSULTASANDRES (EXACTO del archivo original)
-- Archivo: 20_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_consultar_sanandres
-- Tipo: Catalog
-- Descripción: Devuelve todos los registros de la tabla 'datos' del cementerio San Andrés.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultar_sanandres()
RETURNS TABLE (
    id integer,
    clase text,
    seccion text,
    linea text,
    fosa text,
    ppago text,
    nombre text,
    fcompra timestamp,
    otros text,
    clave smallint,
    medida float,
    calle text,
    colonia text
) AS $$
BEGIN
    RETURN QUERY SELECT id, clase, seccion, linea, fosa, ppago, nombre, fcompra, otros, clave, medida, calle, colonia FROM datos;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: CONSULTASANDRES (EXACTO del archivo original)
-- Archivo: 20_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_total_sanandres
-- Tipo: Report
-- Descripción: Devuelve el total de registros de la tabla 'datos' para paginación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_total_sanandres()
RETURNS integer AS $$
DECLARE
    total integer;
BEGIN
    SELECT COUNT(*) INTO total FROM datos;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- ============================================

