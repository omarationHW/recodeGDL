-- ============================================
-- DEPLOY: Cruces.vue
-- Módulo: padron_licencias
-- Componente: Búsqueda de Cruces de Calles
-- Total SPs: 3
-- Fecha: 2025-11-20
-- ============================================

\echo ''
\echo '================================================'
\echo 'DESPLEGANDO: Cruces (3 SPs)'
\echo '================================================'
\echo ''

-- SP 1/3: sp_cruces_search_calle1
CREATE OR REPLACE FUNCTION public.sp_cruces_search_calle1(search_text TEXT)
RETURNS TABLE (
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig CHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecalle, c.cvepoblacion, c.desvial, c.calle, c.cvevig, c.anterior, c.feccap, c.capturista
    FROM public.c_calles c
    WHERE UPPER(c.calle) LIKE '%' || UPPER(search_text) || '%'
      AND c.cvecalle NOT IN (
        SELECT cvecalle FROM public.c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
      )
    ORDER BY c.calle
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 1/3: sp_cruces_search_calle1 creado exitosamente'

-- SP 2/3: sp_cruces_search_calle2
CREATE OR REPLACE FUNCTION public.sp_cruces_search_calle2(search_text TEXT)
RETURNS TABLE (
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig CHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecalle, c.cvepoblacion, c.desvial, c.calle, c.cvevig, c.anterior, c.feccap, c.capturista
    FROM public.c_calles c
    WHERE UPPER(c.calle) LIKE '%' || UPPER(search_text) || '%'
      AND c.cvecalle NOT IN (
        SELECT cvecalle FROM public.c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
      )
    ORDER BY c.calle
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 2/3: sp_cruces_search_calle2 creado exitosamente'

-- SP 3/3: sp_cruces_localiza_calle
CREATE OR REPLACE FUNCTION public.sp_cruces_localiza_calle(cvecalle1 INTEGER, cvecalle2 INTEGER)
RETURNS TABLE (
    tipo INTEGER,
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig CHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    IF cvecalle1 > 0 THEN
        RETURN QUERY
        SELECT 1 AS tipo, c.cvecalle, c.cvepoblacion, c.desvial, c.calle, c.cvevig, c.anterior, c.feccap, c.capturista
        FROM public.c_calles c
        WHERE c.cvecalle = cvecalle1;
    END IF;
    IF cvecalle2 > 0 THEN
        RETURN QUERY
        SELECT 2 AS tipo, c.cvecalle, c.cvepoblacion, c.desvial, c.calle, c.cvevig, c.anterior, c.feccap, c.capturista
        FROM public.c_calles c
        WHERE c.cvecalle = cvecalle2;
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 3/3: sp_cruces_localiza_calle creado exitosamente'
\echo ''
\echo 'DEPLOY COMPLETADO: Cruces'
\echo ''
