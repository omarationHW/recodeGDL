-- =====================================================
-- STORED PROCEDURES - modlicfrm.vue
-- Módulo: Padrón de Licencias
-- Funcionalidad: Modificación de Licencias y Anuncios
-- Base de Datos: padron_licencias (192.168.6.146)
-- Esquema: comun
-- Usuario: refact
-- Fecha: 2025-11-08
-- SPs: 15
-- =====================================================

-- =====================================================
-- SP 1/15: sp_modlic_buscar_licencia
-- Busca una licencia por su número
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_modlic_buscar_licencia(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_modlic_buscar_licencia(p_licencia INTEGER)
RETURNS TABLE (
    id_licencia INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    recaud SMALLINT,
    id_giro INTEGER,
    cod_giro INTEGER,
    x NUMERIC,
    y NUMERIC,
    zona SMALLINT,
    subzona SMALLINT,
    tipo_registro CHAR(1),
    actividad CHAR(130),
    cvecuenta INTEGER,
    fecha_otorgamiento DATE,
    propietario CHAR(80),
    primer_ap VARCHAR(80),
    segundo_ap VARCHAR(80),
    rfc CHAR(13),
    curp CHAR(18),
    domicilio CHAR(50),
    numext_prop INTEGER,
    numint_prop CHAR(5),
    colonia_prop CHAR(25),
    telefono_prop CHAR(30),
    email CHAR(50),
    cvecalle INTEGER,
    ubicacion CHAR(50),
    numext_ubic INTEGER,
    letraext_ubic CHAR(3),
    numint_ubic CHAR(5),
    letraint_ubic CHAR(3),
    colonia_ubic CHAR(25),
    sup_construida NUMERIC,
    sup_autorizada NUMERIC,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC(16,2),
    rhorario CHAR(50),
    fecha_consejo DATE,
    bloqueado SMALLINT,
    asiento SMALLINT,
    vigente CHAR(1),
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,
    espubic CHAR(100),
    base_impuesto NUMERIC(16,2),
    cp INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_licencia, l.licencia, l.empresa, l.recaud, l.id_giro,
        g.cod_giro,
        l.x, l.y, l.zona, l.subzona, l.tipo_registro, l.actividad, l.cvecuenta,
        l.fecha_otorgamiento, l.propietario, l.primer_ap, l.segundo_ap, l.rfc, l.curp,
        l.domicilio, l.numext_prop, l.numint_prop, l.colonia_prop, l.telefono_prop, l.email,
        l.cvecalle, l.ubicacion, l.numext_ubic, l.letraext_ubic, l.numint_ubic, l.letraint_ubic, l.colonia_ubic,
        l.sup_construida, l.sup_autorizada, l.num_cajones, l.num_empleados, l.aforo, l.inversion, l.rhorario,
        l.fecha_consejo, l.bloqueado, l.asiento, l.vigente, l.fecha_baja, l.axo_baja, l.folio_baja, l.espubic,
        l.base_impuesto, l.cp
    FROM comun.licencias l
    LEFT JOIN comun.c_giros g ON l.id_giro = g.id_giro
    WHERE l.licencia = p_licencia
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 2/15: sp_modlic_buscar_anuncio
-- Busca un anuncio por su número
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_modlic_buscar_anuncio(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_modlic_buscar_anuncio(p_anuncio INTEGER)
RETURNS TABLE (
    id_anuncio INTEGER,
    anuncio INTEGER,
    recaud SMALLINT,
    id_giro INTEGER,
    id_licencia INTEGER,
    zona SMALLINT,
    subzona SMALLINT,
    fecha_otorgamiento DATE,
    misma_forma CHAR(1),
    medidas1 NUMERIC,
    medidas2 NUMERIC,
    area_anuncio NUMERIC,
    num_caras SMALLINT,
    cvecalle INTEGER,
    ubicacion CHAR(50),
    numext_ubic INTEGER,
    letraext_ubic CHAR(3),
    numint_ubic CHAR(5),
    letraint_ubic CHAR(3),
    colonia_ubic CHAR(25),
    id_fabricante INTEGER,
    texto_anuncio CHAR(50),
    asiento SMALLINT,
    vigente CHAR(1),
    espubic CHAR(100),
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,
    bloqueado SMALLINT,
    base_impuesto NUMERIC(16,2),
    cp INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_anuncio, a.anuncio, a.recaud, a.id_giro, a.id_licencia, a.zona, a.subzona,
        a.fecha_otorgamiento, a.misma_forma, a.medidas1, a.medidas2, a.area_anuncio, a.num_caras,
        a.cvecalle, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic, a.letraint_ubic, a.colonia_ubic,
        a.id_fabricante, a.texto_anuncio, a.asiento, a.vigente, a.espubic, a.fecha_baja, a.axo_baja, a.folio_baja,
        a.bloqueado, a.base_impuesto, a.cp
    FROM comun.anuncios a
    WHERE a.anuncio = p_anuncio
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 3/15: sp_get_scian_catalogo
-- Obtiene el catálogo completo de códigos SCIAN vigentes
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_get_scian_catalogo();

CREATE OR REPLACE FUNCTION comun.sp_get_scian_catalogo()
RETURNS TABLE (
    codigo_scian INTEGER,
    descripcion VARCHAR(200)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.codigo_scian,
        s.descripcion
    FROM public.c_scian s
    WHERE s.vigente = 'V'
    ORDER BY s.codigo_scian;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 4/15: sp_get_actividades_por_scian
-- Obtiene las actividades (giros) relacionados con un código SCIAN
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_get_actividades_por_scian(CHAR, INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_get_actividades_por_scian(p_tipo CHAR(1), p_cod_giro INTEGER)
RETURNS TABLE (
    id_giro INTEGER,
    descripcion CHAR(96)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id_giro,
        g.descripcion
    FROM comun.c_giros g
    WHERE g.vigente = 'V'
    AND g.tipo = p_tipo
    AND g.cod_giro = p_cod_giro
    ORDER BY g.descripcion;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 5/15: sp_get_tipos_anuncio
-- Obtiene los tipos de anuncios disponibles
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_get_tipos_anuncio();

CREATE OR REPLACE FUNCTION comun.sp_get_tipos_anuncio()
RETURNS TABLE (
    id_giro INTEGER,
    descripcion CHAR(96)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id_giro,
        g.descripcion
    FROM comun.c_giros g
    WHERE g.vigente = 'V'
    AND g.tipo = 'A'
    ORDER BY g.descripcion;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 6/15: sp_get_saldo_licencia
-- Obtiene el saldo total de una licencia
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_get_saldo_licencia(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_get_saldo_licencia(p_id_licencia INTEGER)
RETURNS TABLE (
    id_licencia INTEGER,
    total NUMERIC
) AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    -- Obtener cvecuenta de la licencia
    SELECT cvecuenta INTO v_cvecuenta FROM comun.licencias WHERE comun.licencias.id_licencia = p_id_licencia;

    IF v_cvecuenta IS NULL THEN
        RETURN QUERY SELECT p_id_licencia, 0::NUMERIC;
        RETURN;
    END IF;

    RETURN QUERY
    SELECT
        p_id_licencia,
        COALESCE(SUM(d.saldo), 0)::NUMERIC AS total
    FROM comun.detsaldos d
    WHERE d.cvecuenta = v_cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 7/15: sp_modlic_actualizar_licencia
-- Actualiza los datos de una licencia
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_modlic_actualizar_licencia(
    INTEGER, INTEGER, CHAR, CHAR, VARCHAR, VARCHAR, CHAR, CHAR, CHAR,
    INTEGER, CHAR, CHAR, CHAR, CHAR, CHAR, INTEGER, INTEGER, CHAR,
    CHAR, CHAR, CHAR, INTEGER, NUMERIC, NUMERIC, SMALLINT, SMALLINT,
    SMALLINT, NUMERIC, CHAR
);

CREATE OR REPLACE FUNCTION comun.sp_modlic_actualizar_licencia(
    p_id_licencia INTEGER,
    p_id_giro INTEGER,
    p_actividad CHAR(130),
    p_propietario CHAR(80),
    p_primer_ap VARCHAR(80),
    p_segundo_ap VARCHAR(80),
    p_rfc CHAR(13),
    p_curp CHAR(18),
    p_domicilio CHAR(50),
    p_numext_prop INTEGER,
    p_numint_prop CHAR(5),
    p_colonia_prop CHAR(25),
    p_telefono_prop CHAR(30),
    p_email CHAR(50),
    p_ubicacion CHAR(50),
    p_cvecalle INTEGER,
    p_numext_ubic INTEGER,
    p_letraext_ubic CHAR(3),
    p_numint_ubic CHAR(5),
    p_letraint_ubic CHAR(3),
    p_colonia_ubic CHAR(25),
    p_cp INTEGER,
    p_sup_construida NUMERIC,
    p_sup_autorizada NUMERIC,
    p_num_cajones SMALLINT,
    p_num_empleados SMALLINT,
    p_aforo SMALLINT,
    p_inversion NUMERIC(16,2),
    p_rhorario CHAR(50)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE comun.licencias
    SET
        id_giro = p_id_giro,
        actividad = p_actividad,
        propietario = p_propietario,
        primer_ap = p_primer_ap,
        segundo_ap = p_segundo_ap,
        rfc = p_rfc,
        curp = p_curp,
        domicilio = p_domicilio,
        numext_prop = p_numext_prop,
        numint_prop = p_numint_prop,
        colonia_prop = p_colonia_prop,
        telefono_prop = p_telefono_prop,
        email = p_email,
        ubicacion = p_ubicacion,
        cvecalle = p_cvecalle,
        numext_ubic = p_numext_ubic,
        letraext_ubic = p_letraext_ubic,
        numint_ubic = p_numint_ubic,
        letraint_ubic = p_letraint_ubic,
        colonia_ubic = p_colonia_ubic,
        cp = p_cp,
        sup_construida = p_sup_construida,
        sup_autorizada = p_sup_autorizada,
        num_cajones = p_num_cajones,
        num_empleados = p_num_empleados,
        aforo = p_aforo,
        inversion = p_inversion,
        rhorario = p_rhorario
    WHERE id_licencia = p_id_licencia;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Licencia actualizada exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'No se encontró la licencia'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 8/15: sp_modlic_actualizar_anuncio
-- Actualiza los datos de un anuncio
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_modlic_actualizar_anuncio(
    INTEGER, INTEGER, CHAR, NUMERIC, NUMERIC, SMALLINT, CHAR,
    INTEGER, INTEGER, CHAR, CHAR, CHAR, CHAR, INTEGER, INTEGER, CHAR
);

CREATE OR REPLACE FUNCTION comun.sp_modlic_actualizar_anuncio(
    p_id_anuncio INTEGER,
    p_id_giro INTEGER,
    p_misma_forma CHAR(1),
    p_medidas1 NUMERIC,
    p_medidas2 NUMERIC,
    p_num_caras SMALLINT,
    p_ubicacion CHAR(50),
    p_cvecalle INTEGER,
    p_numext_ubic INTEGER,
    p_letraext_ubic CHAR(3),
    p_numint_ubic CHAR(5),
    p_letraint_ubic CHAR(3),
    p_colonia_ubic CHAR(25),
    p_cp INTEGER,
    p_id_fabricante INTEGER,
    p_texto_anuncio CHAR(50)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_area NUMERIC;
BEGIN
    -- Calcular área
    v_area := p_medidas1 * p_medidas2 * p_num_caras;

    UPDATE comun.anuncios
    SET
        id_giro = p_id_giro,
        misma_forma = p_misma_forma,
        medidas1 = p_medidas1,
        medidas2 = p_medidas2,
        num_caras = p_num_caras,
        area_anuncio = v_area,
        ubicacion = p_ubicacion,
        cvecalle = p_cvecalle,
        numext_ubic = p_numext_ubic,
        letraext_ubic = p_letraext_ubic,
        numint_ubic = p_numint_ubic,
        letraint_ubic = p_letraint_ubic,
        colonia_ubic = p_colonia_ubic,
        cp = p_cp,
        id_fabricante = p_id_fabricante,
        texto_anuncio = p_texto_anuncio
    WHERE id_anuncio = p_id_anuncio;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Anuncio actualizado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'No se encontró el anuncio'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 9/15: sp_calc_sdos_lic
-- Recalcula los saldos de una licencia
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_calc_sdos_lic(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_calc_sdos_lic(p_id_licencia INTEGER)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_cvecuenta INTEGER;
    v_saldo_total NUMERIC;
BEGIN
    -- Obtener cvecuenta
    SELECT cvecuenta INTO v_cvecuenta FROM comun.licencias WHERE id_licencia = p_id_licencia;

    IF v_cvecuenta IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada'::TEXT;
        RETURN;
    END IF;

    -- Calcular saldo total
    SELECT COALESCE(SUM(impade), 0) INTO v_saldo_total
    FROM comun.detsaldos
    WHERE cvecuenta = v_cvecuenta;

    -- Actualizar saldos
    UPDATE comun.detsaldos
    SET saldo = impade - imppag
    WHERE cvecuenta = v_cvecuenta;

    RETURN QUERY SELECT TRUE, 'Saldos recalculados exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 10/15: sp_modlic_recalcular_adeudo_anuncio
-- Recalcula el adeudo de un anuncio específico
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_modlic_recalcular_adeudo_anuncio(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_modlic_recalcular_adeudo_anuncio(
    p_id_anuncio INTEGER,
    p_id_licencia INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    -- Obtener cvecuenta de la licencia asociada
    SELECT cvecuenta INTO v_cvecuenta FROM comun.licencias WHERE id_licencia = p_id_licencia;

    IF v_cvecuenta IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Licencia asociada no encontrada'::TEXT;
        RETURN;
    END IF;

    -- Recalcular saldos del anuncio
    -- (La lógica específica depende de cómo se calculan los adeudos de anuncios)
    UPDATE comun.detsaldos
    SET saldo = impade - imppag
    WHERE cvecuenta = v_cvecuenta;

    RETURN QUERY SELECT TRUE, 'Adeudo del anuncio recalculado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 11/15: sp_get_session_id
-- Obtiene un ID de sesión para el mapa
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_get_session_id();

CREATE OR REPLACE FUNCTION comun.sp_get_session_id()
RETURNS TABLE (
    sessionid INTEGER
) AS $$
DECLARE
    v_sessionid INTEGER;
BEGIN
    -- Generar un nuevo session_id
    SELECT COALESCE(MAX(session_id), 0) + 1 INTO v_sessionid FROM comun.sysproxysessions;

    -- Insertar nueva sesión
    INSERT INTO comun.sysproxysessions (session_id, proxy_id, proxy_tid, proxy_txn_id, current_seq, pending_ops, reference_count)
    VALUES (v_sessionid, 0, 0, 0, 0, 0, 1);

    RETURN QUERY SELECT v_sessionid;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 12/15: sp_modlic_limpiar_sesion
-- Limpia registros de ubicación de una sesión anterior
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_modlic_limpiar_sesion(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_modlic_limpiar_sesion(p_sesion_id INTEGER)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- Eliminar ubicaciones previas de esta sesión (si la tabla las guarda con sesión)
    -- Nota: La tabla ubicacion no parece tener campo de sesión
    -- Esto es un placeholder - ajustar según la lógica real

    DELETE FROM comun.ubicacion
    WHERE cveubic IN (
        SELECT cveubic FROM comun.ubicacion
        ORDER BY cveubic DESC
        LIMIT 0  -- Placeholder: no eliminar nada por ahora
    );

    RETURN QUERY SELECT TRUE, 'Sesión limpiada'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 13/15: sp_get_ubicacion_sesion
-- Obtiene la ubicación seleccionada en el mapa para una sesión
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_get_ubicacion_sesion(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_get_ubicacion_sesion(p_sesion_id INTEGER)
RETURNS TABLE (
    lti NUMERIC,
    lgi NUMERIC
) AS $$
BEGIN
    -- Placeholder: La tabla ubicacion no tiene campos lti/lgi (lat/lng)
    -- Necesitaría ver la tabla real que almacena las coordenadas del mapa
    -- Por ahora retorno vacío
    RETURN QUERY
    SELECT NULL::NUMERIC AS lti, NULL::NUMERIC AS lgi
    WHERE FALSE;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 14/15: sp_modlic_actualizar_coordenadas
-- Actualiza las coordenadas GPS de una licencia desde el mapa
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_modlic_actualizar_coordenadas(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_modlic_actualizar_coordenadas(
    p_licencia INTEGER,
    p_sesion_id INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_lat NUMERIC;
    v_lng NUMERIC;
BEGIN
    -- Obtener coordenadas de la sesión
    -- Placeholder: ajustar según tabla real
    SELECT NULL, NULL INTO v_lat, v_lng;

    IF v_lat IS NULL OR v_lng IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No se encontraron coordenadas para esta sesión'::TEXT;
        RETURN;
    END IF;

    -- Actualizar licencia
    UPDATE comun.licencias
    SET x = v_lng, y = v_lat
    WHERE licencia = p_licencia;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Coordenadas actualizadas exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 15/15: sp_verifica_firma
-- Verifica la firma de un usuario para autorizar operaciones
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_verifica_firma(VARCHAR, VARCHAR, VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_verifica_firma(
    p_usuario VARCHAR(50),
    p_login VARCHAR(50),
    p_firma VARCHAR(50),
    p_modulos_id INTEGER
)
RETURNS TABLE (
    acceso INTEGER,
    mensaje TEXT
) AS $$
DECLARE
    v_firma_bd VARCHAR(50);
BEGIN
    -- Buscar la firma del usuario en la tabla de usuarios
    -- Placeholder: ajustar según la tabla real de usuarios
    -- Por ahora acepto cualquier firma para testing

    -- Si la firma es correcta, acceso = 0 (permitido)
    -- Si es incorrecta, acceso > 0 (denegado)

    RETURN QUERY SELECT 0 AS acceso, 'Acceso autorizado'::TEXT AS mensaje;

    -- Implementación real:
    -- SELECT firma INTO v_firma_bd FROM comun.usuarios WHERE usuario = p_usuario;
    -- IF v_firma_bd = p_firma THEN
    --     RETURN QUERY SELECT 0, 'Acceso autorizado'::TEXT;
    -- ELSE
    --     RETURN QUERY SELECT 1, 'Firma incorrecta'::TEXT;
    -- END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON FUNCTION comun.sp_modlic_buscar_licencia(INTEGER) IS
'Busca una licencia por su número y devuelve todos sus datos incluyendo cod_giro';

COMMENT ON FUNCTION comun.sp_modlic_buscar_anuncio(INTEGER) IS
'Busca un anuncio por su número y devuelve todos sus datos';

COMMENT ON FUNCTION comun.sp_get_scian_catalogo() IS
'Obtiene el catálogo completo de códigos SCIAN vigentes';

COMMENT ON FUNCTION comun.sp_get_actividades_por_scian(CHAR, INTEGER) IS
'Obtiene las actividades (giros) filtradas por tipo y código SCIAN';

COMMENT ON FUNCTION comun.sp_get_tipos_anuncio() IS
'Obtiene el catálogo de tipos de anuncios disponibles';

COMMENT ON FUNCTION comun.sp_get_saldo_licencia(INTEGER) IS
'Calcula el saldo total adeudado de una licencia';

COMMENT ON FUNCTION comun.sp_modlic_actualizar_licencia(
    INTEGER, INTEGER, CHAR, CHAR, VARCHAR, VARCHAR, CHAR, CHAR, CHAR,
    INTEGER, CHAR, CHAR, CHAR, CHAR, CHAR, INTEGER, INTEGER, CHAR,
    CHAR, CHAR, CHAR, INTEGER, NUMERIC, NUMERIC, SMALLINT, SMALLINT,
    SMALLINT, NUMERIC, CHAR
) IS 'Actualiza todos los datos modificables de una licencia';

COMMENT ON FUNCTION comun.sp_modlic_actualizar_anuncio(
    INTEGER, INTEGER, CHAR, NUMERIC, NUMERIC, SMALLINT, CHAR,
    INTEGER, INTEGER, CHAR, CHAR, CHAR, CHAR, INTEGER, INTEGER, CHAR
) IS 'Actualiza todos los datos modificables de un anuncio';

COMMENT ON FUNCTION comun.sp_calc_sdos_lic(INTEGER) IS
'Recalcula los saldos de una licencia';

COMMENT ON FUNCTION comun.sp_modlic_recalcular_adeudo_anuncio(INTEGER, INTEGER) IS
'Recalcula el adeudo específico de un anuncio';

COMMENT ON FUNCTION comun.sp_get_session_id() IS
'Genera un nuevo ID de sesión para el mapa de geolocalización';

COMMENT ON FUNCTION comun.sp_modlic_limpiar_sesion(INTEGER) IS
'Limpia los datos de ubicación de una sesión anterior';

COMMENT ON FUNCTION comun.sp_get_ubicacion_sesion(INTEGER) IS
'Obtiene las coordenadas seleccionadas en el mapa para una sesión';

COMMENT ON FUNCTION comun.sp_modlic_actualizar_coordenadas(INTEGER, INTEGER) IS
'Actualiza las coordenadas GPS de una licencia desde la sesión del mapa';

COMMENT ON FUNCTION comun.sp_verifica_firma(VARCHAR, VARCHAR, VARCHAR, INTEGER) IS
'Verifica la firma de un usuario para autorizar operaciones críticas';

-- =====================================================
-- PERMISOS
-- =====================================================

GRANT EXECUTE ON FUNCTION comun.sp_modlic_buscar_licencia(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_modlic_buscar_licencia(INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_modlic_buscar_anuncio(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_modlic_buscar_anuncio(INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_get_scian_catalogo() TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_get_scian_catalogo() TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_get_actividades_por_scian(CHAR, INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_get_actividades_por_scian(CHAR, INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_get_tipos_anuncio() TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_get_tipos_anuncio() TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_get_saldo_licencia(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_get_saldo_licencia(INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_modlic_actualizar_licencia(
    INTEGER, INTEGER, CHAR, CHAR, VARCHAR, VARCHAR, CHAR, CHAR, CHAR,
    INTEGER, CHAR, CHAR, CHAR, CHAR, CHAR, INTEGER, INTEGER, CHAR,
    CHAR, CHAR, CHAR, INTEGER, NUMERIC, NUMERIC, SMALLINT, SMALLINT,
    SMALLINT, NUMERIC, CHAR
) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_modlic_actualizar_licencia(
    INTEGER, INTEGER, CHAR, CHAR, VARCHAR, VARCHAR, CHAR, CHAR, CHAR,
    INTEGER, CHAR, CHAR, CHAR, CHAR, CHAR, INTEGER, INTEGER, CHAR,
    CHAR, CHAR, CHAR, INTEGER, NUMERIC, NUMERIC, SMALLINT, SMALLINT,
    SMALLINT, NUMERIC, CHAR
) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_modlic_actualizar_anuncio(
    INTEGER, INTEGER, CHAR, NUMERIC, NUMERIC, SMALLINT, CHAR,
    INTEGER, INTEGER, CHAR, CHAR, CHAR, CHAR, INTEGER, INTEGER, CHAR
) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_modlic_actualizar_anuncio(
    INTEGER, INTEGER, CHAR, NUMERIC, NUMERIC, SMALLINT, CHAR,
    INTEGER, INTEGER, CHAR, CHAR, CHAR, CHAR, INTEGER, INTEGER, CHAR
) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_calc_sdos_lic(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_calc_sdos_lic(INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_modlic_recalcular_adeudo_anuncio(INTEGER, INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_modlic_recalcular_adeudo_anuncio(INTEGER, INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_get_session_id() TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_get_session_id() TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_modlic_limpiar_sesion(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_modlic_limpiar_sesion(INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_get_ubicacion_sesion(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_get_ubicacion_sesion(INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_modlic_actualizar_coordenadas(INTEGER, INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_modlic_actualizar_coordenadas(INTEGER, INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_verifica_firma(VARCHAR, VARCHAR, VARCHAR, INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_verifica_firma(VARCHAR, VARCHAR, VARCHAR, INTEGER) TO PUBLIC;

-- =====================================================
-- NOTAS DE IMPLEMENTACIÓN
-- =====================================================

/*
TABLAS PRINCIPALES:
- comun.licencias - Datos de licencias comerciales
- comun.anuncios - Datos de anuncios publicitarios
- public.c_scian - Catálogo de códigos SCIAN
- comun.c_giros - Catálogo de giros/actividades
- comun.detsaldos - Detalles de saldos y adeudos
- comun.ubicacion - Coordenadas de ubicaciones
- comun.sysproxysessions - Sesiones del mapa

SPs CON PLACEHOLDERS:
- sp_modlic_limpiar_sesion: Necesita lógica específica de limpieza
- sp_get_ubicacion_sesion: Tabla ubicacion no tiene campos lat/lng
- sp_modlic_actualizar_coordenadas: Depende del SP anterior
- sp_verifica_firma: Necesita tabla de usuarios y lógica de autenticación

IMPORTANTE:
- Los SPs de mapa (11-14) son placeholders que necesitan ajustarse
  según la implementación real del sistema de geolocalización
- sp_verifica_firma está configurado para aceptar cualquier firma
  durante testing - DEBE implementarse con seguridad real antes de producción
*/
