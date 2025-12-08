-- ============================================
-- DEPLOY: LigaRequisitos.vue
-- Módulo: padron_licencias
-- Total SPs: 5
-- Fecha: 2025-11-20
-- ============================================

\echo 'Desplegando LigaRequisitos (5 SPs)...'

CREATE OR REPLACE FUNCTION public.sp_ligarequisitos_list(p_id_giro INTEGER)
RETURNS TABLE(req INTEGER, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT r.req, gr.descripcion
  FROM public.giro_req r
  JOIN public.c_girosreq gr ON r.req = gr.req
  WHERE r.id_giro = p_id_giro
  ORDER BY r.req;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_ligarequisitos_available(p_id_giro INTEGER)
RETURNS TABLE(req INTEGER, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT gr.req, gr.descripcion
  FROM public.c_girosreq gr
  WHERE gr.req NOT IN (SELECT req FROM public.giro_req WHERE id_giro = p_id_giro)
  ORDER BY gr.req;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_ligarequisitos_giros()
RETURNS TABLE(id_giro INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT g.id_giro, g.descripcion
  FROM comun.c_giros g
  WHERE g.id_giro > 500 AND g.tipo = 'L' AND g.vigente = 'V'
  ORDER BY g.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_ligarequisitos_add(p_id_giro INTEGER, p_req INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.giro_req WHERE id_giro = p_id_giro AND req = p_req) THEN
    RETURN QUERY SELECT FALSE, 'El requisito ya está ligado a este giro'::TEXT;
  ELSE
    INSERT INTO public.giro_req (id_giro, req) VALUES (p_id_giro, p_req);
    RETURN QUERY SELECT TRUE, 'Requisito agregado exitosamente'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_ligarequisitos_remove(p_id_giro INTEGER, p_req INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.giro_req WHERE id_giro = p_id_giro AND req = p_req) THEN
    RETURN QUERY SELECT FALSE, 'El requisito no está ligado a este giro'::TEXT;
  ELSE
    DELETE FROM public.giro_req WHERE id_giro = p_id_giro AND req = p_req;
    RETURN QUERY SELECT TRUE, 'Requisito eliminado exitosamente'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'LigaRequisitos completado'
