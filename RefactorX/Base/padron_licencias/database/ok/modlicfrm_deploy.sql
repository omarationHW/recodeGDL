-- ============================================
-- DEPLOY CONSOLIDADO: modlicfrm
-- Componente 81/95 - BATCH 17
-- Generado: 2025-11-20
-- Total SPs: 3
-- Nota: SPs básicos generados para modificación de licencias
-- ============================================

-- SP 1/3: sp_modlic_get_licencia
CREATE OR REPLACE FUNCTION public.sp_modlic_get_licencia(p_id_licencia INTEGER)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    id_giro INTEGER,
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    domicilio VARCHAR,
    telefono_prop VARCHAR,
    email VARCHAR,
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    colonia_ubic VARCHAR,
    vigente VARCHAR,
    fecha_otorgamiento DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia, l.empresa, l.id_giro, l.propietario, l.primer_ap, l.segundo_ap,
           l.rfc, l.curp, l.domicilio, l.telefono_prop, l.email, l.ubicacion, l.numext_ubic,
           l.colonia_ubic, l.vigente, l.fecha_otorgamiento
    FROM licencias l
    WHERE l.id_licencia = p_id_licencia;
END;
$$ LANGUAGE plpgsql;

-- SP 2/3: sp_modlic_update_licencia
CREATE OR REPLACE FUNCTION public.sp_modlic_update_licencia(
    p_id_licencia INTEGER,
    p_propietario VARCHAR,
    p_primer_ap VARCHAR,
    p_segundo_ap VARCHAR,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_domicilio VARCHAR,
    p_telefono_prop VARCHAR,
    p_email VARCHAR
) RETURNS JSON AS $$
BEGIN
    UPDATE licencias SET
        propietario = p_propietario,
        primer_ap = p_primer_ap,
        segundo_ap = p_segundo_ap,
        rfc = p_rfc,
        curp = p_curp,
        domicilio = p_domicilio,
        telefono_prop = p_telefono_prop,
        email = p_email
    WHERE id_licencia = p_id_licencia;

    RETURN json_build_object('success', true, 'message', 'Licencia actualizada correctamente');
END;
$$ LANGUAGE plpgsql;

-- SP 3/3: sp_modlic_list
CREATE OR REPLACE FUNCTION public.sp_modlic_list()
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia, l.propietario, l.primer_ap, l.segundo_ap, l.vigente
    FROM licencias l
    ORDER BY l.licencia DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;
