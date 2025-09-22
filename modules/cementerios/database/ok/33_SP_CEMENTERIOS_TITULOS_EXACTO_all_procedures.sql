-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TITULOS (EXACTO del archivo original)
-- Archivo: 33_SP_CEMENTERIOS_TITULOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: sp_titulos_search
-- Tipo: CRUD
-- Descripción: Busca un título por fecha, folio y operación, devuelve todos los datos relevantes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulos_search(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(
    control_rcm INTEGER,
    titulo INTEGER,
    libro INTEGER,
    axo INTEGER,
    folio_libro INTEGER,
    nombre_beneficiario TEXT,
    domicilio_beneficiario TEXT,
    colonia_beneficiario TEXT,
    telefono_beneficiario TEXT,
    partida TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.control_rcm, t.titulo, t.libro, t.axo, t.folio, t.nombre_beneficiario, t.domicilio_beneficiario, t.colonia_beneficiario, t.telefono_beneficiario, t.partida
    FROM public.ta_13_titulos t
    WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TITULOS (EXACTO del archivo original)
-- Archivo: 33_SP_CEMENTERIOS_TITULOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 3/6: sp_titulos_print
-- Tipo: Report
-- Descripción: Devuelve los datos necesarios para la impresión del título.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulos_print(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(
    control_rcm INTEGER,
    titulo INTEGER,
    libro INTEGER,
    axo INTEGER,
    folio_libro INTEGER,
    nombre_beneficiario TEXT,
    domicilio_beneficiario TEXT,
    colonia_beneficiario TEXT,
    telefono_beneficiario TEXT,
    partida TEXT,
    datos_json JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.control_rcm, t.titulo, t.libro, t.axo, t.folio, t.nombre_beneficiario, t.domicilio_beneficiario, t.colonia_beneficiario, t.telefono_beneficiario, t.partida,
           to_jsonb(t) as datos_json
    FROM public.ta_13_titulos t
    WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TITULOS (EXACTO del archivo original)
-- Archivo: 33_SP_CEMENTERIOS_TITULOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: sp_titulos_validate
-- Tipo: CRUD
-- Descripción: Valida la existencia de un título.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulos_validate(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(exists BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT EXISTS(
        SELECT 1 FROM public.ta_13_titulos t
        WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TITULOS (EXACTO del archivo original)
-- Archivo: 33_SP_CEMENTERIOS_TITULOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

