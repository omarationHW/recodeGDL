-- ============================================
-- DEPLOY: CatRequisitos.vue
-- Módulo: padron_licencias
-- Total SPs: 5
-- Fecha: 2025-11-20
-- ============================================

\echo 'Desplegando CatRequisitos (5 SPs)...'

CREATE OR REPLACE FUNCTION public.sp_cat_requisitos_list()
RETURNS TABLE(req INTEGER, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT req, descripcion FROM public.c_girosreq ORDER BY req;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_cat_requisitos_search(p_descripcion VARCHAR)
RETURNS TABLE(req INTEGER, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT req, descripcion FROM public.c_girosreq WHERE descripcion ILIKE '%' || p_descripcion || '%' ORDER BY req;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_cat_requisitos_create(p_descripcion VARCHAR)
RETURNS TABLE(req INTEGER, descripcion VARCHAR) AS $$
DECLARE
  new_req INTEGER;
BEGIN
  SELECT COALESCE(MAX(req),0)+1 INTO new_req FROM public.c_girosreq;
  INSERT INTO public.c_girosreq(req, descripcion) VALUES (new_req, p_descripcion);
  RETURN QUERY SELECT req, descripcion FROM public.c_girosreq WHERE req = new_req;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_cat_requisitos_update(p_req INTEGER, p_descripcion VARCHAR)
RETURNS TABLE(req INTEGER, descripcion VARCHAR) AS $$
BEGIN
  UPDATE public.c_girosreq SET descripcion = p_descripcion WHERE req = p_req;
  RETURN QUERY SELECT req, descripcion FROM public.c_girosreq WHERE req = p_req;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_cat_requisitos_delete(p_req INTEGER)
RETURNS TABLE(req INTEGER, descripcion VARCHAR) AS $$
DECLARE
  old_desc VARCHAR;
BEGIN
  SELECT descripcion INTO old_desc FROM public.c_girosreq WHERE req = p_req;
  DELETE FROM public.c_girosreq WHERE req = p_req;
  RETURN QUERY SELECT p_req, old_desc;
END;
$$ LANGUAGE plpgsql;

\echo 'CatRequisitos completado'
