-- ============================================
-- DEFINICIÓN DE TABLA - DOCTOSFRM_TRAMITE
-- ============================================
-- Componente: doctosfrm
-- Módulo: padron_licencias
-- Schema: public
-- Fecha: 2025-11-20
-- ============================================
-- DESCRIPCIÓN:
-- Tabla para almacenar los documentos asociados a cada trámite
-- de licencias. Permite registrar múltiples tipos de documentos
-- mediante un array de códigos y un campo de observaciones.
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- ============================================
-- Eliminar tabla si existe (solo para desarrollo)
-- ============================================
-- DROP TABLE IF EXISTS public.doctosfrm_tramite CASCADE;

-- ============================================
-- Crear tabla doctosfrm_tramite
-- ============================================

CREATE TABLE IF NOT EXISTS public.doctosfrm_tramite (
    -- Identificador único del registro
    id SERIAL PRIMARY KEY,

    -- ID del trámite asociado (FK a tabla tramites)
    tramite_id INTEGER NOT NULL,

    -- Array de códigos de documentos seleccionados
    -- Los códigos válidos se obtienen de sp_doctosfrm_catalog()
    documentos TEXT[] DEFAULT ARRAY[]::TEXT[],

    -- Campo de texto libre para observaciones adicionales
    otro TEXT,

    -- Campos de auditoría
    fecalt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecmod TIMESTAMP,
    capturo INTEGER,
    modifico INTEGER,

    -- Constraints
    CONSTRAINT uk_doctosfrm_tramite UNIQUE (tramite_id)
);

-- ============================================
-- Índices
-- ============================================

-- Índice en tramite_id para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_doctosfrm_tramite_tramite_id
    ON public.doctosfrm_tramite(tramite_id);

-- Índice GIN para búsquedas en el array de documentos
CREATE INDEX IF NOT EXISTS idx_doctosfrm_tramite_documentos
    ON public.doctosfrm_tramite USING GIN(documentos);

-- Índice en fecha de alta
CREATE INDEX IF NOT EXISTS idx_doctosfrm_tramite_fecalt
    ON public.doctosfrm_tramite(fecalt);

-- ============================================
-- Comentarios de documentación
-- ============================================

COMMENT ON TABLE public.doctosfrm_tramite IS
'Almacena los documentos asociados a cada trámite de licencias';

COMMENT ON COLUMN public.doctosfrm_tramite.id IS
'Identificador único del registro';

COMMENT ON COLUMN public.doctosfrm_tramite.tramite_id IS
'ID del trámite asociado (debe existir en tabla tramites)';

COMMENT ON COLUMN public.doctosfrm_tramite.documentos IS
'Array de códigos de documentos. Los códigos válidos se obtienen del catálogo sp_doctosfrm_catalog()';

COMMENT ON COLUMN public.doctosfrm_tramite.otro IS
'Campo de texto libre para observaciones o información adicional sobre la documentación';

COMMENT ON COLUMN public.doctosfrm_tramite.fecalt IS
'Fecha y hora de creación del registro';

COMMENT ON COLUMN public.doctosfrm_tramite.fecmod IS
'Fecha y hora de última modificación';

COMMENT ON COLUMN public.doctosfrm_tramite.capturo IS
'ID del usuario que capturó el registro';

COMMENT ON COLUMN public.doctosfrm_tramite.modifico IS
'ID del usuario que modificó el registro por última vez';

-- ============================================
-- Triggers para auditoría automática
-- ============================================

-- Trigger para actualizar fecmod automáticamente
CREATE OR REPLACE FUNCTION public.trg_doctosfrm_tramite_update_fecmod()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecmod := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_fecmod ON public.doctosfrm_tramite;

CREATE TRIGGER trg_update_fecmod
    BEFORE UPDATE ON public.doctosfrm_tramite
    FOR EACH ROW
    EXECUTE FUNCTION public.trg_doctosfrm_tramite_update_fecmod();

COMMENT ON FUNCTION public.trg_doctosfrm_tramite_update_fecmod() IS
'Función de trigger que actualiza automáticamente el campo fecmod en cada UPDATE';

-- ============================================
-- Grants de permisos (ajustar según usuarios)
-- ============================================

-- Dar permisos de lectura y escritura a usuarios de aplicación
-- GRANT SELECT, INSERT, UPDATE ON public.doctosfrm_tramite TO app_user;
-- GRANT USAGE, SELECT ON SEQUENCE public.doctosfrm_tramite_id_seq TO app_user;

-- ============================================
-- Datos de ejemplo (comentados, descomentar si se necesitan)
-- ============================================

/*
-- Ejemplo de insert
INSERT INTO public.doctosfrm_tramite (tramite_id, documentos, otro, capturo)
VALUES
    (1, ARRAY['fotofachada', 'recibopredial', 'ident_titular'], 'Documentos completos', 1),
    (2, ARRAY['licencia_vigente', 'carta_policia'], NULL, 1),
    (3, ARRAY['acta_constitutiva', 'poder_notarial'], 'Pendiente identificación', 1);
*/

-- ============================================
-- FIN DE DEFINICIÓN DE TABLA
-- ============================================
