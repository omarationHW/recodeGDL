-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Rep_a_Cobrar
-- Generado: 2025-08-27 14:47:41
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_rep_a_cobrar
-- Tipo: Report
-- Descripción: Genera el reporte de cementerios a cobrar para una recaudadora y mes dados.
-- --------------------------------------------

-- PostgreSQL stored procedure for report
CREATE OR REPLACE FUNCTION sp_rep_a_cobrar(par_mes integer, par_id_rec integer)
RETURNS TABLE(
    ano integer,
    mantenimiento numeric,
    recargos numeric
) AS $$
BEGIN
    -- Simulación: Debe ajustarse a la lógica real de cálculo
    RETURN QUERY
    SELECT
        t.axo_cuota AS ano,
        SUM(t.cuota1 * t.metros) AS mantenimiento,
        SUM(t.cuota1 * t.metros * r.porcentaje_global / 100) AS recargos
    FROM ta_13_rcmcuotas t
    JOIN ta_13_datosrcm d ON d.cementerio = t.cementerio
    JOIN ta_12_recaudadoras rca ON rca.id_rec = par_id_rec
    JOIN ta_13_recargosrcm r ON r.axo = t.axo_cuota AND r.mes = par_mes
    WHERE d.id_rec = par_id_rec
    GROUP BY t.axo_cuota
    ORDER BY t.axo_cuota;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_get_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora (nombre, zona, etc) por id_rec.
-- --------------------------------------------

-- PostgreSQL stored procedure for recaudadora info
CREATE OR REPLACE FUNCTION sp_get_recaudadora(par_id_rec integer)
RETURNS TABLE(
    id_rec integer,
    nomre text,
    titulo text,
    d_zona text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.nomre, a.titulo, upper(c.zona) as d_zona
    FROM ta_12_nombrerec a
    JOIN ta_12_recaudadoras b ON a.recing = b.id_rec
    JOIN ta_12_zonas c ON b.id_zona = c.id_zona
    WHERE a.recing = par_id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

