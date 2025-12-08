-- ============================================
-- FIX: SPs de otras_obligaciones
-- Problemas: Datatype mismatch y referencias incorrectas
-- Fecha: 2025-11-25
-- ============================================

-- ============================================
-- 1. FIX sp_otras_oblig_get_etiquetas
-- ============================================
DROP FUNCTION IF EXISTS sp_otras_oblig_get_etiquetas(INTEGER);

CREATE OR REPLACE FUNCTION sp_otras_oblig_get_etiquetas(
    par_tab INTEGER
)
RETURNS TABLE (
    cve_tab VARCHAR,
    abreviatura VARCHAR,
    etiq_control VARCHAR,
    concesionario VARCHAR,
    ubicacion VARCHAR,
    superficie VARCHAR,
    fecha_inicio VARCHAR,
    fecha_fin VARCHAR,
    recaudadora VARCHAR,
    sector VARCHAR,
    zona VARCHAR,
    licencia VARCHAR,
    fecha_cancelacion VARCHAR,
    unidad VARCHAR,
    categoria VARCHAR,
    seccion VARCHAR,
    bloque VARCHAR,
    nombre_comercial VARCHAR,
    lugar VARCHAR,
    obs VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.cve_tab::VARCHAR,
        e.abreviatura::VARCHAR,
        e.etiq_control::VARCHAR,
        e.concesionario::VARCHAR,
        e.ubicacion::VARCHAR,
        e.superficie::VARCHAR,
        e.fecha_inicio::VARCHAR,
        e.fecha_fin::VARCHAR,
        e.recaudadora::VARCHAR,
        e.sector::VARCHAR,
        e.zona::VARCHAR,
        e.licencia::VARCHAR,
        e.fecha_cancelacion::VARCHAR,
        e.unidad::VARCHAR,
        e.categoria::VARCHAR,
        e.seccion::VARCHAR,
        e.bloque::VARCHAR,
        e.nombre_comercial::VARCHAR,
        e.lugar::VARCHAR,
        e.obs::VARCHAR
    FROM t34_etiq e
    WHERE e.cve_tab = par_tab::VARCHAR;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            par_tab::VARCHAR, ''::VARCHAR, 'Control'::VARCHAR, 'Concesionario'::VARCHAR,
            'Ubicación'::VARCHAR, 'Superficie'::VARCHAR, 'Fecha Inicio'::VARCHAR, 'Fecha Fin'::VARCHAR,
            'Recaudadora'::VARCHAR, 'Sector'::VARCHAR, 'Zona'::VARCHAR, 'Licencia'::VARCHAR,
            'Fecha Cancelación'::VARCHAR, 'Unidad'::VARCHAR, 'Categoría'::VARCHAR, 'Sección'::VARCHAR,
            'Bloque'::VARCHAR, 'Nombre Comercial'::VARCHAR, 'Lugar'::VARCHAR, 'Observaciones'::VARCHAR;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 2. FIX sp_otras_oblig_get_tablas
-- Problema: referencia a db_ingresos.t34_unidades inexistente
-- Tablas reales: public.t34_tablas, public.t34_unidades
-- ============================================
DROP FUNCTION IF EXISTS sp_otras_oblig_get_tablas(INTEGER);

CREATE OR REPLACE FUNCTION sp_otras_oblig_get_tablas(
    par_tab INTEGER
)
RETURNS TABLE (
    cve_tab VARCHAR,
    nombre VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.cve_tab::VARCHAR,
        COALESCE(t.nombre, 'Sin nombre')::VARCHAR,
        COALESCE(u.descripcion, '')::VARCHAR
    FROM t34_tablas t
    LEFT JOIN t34_unidades u ON u.cve_tab::VARCHAR = t.cve_tab::VARCHAR
    WHERE t.cve_tab::VARCHAR = par_tab::VARCHAR
    GROUP BY t.cve_tab, t.nombre, u.descripcion
    ORDER BY t.cve_tab, t.nombre, u.descripcion
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            par_tab::VARCHAR AS cve_tab,
            'Tabla desconocida'::VARCHAR AS nombre,
            ''::VARCHAR AS descripcion;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Verificación
SELECT 'SPs corregidos: sp_otras_oblig_get_etiquetas, sp_otras_oblig_get_tablas' AS resultado;
