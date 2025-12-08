-- ============================================
-- DEPLOY: formabuscalle.vue
-- Módulo: padron_licencias
-- Componente: Formulario de Búsqueda de Calles
-- Total SPs: 2
-- Fecha: 2025-11-20
-- ============================================

\echo ''
\echo '================================================'
\echo 'DESPLEGANDO: formabuscalle (2 SPs)'
\echo '================================================'
\echo ''

-- SP 1/2: sp_buscar_calles
CREATE OR REPLACE FUNCTION public.sp_buscar_calles(filtro TEXT)
RETURNS TABLE (
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig VARCHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecalle, c.cvepoblacion, c.desvial, c.calle, c.cvevig, c.anterior, c.feccap, c.capturista
    FROM public.c_calles c
    WHERE c.calle ILIKE '%' || filtro || '%'
      AND c.cvecalle NOT IN (
        SELECT cvecalle FROM public.c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
      )
    ORDER BY c.calle
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 1/2: sp_buscar_calles creado exitosamente'

-- SP 2/2: sp_listar_calles
CREATE OR REPLACE FUNCTION public.sp_listar_calles()
RETURNS TABLE (
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig VARCHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecalle, c.cvepoblacion, c.desvial, c.calle, c.cvevig, c.anterior, c.feccap, c.capturista
    FROM public.c_calles c
    WHERE c.cvecalle NOT IN (
        SELECT cvecalle FROM public.c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
    )
    ORDER BY c.calle
    LIMIT 1000;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 2/2: sp_listar_calles creado exitosamente'
\echo ''
\echo 'DEPLOY COMPLETADO: formabuscalle'
\echo ''
