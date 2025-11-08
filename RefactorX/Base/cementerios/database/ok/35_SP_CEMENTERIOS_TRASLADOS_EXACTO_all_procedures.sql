-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TRASLADOS (EXACTO del archivo original)
-- Archivo: 35_SP_CEMENTERIOS_TRASLADOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_traslados_buscar_pagos_origen
-- Tipo: CRUD
-- Descripción: Busca los pagos en la ubicación origen según los parámetros de búsqueda.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_traslados_buscar_pagos_origen(
    p_cementerio VARCHAR,
    p_clase INTEGER,
    p_clase_alfa VARCHAR,
    p_seccion INTEGER,
    p_seccion_alfa VARCHAR,
    p_linea INTEGER,
    p_linea_alfa VARCHAR,
    p_fosa INTEGER,
    p_fosa_alfa VARCHAR
)
RETURNS TABLE (
    control_id INTEGER,
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase INTEGER,
    clase_alfa VARCHAR,
    seccion INTEGER,
    seccion_alfa VARCHAR,
    linea INTEGER,
    linea_alfa VARCHAR,
    fosa INTEGER,
    fosa_alfa VARCHAR,
    fecing DATE,
    importe_anual NUMERIC,
    vigencia VARCHAR,
    usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, fecing, importe_anual, vigencia, usuario
    FROM public.ta_13_pagosrcm
    WHERE cementerio = p_cementerio
      AND clase = p_clase
      AND (clase_alfa = p_clase_alfa OR (p_clase_alfa IS NULL OR p_clase_alfa = ''))
      AND seccion = p_seccion
      AND (seccion_alfa = p_seccion_alfa OR (p_seccion_alfa IS NULL OR p_seccion_alfa = ''))
      AND linea = p_linea
      AND (linea_alfa = p_linea_alfa OR (p_linea_alfa IS NULL OR p_linea_alfa = ''))
      AND fosa = p_fosa
      AND (fosa_alfa = p_fosa_alfa OR (p_fosa_alfa IS NULL OR p_fosa_alfa = ''));
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TRASLADOS (EXACTO del archivo original)
-- Archivo: 35_SP_CEMENTERIOS_TRASLADOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_traslados_trasladar_pagos
-- Tipo: CRUD
-- Descripción: Realiza el traslado de pagos de una ubicación origen a una destino, actualizando los registros correspondientes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_traslados_trasladar_pagos(
    p_origen_control_id INTEGER,
    p_destino_cementerio VARCHAR,
    p_destino_clase INTEGER,
    p_destino_clase_alfa VARCHAR,
    p_destino_seccion INTEGER,
    p_destino_seccion_alfa VARCHAR,
    p_destino_linea INTEGER,
    p_destino_linea_alfa VARCHAR,
    p_destino_fosa INTEGER,
    p_destino_fosa_alfa VARCHAR,
    p_destino_control_rcm INTEGER,
    p_usuario INTEGER
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_axo INTEGER;
    v_uap INTEGER;
BEGIN
    -- Actualizar pagos
    UPDATE public.ta_13_pagosrcm
    SET cementerio = p_destino_cementerio,
        clase = p_destino_clase,
        clase_alfa = COALESCE(p_destino_clase_alfa, ''),
        seccion = p_destino_seccion,
        seccion_alfa = COALESCE(p_destino_seccion_alfa, ''),
        linea = p_destino_linea,
        linea_alfa = COALESCE(p_destino_linea_alfa, ''),
        fosa = p_destino_fosa,
        fosa_alfa = COALESCE(p_destino_fosa_alfa, ''),
        control_rcm = p_destino_control_rcm,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_id = p_origen_control_id;

    -- Actualizar axo_pagado en datosrcm destino
    SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO v_axo;
    SELECT MAX(axo_pago_hasta) INTO v_uap FROM public.ta_13_pagosrcm WHERE control_rcm = p_destino_control_rcm;
    IF v_uap IS NULL OR v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;
    UPDATE public.ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = p_destino_control_rcm;

    -- Actualizar axo_pagado en datosrcm origen (opcional, según reglas)
    -- SELECT MAX(axo_pago_hasta) INTO v_uap FROM public.ta_13_pagosrcm WHERE control_rcm = (SELECT control_rcm FROM public.ta_13_pagosrcm WHERE control_id = p_origen_control_id);
    -- IF v_uap IS NULL OR v_uap = 0 THEN
    --     v_uap := v_axo - 5;
    -- END IF;
    -- UPDATE public.ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = (SELECT control_rcm FROM public.ta_13_pagosrcm WHERE control_id = p_origen_control_id);

    RETURN QUERY SELECT TRUE, 'Traslado realizado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al trasladar pagos: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

