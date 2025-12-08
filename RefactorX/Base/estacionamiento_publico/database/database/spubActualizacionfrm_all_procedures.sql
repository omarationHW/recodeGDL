-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: spubActualizacionfrm
-- Generado: 2025-08-27 14:48:13
-- Total SPs: 8
-- ============================================

-- SP 0/8: sp_get_estacionamiento_by_numesta
-- Tipo: Query
-- Descripción: Busca un estacionamiento por su número (numesta)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_estacionamiento_by_numesta(
    p_numesta integer
) RETURNS TABLE (
    id integer,
    pubcategoria_id integer,
    categoria varchar(2),
    descripcion varchar,
    numesta integer,
    sector varchar(1),
    nomsector varchar(8),
    zona integer,
    subzona integer,
    numlicencia integer,
    axolicencias integer,
    cvecuenta integer,
    nombre varchar(100),
    calle varchar(100),
    numext varchar(6),
    telefono varchar(15),
    rfc varchar(15),
    cupo integer,
    fecha_at date,
    fecha_inicial date,
    fecha_vencimiento date,
    movto_cve varchar(1),
    solicitud integer,
    control integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.pubcategoria_id,
           TRIM(b.categoria)::varchar(2) as categoria,
           TRIM(b.descripcion)::varchar as descripcion,
           a.numesta,
           TRIM(a.sector)::varchar(1) as sector,
           CASE TRIM(a.sector)
               WHEN 'J' THEN 'JUAREZ'::varchar(8)
               WHEN 'H' THEN 'HIDALGO'::varchar(8)
               WHEN 'L' THEN 'LIBERTAD'::varchar(8)
               WHEN 'R' THEN 'REFORMA'::varchar(8)
               ELSE 'S/N'::varchar(8)
           END AS nomsector,
           a.zona, a.subzona, a.numlicencia, a.axolicencias, a.cvecuenta,
           TRIM(a.nombre)::varchar(100) as nombre,
           TRIM(a.calle)::varchar(100) as calle,
           TRIM(a.numext)::varchar(6) as numext,
           TRIM(a.telefono)::varchar(15) as telefono,
           COALESCE(TRIM(a.rfc), '')::varchar(15) as rfc,
           a.cupo, a.fecha_at, a.fecha_inicial, a.fecha_vencimiento,
           COALESCE(TRIM(a.movto_cve), 'A')::varchar(1) as movto_cve,
           COALESCE(a.solicitud, 0)::integer as solicitud,
           COALESCE(a.control, 0)::integer as control
    FROM public.pubmain a
    JOIN public.pubcategoria b ON b.id = a.pubcategoria_id
    WHERE a.numesta = p_numesta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 1/8: sppubmodi
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

-- SP 2/7: sppubbaja
-- Tipo: CRUD
-- Descripción: Da de baja un estacionamiento público
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sppubbaja(
    p_id integer,
    p_movto_cve varchar,
    p_movto_usr integer,
    p_folio integer,
    p_fecbaja date
) RETURNS TABLE(result integer, resultstr varchar) AS $$
BEGIN
    UPDATE pubmain SET
        movto_cve = p_movto_cve,
        movto_usr = p_movto_usr,
        folio_baja = p_folio,
        fecha_baja = p_fecbaja
    WHERE id = p_id;
    IF FOUND THEN
        result := 0;
        resultstr := 'Baja exitosa';
    ELSE
        result := 1;
        resultstr := 'No se encontró el registro';
    END IF;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

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

-- SP 4/7: insert_pubadeudo
-- Tipo: CRUD
-- Descripción: Inserta un nuevo adeudo para un estacionamiento
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE insert_pubadeudo(
    p_pubmain_id integer,
    p_axo integer,
    p_mes integer,
    p_concepto varchar,
    p_ade_importe numeric,
    p_id_usuario integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO pubadeudo (fecha_at, pubmain_id, axo, mes, tipo, concepto, ade_importe, ade_descto, id_usuario)
    VALUES (CURRENT_DATE, p_pubmain_id, p_axo, p_mes, 2, p_concepto, p_ade_importe, 0, p_id_usuario);
END;
$$;

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

-- SP 6/7: actualiza_pub_pago
-- Tipo: CRUD
-- Descripción: Aplica un pago a un adeudo de estacionamiento
-- --------------------------------------------

CREATE OR REPLACE FUNCTION actualiza_pub_pago(
    p_opc integer,
    p_pubmain_id integer,
    p_axo integer,
    p_mes integer,
    p_tipo integer,
    p_fecha date,
    p_reca integer,
    p_caja varchar,
    p_operacion integer
) RETURNS TABLE(id integer, mensaje varchar) AS $$
BEGIN
    -- Lógica de aplicación de pago
    -- Aquí se debe actualizar pubadeudo y/o insertar en pubadeudo_histo
    -- Ejemplo:
    UPDATE pubadeudo
    SET pagado = TRUE, fecha_movto = p_fecha
    WHERE pubmain_id = p_pubmain_id AND axo = p_axo AND mes = p_mes AND tipo = p_tipo;
    IF FOUND THEN
        id := 1;
        mensaje := 'Pago aplicado correctamente';
    ELSE
        id := 0;
        mensaje := 'No se encontró el adeudo';
    END IF;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

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

