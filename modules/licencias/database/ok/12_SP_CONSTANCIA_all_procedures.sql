-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA CONSTANCIAS
-- Convención: SP_CONSTANCIA_XXX  
-- Generado: 2025-09-09
-- Módulo: 12 - CONSTANCIAFRM (Prioridad Media)
-- ============================================

-- SP 1/4: SP_CONSTANCIA_LIST
CREATE OR REPLACE FUNCTION SP_CONSTANCIA_LIST(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_tipo_constancia VARCHAR(50) DEFAULT NULL,
    p_limite INTEGER DEFAULT 50, p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(folio_constancia VARCHAR(100), numero_licencia VARCHAR(100), tipo_constancia VARCHAR(50), fecha_expedicion DATE, total_registros BIGINT)
LANGUAGE plpgsql AS $$
DECLARE v_total BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total FROM public.constancias WHERE (p_numero_licencia IS NULL OR numero_licencia ILIKE '%' || p_numero_licencia || '%');
    RETURN QUERY SELECT c.folio_constancia, c.numero_licencia, c.tipo_constancia, c.fecha_expedicion, v_total FROM public.constancias c LIMIT p_limite OFFSET p_offset;
END; $$;

-- SP 2/4: SP_CONSTANCIA_CREATE
CREATE OR REPLACE FUNCTION SP_CONSTANCIA_CREATE(
    p_folio_constancia VARCHAR(100), p_numero_licencia VARCHAR(100), 
    p_tipo_constancia VARCHAR(50), p_usuario_expedidor VARCHAR(100)
)
RETURNS TABLE(success BOOLEAN, message TEXT, id INTEGER)
LANGUAGE plpgsql AS $$
DECLARE v_new_id INTEGER;
BEGIN
    INSERT INTO public.constancias (folio_constancia, numero_licencia, tipo_constancia, usuario_expedidor)
    VALUES (upper(trim(p_folio_constancia)), upper(trim(p_numero_licencia)), upper(trim(p_tipo_constancia)), upper(trim(p_usuario_expedidor)))
    RETURNING public.constancias.id INTO v_new_id;
    RETURN QUERY SELECT TRUE, 'Constancia expedida correctamente.', v_new_id;
END; $$;

-- SP 3/4: SP_CONSTANCIA_GET
CREATE OR REPLACE FUNCTION SP_CONSTANCIA_GET(p_folio_constancia VARCHAR(100))
RETURNS TABLE(folio_constancia VARCHAR(100), numero_licencia VARCHAR(100), propietario VARCHAR(255), tipo_constancia VARCHAR(50))
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT c.folio_constancia, c.numero_licencia, c.propietario, c.tipo_constancia FROM public.constancias c WHERE c.folio_constancia = p_folio_constancia;
END; $$;

-- SP 4/4: SP_CONSTANCIA_ESTADISTICAS
CREATE OR REPLACE FUNCTION SP_CONSTANCIA_ESTADISTICAS()
RETURNS TABLE(total_expedidas INTEGER, expedidas_mes INTEGER, tipos_mas_solicitados TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT COUNT(*)::INTEGER, COUNT(CASE WHEN DATE_TRUNC('month', fecha_expedicion) = DATE_TRUNC('month', CURRENT_DATE) THEN 1 END)::INTEGER, 
                        STRING_AGG(DISTINCT tipo_constancia, ', ') FROM public.constancias;
END; $$;