-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsRemesas
-- Generado: 2025-08-27 13:30:41
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_get_remesas
-- Tipo: Report
-- Descripción: Obtiene la lista de remesas filtradas por tipo (A, B, C, D), ordenadas por num_remesa descendente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_remesas(tipo_param character varying)
RETURNS TABLE (
    control integer,
    tipo character varying,
    fecha_inicio date,
    fecha_fin date,
    fecha_hoy date,
    num_remesa integer,
    cant_reg integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT control, tipo, fecha_inicio, fecha_fin, fecha_hoy, num_remesa, cant_reg
    FROM ta14_bitacora
    WHERE tipo = tipo_param
    ORDER BY num_remesa DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_get_remesa_detalle_edo
-- Tipo: Report
-- Descripción: Obtiene el detalle de una remesa del estado (tabla ta14_datos_edo) por nombre de remesa.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_remesa_detalle_edo(remesa_param character varying)
RETURNS SETOF ta14_datos_edo AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta14_datos_edo WHERE remesa = remesa_param;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_get_remesa_detalle_mpio
-- Tipo: Report
-- Descripción: Obtiene el detalle de una remesa municipal (tabla ta14_datos_mpio) por nombre de remesa.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_remesa_detalle_mpio(remesa_param character varying)
RETURNS SETOF ta14_datos_mpio AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta14_datos_mpio WHERE remesa = remesa_param;
END;
$$ LANGUAGE plpgsql;

-- ============================================

