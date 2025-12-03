-- ============================================
-- SP CORREGIDO: RptCuentaPublica
-- Esquemas corregidos según postgreok.csv
-- ============================================

CREATE OR REPLACE FUNCTION public.rpt_cuenta_publica(p_axo integer, p_oficina integer)
RETURNS TABLE(
    id bigint,
    recaudadora text,
    descripcion text,
    saldo_mes_anterior numeric(18,2),
    altas_doctos integer,
    altas_importe numeric(18,2),
    mov_mes_doctos integer,
    mov_mes_importe numeric(18,2),
    bajas_doctos integer,
    bajas_importe numeric(18,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        row_number() OVER () as id,
        r.recaudadora,
        'Concepto' AS descripcion,
        0::numeric(18,2) AS saldo_mes_anterior,
        0::integer AS altas_doctos,
        0::numeric(18,2) AS altas_importe,
        0::integer AS mov_mes_doctos,
        0::numeric(18,2) AS mov_mes_importe,
        0::integer AS bajas_doctos,
        0::numeric(18,2) AS bajas_importe
    FROM padron_licencias.comun.ta_12_recaudadoras r
    WHERE r.id_rec = p_oficina;
END;
$$ LANGUAGE plpgsql;
