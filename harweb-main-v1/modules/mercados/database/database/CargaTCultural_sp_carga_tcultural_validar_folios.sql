-- Stored Procedure: sp_carga_tcultural_validar_folios
-- Tipo: CRUD
-- Descripción: Valida que los folios de pagos existan en ingresos y retorna los que no existen.
-- Generado para formulario: CargaTCultural
-- Fecha: 2025-08-26 19:09:26

CREATE OR REPLACE FUNCTION sp_carga_tcultural_validar_folios(pagos_json jsonb)
RETURNS TABLE(errores text[]) AS $$
DECLARE
    pagos_arr jsonb[];
    errores_arr text[] := ARRAY[]::text[];
    pago jsonb;
    existe integer;
BEGIN
    pagos_arr := ARRAY(SELECT jsonb_array_elements(pagos_json));
    FOREACH pago IN ARRAY pagos_arr LOOP
        SELECT COUNT(*) INTO existe FROM ingresos
        WHERE fecha = (pago->>'fecha')::date
          AND rec = (pago->>'rec')::smallint
          AND caja = (pago->>'caja')
          AND operacion = (pago->>'operacion')::integer;
        IF existe = 0 THEN
            errores_arr := array_append(errores_arr, (pago->>'id_local'));
        END IF;
    END LOOP;
    RETURN QUERY SELECT errores_arr;
END;
$$ LANGUAGE plpgsql;