-- Crear la tabla entregas en el esquema public
-- Esta tabla registra las entregas de requerimientos y notificaciones

-- Primero verificar si ya existe en public
DROP TABLE IF EXISTS public.entregas CASCADE;

CREATE TABLE public.entregas (
    id_entrega SERIAL PRIMARY KEY,
    tipo_entrega VARCHAR(50),
    folio VARCHAR(50) NOT NULL UNIQUE,
    ejecutor VARCHAR(100),
    destinatario VARCHAR(200),
    domicilio VARCHAR(300),
    clave_catastral VARCHAR(50),
    cuenta VARCHAR(50),
    rfc VARCHAR(20),
    concepto VARCHAR(200),
    motivo TEXT,
    monto DECIMAL(15,2),
    fecha_entrega DATE,
    hora_entrega TIME,
    plazo_pago VARCHAR(100),
    observaciones TEXT,
    datos_json TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_registro VARCHAR(50)
);

-- Índices para mejorar búsquedas
CREATE INDEX idx_entregas_folio ON public.entregas(folio);
CREATE INDEX idx_entregas_fecha ON public.entregas(fecha_entrega);
CREATE INDEX idx_entregas_ejecutor ON public.entregas(ejecutor);
CREATE INDEX idx_entregas_cuenta ON public.entregas(cuenta);

-- Comentarios
COMMENT ON TABLE public.entregas IS 'Registro de entregas de requerimientos y notificaciones';
COMMENT ON COLUMN public.entregas.id_entrega IS 'ID único de la entrega';
COMMENT ON COLUMN public.entregas.folio IS 'Folio del requerimiento/notificación entregado';
COMMENT ON COLUMN public.entregas.ejecutor IS 'Nombre del ejecutor que realizó la entrega';
COMMENT ON COLUMN public.entregas.destinatario IS 'Persona que recibió la entrega';
COMMENT ON COLUMN public.entregas.fecha_entrega IS 'Fecha en que se realizó la entrega';
COMMENT ON COLUMN public.entregas.datos_json IS 'Datos completos en formato JSON';
