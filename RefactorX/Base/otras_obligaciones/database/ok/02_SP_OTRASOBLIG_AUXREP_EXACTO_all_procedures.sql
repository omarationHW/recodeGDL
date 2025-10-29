-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: AuxRep (EXACTO del archivo original)
-- Archivo: 02_SP_OTRASOBLIG_AUXREP_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp34_padron
-- Tipo: Report
-- Descripción: Obtiene el padrón de concesionarios filtrado por tabla y vigencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp34_padron(par_tabla integer, par_vigencia text)
RETURNS TABLE(
    control varchar,
    concesionario varchar,
    ubicacion varchar,
    nomcomercial varchar,
    lugar varchar,
    obs varchar,
    statusregistro varchar,
    unidades varchar,
    categoria varchar,
    seccion varchar,
    bloque varchar,
    sector varchar,
    superficie numeric,
    fechainicio date,
    fechafin date,
    recaudadora integer,
    zona integer,
    licencia integer,
    giro integer,
    tipoobligacion varchar,
    id_34_datos integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control,
        a.concesionario,
        a.ubicacion,
        a.nomcomercial,
        a.lugar,
        a.obs,
        b.descripcion as statusregistro,
        a.unidades,
        a.categoria,
        a.seccion,
        a.bloque,
        a.sector,
        a.superficie,
        a.fecha_inicio as fechainicio,
        a.fecha_fin as fechafin,
        a.id_recaudadora as recaudadora,
        a.id_zona as zona,
        a.licencia,
        a.giro,
        a.tipoobligacion,
        a.id_34_datos
    FROM otrasoblig.t34_datos a
    JOIN otrasoblig.t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.cve_tab = par_tabla
      AND (
        par_vigencia = 'TODOS' OR b.descripcion = par_vigencia
      )
    ORDER BY a.control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp34_tablas
-- Tipo: Catalog
-- Descripción: Obtiene información de la tabla y sus unidades.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp34_tablas(par_tab integer)
RETURNS TABLE(
    cve_tab varchar,
    nombre varchar,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM otrasoblig.t34_tablas a
    JOIN otrasoblig.t34_unidades b ON a.cve_tab = b.cve_tab
    WHERE a.cve_tab = par_tab
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp34_etiq
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas de la tabla.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp34_etiq(par_tab integer)
RETURNS TABLE(
    cve_tab varchar,
    abreviatura varchar,
    etiq_control varchar,
    concesionario varchar,
    ubicacion varchar,
    superficie varchar,
    fecha_inicio varchar,
    fecha_fin varchar,
    recaudadora varchar,
    sector varchar,
    zona varchar,
    licencia varchar,
    fecha_cancelacion varchar,
    unidad varchar,
    categoria varchar,
    seccion varchar,
    bloque varchar,
    nombre_comercial varchar,
    lugar varchar,
    obs varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM otrasoblig.t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp34_vigencias
-- Tipo: Catalog
-- Descripción: Obtiene las vigencias disponibles para la tabla.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp34_vigencias(par_tab integer)
RETURNS TABLE(
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT b.descripcion
    FROM otrasoblig.t34_datos a, otrasoblig.t34_status b
    WHERE a.cve_tab = par_tab
      AND b.id_34_stat = a.id_stat
    GROUP BY b.descripcion
    ORDER BY b.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
