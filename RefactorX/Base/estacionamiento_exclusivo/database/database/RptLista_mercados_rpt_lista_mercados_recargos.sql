-- Stored Procedure: rpt_lista_mercados_recargos
-- Tipo: CRUD
-- Descripción: Calcula el porcentaje de recargos para un adeudo dado el año, periodo y fecha de corte.
-- Generado para formulario: RptLista_mercados
-- Fecha: 2025-08-27 14:55:43

CREATE OR REPLACE FUNCTION rpt_lista_mercados_recargos(
    axo integer,
    periodo integer,
    vaxo integer,
    vmes integer,
    vdia integer
) RETURNS numeric AS $$
DECLARE
    vporcentaje numeric := 0;
BEGIN
    SELECT COALESCE(SUM(porcentaje_mes),0) INTO vporcentaje
    FROM padron_licencias.comun.ta_12_recargos
    WHERE (
        (axo = axo AND mes >= periodo)
        OR (axo = vaxo AND mes <= (CASE WHEN vdia <= 12 THEN vmes-1 ELSE vmes END))
        OR (axo > axo AND axo < vaxo)
    );
    IF vporcentaje > 250 THEN
        vporcentaje := 250;
    END IF;
    RETURN vporcentaje;
END;
$$ LANGUAGE plpgsql;
