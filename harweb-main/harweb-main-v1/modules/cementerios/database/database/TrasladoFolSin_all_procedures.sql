-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: TrasladoFolSin
-- Generado: 2025-08-27 15:16:33
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_traslado_folios_sin_adeudo
-- Tipo: CRUD
-- Descripción: Traslada pagos seleccionados de un folio a otro sin afectar adeudos. Actualiza los registros de pagos y los datos de axo_pagado según la lógica de negocio.
-- --------------------------------------------

--
-- sp_traslado_folios_sin_adeudo
-- Traslada pagos seleccionados de un folio a otro sin afectar adeudos
--
CREATE OR REPLACE FUNCTION sp_traslado_folios_sin_adeudo(
    p_folio_de integer,
    p_folio_a integer,
    p_pagos_ids jsonb,
    p_usuario integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_axo integer;
    v_mes integer;
    v_dia integer;
    v_suma integer := 0;
    v_pago_id integer;
    v_uap integer;
BEGIN
    -- Validaciones
    IF p_folio_de IS NULL OR p_folio_a IS NULL OR p_pagos_ids IS NULL OR p_usuario IS NULL THEN
        RETURN QUERY SELECT false, 'Parámetros incompletos';
        RETURN;
    END IF;
    IF p_folio_de = p_folio_a THEN
        RETURN QUERY SELECT false, 'Los folios no deben ser iguales';
        RETURN;
    END IF;
    -- Procesar cada pago seleccionado
    FOR v_pago_id IN SELECT jsonb_array_elements_text(p_pagos_ids)::integer LOOP
        -- Actualizar ta_13_adeudosrcm: poner id_pago=null, vigencia='V', fecha_mov=now()
        UPDATE ta_13_adeudosrcm
        SET id_pago = NULL, vigencia = 'V', fecha_mov = now()
        WHERE control_rcm = p_folio_de
          AND id_pago = v_pago_id;
        -- Actualizar ta_13_pagosrcm: cambiar datos al folio destino
        UPDATE ta_13_pagosrcm
        SET cementerio = (SELECT cementerio FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            clase = (SELECT clase FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            clase_alfa = (SELECT clase_alfa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            seccion = (SELECT seccion FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            seccion_alfa = (SELECT seccion_alfa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            linea = (SELECT linea FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            linea_alfa = (SELECT linea_alfa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            fosa = (SELECT fosa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            fosa_alfa = (SELECT fosa_alfa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            control_rcm = p_folio_a,
            usuario = p_usuario,
            fecha_mov = now()
        WHERE control_id = v_pago_id;
        v_suma := v_suma + 1;
    END LOOP;
    -- Actualizar axo_pagado en ta_13_datosrcm para folio destino
    SELECT EXTRACT(YEAR FROM now()) INTO v_axo;
    -- UAP para folio destino
    SELECT COALESCE(MAX(axo_pago_hasta), 0) INTO v_uap FROM ta_13_pagosrcm WHERE control_rcm = p_folio_a;
    IF v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;
    UPDATE ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = p_folio_a;
    -- UAP para folio origen
    SELECT COALESCE(MAX(axo_pago_hasta), 0) INTO v_uap FROM ta_13_pagosrcm WHERE control_rcm = p_folio_de;
    IF v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;
    UPDATE ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = p_folio_de;
    IF v_suma > 0 THEN
        RETURN QUERY SELECT true, 'Los registros se han trasladado';
    ELSE
        RETURN QUERY SELECT false, 'No se seleccionó ningún registro a trasladar';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- ============================================

