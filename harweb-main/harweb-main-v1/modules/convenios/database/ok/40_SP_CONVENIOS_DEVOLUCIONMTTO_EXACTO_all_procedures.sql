-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: DEVOLUCIONMTTO (EXACTO del archivo original)
-- Archivo: 40_SP_CONVENIOS_DEVOLUCIONMTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_create_devolucion_mtto
-- Tipo: CRUD
-- Descripción: Crea una nueva devolución de pago para un contrato de mantenimiento.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_create_devolucion_mtto(
    p_id_convenio INTEGER,
    p_remesa VARCHAR(20),
    p_oficio VARCHAR(20),
    p_folio VARCHAR(15),
    p_fecha_solicitud DATE,
    p_rfc VARCHAR(20),
    p_importe NUMERIC,
    p_observacion VARCHAR(60),
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP
) RETURNS INTEGER AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO public.ta_17_devoluciones (
        id_convenio, remesa, oficio, folio, fecha_solicitud, rfc, importe, observacion, ejercicio, proc, crbo, id_usuario, fecha_actual
    ) VALUES (
        p_id_convenio, p_remesa, p_oficio, p_folio, p_fecha_solicitud, p_rfc, p_importe, p_observacion, 0, 0, 0, p_id_usuario, p_fecha_actual
    ) RETURNING id_devolucion INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: DEVOLUCIONMTTO (EXACTO del archivo original)
-- Archivo: 40_SP_CONVENIOS_DEVOLUCIONMTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_delete_devolucion_mtto
-- Tipo: CRUD
-- Descripción: Elimina una devolución de pago.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_delete_devolucion_mtto(
    p_id_devolucion INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public.ta_17_devoluciones WHERE id_devolucion = p_id_devolucion;
END;
$$;

-- ============================================

