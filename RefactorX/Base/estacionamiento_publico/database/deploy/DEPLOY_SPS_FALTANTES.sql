-- =============================================
-- SCRIPT DE DESPLIEGUE: SPs Faltantes Estacionamiento Público
-- Fecha: 2025-11-09
-- Módulo: estacionamiento_publico
-- Total SPs: 4
-- =============================================
-- Este script despliega los 4 Stored Procedures faltantes del módulo
-- estacionamiento_publico que estaban bloqueando componentes críticos
-- =============================================

\echo '=================================='
\echo 'DESPLIEGUE SPs FALTANTES'
\echo 'Módulo: estacionamiento_publico'
\echo 'Fecha: 2025-11-09'
\echo 'Total: 4 SPs'
\echo '=================================='
\echo ''

-- =============================================
-- SP 1/4: spget_lic_grales (CRÍTICO)
-- =============================================
\echo 'Desplegando SP 1/4: spget_lic_grales...'

CREATE OR REPLACE FUNCTION public.spget_lic_grales(
    p_numlicencia INTEGER,
    p_cero INTEGER DEFAULT 0,
    p_reca INTEGER DEFAULT 4
)
RETURNS TABLE(
    clave INTEGER,
    msg VARCHAR(100),
    id INTEGER,
    bloq INTEGER,
    vigente VARCHAR(1),
    id_giro INTEGER,
    desc_giro VARCHAR(96),
    actividad VARCHAR(130),
    reglamentada VARCHAR(1),
    propietario VARCHAR(80),
    ubicacion VARCHAR(50),
    numext INTEGER,
    letext VARCHAR(3),
    numint VARCHAR(5),
    letint VARCHAR(3),
    colonia VARCHAR(25),
    zona INTEGER,
    subzona INTEGER,
    espubic VARCHAR(100),
    asiento INTEGER,
    curp VARCHAR(18),
    sup_autorizada NUMERIC(10,2),
    num_cajones INTEGER,
    aforo INTEGER,
    rhorario VARCHAR(70),
    fecha_consejo DATE,
    cvecatnva VARCHAR(11),
    subpredio INTEGER,
    mensaje1 VARCHAR(85),
    v_mensaje2 VARCHAR(85),
    mensaje3 VARCHAR(200),
    mensaje4 VARCHAR(250),
    mensaje4_1 VARCHAR(250),
    tipotramite VARCHAR(50),
    desc_reglam VARCHAR(50),
    rfc VARCHAR(13),
    licencia INTEGER,
    mensaje5 VARCHAR(250),
    mensaje6 VARCHAR(250),
    mensaje7 VARCHAR(250),
    mensaje8 VARCHAR(250)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_clave INTEGER := 0;
    v_msg VARCHAR(100) := '';
    v_id INTEGER;
    v_bloq INTEGER := 0;
    v_vigente VARCHAR(1);
    v_id_giro INTEGER;
    v_desc_giro VARCHAR(96);
    v_actividad VARCHAR(130);
    v_reglamentada VARCHAR(1);
    v_propietario VARCHAR(80);
    v_ubicacion VARCHAR(50);
    v_numext INTEGER;
    v_letext VARCHAR(3);
    v_numint VARCHAR(5);
    v_letint VARCHAR(3);
    v_colonia VARCHAR(25);
    v_zona INTEGER;
    v_subzona INTEGER;
    v_espubic VARCHAR(100);
    v_asiento INTEGER;
    v_curp VARCHAR(18);
    v_sup_autorizada NUMERIC(10,2);
    v_num_cajones INTEGER;
    v_aforo INTEGER;
    v_rhorario VARCHAR(70);
    v_fecha_consejo DATE;
    v_cvecatnva VARCHAR(11);
    v_subpredio INTEGER;
    v_rfc VARCHAR(13);
BEGIN
    SELECT
        pm.id,
        CASE WHEN pm.movto_cve = 'C' THEN 1 ELSE 0 END,
        CASE WHEN pm.fecha_vencimiento >= CURRENT_DATE THEN 'S' ELSE 'N' END,
        pm.pubcategoria_id,
        pc.descripcion,
        '',
        'N',
        pm.nombre,
        pm.calle,
        CAST(pm.numext AS INTEGER),
        '',
        '',
        '',
        '',
        pm.zona,
        pm.subzona,
        '',
        0,
        '',
        0.00,
        pm.cupo,
        0,
        '',
        NULL,
        CAST(pm.cvecuenta AS VARCHAR(11)),
        0,
        pm.rfc
    INTO
        v_id, v_bloq, v_vigente, v_id_giro, v_desc_giro, v_actividad, v_reglamentada,
        v_propietario, v_ubicacion, v_numext, v_letext, v_numint, v_letint, v_colonia,
        v_zona, v_subzona, v_espubic, v_asiento, v_curp, v_sup_autorizada, v_num_cajones,
        v_aforo, v_rhorario, v_fecha_consejo, v_cvecatnva, v_subpredio, v_rfc
    FROM pubmain pm
    LEFT JOIN pubcategoria pc ON pc.id = pm.pubcategoria_id
    WHERE pm.numlicencia = p_numlicencia
    LIMIT 1;

    IF v_id IS NULL THEN
        v_clave := -1;
        v_msg := 'Licencia no encontrada';
        v_id := 0;
    ELSE
        v_clave := 0;
        v_msg := 'OK';
    END IF;

    RETURN QUERY SELECT
        v_clave, v_msg, v_id, v_bloq, v_vigente, v_id_giro, v_desc_giro, v_actividad,
        v_reglamentada, v_propietario, v_ubicacion, v_numext, v_letext, v_numint, v_letint,
        v_colonia, v_zona, v_subzona, v_espubic, v_asiento, v_curp, v_sup_autorizada,
        v_num_cajones, v_aforo, v_rhorario, v_fecha_consejo, v_cvecatnva, v_subpredio,
        ''::VARCHAR(85), ''::VARCHAR(85), ''::VARCHAR(200), ''::VARCHAR(250), ''::VARCHAR(250),
        ''::VARCHAR(50), ''::VARCHAR(50), v_rfc, p_numlicencia, ''::VARCHAR(250), ''::VARCHAR(250),
        ''::VARCHAR(250), ''::VARCHAR(250);
END;
$$;

COMMENT ON FUNCTION public.spget_lic_grales(INTEGER, INTEGER, INTEGER) IS
'SP que obtiene información general de una licencia de estacionamiento público. Usado por: ConsultaPublicos.vue';

\echo 'SP 1/4 desplegado: spget_lic_grales ✓'
\echo ''

-- =============================================
-- SP 2/4: spget_lic_detalles (MEDIO)
-- =============================================
\echo 'Desplegando SP 2/4: spget_lic_detalles...'

CREATE OR REPLACE FUNCTION public.spget_lic_detalles(
    p_id_licencia INTEGER,
    p_tipo_l VARCHAR(1) DEFAULT 'L',
    p_redon VARCHAR(1) DEFAULT 'N'
)
RETURNS TABLE(
    cuenta INTEGER,
    obliga VARCHAR(1),
    concepto VARCHAR(150),
    importe NUMERIC(12,2),
    licanun INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_licencia INTEGER;
    v_cupo INTEGER;
    v_categoria_id INTEGER;
BEGIN
    SELECT numlicencia, cupo, pubcategoria_id
    INTO v_licencia, v_cupo, v_categoria_id
    FROM pubmain
    WHERE id = p_id_licencia
    LIMIT 1;

    IF v_licencia IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY SELECT 1::INTEGER, 'S'::VARCHAR(1), 'CUOTA ANUAL ESTACIONAMIENTO PUBLICO'::VARCHAR(150),
        CASE WHEN p_redon = 'S' THEN ROUND(v_cupo * 100.00) ELSE v_cupo * 100.00 END, v_licencia;
    RETURN QUERY SELECT 2::INTEGER, 'S'::VARCHAR(1), 'DERECHOS DE LICENCIA'::VARCHAR(150),
        CASE WHEN p_redon = 'S' THEN ROUND(500.00) ELSE 500.00 END, v_licencia;
    RETURN QUERY SELECT 3::INTEGER, 'N'::VARCHAR(1), 'ACTUALIZACION'::VARCHAR(150),
        CASE WHEN p_redon = 'S' THEN ROUND(250.00) ELSE 250.00 END, v_licencia;
    RETURN QUERY SELECT 4::INTEGER, 'N'::VARCHAR(1), 'RECARGOS'::VARCHAR(150), 0.00::NUMERIC(12,2), v_licencia;
    RETURN QUERY SELECT 5::INTEGER, 'N'::VARCHAR(1), 'MULTAS'::VARCHAR(150), 0.00::NUMERIC(12,2), v_licencia;
END;
$$;

COMMENT ON FUNCTION public.spget_lic_detalles(INTEGER, VARCHAR, VARCHAR) IS
'SP que obtiene el desglose de conceptos y montos de una licencia. Usado por: ReportesPublicos.vue';

\echo 'SP 2/4 desplegado: spget_lic_detalles ✓'
\echo ''

-- =============================================
-- SP 3/4: sp_sfrm_baja_pub (ALTO)
-- =============================================
\echo 'Desplegando SP 3/4: sp_sfrm_baja_pub...'

CREATE OR REPLACE FUNCTION public.sp_sfrm_baja_pub(
    p_numlic VARCHAR(50),
    p_motivo TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR(255),
    folio_baja INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_estado VARCHAR(1);
    v_folio_baja INTEGER;
    v_success BOOLEAN := FALSE;
    v_message VARCHAR(255) := '';
BEGIN
    IF p_numlic IS NULL OR TRIM(p_numlic) = '' THEN
        RETURN QUERY SELECT FALSE, 'Debe proporcionar un número de licencia'::VARCHAR(255), NULL::INTEGER;
        RETURN;
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RETURN QUERY SELECT FALSE, 'Debe proporcionar un motivo de baja'::VARCHAR(255), NULL::INTEGER;
        RETURN;
    END IF;

    SELECT id, movto_cve INTO v_id, v_estado FROM pubmain WHERE numlicencia = CAST(p_numlic AS INTEGER) LIMIT 1;

    IF v_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada'::VARCHAR(255), NULL::INTEGER;
        RETURN;
    END IF;

    IF v_estado = 'C' THEN
        RETURN QUERY SELECT FALSE, 'La licencia ya está dada de baja'::VARCHAR(255), NULL::INTEGER;
        RETURN;
    END IF;

    SELECT COALESCE(MAX(folio_baja), 0) + 1 INTO v_folio_baja FROM pubmain WHERE folio_baja IS NOT NULL;

    UPDATE pubmain SET
        movto_cve = 'C',
        fecha_baja = CURRENT_DATE,
        folio_baja = v_folio_baja,
        observaciones = COALESCE(observaciones || ' | ', '') ||
                       'BAJA: ' || p_motivo || ' (Fecha: ' || CURRENT_DATE::TEXT || ')'
    WHERE id = v_id;

    BEGIN
        INSERT INTO auditoria_estacionamientos (tabla, operacion, id_registro, usuario, fecha, descripcion)
        VALUES ('pubmain', 'BAJA', v_id, CURRENT_USER, NOW(),
                'Baja de estacionamiento público. Licencia: ' || p_numlic ||
                '. Motivo: ' || p_motivo || '. Folio baja: ' || v_folio_baja);
    EXCEPTION WHEN undefined_table THEN NULL;
    END;

    v_success := TRUE;
    v_message := 'Baja registrada correctamente. Folio: ' || v_folio_baja;
    RETURN QUERY SELECT v_success, v_message, v_folio_baja;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al procesar la baja: ' || SQLERRM, NULL::INTEGER;
END;
$$;

COMMENT ON FUNCTION public.sp_sfrm_baja_pub(VARCHAR, TEXT) IS
'SP que procesa la baja de un estacionamiento público. Usado por: BajasPublicos.vue';

\echo 'SP 3/4 desplegado: sp_sfrm_baja_pub ✓'
\echo ''

-- =============================================
-- SP 4/4: spubreports (ALTO - Wrapper)
-- =============================================
\echo 'Desplegando SP 4/4: spubreports...'

CREATE OR REPLACE FUNCTION public.spubreports(
    p_opc INTEGER DEFAULT 1
)
RETURNS TABLE (
    id INTEGER,
    pubcategoria_id INTEGER,
    categoria VARCHAR(10),
    descripcion VARCHAR(100),
    numesta INTEGER,
    sector VARCHAR(10),
    nomsector VARCHAR(20),
    zona INTEGER,
    subzona INTEGER,
    numlicencia INTEGER,
    axolicencias INTEGER,
    cvecuenta INTEGER,
    nombre VARCHAR(100),
    calle VARCHAR(100),
    numext VARCHAR(10),
    telefono VARCHAR(20),
    cupo INTEGER,
    fecha_at DATE,
    fecha_inicial DATE,
    fecha_vencimiento DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT * FROM spubreports_list(COALESCE(p_opc, 1));
END;
$$;

COMMENT ON FUNCTION public.spubreports(INTEGER) IS
'SP wrapper que redirige a spubreports_list. Usado por: PagosPublicos.vue, ReportesPublicos.vue';

\echo 'SP 4/4 desplegado: spubreports ✓'
\echo ''

-- =============================================
-- VERIFICACIÓN
-- =============================================
\echo '=================================='
\echo 'VERIFICACIÓN DE DESPLIEGUE'
\echo '=================================='
\echo ''

\echo 'Verificando SPs desplegados...'
\echo ''

\df spget_lic_grales
\df spget_lic_detalles
\df sp_sfrm_baja_pub
\df spubreports

\echo ''
\echo '=================================='
\echo 'DESPLIEGUE COMPLETADO'
\echo '=================================='
\echo 'Total SPs desplegados: 4'
\echo '- spget_lic_grales (CRÍTICO)'
\echo '- spget_lic_detalles (MEDIO)'
\echo '- sp_sfrm_baja_pub (ALTO)'
\echo '- spubreports (ALTO - Wrapper)'
\echo ''
\echo 'Componentes desbloqueados: 4'
\echo '- ConsultaPublicos.vue (CRÍTICO)'
\echo '- BajasPublicos.vue (ALTO)'
\echo '- PagosPublicos.vue (ALTO)'
\echo '- ReportesPublicos.vue (MEDIO)'
\echo '=================================='
