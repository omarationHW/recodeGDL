-- Tabla: fosas
-- Base de datos: multas_reglamentos
-- Esquema: publico (sin 'c' al final)
-- Descripción: Almacena información de fosas en panteones municipales

-- Verificar si la tabla existe antes de crearla
CREATE TABLE IF NOT EXISTS publico.fosas (
    id_control INTEGER PRIMARY KEY,
    cementerio VARCHAR(200),
    clase VARCHAR(100),
    seccion VARCHAR(50),
    linea VARCHAR(50),
    fosa VARCHAR(50),
    nombre_titular VARCHAR(300),
    anio_minimo INTEGER,
    anio_maximo INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para optimizar búsquedas
CREATE INDEX IF NOT EXISTS idx_fosas_id_control ON publico.fosas(id_control);
CREATE INDEX IF NOT EXISTS idx_fosas_cementerio ON publico.fosas(cementerio);
CREATE INDEX IF NOT EXISTS idx_fosas_titular ON publico.fosas(nombre_titular);

-- Comentario descriptivo de la tabla
COMMENT ON TABLE publico.fosas IS
'Almacena información de fosas en panteones municipales, incluyendo ubicación (cementerio, sección, línea) y datos del titular.';

-- Comentarios en las columnas
COMMENT ON COLUMN publico.fosas.id_control IS 'ID de control único de la fosa';
COMMENT ON COLUMN publico.fosas.cementerio IS 'Nombre del cementerio o panteón municipal';
COMMENT ON COLUMN publico.fosas.clase IS 'Clasificación de la fosa';
COMMENT ON COLUMN publico.fosas.seccion IS 'Sección dentro del cementerio';
COMMENT ON COLUMN publico.fosas.linea IS 'Línea dentro de la sección';
COMMENT ON COLUMN publico.fosas.fosa IS 'Número o identificador de la fosa';
COMMENT ON COLUMN publico.fosas.nombre_titular IS 'Nombre del titular de la fosa';
COMMENT ON COLUMN publico.fosas.anio_minimo IS 'Año mínimo del período de vigencia';
COMMENT ON COLUMN publico.fosas.anio_maximo IS 'Año máximo del período de vigencia';
