-- Stored Procedure: sp_carga_tcultural_cargar_pagos
-- Tipo: CRUD
-- Descripción: Carga los pagos del tianguis cultural, inserta en pagos_local y elimina adeudos correspondientes. Aplica descuento si corresponde.
-- Generado para formulario: CargaTCultural
-- Fecha: 2025-08-26 19:09:26

CREATE OR REPLACE FUNCTION sp_carga_tcultural_cargar_pagos(pagos_json jsonb, usuario_id integer)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    pagos_arr jsonb[];
    pago jsonb;
    renta numeric;
    renta_desc numeric;
BEGIN
    pagos_arr := ARRAY(SELECT jsonb_array_elements(pagos_json));
    FOREACH pago IN ARRAY pagos_arr LOOP
        IF (pago->>'fecha') IS NULL OR (pago->>'rec') IS NULL OR (pago->>'caja') IS NULL OR (pago->>'operacion') IS NULL THEN
            CONTINUE;
        END IF;
        IF (pago->>'descuento')::numeric > 0 THEN
            renta := (pago->>'importe')::numeric;
            renta_desc := round(renta - (renta * (pago->>'descuento')::numeric / 100), 2);
        ELSE
            renta_desc := (pago->>'importe')::numeric;
        END IF;
        INSERT INTO ta_11_pagos_local (
            id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
        ) VALUES (
            DEFAULT,
            (pago->>'id_local')::integer,
            (pago->>'axo')::smallint,
            (pago->>'periodo')::smallint,
            (pago->>'fecha')::date,
            (pago->>'rec')::smallint,
            (pago->>'caja'),
            (pago->>'operacion')::integer,
            renta_desc,
            (pago->>'partida'),
            now(),
            usuario_id
        );
        DELETE FROM ta_11_adeudo_local
        WHERE id_local = (pago->>'id_local')::integer
          AND axo = (pago->>'axo')::smallint
          AND periodo = (pago->>'periodo')::smallint;
    END LOOP;
    RETURN QUERY SELECT true, 'Pagos cargados correctamente';
END;
$$ LANGUAGE plpgsql;