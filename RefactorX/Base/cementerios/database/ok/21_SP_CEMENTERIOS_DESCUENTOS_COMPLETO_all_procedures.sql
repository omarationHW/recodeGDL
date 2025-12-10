-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public (cementerio)
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: Descuentos
-- Archivo: 21_SP_CEMENTERIOS_DESCUENTOS_COMPLETO_all_procedures.sql
-- Generado: 2025-11-30
-- Total SPs: 5
-- ============================================
--
-- CORRECCIONES POSTGRESQL - AGENTE CATALIZADOR
-- Fecha: 2025-12-04
-- Total Correcciones: 18
--
-- Correcciones aplicadas:
-- SP 1: sp_descuentos_buscar_folio
-- 1. cementerio: CHAR(2) → CHAR(1)
-- 2. linea_alfa: VARCHAR(10) → VARCHAR(20)
-- 3. fosa_alfa: VARCHAR(10) → VARCHAR(20)
-- 4. nombre: VARCHAR(255) → VARCHAR(60)
-- 5. domicilio: VARCHAR(255) → VARCHAR(60)
-- 6. exterior: CHAR(20) → CHAR(6)
-- 7. interior: CHAR(20) → CHAR(6)
-- 8. colonia: VARCHAR(100) → VARCHAR(30)
-- 9. metros: NUMERIC(10,2) → NUMERIC
--
-- SP 2: sp_descuentos_listar_adeudos
-- 10. importe: NUMERIC(10,2) → NUMERIC(16,2)
-- 11. importe_recargos: NUMERIC(10,2) → NUMERIC(16,2)
-- 12. descto_impote: NUMERIC(10,2) → NUMERIC(16,2)
-- 13. descto_recargos: NUMERIC(10,2) → NUMERIC(16,2)
--
-- SP 3: sp_descuentos_listar_descuentos_aplicados
-- 14. descrip_descto: CHAR(25) → VARCHAR(60)
--
-- SP 4: sp_descuentos_listar_tipos_descuento
-- 15. descrip_descto: CHAR(15) → VARCHAR(60)
--
-- SP 5: spd_13_abcdesctos (2 versiones)
-- 16. par_observ: VARCHAR → VARCHAR(255)
-- 17. v_reac: VARCHAR(1) → CHAR(1)
-- 18. v_tipo_descto: VARCHAR(1) → CHAR(1)
-- ============================================

-- =============================================
-- SP 1/5: sp_descuentos_buscar_folio
-- Descripción: Busca información completa del folio
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_descuentos_buscar_folio(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    control_rcm INTEGER,
    cementerio CHAR(1),
    clase SMALLINT,
    clase_alfa VARCHAR(10),
    seccion SMALLINT,
    seccion_alfa VARCHAR(10),
    linea SMALLINT,
    linea_alfa VARCHAR(20),
    fosa SMALLINT,
    fosa_alfa VARCHAR(20),
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    exterior CHAR(6),
    interior CHAR(6),
    colonia VARCHAR(30),
    metros NUMERIC,
    axo_pagado INTEGER,
    tipo CHAR(1),
    vigencia CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control_rcm,
        a.cementerio,
        a.clase,
        a.clase_alfa,
        a.seccion,
        a.seccion_alfa,
        a.linea,
        a.linea_alfa,
        a.fosa,
        a.fosa_alfa,
        a.nombre,
        a.domicilio,
        a.exterior,
        a.interior,
        a.colonia,
        a.metros,
        a.axo_pagado,
        a.tipo,
        a.vigencia
    FROM padron_licencias.comun.ta_13_datosrcm a
    WHERE a.control_rcm = p_control_rcm;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_descuentos_buscar_folio IS 'Busca información completa del folio para módulo descuentos';

-- =============================================
-- SP 2/5: sp_descuentos_listar_adeudos
-- Descripción: Lista adeudos vigentes del folio
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_descuentos_listar_adeudos(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    id_adeudo INTEGER,
    control_rcm INTEGER,
    axo_adeudo INTEGER,
    importe NUMERIC(16,2),
    importe_recargos NUMERIC(16,2),
    descto_impote NUMERIC(16,2),
    descto_recargos NUMERIC(16,2),
    vigencia CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_adeudo,
        a.control_rcm,
        a.axo_adeudo,
        a.importe,
        a.importe_recargos,
        a.descto_impote,
        a.descto_recargos,
        a.vigencia
    FROM padron_licencias.comun.ta_13_adeudosrcm a
    WHERE a.control_rcm = p_control_rcm
      AND a.vigencia = 'V'
    ORDER BY a.axo_adeudo DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_descuentos_listar_adeudos IS 'Lista adeudos vigentes del folio';

-- =============================================
-- SP 3/5: sp_descuentos_listar_descuentos_aplicados
-- Descripción: Lista descuentos aplicados al folio
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_descuentos_listar_descuentos_aplicados(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    control_des INTEGER,
    control_rcm INTEGER,
    axo_descto INTEGER,
    descuento INTEGER,
    tipo_descto CHAR(1),
    descrip_descto VARCHAR(60),
    usuario INTEGER,
    --nombre VARCHAR(255),
    fecha_alta DATE,
    vigencia CHAR(1),
    reactivar CHAR(1),
    usuario_mov INTEGER,
    fecha_mov DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control_des,
        a.control_rcm,
        a.axo_descto,
        a.descuento,
        a.tipo_descto,
        d.descrip_descto,
        a.usuario,
      --  b.nombre,
        a.fecha_alta,
        a.vigencia,
        a.reactivar,
        a.usuario_mov,
        a.fecha_mov
    FROM public.ta_13_descpens a
    --INNER JOIN padron_licencias.comun.ta_12_passwords b ON a.usuario = b.id_usuario
    LEFT JOIN public.ta_13_descuentos d
        ON d.axo_descto = a.axo_descto
        AND d.tipo_descto = a.tipo_descto
    WHERE a.control_rcm = p_control_rcm
    ORDER BY a.axo_descto DESC, a.fecha_alta DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_descuentos_listar_descuentos_aplicados IS 'Lista descuentos aplicados al folio con información del usuario';

-- =============================================
-- SP 4/5: sp_descuentos_listar_tipos_descuento
-- Descripción: Lista catálogo de tipos de descuento disponibles
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_descuentos_listar_tipos_descuento(
    p_axo INTEGER
)
RETURNS TABLE(
    axo_descto SMALLINT,
    tipo_descto CHAR(1),
    descrip_descto VARCHAR(60),
    porcentaje SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.axo_descto,
        a.tipo_descto,
        a.descrip_descto,
        a.porcentaje
    FROM public.ta_13_descuentos a
    WHERE a.axo_descto = p_axo
      AND a.tipo_descto <> 'N'
    ORDER BY a.tipo_descto;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_descuentos_listar_tipos_descuento IS 'Lista catálogo de tipos de descuento para un año específico';

-- =============================================
-- SP 5/5: spd_13_abcdesctos (CRUD Principal)
-- Descripción: Alta, baja, modificación y reactivación de descuentos
-- OPC: 1=alta, 2=baja, 3=modifica, 4=reactivar
-- =============================================

CREATE OR REPLACE FUNCTION public.spd_13_abcdesctos(
    v_control INTEGER,
    v_axo INTEGER,
    v_porc INTEGER,
    v_usu INTEGER,
    v_reac CHAR(1),
    v_tipo_descto CHAR(1),
    v_opc INTEGER
)
RETURNS TABLE(par_ok SMALLINT, par_observ VARCHAR(255)) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    IF v_opc NOT IN (1,2,3,4) THEN
        RETURN QUERY SELECT 1::SMALLINT, 'Operación no soportada'::VARCHAR(255);
    END IF;

    IF v_opc = 1 THEN -- Alta
        SELECT COUNT(*) INTO v_exists
        FROM public.ta_13_descpens
        WHERE control_rcm = v_control AND axo_descto = v_axo AND vigencia = 'V';

        IF v_exists > 0 THEN
            RETURN QUERY SELECT 1::SMALLINT, 'Ya existe descuento vigente para el año'::VARCHAR(255);
        END IF;

        INSERT INTO public.ta_13_descpens(
            control_rcm, axo_descto, descuento, usuario, fecha_alta,
            vigencia, reactivar, tipo_descto
        )
        VALUES (v_control, v_axo, v_porc, v_usu, CURRENT_DATE,
                'V', COALESCE(v_reac,'N'), v_tipo_descto);

        RETURN QUERY SELECT 0::SMALLINT, 'Descuento dado de alta correctamente'::VARCHAR(255);

    ELSIF v_opc = 2 THEN -- Baja
        UPDATE public.ta_13_descpens
        SET vigencia = 'B', usuario_mov = v_usu, fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control AND axo_descto = v_axo AND vigencia = 'V';

        IF FOUND THEN
            RETURN QUERY SELECT 0::SMALLINT, 'Descuento dado de baja correctamente'::VARCHAR(255);
        ELSE
            RETURN QUERY SELECT 1::SMALLINT, 'No se encontró descuento vigente para dar de baja'::VARCHAR(255);
        END IF;

    ELSIF v_opc = 3 THEN -- Modificar
        UPDATE public.ta_13_descpens
        SET descuento = v_porc, usuario_mov = v_usu, fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control AND axo_descto = v_axo AND vigencia = 'V';

        IF FOUND THEN
            RETURN QUERY SELECT 0::SMALLINT, 'Descuento modificado correctamente'::VARCHAR(255);
        ELSE
            RETURN QUERY SELECT 1::SMALLINT, 'No se encontró descuento vigente para modificar'::VARCHAR(255);
        END IF;

    ELSE -- Reactivar
        UPDATE public.ta_13_descpens
        SET reactivar = 'S', usuario_mov = v_usu, fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control AND axo_descto = v_axo;

        IF FOUND THEN
            RETURN QUERY SELECT 0::SMALLINT, 'Folio reactivado correctamente'::VARCHAR(255);
        ELSE
            INSERT INTO public.ta_13_descpens(
                control_rcm, axo_descto, descuento, usuario, fecha_alta,
                vigencia, reactivar, tipo_descto
            )
            VALUES (v_control, v_axo, 0, v_usu, CURRENT_DATE,
                    'V', 'S', v_tipo_descto);

            RETURN QUERY SELECT 0::SMALLINT, 'Folio reactivado correctamente'::VARCHAR(255);
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION cementerio.spd_13_abcdesctos(
    v_control INTEGER,
    v_axo INTEGER,
    v_porc INTEGER,
    v_usu INTEGER,
    v_reac CHAR(1),
    v_tipo_descto CHAR(1),
    v_opc INTEGER
)
RETURNS TABLE(par_ok SMALLINT, par_observ VARCHAR(255)) AS $$
DECLARE
    v_exists INTEGER;
    v_control_des INTEGER;
BEGIN
    IF v_opc = 1 THEN -- Alta
        -- Verificar si ya existe descuento vigente para el año
        SELECT COUNT(*) INTO v_exists
        FROM padron_licencias.comun.ta_13_descpens
        WHERE control_rcm = v_control
          AND axo_descto = v_axo
          AND vigencia = 'V';

        IF v_exists > 0 THEN
            par_ok := 1;
            par_observ := 'Ya tiene descuento para el adeudo del año seleccionado, verifique';
            RETURN NEXT;
            RETURN;
        END IF;

        -- Insertar nuevo descuento
        INSERT INTO padron_licencias.comun.ta_13_descpens (
            control_rcm, axo_descto, descuento, usuario, fecha_alta,
            vigencia, reactivar, tipo_descto
        )
        VALUES (
            v_control, v_axo, v_porc, v_usu, CURRENT_DATE,
            'V', COALESCE(v_reac, 'N'), v_tipo_descto
        );

        par_ok := 0;
        par_observ := 'Descuento dado de alta correctamente';
        RETURN NEXT;

    ELSIF v_opc = 2 THEN -- Baja
        UPDATE padron_licencias.comun.ta_13_descpens
        SET vigencia = 'B',
            usuario_mov = v_usu,
            fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control
          AND axo_descto = v_axo
          AND vigencia = 'V';

        IF FOUND THEN
            par_ok := 0;
            par_observ := 'Descuento dado de baja correctamente';
        ELSE
            par_ok := 1;
            par_observ := 'No se encontró descuento vigente para dar de baja';
        END IF;
        RETURN NEXT;

    ELSIF v_opc = 3 THEN -- Modificar
        UPDATE padron_licencias.comun.ta_13_descpens
        SET descuento = v_porc,
            usuario_mov = v_usu,
            fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control
          AND axo_descto = v_axo
          AND vigencia = 'V';

        IF FOUND THEN
            par_ok := 0;
            par_observ := 'Descuento modificado correctamente';
        ELSE
            par_ok := 1;
            par_observ := 'No se encontró descuento vigente para modificar';
        END IF;
        RETURN NEXT;

    ELSIF v_opc = 4 THEN -- Reactivar
        UPDATE padron_licencias.comun.ta_13_descpens
        SET reactivar = 'S',
            usuario_mov = v_usu,
            fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control
          AND axo_descto = v_axo;

        IF FOUND THEN
            par_ok := 0;
            par_observ := 'Folio reactivado correctamente';
        ELSE
            -- Si no existe, insertar registro de reactivación
            INSERT INTO padron_licencias.comun.ta_13_descpens (
                control_rcm, axo_descto, descuento, usuario, fecha_alta,
                vigencia, reactivar, tipo_descto
            )
            VALUES (
                v_control, v_axo, 0, v_usu, CURRENT_DATE,
                'V', 'S', ''
            );

            par_ok := 0;
            par_observ := 'Folio reactivado correctamente';
        END IF;
        RETURN NEXT;

    ELSE
        par_ok := 1;
        par_observ := 'Operación no soportada';
        RETURN NEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.spd_13_abcdesctos IS 'CRUD de descuentos - OPC: 1=alta, 2=baja, 3=modifica, 4=reactivar';

-- ============================================
-- FIN DE STORED PROCEDURES - DESCUENTOS
-- ============================================
