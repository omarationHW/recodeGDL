-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: Bonificaciones (EXACTO del archivo original)
-- Archivo: 04_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_bonificaciones_create
-- Tipo: CRUD
-- Descripción: Crea una nueva bonificación en ta_13_bonifrcm
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bonificaciones_create(
    p_oficio integer,
    p_axo integer,
    p_doble varchar,
    p_control_rcm integer,
    p_cementerio varchar,
    p_clase integer,
    p_clase_alfa varchar,
    p_seccion integer,
    p_seccion_alfa varchar,
    p_linea integer,
    p_linea_alfa varchar,
    p_fosa integer,
    p_fosa_alfa varchar,
    p_fecha_ofic date,
    p_importe_bonificar numeric,
    p_importe_bonificado numeric,
    p_importe_resto numeric,
    p_usuario integer,
    p_fecha_mov timestamp,
    OUT p_error text
) RETURNS void AS $$
BEGIN
    INSERT INTO public.ta_13_bonifrcm (
        control_bon, oficio, axo, doble, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, fecha_ofic, importe_bonificar, importe_bonificado, importe_resto, usuario, fecha_mov
    ) VALUES (
        DEFAULT, p_oficio, p_axo, p_doble, p_control_rcm, p_cementerio, p_clase, p_clase_alfa, p_seccion, p_seccion_alfa, p_linea, p_linea_alfa, p_fosa, p_fosa_alfa, p_fecha_ofic, p_importe_bonificar, p_importe_bonificado, p_importe_resto, p_usuario, p_fecha_mov
    );
    p_error := NULL;
EXCEPTION WHEN OTHERS THEN
    p_error := SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_bonificaciones_update
-- Tipo: CRUD
-- Descripción: Actualiza una bonificación existente en ta_13_bonifrcm
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bonificaciones_update(
    p_oficio integer,
    p_axo integer,
    p_doble varchar,
    p_fecha_ofic date,
    p_importe_bonificar numeric,
    p_importe_bonificado numeric,
    p_importe_resto numeric,
    p_usuario integer
) RETURNS void AS $$
BEGIN
    UPDATE public.ta_13_bonifrcm
    SET fecha_ofic = p_fecha_ofic,
        importe_bonificar = p_importe_bonificar,
        importe_bonificado = p_importe_bonificado,
        importe_resto = p_importe_resto,
        usuario = p_usuario,
        fecha_mov = NOW()
    WHERE oficio = p_oficio AND axo = p_axo AND doble = p_doble;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_bonificaciones_delete
-- Tipo: CRUD
-- Descripción: Elimina una bonificación de ta_13_bonifrcm
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bonificaciones_delete(
    p_oficio integer,
    p_axo integer,
    p_doble varchar,
    p_usuario integer
) RETURNS void AS $$
BEGIN
    DELETE FROM public.ta_13_bonifrcm
    WHERE oficio = p_oficio AND axo = p_axo AND doble = p_doble;
END;
$$ LANGUAGE plpgsql;

-- ============================================