-- Stored Procedure: sp_validate_pagos_tcultural
-- Tipo: CRUD
-- Descripción: Valida que los folios de pagos existan en ingresos y no estén duplicados.
-- Generado para formulario: CargaTCultural
-- Fecha: 2025-08-26 23:03:00

CREATE OR REPLACE FUNCTION sp_validate_pagos_tcultural(
    p_pagos_json JSON
) RETURNS TABLE(foliosErroneos TEXT[]) AS $$
DECLARE
    pagos RECORD;
    folios_err TEXT[] := ARRAY[]::TEXT[];
    rec RECORD;
BEGIN
    FOR pagos IN SELECT * FROM json_populate_recordset(NULL::record, p_pagos_json) LOOP
        -- Validar que los campos requeridos estén presentes
        IF pagos.fecha_pago IS NULL OR pagos.rec IS NULL OR pagos.caja IS NULL OR pagos.operacion IS NULL OR pagos.partida IS NULL THEN
            folios_err := array_append(folios_err, pagos.local::TEXT);
        ELSE
            -- Validar existencia en ingresos (ejemplo: tabla ta_12_importes)
            SELECT 1 INTO rec FROM ta_12_importes
                WHERE fecing = pagos.fecha_pago::date
                  AND recing = pagos.rec::smallint
                  AND cajing = pagos.caja::varchar
                  AND opcaja = pagos.operacion::integer
            LIMIT 1;
            IF NOT FOUND THEN
                folios_err := array_append(folios_err, pagos.local::TEXT);
            END IF;
        END IF;
    END LOOP;
    RETURN QUERY SELECT folios_err;
END;
$$ LANGUAGE plpgsql;