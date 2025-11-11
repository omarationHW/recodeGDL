-- Stored Procedure: rptreq_pba_calc_recargos
-- Tipo: CRUD
-- Descripción: Calcula el monto de recargos para un adeudo local según la lógica del reporte.
-- Generado para formulario: RptReq_pba
-- Fecha: 2025-08-27 15:11:39

CREATE OR REPLACE FUNCTION rptreq_pba_calc_recargos(
    varaxoper integer,
    varperiodo integer,
    importe numeric,
    vaxo integer,
    vmes integer,
    vdia integer
) RETURNS numeric AS $$
DECLARE
    vporcentaje float := 0;
    recargos numeric := 0;
BEGIN
    -- Suma de porcentaje de recargos
    SELECT COALESCE(SUM(porcentaje_mes), 0)
      INTO vporcentaje
      FROM padron_licencias.comun.ta_12_recargos
     WHERE (axo = varaxoper AND mes >= varperiodo)
        OR (axo = vaxo AND mes <= (CASE WHEN vdia <= 12 THEN vmes - 1 ELSE vmes END))
        OR (axo > varaxoper AND axo < vaxo);

    IF vporcentaje > 250 THEN
        vporcentaje := 250;
    END IF;

    IF varaxoper = vaxo THEN
        IF varperiodo = vmes THEN
            IF vdia > 12 THEN
                recargos := (importe * vporcentaje) / 100;
            ELSE
                recargos := 0;
            END IF;
        ELSE
            recargos := (importe * vporcentaje) / 100;
        END IF;
    ELSE
        recargos := (importe * vporcentaje) / 100;
    END IF;

    IF recargos > 0 THEN
        recargos := trunc(recargos::numeric, 2);
    END IF;

    RETURN recargos;
END;
$$ LANGUAGE plpgsql;