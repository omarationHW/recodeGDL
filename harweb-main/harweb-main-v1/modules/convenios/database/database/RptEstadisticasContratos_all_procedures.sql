-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptEstadisticasContratos
-- Generado: 2025-08-27 15:38:58
-- Total SPs: 3
-- ============================================

-- SP 1/3: spd_17_cta_publica
-- Tipo: Report
-- Descripción: Genera el reporte de estadísticas de pagos de contratos por año de obra y fondo/programa.
-- --------------------------------------------

-- PostgreSQL version of spd_17_cta_publica
CREATE OR REPLACE FUNCTION spd_17_cta_publica(parm_alo integer, parm_fondo integer)
RETURNS TABLE(
    NumColonia smallint,
    NombreColonia varchar(50),
    Costo numeric,
    Pagos_Ing numeric,
    Pagos_dev numeric,
    Pagos_dif numeric,
    Pagos_real numeric,
    Saldo_real numeric,
    Desc_tipo varchar(50),
    Vigencia varchar(1),
    convenios integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.colonia AS NumColonia,
        col.descripcion AS NombreColonia,
        SUM(c.costo) AS Costo,
        SUM(c.pagos_ing) AS Pagos_Ing,
        SUM(c.pagos_dev) AS Pagos_dev,
        SUM(c.pagos_dif) AS Pagos_dif,
        SUM(c.pagos_real) AS Pagos_real,
        SUM(c.saldo_real) AS Saldo_real,
        t.descripcion AS Desc_tipo,
        c.vigencia AS Vigencia,
        COUNT(*) AS convenios
    FROM ta_17_convenios c
    INNER JOIN ta_17_colonias col ON c.colonia = col.colonia
    INNER JOIN ta_17_tipos t ON c.tipo = t.tipo
    WHERE c.axo_obra = parm_alo
      AND c.fondo = parm_fondo
    GROUP BY c.colonia, col.descripcion, t.descripcion, c.vigencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: get_fondos
-- Tipo: Catalog
-- Descripción: Obtiene la lista de fondos/programas disponibles.
-- --------------------------------------------

-- PostgreSQL version
CREATE OR REPLACE FUNCTION get_fondos()
RETURNS TABLE(id integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY SELECT id, descripcion FROM fondos ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: get_anios_obra
-- Tipo: Catalog
-- Descripción: Obtiene los años de obra disponibles en la base de datos.
-- --------------------------------------------

-- PostgreSQL version
CREATE OR REPLACE FUNCTION get_anios_obra()
RETURNS TABLE(axo_obra integer) AS $$
BEGIN
    RETURN QUERY SELECT DISTINCT axo_obra FROM ta_17_calles ORDER BY axo_obra DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

