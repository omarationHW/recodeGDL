-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: INTERESES (EXACTO del archivo original)
-- Archivo: 52_SP_CONVENIOS_INTERESES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_intereses_list
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo completo de intereses, incluyendo usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_intereses_list()
RETURNS TABLE (
    axo smallint,
    mes smallint,
    porcentaje numeric(12,8),
    id_usuario integer,
    fecha_actual timestamp,
    usuario varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.axo, a.mes, a.porcentaje, a.id_usuario, a.fecha_actual, b.usuario
    FROM public.ta_12_intereses a
    JOIN public.ta_12_passwords b ON b.id_usuario = a.id_usuario
    ORDER BY a.axo ASC, a.mes ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: INTERESES (EXACTO del archivo original)
-- Archivo: 52_SP_CONVENIOS_INTERESES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_intereses_update
-- Tipo: CRUD
-- Descripción: Actualiza el porcentaje de un registro de interés existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_intereses_update(
    p_axo smallint,
    p_mes smallint,
    p_porcentaje numeric(12,8),
    p_id_usuario integer
) RETURNS TABLE (
    axo smallint,
    mes smallint,
    porcentaje numeric(12,8),
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    UPDATE public.ta_12_intereses
    SET porcentaje = p_porcentaje,
        id_usuario = p_id_usuario,
        fecha_actual = NOW()
    WHERE axo = p_axo AND mes = p_mes;
    RETURN QUERY SELECT axo, mes, porcentaje, id_usuario, fecha_actual
      FROM public.ta_12_intereses WHERE axo = p_axo AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: INTERESES (EXACTO del archivo original)
-- Archivo: 52_SP_CONVENIOS_INTERESES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

