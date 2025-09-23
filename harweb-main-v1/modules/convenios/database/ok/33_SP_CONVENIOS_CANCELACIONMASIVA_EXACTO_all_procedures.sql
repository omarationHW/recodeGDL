-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: CANCELACIONMASIVA (EXACTO del archivo original)
-- Archivo: 33_SP_CONVENIOS_CANCELACIONMASIVA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_cancelacionmasiva_listar
-- Tipo: Report
-- Descripción: Lista los convenios cancelados hoy (vigencia = 'B')
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancelacionmasiva_listar()
RETURNS TABLE (
    tipo smallint,
    subtipo smallint,
    letras_exp varchar(4),
    numero_exp integer,
    axo_exp smallint,
    id_conv_resto integer,
    fecha_inicio date,
    fecha_venc date,
    modulo smallint,
    referencia varchar(30),
    usuario varchar(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.tipo, d.subtipo, d.letras_exp, d.numero_exp, d.axo_exp,
           a.id_conv_resto, a.fecha_inicio, a.fecha_venc,
           b.modulo, b.referencia, p.usuario
    FROM public.ta_17_conv_diverso d
    JOIN public.ta_17_conv_d_resto a ON a.tipo = d.tipo AND a.id_conv_diver = d.id_conv_diver
    JOIN public.ta_17_referencia b ON b.id_conv_resto = a.id_conv_resto
    JOIN public.ta_12_passwords p ON p.id_usuario = a.id_usuario
    WHERE a.vigencia = 'B' AND a.fecha_actual::date = CURRENT_DATE
    ORDER BY 1,2,3,4,5;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: CANCELACIONMASIVA (EXACTO del archivo original)
-- Archivo: 33_SP_CONVENIOS_CANCELACIONMASIVA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

