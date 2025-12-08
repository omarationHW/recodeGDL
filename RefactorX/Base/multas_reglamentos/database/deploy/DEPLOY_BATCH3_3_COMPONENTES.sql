-- ============================================
-- DEPLOY BATCH 3 - MULTAS Y REGLAMENTOS
-- 3 Componentes: DescDerechosMerc, DrecgoTrans, DrecgoFosa
-- Fecha: 2025-11-24
-- ============================================

-- ============================================
-- COMPONENTE 1: DescDerechosMerc
-- Descuentos en rentas de mercados
-- ============================================

-- SP: Obtener recaudadoras
CREATE OR REPLACE FUNCTION descderechosmerc_sp_get_recaudadoras()
RETURNS TABLE(
    recaud INTEGER,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.recaud, r.descripcion
    FROM c_recaudadora r
    WHERE COALESCE(r.status, 'A') = 'A'
    ORDER BY r.recaud;
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener mercados por recaudadora
CREATE OR REPLACE FUNCTION descderechosmerc_sp_get_mercados(p_recaud INTEGER)
RETURNS TABLE(
    cvemercado INTEGER,
    nombre TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.cvemercado, m.nombre
    FROM mercados m
    WHERE m.recaud = p_recaud
    ORDER BY m.nombre;
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener secciones por mercado
CREATE OR REPLACE FUNCTION descderechosmerc_sp_get_secciones(p_cvemercado INTEGER)
RETURNS TABLE(
    cveseccion INTEGER,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.cveseccion, s.descripcion
    FROM secciones_mercado s
    WHERE s.cvemercado = p_cvemercado
    ORDER BY s.descripcion;
END;
$$ LANGUAGE plpgsql;

-- SP: Buscar locales de mercado
CREATE OR REPLACE FUNCTION descderechosmerc_sp_buscar_locales(
    p_recaud INTEGER,
    p_cvemercado INTEGER DEFAULT NULL,
    p_cveseccion INTEGER DEFAULT NULL
)
RETURNS TABLE(
    folio INTEGER,
    local_num TEXT,
    titular TEXT,
    mercado TEXT,
    seccion TEXT,
    importe NUMERIC,
    recargos NUMERIC,
    total NUMERIC,
    estado TEXT,
    id_descto INTEGER,
    porcentaje NUMERIC,
    observaciones TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.folio,
        l.local_num,
        l.titular,
        m.nombre AS mercado,
        s.descripcion AS seccion,
        l.importe,
        l.recargos,
        COALESCE(l.importe, 0) + COALESCE(l.recargos, 0) AS total,
        COALESCE(d.estado, 'V') AS estado,
        d.id_descto,
        d.porcentaje,
        d.observaciones
    FROM locales_mercado l
    JOIN mercados m ON m.cvemercado = l.cvemercado
    LEFT JOIN secciones_mercado s ON s.cveseccion = l.cveseccion AND s.cvemercado = l.cvemercado
    LEFT JOIN descrecmerc d ON d.folio = l.folio AND d.estado = 'V'
    WHERE l.recaud = p_recaud
      AND (p_cvemercado IS NULL OR l.cvemercado = p_cvemercado)
      AND (p_cveseccion IS NULL OR l.cveseccion = p_cveseccion)
      AND l.recargos > 0
      AND (l.cvepago = 0 OR l.cvepago IS NULL)
    ORDER BY l.folio;
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener autorizadores mercado
CREATE OR REPLACE FUNCTION descderechosmerc_sp_get_autorizadores()
RETURNS TABLE(
    cveautoriza INTEGER,
    descripcion TEXT,
    nombre TEXT,
    porcentajetope INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cveautoriza, a.descripcion, a.nombre, a.porcentajetope
    FROM c_autdescrec a
    WHERE a.vigencia = 'V'
    ORDER BY a.cveautoriza DESC;
END;
$$ LANGUAGE plpgsql;

-- SP: Alta descuento mercado
CREATE OR REPLACE FUNCTION descderechosmerc_sp_alta_descuento(
    p_folio INTEGER,
    p_porcentaje NUMERIC,
    p_observaciones TEXT,
    p_autoriza INTEGER,
    p_user TEXT
) RETURNS JSON AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO descrecmerc (
        folio, porcentaje, fecalta, captalta,
        estado, autoriza, observaciones
    ) VALUES (
        p_folio, p_porcentaje, CURRENT_DATE, p_user,
        'V', p_autoriza, p_observaciones
    ) RETURNING id_descto INTO v_id;

    RETURN json_build_object('ok', true, 'id_descto', v_id);
END;
$$ LANGUAGE plpgsql;

-- SP: Cancelar descuento mercado
CREATE OR REPLACE FUNCTION descderechosmerc_sp_cancelar_descuento(
    p_folio INTEGER,
    p_id_descto INTEGER,
    p_user TEXT
) RETURNS JSON AS $$
BEGIN
    UPDATE descrecmerc
    SET estado = 'C',
        fecbaja = CURRENT_DATE,
        captbaja = p_user
    WHERE folio = p_folio AND id_descto = p_id_descto AND estado = 'V';

    RETURN json_build_object('ok', true, 'mensaje', 'Descuento cancelado');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMPONENTE 2: DrecgoTrans
-- Descuentos en recargos de transmisiones
-- (SPs ya creados en DrecgoTrans_all_procedures.sql)
-- Solo agregamos si no existen
-- ============================================

-- SP: Busca multa/transmision
CREATE OR REPLACE FUNCTION busca_multa_trans(p_folio INTEGER, p_tipo TEXT)
RETURNS TABLE(
    folio INTEGER,
    baseimpuesto NUMERIC,
    recargos NUMERIC,
    multas NUMERIC,
    total NUMERIC,
    estado TEXT,
    id_descto INTEGER,
    porcentaje NUMERIC,
    observaciones TEXT
) AS $$
BEGIN
    IF p_tipo = 'completa' THEN
        RETURN QUERY
        SELECT i.folio, i.baseimpuesto, i.recargos, i.multas, i.total,
            COALESCE(dt.estado, 'V') AS estado,
            dt.id_descto, dt.porcentaje, dt.observaciones
        FROM impuestoTransp i
        LEFT JOIN descrectrans dt ON dt.folio = i.folio AND dt.estado = 'V'
        WHERE i.folio = p_folio AND i.recargos > 0 AND (i.cvepago = 0 OR i.cvepago IS NULL);
    ELSE
        RETURN QUERY
        SELECT i.foliot AS folio, i.baseimpuesto, i.recargos, i.multas, i.total,
            COALESCE(dt.estado, 'V') AS estado,
            dt.id_descto, dt.porcentaje, dt.observaciones
        FROM diferencias_glosa i
        LEFT JOIN descrectrans dt ON dt.folio = i.foliot AND dt.estado = 'V'
        WHERE i.foliot = p_folio AND i.recargos > 0 AND (i.cvepago = 0 OR i.cvepago IS NULL);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- SP: Busca diferencia transmision
CREATE OR REPLACE FUNCTION busca_diferencia_trans(p_folio INTEGER)
RETURNS TABLE(
    folio INTEGER,
    baseimpuesto NUMERIC,
    recargos NUMERIC,
    multas NUMERIC,
    total NUMERIC,
    estado TEXT,
    id_descto INTEGER,
    porcentaje NUMERIC,
    observaciones TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT i.foliot, i.baseimpuesto, i.recargos, i.multas, i.total,
        COALESCE(dt.estado, 'V') AS estado,
        dt.id_descto, dt.porcentaje, dt.observaciones
    FROM diferencias_glosa i
    LEFT JOIN descrectrans dt ON dt.folio = i.foliot AND dt.estado = 'V'
    WHERE i.foliot = p_folio AND i.recargos > 0 AND (i.cvepago = 0 OR i.cvepago IS NULL);
END;
$$ LANGUAGE plpgsql;

-- SP: Alta descuento transmision
CREATE OR REPLACE FUNCTION alta_descuento_trans(
    p_folio INTEGER,
    p_porcentaje NUMERIC,
    p_observaciones TEXT,
    p_autoriza INTEGER,
    p_user TEXT
) RETURNS JSON AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO descrectrans (
        folio, porcentaje, fecalta, captalta, estado, autoriza, observaciones
    ) VALUES (
        p_folio, p_porcentaje, CURRENT_DATE, p_user, 'V', p_autoriza, p_observaciones
    ) RETURNING id_descto INTO v_id;

    RETURN json_build_object('ok', true, 'id_descto', v_id);
END;
$$ LANGUAGE plpgsql;

-- SP: Cancelar descuento transmision
CREATE OR REPLACE FUNCTION cancelar_descuento_trans(
    p_folio INTEGER,
    p_id_descto INTEGER,
    p_user TEXT
) RETURNS JSON AS $$
BEGIN
    UPDATE descrectrans
    SET estado = 'C', fecbaja = CURRENT_DATE, captbaja = p_user
    WHERE folio = p_folio AND id_descto = p_id_descto AND estado = 'V';

    RETURN json_build_object('ok', true, 'mensaje', 'Descuento cancelado');
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener autorizadores transmision
CREATE OR REPLACE FUNCTION get_autorizadores_trans(p_usuario TEXT)
RETURNS TABLE(
    cveautoriza INTEGER,
    descripcion TEXT,
    nombre TEXT,
    porcentajetope INTEGER
) AS $$
BEGIN
    -- Verificar permisos especiales
    IF EXISTS (
        SELECT 1 FROM autoriza a, usuarios b, deptos d
        WHERE a.usuario = p_usuario
        AND a.num_tag IN (1319,1320)
        AND b.usuario = a.usuario
        AND d.cvedepto = b.cvedepto
    ) THEN
        RETURN QUERY
        SELECT a.cveautoriza, a.descripcion, a.nombre, a.porcentajetope
        FROM c_autdescrec a
        WHERE a.vigencia = 'V'
        ORDER BY a.cveautoriza DESC;
    ELSE
        RETURN QUERY
        SELECT a.cveautoriza, a.descripcion, a.nombre, a.porcentajetope
        FROM c_autdescrec a
        WHERE a.funcionario = 'N' AND a.vigencia = 'V';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMPONENTE 3: DrecgoFosa
-- Descuentos en recargos de fosas (panteon)
-- ============================================

-- SP: Buscar fosas con recargos
CREATE OR REPLACE FUNCTION drecgofosa_sp_buscar(
    p_folio INTEGER,
    p_panteon TEXT DEFAULT NULL
)
RETURNS TABLE(
    folio INTEGER,
    panteon TEXT,
    titular TEXT,
    importe NUMERIC,
    recargos NUMERIC,
    total NUMERIC,
    estado TEXT,
    id_descto INTEGER,
    porcentaje NUMERIC,
    observaciones TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.folio,
        f.panteon,
        f.titular,
        f.importe,
        f.recargos,
        COALESCE(f.importe, 0) + COALESCE(f.recargos, 0) AS total,
        COALESCE(d.estado, 'V') AS estado,
        d.id_descto,
        d.porcentaje,
        d.observaciones
    FROM fosas f
    LEFT JOIN descrecfosa d ON d.folio = f.folio AND d.estado = 'V'
    WHERE f.folio = p_folio
      AND (p_panteon IS NULL OR f.panteon = p_panteon)
      AND f.recargos > 0
      AND (f.cvepago = 0 OR f.cvepago IS NULL);
END;
$$ LANGUAGE plpgsql;

-- SP: Obtener funcionarios autorizadores fosa
CREATE OR REPLACE FUNCTION drecgofosa_sp_get_funcionarios(p_usuario TEXT)
RETURNS TABLE(
    cveautoriza INTEGER,
    descripcion TEXT,
    nombre TEXT,
    porcentajetope INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cveautoriza, a.descripcion, a.nombre, a.porcentajetope
    FROM c_autdescrec a
    WHERE a.vigencia = 'V'
    ORDER BY a.cveautoriza DESC;
END;
$$ LANGUAGE plpgsql;

-- SP: Alta descuento fosa
CREATE OR REPLACE FUNCTION drecgofosa_sp_alta_descuento(
    p_folio INTEGER,
    p_porcentaje NUMERIC,
    p_observaciones TEXT,
    p_autoriza INTEGER,
    p_user TEXT
) RETURNS JSON AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO descrecfosa (
        folio, porcentaje, fecalta, captalta, estado, autoriza, observaciones
    ) VALUES (
        p_folio, p_porcentaje, CURRENT_DATE, p_user, 'V', p_autoriza, p_observaciones
    ) RETURNING id_descto INTO v_id;

    RETURN json_build_object('ok', true, 'id_descto', v_id);
END;
$$ LANGUAGE plpgsql;

-- SP: Cancelar descuento fosa
CREATE OR REPLACE FUNCTION drecgofosa_sp_cancelar_descuento(
    p_folio INTEGER,
    p_id_descto INTEGER,
    p_user TEXT
) RETURNS JSON AS $$
BEGIN
    UPDATE descrecfosa
    SET estado = 'C', fecbaja = CURRENT_DATE, captbaja = p_user
    WHERE folio = p_folio AND id_descto = p_id_descto AND estado = 'V';

    RETURN json_build_object('ok', true, 'mensaje', 'Descuento cancelado');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DEPLOY BATCH 3
-- ============================================

-- Verificacion rapida
DO $$
BEGIN
    RAISE NOTICE '=== DEPLOY BATCH 3 COMPLETADO ===';
    RAISE NOTICE 'Componentes desplegados:';
    RAISE NOTICE '1. DescDerechosMerc - 7 SPs';
    RAISE NOTICE '2. DrecgoTrans - 5 SPs';
    RAISE NOTICE '3. DrecgoFosa - 4 SPs';
    RAISE NOTICE 'Total: 16 SPs';
END $$;
