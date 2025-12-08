-- =====================================================
-- DEPLOY BATCH 7 - MULTAS Y REGLAMENTOS
-- Componentes: canc, centrosfrm, codificafrm, conscentrosfrm, consescrit400
-- Fecha: 2025-11-24
-- =====================================================

-- =====================================================
-- 1. CANC - Cancelación/Reasignación de Folios
-- =====================================================

-- SP: Buscar folios en rango
CREATE OR REPLACE FUNCTION canc_sp_buscar_folios(
    p_tipo VARCHAR(50),
    p_recaud INTEGER,
    p_folio_ini INTEGER,
    p_folio_fin INTEGER
)
RETURNS TABLE (
    folioreq INTEGER,
    cvecuenta VARCHAR(20),
    cveejecut VARCHAR(10),
    vigencia DATE,
    estado VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.folioreq,
        r.cvecuenta,
        r.cveejecut,
        r.vigencia,
        CASE
            WHEN r.cancelado = true THEN 'Cancelado'::VARCHAR(20)
            WHEN r.pagado = true THEN 'Pagado'::VARCHAR(20)
            ELSE 'Activo'::VARCHAR(20)
        END as estado
    FROM requerimientos r
    WHERE r.tipo = p_tipo
      AND r.recaudadora = p_recaud
      AND r.folioreq BETWEEN p_folio_ini AND p_folio_fin
    ORDER BY r.folioreq;
END;
$$ LANGUAGE plpgsql;

-- SP: Cancelar folios
CREATE OR REPLACE FUNCTION canc_sp_cancelar_folios(
    p_tipo VARCHAR(50),
    p_folios TEXT,
    p_recaud INTEGER,
    p_usuario VARCHAR(50),
    p_motivo TEXT
)
RETURNS JSON AS $$
DECLARE
    v_folio INTEGER;
    v_count INTEGER := 0;
BEGIN
    FOR v_folio IN SELECT unnest(string_to_array(p_folios, ','))::INTEGER
    LOOP
        UPDATE requerimientos
        SET cancelado = true,
            fecha_cancelacion = CURRENT_DATE,
            usuario_cancelacion = p_usuario,
            motivo_cancelacion = p_motivo
        WHERE tipo = p_tipo
          AND recaudadora = p_recaud
          AND folioreq = v_folio;

        v_count := v_count + 1;
    END LOOP;

    RETURN json_build_object('ok', true, 'cancelados', v_count);
END;
$$ LANGUAGE plpgsql;

-- SP: Reasignar folios
CREATE OR REPLACE FUNCTION canc_sp_reasignar_folios(
    p_tipo VARCHAR(50),
    p_folios TEXT,
    p_recaud INTEGER,
    p_ejecutor_actual INTEGER,
    p_ejecutor_nuevo INTEGER,
    p_fecha DATE
)
RETURNS JSON AS $$
DECLARE
    v_folio INTEGER;
    v_count INTEGER := 0;
BEGIN
    FOR v_folio IN SELECT unnest(string_to_array(p_folios, ','))::INTEGER
    LOOP
        UPDATE requerimientos
        SET cveejecut = p_ejecutor_nuevo::VARCHAR,
            fecha_asignacion = p_fecha
        WHERE tipo = p_tipo
          AND recaudadora = p_recaud
          AND folioreq = v_folio
          AND (p_ejecutor_actual = 0 OR cveejecut::INTEGER = p_ejecutor_actual);

        v_count := v_count + 1;
    END LOOP;

    RETURN json_build_object('ok', true, 'reasignados', v_count);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. CENTROSFRM - Catálogo de Centros
-- =====================================================

-- SP: Listar centros
CREATE OR REPLACE FUNCTION centrosfrm_sp_list(
    p_q VARCHAR(100),
    p_estado VARCHAR(20)
)
RETURNS TABLE (
    id_centro INTEGER,
    clave VARCHAR(10),
    nombre VARCHAR(100),
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    activo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_centro,
        c.clave,
        c.nombre,
        c.direccion,
        c.telefono,
        c.activo
    FROM centros_recaudacion c
    WHERE (p_q = '' OR c.nombre ILIKE '%' || p_q || '%' OR c.clave ILIKE '%' || p_q || '%')
      AND (p_estado = '' OR
           (p_estado = 'activo' AND c.activo = true) OR
           (p_estado = 'inactivo' AND c.activo = false))
    ORDER BY c.nombre;
END;
$$ LANGUAGE plpgsql;

-- SP: Crear centro
CREATE OR REPLACE FUNCTION centrosfrm_sp_create(
    p_id_centro INTEGER,
    p_clave VARCHAR(10),
    p_nombre VARCHAR(100),
    p_direccion VARCHAR(200),
    p_telefono VARCHAR(20),
    p_activo BOOLEAN
)
RETURNS JSON AS $$
BEGIN
    INSERT INTO centros_recaudacion (clave, nombre, direccion, telefono, activo)
    VALUES (p_clave, p_nombre, p_direccion, p_telefono, p_activo);

    RETURN json_build_object('ok', true);
END;
$$ LANGUAGE plpgsql;

-- SP: Actualizar centro
CREATE OR REPLACE FUNCTION centrosfrm_sp_update(
    p_id_centro INTEGER,
    p_clave VARCHAR(10),
    p_nombre VARCHAR(100),
    p_direccion VARCHAR(200),
    p_telefono VARCHAR(20),
    p_activo BOOLEAN
)
RETURNS JSON AS $$
BEGIN
    UPDATE centros_recaudacion
    SET nombre = p_nombre,
        direccion = p_direccion,
        telefono = p_telefono,
        activo = p_activo
    WHERE id_centro = p_id_centro;

    RETURN json_build_object('ok', true);
END;
$$ LANGUAGE plpgsql;

-- SP: Cambiar estado centro
CREATE OR REPLACE FUNCTION centrosfrm_sp_cambiar_estado(
    p_id_centro INTEGER,
    p_activo BOOLEAN
)
RETURNS JSON AS $$
BEGIN
    UPDATE centros_recaudacion
    SET activo = p_activo
    WHERE id_centro = p_id_centro;

    RETURN json_build_object('ok', true);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. CODIFICAFRM - Codificación
-- =====================================================

-- SP: Procesar codificación/decodificación
CREATE OR REPLACE FUNCTION codificafrm_sp_procesar(
    p_tipo VARCHAR(20),
    p_texto VARCHAR(100),
    p_accion VARCHAR(20)
)
RETURNS JSON AS $$
DECLARE
    v_resultado VARCHAR(100);
    v_verificador INTEGER;
BEGIN
    IF p_accion = 'codificar' THEN
        -- Generar código según tipo
        v_resultado := UPPER(REPLACE(p_texto, ' ', ''));
        v_verificador := MOD(LENGTH(p_texto), 10);

        RETURN json_build_object(
            'codigo', v_resultado || v_verificador::TEXT,
            'verificador', v_verificador,
            'formato', p_tipo,
            'valido', true
        );
    ELSE
        -- Decodificar
        v_resultado := p_texto;

        RETURN json_build_object(
            'decodificado', v_resultado,
            'formato', p_tipo,
            'valido', true
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. CONSCENTROSFRM - Consulta de Centros
-- =====================================================

-- SP: Obtener dependencias
CREATE OR REPLACE FUNCTION conscentrosfrm_sp_get_dependencias()
RETURNS TABLE (
    id INTEGER,
    abrevia VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id_dependencia as id, d.abrevia
    FROM dependencias d
    WHERE d.activo = true
    ORDER BY d.abrevia;
END;
$$ LANGUAGE plpgsql;

-- SP: Listar multas en centros
CREATE OR REPLACE FUNCTION conscentrosfrm_sp_list(
    p_fecha VARCHAR(20),
    p_id_dependencia INTEGER,
    p_axo_acta INTEGER,
    p_num_acta INTEGER
)
RETURNS TABLE (
    fecha DATE,
    abrevia VARCHAR(50),
    axo_acta INTEGER,
    num_acta INTEGER,
    num_recibo VARCHAR(20),
    importe_pago NUMERIC(12,2),
    contribuyente VARCHAR(200),
    domicilio VARCHAR(300)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.fecha_pago as fecha,
        d.abrevia,
        m.axo_acta,
        m.num_acta,
        m.num_recibo,
        m.importe as importe_pago,
        m.contribuyente,
        m.domicilio
    FROM multas_centros m
    LEFT JOIN dependencias d ON m.id_dependencia = d.id_dependencia
    WHERE (p_fecha = '' OR m.fecha_pago = p_fecha::DATE)
      AND (p_id_dependencia = 0 OR m.id_dependencia = p_id_dependencia)
      AND (p_axo_acta = 0 OR m.axo_acta = p_axo_acta)
      AND (p_num_acta = 0 OR m.num_acta = p_num_acta)
    ORDER BY m.fecha_pago DESC, m.num_recibo;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. CONSESCRIT400 - Consulta de Escrituras AS400
-- =====================================================

-- SP: Buscar escrituras
CREATE OR REPLACE FUNCTION consescrit400_sp_search(
    p_mpio INTEGER,
    p_notario INTEGER,
    p_escritura INTEGER,
    p_folio INTEGER,
    p_fecha INTEGER
)
RETURNS TABLE (
    escritura INTEGER,
    notario INTEGER,
    mpio INTEGER,
    folio INTEGER,
    axofolio INTEGER,
    cuenta VARCHAR(20),
    recaud INTEGER,
    nocomp INTEGER,
    axocomp INTEGER,
    ccta VARCHAR(20),
    crec INTEGER,
    clave VARCHAR(20),
    capturista VARCHAR(50),
    enviado BOOLEAN,
    regresado BOOLEAN,
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.num_escritura as escritura,
        e.num_notario as notario,
        e.cve_mpio as mpio,
        e.num_folio as folio,
        e.axo_folio as axofolio,
        e.cve_cuenta as cuenta,
        e.cve_recaud as recaud,
        e.num_comprobante as nocomp,
        e.axo_comprobante as axocomp,
        e.cve_cuenta_catastral as ccta,
        e.cve_recaudadora as crec,
        e.clave_catastral as clave,
        e.usuario_captura as capturista,
        e.enviado,
        e.regresado,
        e.fecha_captura as fecha
    FROM escrituras_as400 e
    WHERE (p_mpio = 0 OR e.cve_mpio = p_mpio)
      AND (p_notario = 0 OR e.num_notario = p_notario)
      AND (p_escritura = 0 OR e.num_escritura = p_escritura)
      AND (p_folio = 0 OR e.num_folio = p_folio)
      AND (p_fecha = 0 OR e.axo_folio = p_fecha)
    ORDER BY e.fecha_captura DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FIN BATCH 7
-- =====================================================
