-- ========================================================================
-- DEPLOY: STORED PROCEDURES PARA GNUEVOS Y RNUEVOS - OTRAS OBLIGACIONES
-- ========================================================================
-- Fecha: 2025-12-02
-- Descripción: Script de despliegue para los SPs corregidos de GNuevos y RNuevos
-- Componentes: GNuevos.vue, RNuevos.vue
-- ========================================================================

-- ========================================================================
-- 1. SP_GET_ETIQUETAS - Corregido tipo de parámetro
-- ========================================================================
DROP FUNCTION IF EXISTS sp_get_etiquetas(VARCHAR);
DROP FUNCTION IF EXISTS sp_get_etiquetas(INTEGER);

CREATE OR REPLACE FUNCTION sp_get_etiquetas(par_tab INTEGER)
RETURNS TABLE(
    cve_tab INTEGER,
    abreviatura VARCHAR,
    etiq_control VARCHAR,
    concesionario VARCHAR,
    ubicacion VARCHAR,
    superficie VARCHAR,
    fecha_inicio VARCHAR,
    fecha_fin VARCHAR,
    recaudadora VARCHAR,
    sector VARCHAR,
    zona VARCHAR,
    licencia VARCHAR,
    fecha_cancelacion VARCHAR,
    unidad VARCHAR,
    categoria VARCHAR,
    seccion VARCHAR,
    bloque VARCHAR,
    nombre_comercial VARCHAR,
    lugar VARCHAR,
    obs VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t34_etiq.cve_tab,
        t34_etiq.abreviatura,
        t34_etiq.etiq_control,
        t34_etiq.concesionario,
        t34_etiq.ubicacion,
        t34_etiq.superficie,
        t34_etiq.fecha_inicio,
        t34_etiq.fecha_fin,
        t34_etiq.recaudadora,
        t34_etiq.sector,
        t34_etiq.zona,
        t34_etiq.licencia,
        t34_etiq.fecha_cancelacion,
        t34_etiq.unidad,
        t34_etiq.categoria,
        t34_etiq.seccion,
        t34_etiq.bloque,
        t34_etiq.nombre_comercial,
        t34_etiq.lugar,
        t34_etiq.obs
    FROM t34_etiq
    WHERE t34_etiq.cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

-- ========================================================================
-- 2. SP_GET_TABLAS - Corregido tipo de parámetro y GROUP BY
-- ========================================================================
DROP FUNCTION IF EXISTS sp_get_tablas(VARCHAR);
DROP FUNCTION IF EXISTS sp_get_tablas(INTEGER);

CREATE OR REPLACE FUNCTION sp_get_tablas(par_tab INTEGER)
RETURNS TABLE(
    cve_tab INTEGER,
    nombre VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    JOIN t34_unidades b ON a.cve_tab = b.cve_tab
    WHERE a.cve_tab = par_tab
    ORDER BY b.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ========================================================================
-- 3. SP_GNUEVOS_ALTA - Alta de nuevo registro (GNuevos)
-- ========================================================================
DROP FUNCTION IF EXISTS sp_gnuevos_alta(INTEGER, TEXT, TEXT, TEXT, NUMERIC, INTEGER, INTEGER, INTEGER, TEXT, INTEGER, INTEGER, TEXT, TEXT, TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION sp_gnuevos_alta(
    par_tabla INTEGER,
    par_control TEXT,
    par_conces TEXT,
    par_ubica TEXT,
    par_sup NUMERIC,
    par_Axo_Ini INTEGER,
    par_Mes_Ini INTEGER,
    par_ofna INTEGER,
    par_sector TEXT,
    par_zona INTEGER,
    par_lic INTEGER,
    par_Descrip TEXT,
    par_NomCom TEXT,
    par_Lugar TEXT,
    par_Obs TEXT,
    par_usuario TEXT
) RETURNS TABLE(status INTEGER, concepto_status TEXT) AS $$
DECLARE
    v_exists INTEGER;
    v_id_34_datos INTEGER;
    v_msg TEXT;
BEGIN
    -- Validaciones básicas
    IF par_conces IS NULL OR trim(par_conces) = '' THEN
        RETURN QUERY SELECT 0, 'Falta el dato del CONCESIONARIO';
        RETURN;
    END IF;
    IF par_ubica IS NULL OR trim(par_ubica) = '' THEN
        RETURN QUERY SELECT 0, 'Falta el dato de la UBICACION';
        RETURN;
    END IF;
    IF par_sup IS NULL OR par_sup <= 0 THEN
        RETURN QUERY SELECT 0, 'Falta el dato de la SUPERFICIE';
        RETURN;
    END IF;
    IF par_lic IS NULL OR par_lic = 0 THEN
        RETURN QUERY SELECT 0, 'Falta el dato de la LICENCIA';
        RETURN;
    END IF;
    IF par_Axo_Ini IS NULL OR par_Axo_Ini < 2020 THEN
        RETURN QUERY SELECT 0, 'Falta el dato del AÑO de inicio de OBLIGACION';
        RETURN;
    END IF;

    -- Validar que no exista el control
    SELECT count(*) INTO v_exists FROM t34_datos WHERE control = par_control AND cve_tab = par_tabla;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 0, 'Ya existe un registro con ese control';
        RETURN;
    END IF;

    -- Insertar en t34_datos
    INSERT INTO t34_datos (
        cve_tab, control, concesionario, ubicacion, superficie, fecha_inicio, id_recaudadora, sector, id_zona, licencia, descrip_unidad, nom_comercial, lugar, obs, usuario_alta, fecha_alta
    ) VALUES (
        par_tabla, par_control, par_conces, par_ubica, par_sup, make_date(par_Axo_Ini, par_Mes_Ini, 1), par_ofna, par_sector, par_zona, par_lic, par_Descrip, par_NomCom, par_Lugar, par_Obs, par_usuario, now()
    ) RETURNING id_34_datos INTO v_id_34_datos;

    RETURN QUERY SELECT 1, 'Registro creado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ========================================================================
-- 4. SP_INS34_RASTRO_01 - Alta de nuevo local/concesión (RNuevos)
-- ========================================================================
DROP FUNCTION IF EXISTS sp_ins34_rastro_01(INTEGER, VARCHAR, VARCHAR, VARCHAR, NUMERIC, INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER, INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION sp_ins34_rastro_01(
    par_tabla INTEGER,
    par_control VARCHAR,
    par_conces VARCHAR,
    par_ubica VARCHAR,
    par_sup NUMERIC,
    par_Axo_Ini INTEGER,
    par_Mes_Ini INTEGER,
    par_ofna INTEGER,
    par_sector VARCHAR,
    par_zona INTEGER,
    par_lic INTEGER,
    par_Descrip VARCHAR
) RETURNS TABLE(expression INTEGER, expression_1 VARCHAR) AS $$
DECLARE
    v_exists INTEGER;
    v_id_unidad INTEGER;
    v_id_stat INTEGER := 1; -- VIGENTE
BEGIN
    SELECT COUNT(*) INTO v_exists FROM t34_datos WHERE control = par_control;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 1 AS expression, 'Ya existe LOCAL con este dato, intentalo de nuevo' AS expression_1;
        RETURN;
    END IF;

    -- Buscar id_unidad por descripcion
    SELECT id_34_unidad INTO v_id_unidad FROM t34_unidades WHERE descripcion = par_Descrip AND cve_tab = par_tabla LIMIT 1;
    IF v_id_unidad IS NULL THEN
        v_id_unidad := 1; -- fallback
    END IF;

    INSERT INTO t34_datos (
        cve_tab, control, concesionario, ubicacion, superficie, fecha_inicio, id_recaudadora, sector, id_zona, licencia, id_unidad, id_stat
    ) VALUES (
        par_tabla, par_control, par_conces, par_ubica, par_sup, make_date(par_Axo_Ini, par_Mes_Ini, 1), par_ofna, par_sector, par_zona, par_lic, v_id_unidad, v_id_stat
    );

    RETURN QUERY SELECT 0 AS expression, 'Se ejecutó correctamente la creación del Local/Concesión' AS expression_1;
END;
$$ LANGUAGE plpgsql;

-- ========================================================================
-- VERIFICACIÓN
-- ========================================================================
SELECT 'Stored Procedures creados exitosamente' AS status;

-- Verificar que las funciones existen
SELECT
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('sp_get_etiquetas', 'sp_get_tablas', 'sp_gnuevos_alta', 'sp_ins34_rastro_01')
ORDER BY routine_name;
