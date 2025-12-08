-- ============================================
-- CONFIGURACION BASE DE DATOS: estacionamiento_publico
-- ESQUEMA: public
-- ============================================
-- \c estacionamiento_publico;
-- SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: REPORTES_FOLIOS (SolicRepFoliosPublicos.vue)
-- Archivo: 20_SP_ESTACIONAMIENTOS_REPORTES_FOLIOS_EXACTO_all_procedures.sql
-- Actualizado: 2025-12-07
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_solicrep_folios
-- Tipo: Report
-- Descripcion: Obtiene el reporte de folios segun clave de infraccion, tipo de solicitud y rango de fechas.
-- Opciones: 1=adeudos, 2=pagados, 3=cancelados, 4=condonados, 5=cancelados y condonados
-- Traducido de: cons14_solicrep (Informix)
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_solicrep_folios(integer, integer, date, date);

CREATE OR REPLACE FUNCTION sp_solicrep_folios(
    p_cveinf INTEGER,
    p_opc INTEGER,
    p_fec_ini DATE,
    p_fec_fin DATE
)
RETURNS TABLE (
    descrip VARCHAR(80),
    fecha_movto DATE,
    axo INTEGER,
    folio INTEGER,
    fecha_folio DATE,
    placa VARCHAR(7),
    fecha_captura DATE,
    porc NUMERIC(5,2),
    tarifa NUMERIC(12,2),
    dscto NUMERIC(12,2),
    pago NUMERIC(12,2),
    infraccion INTEGER
) AS $$
DECLARE
    v_descrip_movto VARCHAR(40);
    v_descrip_submovto VARCHAR(40);
    v_descripcion VARCHAR(80);
    rec RECORD;
BEGIN
    -- Opcion 1: Folios Adeudo
    IF p_opc = 1 THEN
        FOR rec IN
            SELECT
                a.axo,
                a.folio,
                a.fecha_folio,
                a.placa,
                a.fec_cap,
                a.infraccion,
                COALESCE(b.tarifa, 0) + COALESCE(b.costo_fijo01, 0) AS tarifa_calc
            FROM public.ta14_folios_adeudo a
            LEFT JOIN mercados.public.ta14_tarifas b ON b.num_clave = a.infraccion
                AND b.fecha_inicial = make_date(a.axo, 1, 1)
                AND b.fecha_fin = make_date(a.axo, 12, 31)
            WHERE (p_cveinf = 0 OR a.infraccion = p_cveinf)
                AND a.fecha_folio BETWEEN p_fec_ini AND p_fec_fin
            ORDER BY a.axo, a.folio
        LOOP
            RETURN QUERY SELECT
                NULL::VARCHAR(80),
                NULL::DATE,
                rec.axo,
                rec.folio,
                rec.fecha_folio,
                rec.placa::VARCHAR(7),
                rec.fec_cap,
                NULL::NUMERIC(5,2),
                rec.tarifa_calc::NUMERIC(12,2),
                NULL::NUMERIC(12,2),
                NULL::NUMERIC(12,2),
                rec.infraccion;
        END LOOP;

    -- Opcion 2: Folios Pagados
    ELSIF p_opc = 2 THEN
        FOR rec IN
            SELECT
                a.fecha_movto,
                a.axo,
                a.folio,
                a.fecha_folio,
                a.placa,
                a.fec_cap,
                a.infraccion,
                a.codigo_movto,
                a.sub_codigo,
                COALESCE(100 - COALESCE(c.porc_cobro, 100), 0) AS porc_dcto,
                COALESCE(b.tarifa, 0) + COALESCE(b.costo_fijo01, 0) AS tarifa_calc,
                COALESCE((COALESCE(b.tarifa, 0) + COALESCE(b.costo_fijo01, 0)) -
                    (((COALESCE(b.tarifa, 0) + COALESCE(b.costo_fijo01, 0)) * COALESCE(c.porc_cobro, 100)) / 100), 0) AS dscto_calc
            FROM public.ta14_folios_histo a
            LEFT JOIN mercados.public.ta14_tarifas b ON b.num_clave = a.infraccion
                AND b.fecha_inicial = make_date(a.axo, 1, 1)
                AND b.fecha_fin = make_date(a.axo, 12, 31)
            LEFT JOIN public.ta14_folios_free c ON c.axo = a.axo AND c.folio = a.folio AND c.clave = 'A'
            WHERE (p_cveinf = 0 OR a.infraccion = p_cveinf)
                AND a.fecha_movto BETWEEN p_fec_ini AND p_fec_fin
                AND a.codigo_movto IN (3,4,6,8,9,10,13,24)
            ORDER BY a.fecha_movto, a.placa, a.axo, a.folio
        LOOP
            -- Obtener descripcion del movimiento
            SELECT descripcion INTO v_descrip_movto
            FROM public.ta14_codigomovtos
            WHERE codigo_movto = rec.codigo_movto;

            IF rec.sub_codigo > 0 THEN
                SELECT descripcion INTO v_descrip_submovto
                FROM public.ta14_codigomovtos_sub
                WHERE codigo_movtos = rec.codigo_movto AND sub = rec.sub_codigo;

                IF v_descrip_submovto IS NOT NULL THEN
                    v_descripcion := TRIM(v_descrip_movto) || ' - ' || TRIM(v_descrip_submovto);
                ELSE
                    v_descripcion := TRIM(v_descrip_movto);
                END IF;
            ELSE
                v_descripcion := TRIM(v_descrip_movto);
            END IF;

            RETURN QUERY SELECT
                v_descripcion::VARCHAR(80),
                rec.fecha_movto,
                rec.axo,
                rec.folio,
                rec.fecha_folio,
                rec.placa::VARCHAR(7),
                rec.fec_cap,
                rec.porc_dcto::NUMERIC(5,2),
                rec.tarifa_calc::NUMERIC(12,2),
                rec.dscto_calc::NUMERIC(12,2),
                (rec.tarifa_calc - rec.dscto_calc)::NUMERIC(12,2),
                rec.infraccion;
        END LOOP;

    -- Opcion 3: Folios Cancelados
    ELSIF p_opc = 3 THEN
        FOR rec IN
            SELECT
                a.fecha_movto,
                a.axo,
                a.folio,
                a.fecha_folio,
                a.placa,
                a.fec_cap,
                a.infraccion,
                a.codigo_movto,
                a.sub_codigo,
                COALESCE(b.tarifa, 0) + COALESCE(b.costo_fijo01, 0) AS tarifa_calc
            FROM public.ta14_folios_histo a
            LEFT JOIN mercados.public.ta14_tarifas b ON b.num_clave = a.infraccion
                AND b.fecha_inicial = make_date(a.axo, 1, 1)
                AND b.fecha_fin = make_date(a.axo, 12, 31)
            WHERE (p_cveinf = 0 OR a.infraccion = p_cveinf)
                AND a.fecha_movto BETWEEN p_fec_ini AND p_fec_fin
                AND a.codigo_movto IN (1,11,22,23)
            ORDER BY a.fecha_movto, a.placa, a.axo, a.folio
        LOOP
            SELECT descripcion INTO v_descrip_movto
            FROM public.ta14_codigomovtos
            WHERE codigo_movto = rec.codigo_movto;

            IF rec.sub_codigo > 0 THEN
                SELECT descripcion INTO v_descrip_submovto
                FROM public.ta14_codigomovtos_sub
                WHERE codigo_movtos = rec.codigo_movto AND sub = rec.sub_codigo;

                IF v_descrip_submovto IS NOT NULL THEN
                    v_descripcion := TRIM(v_descrip_movto) || ' - ' || TRIM(v_descrip_submovto);
                ELSE
                    v_descripcion := TRIM(v_descrip_movto);
                END IF;
            ELSE
                v_descripcion := TRIM(v_descrip_movto);
            END IF;

            RETURN QUERY SELECT
                v_descripcion::VARCHAR(80),
                rec.fecha_movto,
                rec.axo,
                rec.folio,
                rec.fecha_folio,
                rec.placa::VARCHAR(7),
                rec.fec_cap,
                0::NUMERIC(5,2),
                rec.tarifa_calc::NUMERIC(12,2),
                0::NUMERIC(12,2),
                0::NUMERIC(12,2),
                rec.infraccion;
        END LOOP;

    -- Opcion 4: Folios Condonados
    ELSIF p_opc = 4 THEN
        FOR rec IN
            SELECT
                a.fecha_movto,
                a.axo,
                a.folio,
                a.fecha_folio,
                a.placa,
                a.fec_cap,
                a.infraccion,
                a.codigo_movto,
                a.sub_codigo,
                COALESCE(b.tarifa, 0) + COALESCE(b.costo_fijo01, 0) AS tarifa_calc
            FROM public.ta14_folios_histo a
            LEFT JOIN mercados.public.ta14_tarifas b ON b.num_clave = a.infraccion
                AND b.fecha_inicial = make_date(a.axo, 1, 1)
                AND b.fecha_fin = make_date(a.axo, 12, 31)
            WHERE (p_cveinf = 0 OR a.infraccion = p_cveinf)
                AND a.fecha_movto BETWEEN p_fec_ini AND p_fec_fin
                AND a.codigo_movto IN (2,15,16,17,18,19,20,21,25)
            ORDER BY a.fecha_movto, a.placa, a.axo, a.folio
        LOOP
            SELECT descripcion INTO v_descrip_movto
            FROM public.ta14_codigomovtos
            WHERE codigo_movto = rec.codigo_movto;

            IF rec.sub_codigo > 0 THEN
                SELECT descripcion INTO v_descrip_submovto
                FROM public.ta14_codigomovtos_sub
                WHERE codigo_movtos = rec.codigo_movto AND sub = rec.sub_codigo;

                IF v_descrip_submovto IS NOT NULL THEN
                    v_descripcion := TRIM(v_descrip_movto) || ' - ' || TRIM(v_descrip_submovto);
                ELSE
                    v_descripcion := TRIM(v_descrip_movto);
                END IF;
            ELSE
                v_descripcion := TRIM(v_descrip_movto);
            END IF;

            RETURN QUERY SELECT
                v_descripcion::VARCHAR(80),
                rec.fecha_movto,
                rec.axo,
                rec.folio,
                rec.fecha_folio,
                rec.placa::VARCHAR(7),
                rec.fec_cap,
                0::NUMERIC(5,2),
                rec.tarifa_calc::NUMERIC(12,2),
                0::NUMERIC(12,2),
                0::NUMERIC(12,2),
                rec.infraccion;
        END LOOP;

    -- Opcion 5: Folios Cancelados y Condonados
    ELSIF p_opc = 5 THEN
        FOR rec IN
            SELECT
                a.fecha_movto,
                a.axo,
                a.folio,
                a.fecha_folio,
                a.placa,
                a.fec_cap,
                a.infraccion,
                a.codigo_movto,
                a.sub_codigo,
                COALESCE(b.tarifa, 0) + COALESCE(b.costo_fijo01, 0) AS tarifa_calc
            FROM public.ta14_folios_histo a
            LEFT JOIN mercados.public.ta14_tarifas b ON b.num_clave = a.infraccion
                AND b.fecha_inicial = make_date(a.axo, 1, 1)
                AND b.fecha_fin = make_date(a.axo, 12, 31)
            WHERE a.infraccion < 11
                AND a.fecha_movto BETWEEN p_fec_ini AND p_fec_fin
                AND a.codigo_movto IN (1,2,11,15,16,17,18,19,20,21,22,23,25)
            ORDER BY a.fecha_movto, a.codigo_movto, a.placa, a.axo, a.folio
        LOOP
            SELECT descripcion INTO v_descrip_movto
            FROM public.ta14_codigomovtos
            WHERE codigo_movto = rec.codigo_movto;

            IF rec.sub_codigo > 0 THEN
                SELECT descripcion INTO v_descrip_submovto
                FROM public.ta14_codigomovtos_sub
                WHERE codigo_movtos = rec.codigo_movto AND sub = rec.sub_codigo;

                IF v_descrip_submovto IS NOT NULL THEN
                    v_descripcion := TRIM(v_descrip_movto) || ' - ' || TRIM(v_descrip_submovto);
                ELSE
                    v_descripcion := TRIM(v_descrip_movto);
                END IF;
            ELSE
                v_descripcion := TRIM(v_descrip_movto);
            END IF;

            RETURN QUERY SELECT
                v_descripcion::VARCHAR(80),
                rec.fecha_movto,
                rec.axo,
                rec.folio,
                rec.fecha_folio,
                rec.placa::VARCHAR(7),
                rec.fec_cap,
                0::NUMERIC(5,2),
                rec.tarifa_calc::NUMERIC(12,2),
                0::NUMERIC(12,2),
                0::NUMERIC(12,2),
                rec.infraccion;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_solicrep_descuentos
-- Tipo: Report
-- Descripcion: Obtiene la relacion de descuentos otorgados en un rango de fechas.
-- Traducido de: cons14_solicrep_c (Informix)
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_solicrep_descuentos(date, date);

CREATE OR REPLACE FUNCTION sp_solicrep_descuentos(
    p_fec_ini DATE,
    p_fec_fin DATE
)
RETURNS TABLE (
    placa VARCHAR(7),
    axo INTEGER,
    folio INTEGER,
    clave INTEGER,
    fecha_folio DATE,
    tarifa NUMERIC(12,2),
    porc NUMERIC(5,2),
    apagar NUMERIC(12,2),
    autoridad_otorga VARCHAR(100),
    nombre_otorgo VARCHAR(50),
    fecha_otorga DATE,
    fecha_pago DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.placa::VARCHAR(7),
        a.axo,
        a.folio,
        a.infraccion AS clave,
        a.fecha_folio,
        COALESCE(b.tarifa, 0)::NUMERIC(12,2) AS tarifa_val,
        (100 - COALESCE(c.porc_cobro, 100))::NUMERIC(5,2) AS porc_dcto,
        COALESCE(b.tarifa - ((b.tarifa * COALESCE(c.porc_cobro, 100)) / 100), 0)::NUMERIC(12,2) AS a_pagar,
        COALESCE(c.obs, '')::VARCHAR(100) AS autoridad,
        COALESCE(d.nombre, '')::VARCHAR(50) AS nombre_aplico,
        c.fecha_otorga,
        a.fecha_movto AS fecha_pago_val
    FROM public.ta14_folios_histo a
    LEFT JOIN mercados.public.ta14_tarifas b ON b.num_clave = a.infraccion
        AND b.fecha_inicial = make_date(a.axo, 1, 1)
        AND b.fecha_fin = make_date(a.axo, 12, 31)
    LEFT JOIN public.ta14_folios_free c ON c.axo = a.axo AND c.folio = a.folio AND c.clave = 'A'
    LEFT JOIN padron_licencias.comun.ta_12_passwords d ON d.id_usuario = c.usu_inicial
    WHERE a.fecha_movto BETWEEN p_fec_ini AND p_fec_fin
        AND a.codigo_movto IN (3,4,6,8,9,10,13,24)
        AND (100 - COALESCE(c.porc_cobro, 100)) > 0
    ORDER BY a.fecha_movto, a.placa, a.axo, a.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_get_infracciones
-- Tipo: Catalogo
-- Descripcion: Obtiene el catalogo de infracciones para el combo de filtro.
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_get_infracciones();

CREATE OR REPLACE FUNCTION sp_get_infracciones()
RETURNS TABLE (
    num_clave INTEGER,
    descripcion VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        i.num_clave,
        i.descripcion::VARCHAR(100)
    FROM public.ta14_infraccion i
    ORDER BY i.num_clave;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES - REPORTES_FOLIOS
-- ============================================

