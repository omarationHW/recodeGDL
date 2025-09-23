-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: GRep_Padron (EXACTO del archivo original)
-- Archivo: 15_SP_OTRASOBLIG_GREP_PADRON_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp34_padron
-- Tipo: Report
-- Descripción: Obtiene el padrón de concesiones con adeudos filtrado por tabla y vigencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp34_padron(par_tabla integer, par_vigencia text)
RETURNS TABLE(
    id_34_datos integer,
    control text,
    concesionario text,
    ubicacion text,
    nomcomercial text,
    lugar text,
    obs text,
    statusregistro text,
    unidades text,
    categoria text,
    seccion text,
    bloque text,
    sector text,
    superficie numeric,
    fechainicio date,
    fechafin date,
    recaudadora integer,
    zona integer,
    licencia integer,
    giro integer,
    tipoobligacion text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.nomcomercial, a.lugar, a.obs, b.descripcion as statusregistro, a.unidades, a.categoria, a.seccion, a.bloque, a.sector, a.superficie, a.fecha_inicio, a.fecha_fin, a.id_recaudadora, a.zona, a.licencia, a.giro, a.tipoobligacion
    FROM otrasoblig.t34_datos a
    JOIN otrasoblig.t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.cve_tab = par_tabla
      AND (par_vigencia = 'TODOS' OR b.descripcion = par_vigencia)
    ORDER BY a.control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: con34_gdetade_01
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de una concesión específica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION con34_gdetade_01(par_tab integer, par_control integer, par_rep text, par_fecha text)
RETURNS TABLE(
    concepto text,
    importe_adeudos numeric,
    importe_recargos numeric,
    importe_multa numeric,
    importe_gastos numeric,
    importe_actualizacion numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, importe_adeudos, importe_recargos, importe_multa, importe_gastos, importe_actualizacion
    FROM otrasoblig.t34_adeudos_detalle
    WHERE cve_tab = par_tab
      AND id_34_datos = par_control
      AND rep_tipo = par_rep
      AND periodo = par_fecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp34_vigencias_concesion
-- Tipo: Catalog
-- Descripción: Obtiene las vigencias de concesión disponibles para una tabla.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp34_vigencias_concesion(par_tab integer)
RETURNS TABLE(descripcion text) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT b.descripcion
    FROM otrasoblig.t34_datos a
    JOIN otrasoblig.t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.cve_tab = par_tab
    ORDER BY b.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp34_etiq_tabla
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas de la tabla para mostrar en el frontend.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp34_etiq_tabla(par_tab integer)
RETURNS TABLE(
    cve_tab text,
    abreviatura text,
    etiq_control text,
    concesionario text,
    ubicacion text,
    superficie text,
    fecha_inicio text,
    fecha_fin text,
    recaudadora text,
    sector text,
    zona text,
    licencia text,
    fecha_cancelacion text,
    unidad text,
    categoria text,
    seccion text,
    bloque text,
    nombre_comercial text,
    lugar text,
    obs text
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM otrasoblig.t34_etiq WHERE cve_tab = par_tab::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp34_nombre_tabla
-- Tipo: Catalog
-- Descripción: Obtiene el nombre de la tabla (rubro) para mostrar en el frontend.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp34_nombre_tabla(par_tab integer)
RETURNS TABLE(nombre text) AS $$
BEGIN
    RETURN QUERY
    SELECT nombre FROM otrasoblig.t34_tablas WHERE cve_tab = par_tab::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================