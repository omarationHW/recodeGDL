-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: comun
-- ============================================
\c padron_licencias;
SET search_path TO comun, public;

-- ============================================
-- STORED PROCEDURE PARA GIROS CON ADEUDO
-- Componente: GirosDconAdeudofrm
-- Convención: sp_giros_dcon_adeudo
-- Implementado: 2025-11-20
-- Tablas: comun.licencias, comun.c_giros, comun.detsal_lic
-- Módulo: GIROSDCONADEUDOFRM - Reporte de giros restringidos con adeudo
-- ============================================

-- ============================================
-- SP: sp_giros_dcon_adeudo
-- Tipo: Reporte/Consulta
-- Descripción: Reporte de giros restringidos (clasificación 'D') con adeudos desde un año específico
--              Devuelve licencias, propietario, domicilio completo, descripción del giro y año del adeudo
-- Parámetros:
--   - p_year: Año desde el cual se consideran los adeudos (REQUERIDO)
-- Retorna: Conjunto de registros con licencias que tienen adeudos desde el año especificado
-- Esquema destino: comun
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_giros_dcon_adeudo(
    p_year INTEGER
)
RETURNS TABLE(
    licencia VARCHAR,
    propietario VARCHAR,
    propietario_completo VARCHAR,
    domicilio_completo VARCHAR,
    descripcion_giro VARCHAR,
    anio_adeudo INTEGER
) AS $$
BEGIN
    -- Validación de parámetro requerido
    IF p_year IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_year es obligatorio';
    END IF;

    -- Consulta principal: giros restringidos (clasificación 'D') con adeudos desde el año especificado
    RETURN QUERY
    SELECT
        l.licencia::VARCHAR,
        l.propietario::VARCHAR,
        -- Construcción del nombre completo del propietario
        (TRIM(COALESCE(l.primer_ap, '')) || ' ' ||
         TRIM(COALESCE(l.segundo_ap, '')) || ' ' ||
         TRIM(COALESCE(l.propietario, '')))::VARCHAR as propietario_completo,
        -- Construcción del domicilio completo
        (TRIM(COALESCE(l.ubicacion, '')) ||
         ' No. ext.: ' || COALESCE(l.numext_ubic, '') ||
         ' Letra ext.: ' || COALESCE(l.letraext_ubic, '') ||
         ' No. int.: ' || COALESCE(l.numint_ubic, '') ||
         ' Letra int.: ' || COALESCE(l.letraint_ubic, ''))::VARCHAR as domicilio_completo,
        g.descripcion::VARCHAR as descripcion_giro,
        MIN(d.axo)::INTEGER as anio_adeudo
    FROM comun.licencias l
    INNER JOIN comun.detsal_lic d ON l.id_licencia = d.id_licencia
    INNER JOIN comun.c_giros g ON g.id_giro = l.id_giro
    WHERE d.cvepago = 0              -- Sin clave de pago (adeudo pendiente)
      AND d.id_anuncio = 0           -- Sin anuncio asociado
      AND g.clasificacion = 'D'      -- Giros restringidos
    GROUP BY
        l.licencia,
        l.propietario,
        l.primer_ap,
        l.segundo_ap,
        l.ubicacion,
        l.numext_ubic,
        l.letraext_ubic,
        l.numint_ubic,
        l.letraint_ubic,
        g.descripcion
    HAVING MIN(d.axo) = p_year       -- Filtra por año del primer adeudo
    ORDER BY l.licencia ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMENTARIOS Y DOCUMENTACIÓN
-- ============================================

COMMENT ON FUNCTION comun.sp_giros_dcon_adeudo IS
'Reporte de giros restringidos (clasificación D) con adeudos desde un año específico.
Devuelve: licencia, propietario, nombre completo, domicilio completo, giro y año del adeudo.
Parámetros: p_year (INTEGER) - Año desde el cual se consideran los adeudos (REQUERIDO).
Uso: SELECT * FROM comun.sp_giros_dcon_adeudo(2023);';

-- ============================================
-- PERMISOS
-- ============================================

GRANT EXECUTE ON FUNCTION comun.sp_giros_dcon_adeudo(INTEGER) TO public;

-- ============================================
-- ÍNDICES RECOMENDADOS (si no existen)
-- ============================================

-- Índice en detsal_lic para optimizar búsquedas por licencia y cvepago
CREATE INDEX IF NOT EXISTS idx_detsal_lic_id_licencia_cvepago
ON comun.detsal_lic(id_licencia, cvepago);

-- Índice en detsal_lic para optimizar búsquedas por año
CREATE INDEX IF NOT EXISTS idx_detsal_lic_axo
ON comun.detsal_lic(axo);

-- Índice en detsal_lic para optimizar búsquedas por id_anuncio
CREATE INDEX IF NOT EXISTS idx_detsal_lic_id_anuncio
ON comun.detsal_lic(id_anuncio);

-- Índice en c_giros para optimizar búsquedas por clasificación
CREATE INDEX IF NOT EXISTS idx_c_giros_clasificacion
ON comun.c_giros(clasificacion);

-- Índice en licencias para optimizar búsquedas por id_giro
CREATE INDEX IF NOT EXISTS idx_licencias_id_giro
ON comun.licencias(id_giro);

-- ============================================
-- EJEMPLOS DE USO
-- ============================================

-- Ejemplo 1: Obtener giros con adeudo desde el año 2023
-- SELECT * FROM comun.sp_giros_dcon_adeudo(2023);

-- Ejemplo 2: Obtener giros con adeudo desde el año 2022
-- SELECT * FROM comun.sp_giros_dcon_adeudo(2022);

-- Ejemplo 3: Contar total de licencias con adeudo desde 2023
-- SELECT COUNT(*) as total_licencias
-- FROM comun.sp_giros_dcon_adeudo(2023);

-- Ejemplo 4: Agrupar por giro para obtener estadísticas
-- SELECT
--     descripcion_giro,
--     COUNT(*) as total_licencias,
--     anio_adeudo
-- FROM comun.sp_giros_dcon_adeudo(2023)
-- GROUP BY descripcion_giro, anio_adeudo
-- ORDER BY total_licencias DESC;

-- ============================================
-- NOTAS TÉCNICAS
-- ============================================

-- 1. CLASIFICACIÓN DE GIROS:
--    - 'D': Giros restringidos (requieren permisos especiales)
--    - Solo se reportan giros con clasificación 'D'

-- 2. CRITERIOS DE ADEUDO:
--    - cvepago = 0: Indica que no hay pago registrado (adeudo pendiente)
--    - id_anuncio = 0: Indica que no hay anuncio asociado
--    - MIN(axo): Se toma el año más antiguo del adeudo

-- 3. CONSTRUCCIÓN DE DATOS:
--    - propietario_completo: Concatena primer apellido + segundo apellido + nombre
--    - domicilio_completo: Concatena ubicación + número exterior/interior + letras

-- 4. PERFORMANCE:
--    - Los índices recomendados mejoran significativamente el rendimiento
--    - La consulta está optimizada para evitar subconsultas innecesarias
--    - Usa INNER JOIN en lugar de LEFT JOIN para filtrar datos más eficientemente

-- 5. VALIDACIONES:
--    - Valida que el parámetro p_year sea obligatorio
--    - GROUP BY asegura que no haya duplicados por licencia
--    - HAVING filtra por el año exacto del primer adeudo

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================

-- Componente:        GirosDconAdeudofrm
-- Total SPs:         1
-- SP Implementado:   comun.sp_giros_dcon_adeudo
-- Tipo:              Reporte
-- Esquema:           comun
-- Estado:            COMPLETO ✓
-- Fecha:             2025-11-20
-- Performance:       Optimizado con índices recomendados
-- Validaciones:      Parámetro requerido validado
-- Documentación:     Completa con ejemplos de uso

-- ============================================
-- FIN DE IMPLEMENTACIÓN
-- ============================================
