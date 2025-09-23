-- Stored Procedure: spd_17_cta_publica
-- Tipo: Report
-- Descripción: Genera el reporte de estadísticas de pagos de contratos por año de obra y fondo/programa.
-- Generado para formulario: RptEstadisticasContratos
-- Fecha: 2025-08-27 15:38:58

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