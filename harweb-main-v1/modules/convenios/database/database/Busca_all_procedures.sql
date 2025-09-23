-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Busca
-- Generado: 2025-08-27 13:51:05
-- Total SPs: 6
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
    FROM ta_17_conv_d_resto d
    LEFT JOIN vw_conv_complemento v ON d.id_conv_diver = v.id_conv_diver
    WHERE d.nombre ILIKE '%' || p_nombre || '%';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_busca_by_domicilio
-- Tipo: Report
-- Descripción: Busca convenios por domicilio (calle y número exterior)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_by_domicilio(p_calle TEXT, p_num_exterior INTEGER)
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
    FROM ta_17_conv_d_resto d
    LEFT JOIN vw_conv_complemento v ON d.id_conv_diver = v.id_conv_diver
    WHERE d.calle ILIKE '%' || p_calle || '%'
      AND (p_num_exterior IS NULL OR d.num_exterior = p_num_exterior);
END;
$$ LANGUAGE plpgsql;

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
    FROM ta_17_conv_d_resto d
    LEFT JOIN vw_conv_complemento v ON d.id_conv_diver = v.id_conv_diver
    WHERE v.recaudadora = p_rec AND v.ur = p_ur AND v.cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_busca_by_licencia
-- Tipo: Report
-- Descripción: Busca convenios por número de licencia de giro
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_by_licencia(p_licencia INTEGER)
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
    FROM ta_17_conv_d_resto d
    LEFT JOIN vw_conv_complemento v ON d.id_conv_diver = v.id_conv_diver
    WHERE v.licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;

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
    FROM ta_17_conv_d_resto d
    LEFT JOIN vw_conv_complemento v ON d.id_conv_diver = v.id_conv_diver
    WHERE v.anuncio = p_anuncio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_busca_by_multa
-- Tipo: Report
-- Descripción: Busca convenios por multa (dependencia, año acta, número acta)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_by_multa(p_dependencia TEXT, p_axo_acta INTEGER, p_num_acta INTEGER)
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
    FROM ta_17_conv_d_resto d
    LEFT JOIN vw_conv_complemento v ON d.id_conv_diver = v.id_conv_diver
    WHERE v.dependencia = p_dependencia AND v.axo_acta = p_axo_acta AND v.num_acta = p_num_acta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

