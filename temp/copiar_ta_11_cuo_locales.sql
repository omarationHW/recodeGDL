-- ============================================
-- COPIA DE TABLA: ta_11_cuo_locales
-- Origen:  mercados.public.ta_11_cuo_locales
-- Destino: padron_licencias.comun.ta_11_cuo_locales
-- ============================================

-- Conectarse a la base padron_licencias
\c padron_licencias;

-- Crear schema comun si no existe
CREATE SCHEMA IF NOT EXISTS comun;

-- Eliminar tabla si existe (CUIDADO: esto borra datos existentes)
DROP TABLE IF EXISTS comun.ta_11_cuo_locales CASCADE;

-- Crear tabla con la misma estructura que en mercados
-- NOTA: Ajustar los tipos de datos según la estructura real de la tabla

-- Opción 1: Si conoces la estructura exacta, créala manualmente
-- CREATE TABLE comun.ta_11_cuo_locales (
--   ... columnas ...
-- );

-- Opción 2: Usar pg_dump y pg_restore (ejecutar desde línea de comandos)
-- pg_dump -U postgres -h localhost -p 5432 -d mercados -t public.ta_11_cuo_locales --schema-only |
-- sed 's/public\./comun./g' |
-- psql -U postgres -h localhost -p 5432 -d padron_licencias

-- ============================================
-- Método alternativo: Usando dblink
-- ============================================

-- 1. Instalar extensión dblink (si no está instalada)
CREATE EXTENSION IF NOT EXISTS dblink;

-- 2. Crear la tabla en el schema comun copiando la estructura desde mercados
-- Esto requiere una conexión temporal

-- Crear tabla con estructura desde mercados usando dblink
SELECT *
INTO comun.ta_11_cuo_locales
FROM dblink(
    'dbname=mercados host=localhost port=5432 user=postgres password=sistemas',
    'SELECT * FROM public.ta_11_cuo_locales LIMIT 0'
) AS t(
    -- IMPORTANTE: Definir aquí todas las columnas con sus tipos
    -- Ejemplo (ajustar según estructura real):
    categoria INTEGER,
    seccion VARCHAR(10),
    clave_cuota INTEGER,
    importe_cuota NUMERIC(10,2),
    axo INTEGER,
    -- ... agregar todas las columnas necesarias
    descripcion TEXT
);

-- 3. Copiar los datos desde mercados
INSERT INTO comun.ta_11_cuo_locales
SELECT *
FROM dblink(
    'dbname=mercados host=localhost port=5432 user=postgres password=sistemas',
    'SELECT * FROM public.ta_11_cuo_locales'
) AS t(
    -- IMPORTANTE: Definir aquí todas las columnas con sus tipos (igual que arriba)
    categoria INTEGER,
    seccion VARCHAR(10),
    clave_cuota INTEGER,
    importe_cuota NUMERIC(10,2),
    axo INTEGER,
    -- ... agregar todas las columnas necesarias
    descripcion TEXT
);

-- 4. Verificar copia
SELECT COUNT(*) as total_registros FROM comun.ta_11_cuo_locales;

-- 5. Crear índices si es necesario
-- CREATE INDEX idx_ta_11_cuo_locales_categoria ON comun.ta_11_cuo_locales(categoria);
-- CREATE INDEX idx_ta_11_cuo_locales_axo ON comun.ta_11_cuo_locales(axo);
-- etc...

-- ============================================
-- FIN DEL SCRIPT
-- ============================================

-- Verificación final
\d comun.ta_11_cuo_locales
SELECT COUNT(*) FROM comun.ta_11_cuo_locales;
