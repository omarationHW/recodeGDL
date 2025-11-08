-- Stored Procedure: sp_carga_pagos_texto
-- Tipo: CRUD
-- Descripción: Procesa un lote de pagos desde archivo de texto, inserta en ta_11_pagos_local y borra adeudos correspondientes. Devuelve resumen.
-- Generado para formulario: CargaPagosTexto
-- Fecha: 2025-08-26 19:59:26

-- PostgreSQL stored procedure para procesar pagos en lote
CREATE OR REPLACE FUNCTION sp_carga_pagos_texto(pagos_json jsonb, user_id integer)
RETURNS TABLE(grabados integer, nograbados integer, borrados integer, total integer, importe numeric) AS $$
DECLARE
    pago jsonb;
    i integer := 0;
    v_grabados integer := 0;
    v_nograbados integer := 0;
    v_borrados integer := 0;
    v_total integer := 0;
    v_importe numeric := 0;
    v_id_local integer;
    v_axo integer;
    v_periodo integer;
    v_fecha_pago date;
    v_oficina_pago integer;
    v_caja_pago text;
    v_operacion_pago integer;
    v_importe_pago numeric;
    v_folio text;
    v_fecha_modificacion timestamp;
    v_id_usuario integer;
    v_adeudo_id integer;
BEGIN
    FOR i IN 0 .. jsonb_array_length(pagos_json) - 1 LOOP
        pago := pagos_json->i;
        v_id_local := (pago->>'id_local')::integer;
        v_axo := (pago->>'axo')::integer;
        v_periodo := (pago->>'periodo')::integer;
        v_fecha_pago := to_date(pago->>'fecha_pago', 'DD/MM/YYYY');
        v_oficina_pago := (pago->>'oficina_pago')::integer;
        v_caja_pago := pago->>'caja_pago';
        v_operacion_pago := (pago->>'operacion_pago')::integer;
        v_importe_pago := (pago->>'importe_pago')::numeric;
        v_folio := pago->>'folio';
        v_fecha_modificacion := now();
        v_id_usuario := user_id;
        v_total := v_total + 1;
        v_importe := v_importe + coalesce(v_importe_pago,0);
        BEGIN
            INSERT INTO ta_11_pagos_local (
                id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
            ) VALUES (
                DEFAULT, v_id_local, v_axo, v_periodo, v_fecha_pago, v_oficina_pago, v_caja_pago, v_operacion_pago, v_importe_pago, v_folio, v_fecha_modificacion, v_id_usuario
            );
            v_grabados := v_grabados + 1;
        EXCEPTION WHEN unique_violation OR foreign_key_violation OR others THEN
            v_nograbados := v_nograbados + 1;
        END;
        -- Borrar adeudo si existe
        SELECT id_adeudo_local INTO v_adeudo_id FROM ta_11_adeudo_local WHERE id_local = v_id_local AND axo = v_axo AND periodo = v_periodo LIMIT 1;
        IF v_adeudo_id IS NOT NULL THEN
            DELETE FROM ta_11_adeudo_local WHERE id_adeudo_local = v_adeudo_id;
            v_borrados := v_borrados + 1;
        END IF;
    END LOOP;
    RETURN QUERY SELECT v_grabados, v_nograbados, v_borrados, v_total, v_importe;
END;
$$ LANGUAGE plpgsql;