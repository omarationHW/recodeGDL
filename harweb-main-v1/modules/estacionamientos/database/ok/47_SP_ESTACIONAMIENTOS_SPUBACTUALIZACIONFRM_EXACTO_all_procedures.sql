-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SPUBACTUALIZACIONFRM (EXACTO del archivo original)
-- Archivo: 47_SP_ESTACIONAMIENTOS_SPUBACTUALIZACIONFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 1/7: sppubmodi
-- Tipo: CRUD
-- Descripción: Actualiza los datos de un estacionamiento público
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sppubmodi(
    p_id integer,
    p_sector varchar,
    p_zona integer,
    p_subzona integer,
    p_numlicencia integer,
    p_cvecuenta integer,
    p_calle varchar,
    p_numext varchar,
    p_telefono varchar,
    p_fecha_at date,
    p_fecha_inicial date,
    p_fecha_vencimiento date,
    p_movto_cve varchar,
    p_movto_usr integer,
    p_solicitud integer,
    p_control integer
) RETURNS TABLE(result integer, resultstr varchar) AS $$
BEGIN
    UPDATE pubmain SET
        sector = p_sector,
        zona = p_zona,
        subzona = p_subzona,
        numlicencia = p_numlicencia,
        cvecuenta = p_cvecuenta,
        calle = p_calle,
        numext = p_numext,
        telefono = p_telefono,
        fecha_at = p_fecha_at,
        fecha_inicial = p_fecha_inicial,
        fecha_vencimiento = p_fecha_vencimiento,
        movto_cve = p_movto_cve,
        movto_usr = p_movto_usr,
        solicitud = p_solicitud,
        control = p_control
    WHERE id = p_id;
    IF FOUND THEN
        result := 0;
        resultstr := 'Actualización exitosa';
    ELSE
        result := 1;
        resultstr := 'No se encontró el registro';
    END IF;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SPUBACTUALIZACIONFRM (EXACTO del archivo original)
-- Archivo: 47_SP_ESTACIONAMIENTOS_SPUBACTUALIZACIONFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 3/7: cajero_pub_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de un estacionamiento
-- --------------------------------------------

CREATE OR REPLACE FUNCTION cajero_pub_detalle(
    p_opc integer,
    p_pubid integer,
    p_axo integer,
    p_mes integer
) RETURNS TABLE(concepto varchar, axo integer, mes integer, adeudo numeric, recargos numeric) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, axo, mes, adeudo, recargos
    FROM pubadeudo
    WHERE pubmain_id = p_pubid;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SPUBACTUALIZACIONFRM (EXACTO del archivo original)
-- Archivo: 47_SP_ESTACIONAMIENTOS_SPUBACTUALIZACIONFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 5/7: delete_pubadeudo
-- Tipo: CRUD
-- Descripción: Elimina adeudos hasta un año/mes específico para un estacionamiento
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE delete_pubadeudo(
    p_pubmain_id integer,
    p_axo integer,
    p_mes integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM pubadeudo
    WHERE pubmain_id = p_pubmain_id
      AND ((axo * 10) + mes) <= ((p_axo * 10) + p_mes)
      AND tipo = 10;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SPUBACTUALIZACIONFRM (EXACTO del archivo original)
-- Archivo: 47_SP_ESTACIONAMIENTOS_SPUBACTUALIZACIONFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 7/7: sp_pub_movtos
-- Tipo: CRUD
-- Descripción: Registra incrementos/decrementos de cajones o cambio de categoría
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pub_movtos(
    p_opc integer,
    p_pubmain_id integer,
    p_fecha date,
    p_cajones integer,
    p_categoria integer,
    p_oficio varchar,
    p_usuario integer
) RETURNS TABLE(resultado integer) AS $$
BEGIN
    IF p_opc = 1 THEN
        UPDATE pubmain SET cupo = cupo + p_cajones WHERE id = p_pubmain_id;
        resultado := 0;
    ELSIF p_opc = 2 THEN
        UPDATE pubmain SET pubcategoria_id = p_categoria WHERE id = p_pubmain_id;
        resultado := 0;
    ELSE
        resultado := 1;
    END IF;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

