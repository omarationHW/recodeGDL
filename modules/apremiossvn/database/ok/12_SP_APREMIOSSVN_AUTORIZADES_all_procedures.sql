-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Autorización de Descuentos
-- Archivo: 12_SP_APREMIOSSVN_AUTORIZADES_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 7
-- ============================================

-- SP 1/7: SP_APREMIOSSVN_AUTORIZADES_SEARCH
-- Tipo: CRUD
-- Descripción: Busca folio de requerimiento y devuelve datos, incluyendo descuentos autorizados vigentes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_AUTORIZADES_SEARCH(
    p_folio INTEGER,
    p_id_rec INTEGER,
    p_id_modulo INTEGER,
    p_usuario_id INTEGER
) RETURNS TABLE (
    id_control INTEGER,
    zona INTEGER,
    modulo INTEGER,
    control_otr INTEGER,
    folio INTEGER,
    diligencia TEXT,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio INTEGER,
    fecha_emision DATE,
    clave_practicado TEXT,
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor INTEGER,
    clave_secuestro INTEGER,
    clave_remate TEXT,
    fecha_remate DATE,
    porcentaje_multa INTEGER,
    observaciones TEXT,
    fecha_pago DATE,
    recaudadora INTEGER,
    caja TEXT,
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia TEXT,
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov TEXT,
    hora_practicado TIMESTAMP,
    datos TEXT,
    autorizados JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_control, a.zona, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos, a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor, a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, a.importe_pago, a.vigencia, a.fecha_actualiz, a.usuario, a.clave_mov, a.hora_practicado,
        -- datos: concatenación según modulo
        CASE 
            WHEN a.modulo = 16 THEN 'No. Contrato ' || coalesce(ta_16_tipo_public.tipo_aseo,'') || '-' || coalesce(ta_16_contratos.num_contrato::text,'')
            WHEN a.modulo = 11 THEN 'Mercado No. ' || coalesce(ta_11_locales.num_mercado::text,'') || ' Categoria ' || coalesce(ta_11_locales.categoria::text,'') || ' Secc. ' || coalesce(ta_11_locales.seccion,'') || ' Local ' || coalesce(ta_11_locales.local::text,'') || '-' || coalesce(ta_11_locales.letra_local,'') || '-' || coalesce(ta_11_locales.bloque,'')
            WHEN a.modulo = 24 THEN 'Estacionamiento Publico No. ' || coalesce(pubmain.numesta::text,'')
            WHEN a.modulo = 28 THEN 'Estacionamiento Exclusivo No. ' || coalesce(ex_contrato.no_exclusivo::text,'')
            WHEN a.modulo = 14 THEN 'Placa No. ' || coalesce(ta_padron.placa,'')
            WHEN a.modulo = 13 THEN 'Folio: ' || coalesce(ta_13_datosrcm.control_rcm::text,'') || ' Cementerio:' || coalesce(ta_13_datosrcm.cementerio,'') || ' C-' || coalesce(ta_13_datosrcm.clase::text,'') || ' ' || coalesce(ta_13_datosrcm.clase_alfa,'') || ' S-' || coalesce(ta_13_datosrcm.seccion::text,'') || ' ' || coalesce(ta_13_datosrcm.seccion_alfa,'') || ' L-' || coalesce(ta_13_datosrcm.linea::text,'') || ' ' || coalesce(ta_13_datosrcm.linea_alfa,'') || ' F-' || coalesce(ta_13_datosrcm.fosa::text,'') || ' ' || coalesce(ta_13_datosrcm.fosa_alfa,'')
            ELSE NULL
        END as datos,
        (
            SELECT jsonb_agg(row_to_json(aut)) FROM (
                SELECT aut.*, q.quien, q.porcentajetope FROM public.ta_15_autorizados aut
                LEFT JOIN public.ta_15_quienautor q ON q.cveaut = aut.cveaut
                WHERE aut.control = a.id_control AND aut.estado <> 3
            ) aut
        ) as autorizados
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_16_contratos ON a.modulo = 16 AND a.control_otr = ta_16_contratos.control_contrato
    LEFT JOIN public.ta_16_tipo_aseo ON ta_16_contratos.ctrol_aseo = ta_16_tipo_public.ctrol_aseo
    LEFT JOIN public.ta_11_locales ON a.modulo = 11 AND a.control_otr = ta_11_locales.id_local
    LEFT JOIN public.pubmain ON a.modulo = 24 AND a.control_otr = pubmain.id
    LEFT JOIN public.ex_contrato ON a.modulo = 28 AND a.control_otr = ex_contrato.id
    LEFT JOIN public.ta_padron ON a.modulo = 14 AND a.control_otr = ta_padron.id
    LEFT JOIN public.ta_13_datosrcm ON a.modulo = 13 AND a.control_otr = ta_13_datosrcm.control_rcm
    WHERE a.zona = p_id_rec AND a.modulo = p_id_modulo AND a.folio = p_folio AND a.vigencia = '1' AND a.clave_practicado = 'P';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: SP_APREMIOSSVN_AUTORIZADES_ALTA
-- Tipo: CRUD
-- Descripción: Da de alta un descuento autorizado para un folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_AUTORIZADES_ALTA(
    p_id_control INTEGER,
    p_id_rec INTEGER,
    p_cveaut INTEGER,
    p_porcentaje INTEGER,
    p_fecha_alta DATE,
    p_usuario_id INTEGER
) RETURNS TABLE (ok BOOLEAN, msg TEXT) AS $$
DECLARE
    v_estado SMALLINT := 1;
BEGIN
    INSERT INTO public.ta_15_autorizados (control, id_rec, cveaut, porcentaje, fecha_alta, id_usuarioa, fecha_baja, estado, id_usuario, fecha_actual)
    VALUES (p_id_control, p_id_rec, p_cveaut, p_porcentaje, p_fecha_alta, p_usuario_id, NULL, v_estado, p_usuario_id, NOW());
    
    UPDATE public.ta_15_apremios SET porcentaje_multa = p_porcentaje WHERE id_control = p_id_control;
    RETURN QUERY SELECT TRUE, 'Alta exitosa';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: SP_APREMIOSSVN_AUTORIZADES_MODIFICAR
-- Tipo: CRUD
-- Descripción: Modifica un descuento autorizado existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_AUTORIZADES_MODIFICAR(
    p_id_control INTEGER,
    p_id_rec INTEGER,
    p_cveaut INTEGER,
    p_porcentaje INTEGER,
    p_fecha_alta DATE,
    p_usuario_id INTEGER
) RETURNS TABLE (ok BOOLEAN, msg TEXT) AS $$
BEGIN
    UPDATE public.ta_15_autorizados
    SET cveaut = p_cveaut, porcentaje = p_porcentaje, fecha_alta = p_fecha_alta, id_usuario = p_usuario_id, fecha_actual = NOW()
    WHERE control = p_id_control AND estado = 1;
    
    UPDATE public.ta_15_apremios SET porcentaje_multa = p_porcentaje WHERE id_control = p_id_control;
    RETURN QUERY SELECT TRUE, 'Modificación exitosa';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: SP_APREMIOSSVN_AUTORIZADES_BAJA
-- Tipo: CRUD
-- Descripción: Da de baja (cancela) un descuento autorizado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_AUTORIZADES_BAJA(
    p_id_control INTEGER,
    p_fecha_baja DATE,
    p_usuario_id INTEGER,
    p_motivo TEXT DEFAULT NULL
) RETURNS TABLE (ok BOOLEAN, msg TEXT) AS $$
BEGIN
    UPDATE public.ta_15_autorizados
    SET fecha_baja = p_fecha_baja, id_usuario = p_usuario_id, estado = 2, fecha_actual = NOW(), observaciones = p_motivo
    WHERE control = p_id_control AND estado = 1;
    
    UPDATE public.ta_15_apremios SET porcentaje_multa = 100 WHERE id_control = p_id_control AND porcentaje_multa < 100;
    RETURN QUERY SELECT TRUE, 'Baja exitosa';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: SP_APREMIOSSVN_AUTORIZADES_CATALOGO_QUIEN
-- Tipo: Catalog
-- Descripción: Devuelve catálogo de personas autorizadas para descuentos según permisos del usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_AUTORIZADES_CATALOGO_QUIEN(
    p_usuario_id INTEGER
) RETURNS TABLE (
    cveaut INTEGER,
    quien TEXT,
    nombre TEXT,
    porcentajetope INTEGER
) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.ta_autoriza WHERE id_modulo = 15 AND id_usuario = p_usuario_id AND tag = 26) THEN
        RETURN QUERY SELECT q.cveaut, q.quien, q.nombre, q.porcentajetope FROM public.ta_15_quienautor q WHERE q.vigencia = 'V' ORDER BY q.cveaut DESC;
    ELSE
        RETURN QUERY SELECT q.cveaut, q.quien, q.nombre, q.porcentajetope FROM public.ta_15_quienautor q WHERE q.funcionario = 'N' AND q.vigencia = 'V';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: SP_APREMIOSSVN_AUTORIZADES_CATALOGO_APLICACION
-- Tipo: Catalog
-- Descripción: Devuelve catálogo de aplicaciones (modulos) válidos para descuentos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_AUTORIZADES_CATALOGO_APLICACION() RETURNS TABLE (
    id_modulo INTEGER,
    descripcion TEXT,
    aplicacion TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT m.id_modulo, m.descripcion, m.aplicacion FROM public.ta_12_modulos m WHERE m.id_modulo IN (11,13,14,16,24,28);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: SP_APREMIOSSVN_AUTORIZADES_CATALOGO_OFICINA
-- Tipo: Catalog
-- Descripción: Devuelve catálogo de oficinas (recaudadoras).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_AUTORIZADES_CATALOGO_OFICINA() RETURNS TABLE (
    id_rec INTEGER,
    nombre TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT a.id_rec, b.zona as nombre FROM public.ta_12_recaudadoras a JOIN public.ta_12_zonas b ON a.id_zona = b.id_zona;
END;
$$ LANGUAGE plpgsql;

-- ============================================