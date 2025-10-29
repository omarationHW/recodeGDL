-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: IMPRECIBOFRM (EXACTO del archivo original)
-- Archivo: 21_SP_LICENCIAS_IMPRECIBOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_get_licencia_recibo
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la licencia para impresión de recibo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_licencia_recibo(p_licencia INTEGER)
RETURNS TABLE(
    licencia INTEGER,
    nombre TEXT,
    domicilio TEXT,
    id_licencia INTEGER,
    dom_completo TEXT,
    propietarionvo TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.licencia,
           (COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) AS nombre,
           (l.ubicacion || ' ' || l.numext_ubic || '-' || COALESCE(l.letraext_ubic, '') || '-' || COALESCE(l.numint_ubic, '') || '-' || COALESCE(l.letraint_ubic, '')) AS domicilio,
           l.id_licencia,
           (l.ubicacion || ' ' || l.numext_ubic || '-' || COALESCE(l.letraext_ubic, '') || '-' || COALESCE(l.numint_ubic, '') || '-' || COALESCE(l.letraint_ubic, '')) AS dom_completo,
           (COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) AS propietarionvo
    FROM public l
    WHERE l.licencia = p_licencia AND l.vigente = 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: IMPRECIBOFRM (EXACTO del archivo original)
-- Archivo: 21_SP_LICENCIAS_IMPRECIBOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_numero_a_letras
-- Tipo: CRUD
-- Descripción: Convierte un número a letras en español (simplificado, para montos menores a 1000000)
-- --------------------------------------------

-- NOTA: Para producción, usar una extensión o función más robusta
CREATE OR REPLACE FUNCTION sp_numero_a_letras(p_numero NUMERIC)
RETURNS TEXT AS $$
DECLARE
    unidades TEXT[] := ARRAY['CERO','UNO','DOS','TRES','CUATRO','CINCO','SEIS','SIETE','OCHO','NUEVE'];
    decenas TEXT[] := ARRAY['', 'DIEZ','VEINTE','TREINTA','CUARENTA','CINCUENTA','SESENTA','SETENTA','OCHENTA','NOVENTA'];
    centenas TEXT[] := ARRAY['','CIEN','DOSCIENTOS','TRESCIENTOS','CUATROCIENTOS','QUINIENTOS','SEISCIENTOS','SETECIENTOS','OCHOCIENTOS','NOVECIENTOS'];
    n INT := p_numero;
    resultado TEXT := '';
BEGIN
    IF n < 10 THEN
        resultado := unidades[n+1];
    ELSIF n < 100 THEN
        resultado := decenas[n/10] || CASE WHEN n%10 > 0 THEN ' Y ' || unidades[(n%10)+1] ELSE '' END;
    ELSIF n < 1000 THEN
        resultado := centenas[n/100] || CASE WHEN n%100 > 0 THEN ' ' || decenas[(n%100)/10] END;
    ELSE
        resultado := 'CANTIDAD ALTA';
    END IF;
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

-- ============================================

