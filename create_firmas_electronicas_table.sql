-- Crear la tabla firmas_electronicas en el esquema public
-- Esta tabla registra las firmas electrónicas de documentos

-- Primero verificar si ya existe
DROP TABLE IF EXISTS public.firmas_electronicas CASCADE;

CREATE TABLE public.firmas_electronicas (
    id_firma SERIAL PRIMARY KEY,
    folio VARCHAR(100) NOT NULL UNIQUE,
    usuario VARCHAR(100) NOT NULL,
    tipo VARCHAR(50),
    datos_firma TEXT,
    hash_firma VARCHAR(255),
    fecha_firma TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    datos_json TEXT,
    ip_address VARCHAR(50),
    dispositivo VARCHAR(200),
    observaciones TEXT,
    estado VARCHAR(20) DEFAULT 'ACTIVA'
);

-- Índices para mejorar búsquedas
CREATE INDEX idx_firmas_folio ON public.firmas_electronicas(folio);
CREATE INDEX idx_firmas_fecha ON public.firmas_electronicas(fecha_firma);
CREATE INDEX idx_firmas_usuario ON public.firmas_electronicas(usuario);
CREATE INDEX idx_firmas_hash ON public.firmas_electronicas(hash_firma);

-- Comentarios
COMMENT ON TABLE public.firmas_electronicas IS 'Registro de firmas electrónicas de documentos';
COMMENT ON COLUMN public.firmas_electronicas.id_firma IS 'ID único de la firma';
COMMENT ON COLUMN public.firmas_electronicas.folio IS 'Folio del documento firmado (único)';
COMMENT ON COLUMN public.firmas_electronicas.usuario IS 'Usuario que realizó la firma';
COMMENT ON COLUMN public.firmas_electronicas.tipo IS 'Tipo de firma o documento';
COMMENT ON COLUMN public.firmas_electronicas.datos_firma IS 'Datos de la firma electrónica';
COMMENT ON COLUMN public.firmas_electronicas.hash_firma IS 'Hash criptográfico de la firma';
COMMENT ON COLUMN public.firmas_electronicas.fecha_firma IS 'Fecha y hora de la firma';
COMMENT ON COLUMN public.firmas_electronicas.datos_json IS 'Datos completos en formato JSON';
COMMENT ON COLUMN public.firmas_electronicas.estado IS 'Estado de la firma (ACTIVA, REVOCADA, etc)';
