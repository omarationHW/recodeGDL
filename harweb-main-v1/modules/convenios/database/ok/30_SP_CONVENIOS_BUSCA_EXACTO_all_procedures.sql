-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: BUSCA (EXACTO del archivo original)
-- Archivo: 30_SP_CONVENIOS_BUSCA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: sp_busca_by_nombre
-- Tipo: Report
-- Descripción: Busca convenios por nombre del contribuyente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_by_nombre(p_nombre TEXT)
RETURNS TABLE (
    id_conv_diver INTEGER,
    nombre TEXT,
    calle TEXT,
    num_exterior SMALLINT,
    num_interior SMALLINT,
    inciso TEXT,
    tipo SMALLINT,
    subtipo SMALLINT,
    manzana TEXT,
    lote INTEGER,
    letra TEXT,
    aloofi SMALLINT,
    numofi INTEGER,
    letexp TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_conv_diver,
        d.nombre,
        d.calle,
        d.num_exterior,
        d.num_interior,
        d.inciso,
        d.tipo,
        v.subtipo,
        v.manzana,
        v.lote,
        v.letra,
        v.aloofi,
        v.numofi,
        v.letexp
    FROM public.ta_17_conv_d_resto d
    LEFT JOIN vw_conv_complemento v ON d.id_conv_diver = v.id_conv_diver
    WHERE d.nombre ILIKE '%' || p_nombre || '%';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: BUSCA (EXACTO del archivo original)
-- Archivo: 30_SP_CONVENIOS_BUSCA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 3/6: sp_busca_by_cuenta
-- Tipo: Report
-- Descripción: Busca convenios por cuenta (recaudadora, ur, cuenta)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_by_cuenta(p_rec INTEGER, p_ur TEXT, p_cuenta INTEGER)
RETURNS TABLE (
    id_conv_diver INTEGER,
    nombre TEXT,
    calle TEXT,
    num_exterior SMALLINT,
    num_interior SMALLINT,
    inciso TEXT,
    tipo SMALLINT,
    subtipo SMALLINT,
    manzana TEXT,
    lote INTEGER,
    letra TEXT,
    aloofi SMALLINT,
    numofi INTEGER,
    letexp TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_conv_diver,
        d.nombre,
        d.calle,
        d.num_exterior,
        d.num_interior,
        d.inciso,
        d.tipo,
        v.subtipo,
        v.manzana,
        v.lote,
        v.letra,
        v.aloofi,
        v.numofi,
        v.letexp
    FROM public.ta_17_conv_d_resto d
    LEFT JOIN vw_conv_complemento v ON d.id_conv_diver = v.id_conv_diver
    WHERE v.recaudadora = p_rec AND v.ur = p_ur AND v.cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: BUSCA (EXACTO del archivo original)
-- Archivo: 30_SP_CONVENIOS_BUSCA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: sp_busca_by_anuncio
-- Tipo: Report
-- Descripción: Busca convenios por número de anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_by_anuncio(p_anuncio INTEGER)
RETURNS TABLE (
    id_conv_diver INTEGER,
    nombre TEXT,
    calle TEXT,
    num_exterior SMALLINT,
    num_interior SMALLINT,
    inciso TEXT,
    tipo SMALLINT,
    subtipo SMALLINT,
    manzana TEXT,
    lote INTEGER,
    letra TEXT,
    aloofi SMALLINT,
    numofi INTEGER,
    letexp TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_conv_diver,
        d.nombre,
        d.calle,
        d.num_exterior,
        d.num_interior,
        d.inciso,
        d.tipo,
        v.subtipo,
        v.manzana,
        v.lote,
        v.letra,
        v.aloofi,
        v.numofi,
        v.letexp
    FROM public.ta_17_conv_d_resto d
    LEFT JOIN vw_conv_complemento v ON d.id_conv_diver = v.id_conv_diver
    WHERE v.anuncio = p_anuncio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: BUSCA (EXACTO del archivo original)
-- Archivo: 30_SP_CONVENIOS_BUSCA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

