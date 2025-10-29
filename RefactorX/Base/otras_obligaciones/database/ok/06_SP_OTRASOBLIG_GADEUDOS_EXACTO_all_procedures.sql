-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: GAdeudos (EXACTO del archivo original)
-- Archivo: 06_SP_OTRASOBLIG_GADEUDOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_gadeudos_busca
-- Tipo: Report
-- Descripción: Busca el registro de concesión/control para GAdeudos por tabla y control
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_gadeudos_busca(par_tab TEXT, par_control TEXT)
RETURNS TABLE(
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie NUMERIC,
    fechainicio DATE,
    fechafin DATE,
    recaudadora INTEGER,
    sector TEXT,
    zona INTEGER,
    licencia INTEGER,
    unidades TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.control, d.concesionario, d.ubicacion, d.superficie, d.fecha_inicio, d.fecha_fin, d.id_recaudadora, d.sector, d.id_zona, d.licencia, u.descripcion as unidades
    FROM otrasoblig.t34_datos d
    LEFT JOIN otrasoblig.t34_unidades u ON u.cve_tab = d.cve_tab
    WHERE d.cve_tab = par_tab AND d.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_gadeudos_detalle
-- Tipo: Report
-- Descripción: Devuelve el detalle de adeudos para un control, periodo y tipo de reporte
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_gadeudos_detalle(par_tab TEXT, par_control TEXT, par_rep TEXT, par_fecha TEXT)
RETURNS TABLE(
    concepto TEXT,
    importe_adeudos NUMERIC,
    importe_recargos NUMERIC,
    importe_multas NUMERIC,
    importe_actualizacion NUMERIC,
    importe_gastos NUMERIC
) AS $$
DECLARE
    v_id_datos INTEGER;
    v_ano INTEGER;
    v_mes INTEGER;
BEGIN
    SELECT id_34_datos INTO v_id_datos FROM otrasoblig.t34_datos WHERE cve_tab = par_tab AND control = par_control LIMIT 1;
    IF v_id_datos IS NULL THEN
        RETURN;
    END IF;
    v_ano := split_part(par_fecha, '-', 1)::INTEGER;
    v_mes := split_part(par_fecha, '-', 2)::INTEGER;
    RETURN QUERY
    SELECT c.concepto, c.importe_adeudos, c.importe_recargos, c.importe_multa, c.importe_actualizacion, c.importe_gastos
    FROM otrasoblig.t34_conceptos c
    WHERE c.id_datos = v_id_datos
      AND (c.anio < v_ano OR (c.anio = v_ano AND c.mes <= v_mes))
    ORDER BY c.anio, c.mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_gadeudos_tablas
-- Tipo: Catalog
-- Descripción: Devuelve información de la tabla/rubro
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_gadeudos_tablas(par_tab TEXT)
RETURNS TABLE(
    cve_tab TEXT,
    nombre TEXT,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM otrasoblig.t34_tablas a
    LEFT JOIN otrasoblig.t34_unidades b ON b.cve_tab = a.cve_tab
    WHERE a.cve_tab = par_tab
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_gadeudos_etiquetas
-- Tipo: Catalog
-- Descripción: Devuelve las etiquetas de la tabla para mostrar en el frontend
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_gadeudos_etiquetas(par_tab TEXT)
RETURNS TABLE(
    cve_tab TEXT,
    abreviatura TEXT,
    etiq_control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie TEXT,
    fecha_inicio TEXT,
    fecha_fin TEXT,
    recaudadora TEXT,
    sector TEXT,
    zona TEXT,
    licencia TEXT,
    fecha_cancelacion TEXT,
    unidad TEXT,
    categoria TEXT,
    seccion TEXT,
    bloque TEXT,
    nombre_comercial TEXT,
    lugar TEXT,
    obs TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM otrasoblig.t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

-- ============================================