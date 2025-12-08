-- =====================================================
-- Script para configurar acceso a tablas compartidas
-- de padron_licencias en otras_obligaciones
-- =====================================================

-- 1. Instalar extension postgres_fdw si no existe
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- 2. Crear el foreign server para conectar a padron_licencias
DROP SERVER IF EXISTS padron_licencias_server CASCADE;
CREATE SERVER padron_licencias_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host '192.168.6.146', port '5432', dbname 'padron_licencias');

-- 3. Crear el user mapping
DROP USER MAPPING IF EXISTS FOR refact SERVER padron_licencias_server;
CREATE USER MAPPING FOR refact
    SERVER padron_licencias_server
    OPTIONS (user 'refact', password 'FF)-BQk2');

-- 4. Crear el schema comun si no existe
CREATE SCHEMA IF NOT EXISTS comun;

-- 5. Importar la tabla ta_15_apremios desde padron_licencias
DROP FOREIGN TABLE IF EXISTS comun.ta_15_apremios;
CREATE FOREIGN TABLE comun.ta_15_apremios (
    id_control INTEGER NOT NULL,
    zona SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia CHAR(1),
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado CHAR(1),
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate CHAR(1),
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones VARCHAR(13055),
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja CHAR(2),
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia CHAR(1),
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov CHAR(2),
    hora_practicado TIMESTAMP,
    fea_secuencia INTEGER,
    importe_actualizacion NUMERIC
)
SERVER padron_licencias_server
OPTIONS (schema_name 'comun', table_name 'ta_15_apremios');

-- 6. Importar tabla de periodos de apremio
DROP FOREIGN TABLE IF EXISTS comun.ta_15_periodos;
CREATE FOREIGN TABLE comun.ta_15_periodos (
    id_periodo INTEGER NOT NULL,
    anio SMALLINT,
    mes SMALLINT,
    descripcion VARCHAR(50),
    fecha_inicio DATE,
    fecha_fin DATE,
    activo CHAR(1)
)
SERVER padron_licencias_server
OPTIONS (schema_name 'comun', table_name 'ta_15_periodos');

-- 7. Importar tabla de ejecutores
DROP FOREIGN TABLE IF EXISTS comun.ta_15_ejecutores;
CREATE FOREIGN TABLE comun.ta_15_ejecutores (
    id_ejecutor INTEGER NOT NULL,
    nombre VARCHAR(100),
    activo CHAR(1)
)
SERVER padron_licencias_server
OPTIONS (schema_name 'comun', table_name 'ta_15_ejecutores');

-- 8. Verificar que todo funciona
DO $$
BEGIN
    RAISE NOTICE 'Verificando acceso a foreign tables...';

    -- Test query
    PERFORM COUNT(*) FROM comun.ta_15_apremios LIMIT 1;

    RAISE NOTICE 'Configuracion de FDW completada exitosamente!';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error verificando: %', SQLERRM;
END $$;

-- Otorgar permisos
GRANT USAGE ON SCHEMA comun TO refact;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA comun TO refact;
