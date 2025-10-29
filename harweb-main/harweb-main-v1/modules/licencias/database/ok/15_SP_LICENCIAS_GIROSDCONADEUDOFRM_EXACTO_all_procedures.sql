-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: GIROSDCONADEUDOFRM (EXACTO del archivo original)
-- Archivo: 15_SP_LICENCIAS_GIROSDCONADEUDOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: report_giros_dcon_adeudo
-- Tipo: Report
-- Descripción: Reporte de giros restringidos con adeudo desde un año específico. Devuelve licencias, propietario, nombre, ubicación, giro y año.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION report_giros_dcon_adeudo(p_year INTEGER)
RETURNS TABLE(
    licencia VARCHAR,
    propietario VARCHAR,
    propietarionvo VARCHAR,
    domCompleto VARCHAR,
    descripcion VARCHAR,
    axo INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.licencia,
        l.propietario,
        TRIM(COALESCE(l.primer_ap, '')) || ' ' || TRIM(COALESCE(l.segundo_ap, '')) || ' ' || TRIM(l.propietario) AS propietarionvo,
        TRIM(l.ubicacion) || ' No. ext.:' || COALESCE(l.numext_ubic, '') || ' Letra ext. ' || COALESCE(l.letraext_ubic, '') || ' No. int.' || COALESCE(l.numint_ubic, '') || ' Letra int. ' || COALESCE(l.letraint_ubic, '') AS domCompleto,
        g.descripcion,
        MIN(d.axo) AS axo
    FROM public l
    JOIN detsal_lic d ON l.id_licencia = d.id_licencia
    JOIN c_giros g ON g.id_giro = l.id_giro
    WHERE d.cvepago = 0
      AND d.id_anuncio = 0
      AND g.clasificacion = 'D'
    GROUP BY l.licencia, l.propietario, l.primer_ap, l.segundo_ap, l.propietario, l.ubicacion, l.numext_ubic, l.letraext_ubic, l.numint_ubic, l.letraint_ubic, g.descripcion
    HAVING MIN(d.axo) = p_year
    ORDER BY l.licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

