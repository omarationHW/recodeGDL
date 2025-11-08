-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: AGENDAVISITASFRM (EXACTO del archivo original)
-- Archivo: 05_SP_LICENCIAS_AGENDAVISITASFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_get_dependencias
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de dependencias disponibles para agendar visitas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_dependencias()
RETURNS TABLE (
    id_dependencia INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id_dependencia, d.descripcion
    FROM c_dep_horario c
    INNER JOIN c_dependencias d ON c.id_dependencia = d.id_dependencia
    GROUP BY d.id_dependencia, d.descripcion
    ORDER BY d.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: AGENDAVISITASFRM (EXACTO del archivo original)
-- Archivo: 05_SP_LICENCIAS_AGENDAVISITASFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: fn_dialetra
-- Tipo: Catalog
-- Descripción: Devuelve el nombre del día de la semana en español a partir del número de día (0=domingo, 1=lunes, ...).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION fn_dialetra(p_dia INTEGER)
RETURNS VARCHAR AS $$
DECLARE
    dias TEXT[] := ARRAY['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
BEGIN
    IF p_dia IS NULL OR p_dia < 0 OR p_dia > 6 THEN
        RETURN '';
    END IF;
    RETURN dias[p_dia+1];
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================

