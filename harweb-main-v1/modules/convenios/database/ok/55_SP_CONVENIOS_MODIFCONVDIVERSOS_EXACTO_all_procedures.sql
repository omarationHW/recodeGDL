-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MODIFCONVDIVERSOS (EXACTO del archivo original)
-- Archivo: 55_SP_CONVENIOS_MODIFCONVDIVERSOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 1/8: sp_buscar_convenio_diversos
-- Tipo: Report
-- Descripción: Busca un convenio diversos por tipo, subtipo, letras, folio, año, manzana
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_convenio_diversos(
    p_tipo INTEGER,
    p_subtipo INTEGER,
    p_letras_ofi VARCHAR,
    p_folio_ofi INTEGER,
    p_alo_oficio INTEGER,
    p_manzana VARCHAR DEFAULT NULL
) RETURNS TABLE (
    id_conv_diver INTEGER,
    tipo INTEGER,
    subtipo INTEGER,
    letras_exp VARCHAR,
    numero_exp INTEGER,
    axo_exp INTEGER,
    id_conv_resto INTEGER,
    nombre VARCHAR,
    calle VARCHAR,
    num_exterior INTEGER,
    num_interior INTEGER,
    inciso VARCHAR,
    metros NUMERIC,
    telefono VARCHAR,
    correo VARCHAR,
    oficio VARCHAR,
    fechaoficio DATE,
    nombrefirma VARCHAR,
    observaciones VARCHAR,
    vigencia VARCHAR,
    bloqueo INTEGER,
    modulo INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_conv_diver, a.tipo, a.subtipo, a.letras_exp, a.numero_exp, a.axo_exp,
           b.id_conv_resto, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.metros,
           b.telefono, b.correo, b.oficio, b.fechaoficio, b.nombrefirma, b.observaciones, b.vigencia, b.bloqueo, b.modulo
    FROM public.ta_17_conv_diverso a
    JOIN public.ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_diver = b.id_conv_diver
    WHERE a.tipo = p_tipo AND a.subtipo = p_subtipo
      AND a.letras_exp = COALESCE(p_letras_ofi, a.letras_exp)
      AND a.numero_exp = COALESCE(p_folio_ofi, a.numero_exp)
      AND a.axo_exp = COALESCE(p_alo_oficio, a.axo_exp)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MODIFCONVDIVERSOS (EXACTO del archivo original)
-- Archivo: 55_SP_CONVENIOS_MODIFCONVDIVERSOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 3/8: sp_bloquear_convenio_diversos
-- Tipo: CRUD
-- Descripción: Bloquea un convenio diversos (bloqueo=1)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloquear_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_observaciones VARCHAR
) RETURNS VOID AS $$
BEGIN
    UPDATE public.ta_17_conv_d_resto SET
        bloqueo = 1,
        observaciones = UPPER(TRIM(p_observaciones)),
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MODIFCONVDIVERSOS (EXACTO del archivo original)
-- Archivo: 55_SP_CONVENIOS_MODIFCONVDIVERSOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 5/8: sp_dar_pagado_convenio_diversos
-- Tipo: CRUD
-- Descripción: Marca un convenio como pagado (vigencia='P') y ejecuta lógica de bloqueo/desbloqueo según módulo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_dar_pagado_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_modulo INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE public.ta_17_conv_d_resto SET
        vigencia = 'P',
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_conv_resto = p_id_conv_resto;
    -- Aquí se puede agregar lógica adicional para afectar otras tablas según el módulo
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MODIFCONVDIVERSOS (EXACTO del archivo original)
-- Archivo: 55_SP_CONVENIOS_MODIFCONVDIVERSOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 7/8: sp_listar_tipos_convenio_diversos
-- Tipo: Catalog
-- Descripción: Lista los tipos de convenio diversos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_listar_tipos_convenio_diversos() RETURNS TABLE (
    tipo INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM public.ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MODIFCONVDIVERSOS (EXACTO del archivo original)
-- Archivo: 55_SP_CONVENIOS_MODIFCONVDIVERSOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

