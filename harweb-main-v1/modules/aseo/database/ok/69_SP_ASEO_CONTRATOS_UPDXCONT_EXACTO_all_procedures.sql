-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPDXCONT (EXACTO del archivo original)
-- Archivo: 69_SP_ASEO_CONTRATOS_UPDXCONT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp16_buscar_contrato
-- Tipo: CRUD
-- Descripción: Busca un contrato por número y tipo de aseo, devuelve todos los datos relevantes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_buscar_contrato(p_num_contrato INTEGER, p_ctrol_aseo INTEGER)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    ctrol_recolec INTEGER,
    cantidad_recolec SMALLINT,
    domicilio VARCHAR,
    sector VARCHAR,
    ctrol_zona INTEGER,
    id_rec SMALLINT,
    fecha_hora_alta TIMESTAMP,
    status_vigencia VARCHAR,
    aso_mes_oblig DATE,
    cve VARCHAR,
    usuario INTEGER,
    fecha_hora_baja TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_contrato, num_contrato, ctrol_aseo, num_empresa, ctrol_emp, ctrol_recolec, cantidad_recolec, domicilio, sector, ctrol_zona, id_rec, fecha_hora_alta, status_vigencia, aso_mes_oblig, cve, usuario, fecha_hora_baja
    FROM public.ta_16_contratos
    WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPDXCONT (EXACTO del archivo original)
-- Archivo: 69_SP_ASEO_CONTRATOS_UPDXCONT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp16_alta_empresa
-- Tipo: CRUD
-- Descripción: Da de alta una nueva empresa privada con nombre y representante igual.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_alta_empresa(p_nombre VARCHAR)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR
) AS $$
DECLARE
    v_max INTEGER;
BEGIN
    SELECT COALESCE(MAX(num_empresa),0) INTO v_max FROM public.ta_16_empresas WHERE ctrol_emp = 9;
    INSERT INTO public.ta_16_empresas (num_empresa, ctrol_emp, descripcion, representante)
    VALUES (v_max+1, 9, p_nombre, p_nombre);
    RETURN QUERY SELECT v_max+1, 9, p_nombre, p_nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPDXCONT (EXACTO del archivo original)
-- Archivo: 69_SP_ASEO_CONTRATOS_UPDXCONT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

