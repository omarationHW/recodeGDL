-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: GFacturacion
-- Generado: 2025-08-28 13:15:04
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_con34_gfact_02
-- Tipo: Report
-- Descripción: Obtiene la facturación general filtrada por tabla, tipo de adeudo, recargos, año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_con34_gfact_02(
    par_Tab VARCHAR,
    par_Ade VARCHAR,
    Par_Rcgo VARCHAR,
    par_Axo INTEGER,
    par_Mes INTEGER
)
RETURNS TABLE(
    control VARCHAR,
    concesionario VARCHAR,
    superficie NUMERIC,
    tipo VARCHAR,
    licencia INTEGER,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.control,
        d.concesionario,
        d.superficie,
        u.descripcion AS tipo,
        d.licencia,
        SUM(a.importe) AS importe
    FROM t34_datos d
    JOIN t34_unidades u ON d.cve_tab = u.cve_tab
    JOIN t34_adeudos a ON d.id_34_datos = a.id_datos
    WHERE d.cve_tab = par_Tab
      AND (
        (par_Ade = 'A' AND a.status IN ('ADEUDO', 'PAGADO')) OR
        (par_Ade = 'B' AND a.status = 'ADEUDO') OR
        (par_Ade = 'C' AND a.status = 'PAGADO')
      )
      AND (
        (Par_Rcgo = 'S' AND a.recargo > 0) OR
        (Par_Rcgo = 'N')
      )
      AND a.axo = par_Axo
      AND a.mes = par_Mes
    GROUP BY d.control, d.concesionario, d.superficie, u.descripcion, d.licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_get_tablas
-- Tipo: Catalog
-- Descripción: Obtiene las tablas de facturación y sus descripciones.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tablas(par_tab VARCHAR)
RETURNS TABLE(
    cve_tab VARCHAR,
    nombre VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    JOIN t34_unidades b ON a.cve_tab = b.cve_tab
    WHERE a.cve_tab = par_tab
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_get_etiquetas
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas de la tabla seleccionada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_etiquetas(par_tab VARCHAR)
RETURNS TABLE(
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
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

-- ============================================

