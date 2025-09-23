-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: COLONIAS (EXACTO del archivo original)
-- Archivo: 36_SP_CONVENIOS_COLONIAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: colonias_list
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo completo de colonias con zona y usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION colonias_list()
RETURNS TABLE (
    colonia SMALLINT,
    descripcion VARCHAR,
    id_rec SMALLINT,
    id_zona INTEGER,
    col_obra94 SMALLINT,
    id_usuario INTEGER,
    fecha_actual TIMESTAMP,
    zona VARCHAR,
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.colonia, a.descripcion, a.id_rec, a.id_zona, a.col_obra94, a.id_usuario, a.fecha_actual,
           upper(b.zona) as zona, c.usuario
    FROM public.ta_17_colonias a
    JOIN public.ta_12_zonas b ON a.id_zona = b.id_zona
    JOIN public.ta_12_passwords c ON a.id_usuario = c.id_usuario
    ORDER BY a.colonia;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: COLONIAS (EXACTO del archivo original)
-- Archivo: 36_SP_CONVENIOS_COLONIAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: colonias_update
-- Tipo: CRUD
-- Descripción: Actualiza los datos de una colonia existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION colonias_update(
    p_colonia SMALLINT,
    p_descripcion VARCHAR,
    p_id_rec SMALLINT,
    p_id_zona INTEGER,
    p_col_obra94 SMALLINT,
    p_id_usuario INTEGER
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE public.ta_17_colonias
    SET descripcion = p_descripcion,
        id_rec = p_id_rec,
        id_zona = p_id_zona,
        col_obra94 = p_col_obra94,
        id_usuario = p_id_usuario,
        fecha_actual = now()
    WHERE colonia = p_colonia;
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Colonia actualizada correctamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'Colonia no encontrada';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: COLONIAS (EXACTO del archivo original)
-- Archivo: 36_SP_CONVENIOS_COLONIAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: colonias_report
-- Tipo: Report
-- Descripción: Devuelve el catálogo de colonias para impresión/reporte.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION colonias_report()
RETURNS TABLE (
    colonia SMALLINT,
    descripcion VARCHAR,
    id_rec SMALLINT,
    id_zona INTEGER,
    col_obra94 SMALLINT,
    id_usuario INTEGER,
    fecha_actual TIMESTAMP,
    zona VARCHAR,
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.colonia, a.descripcion, a.id_rec, a.id_zona, a.col_obra94, a.id_usuario, a.fecha_actual,
           upper(b.zona) as zona, c.usuario
    FROM public.ta_17_colonias a
    JOIN public.ta_12_zonas b ON a.id_zona = b.id_zona
    JOIN public.ta_12_passwords c ON a.id_usuario = c.id_usuario
    ORDER BY a.colonia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

