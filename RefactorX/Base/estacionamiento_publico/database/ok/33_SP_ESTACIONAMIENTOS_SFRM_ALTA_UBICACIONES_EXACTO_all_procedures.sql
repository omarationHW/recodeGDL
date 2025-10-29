-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_ALTA_UBICACIONES (EXACTO del archivo original)
-- Archivo: 33_SP_ESTACIONAMIENTOS_SFRM_ALTA_UBICACIONES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_exc_ubicacion
-- Tipo: CRUD
-- Descripción: Alta de ubicaciones para estacionamiento exclusivo. Inserta una nueva ubicación asociada a un contrato.
-- --------------------------------------------

-- PostgreSQL stored procedure for alta de ubicaciones
CREATE OR REPLACE FUNCTION sp_exc_ubicacion(
    opc integer,
    id_ubic integer,
    contrato_id integer,
    tipo_esta varchar,
    calle varchar,
    colonia varchar,
    zona integer,
    subzona integer,
    extencion numeric,
    acera varchar,
    inter varchar,
    inter2 varchar,
    apartir integer,
    hacia varchar,
    usuario integer
)
RETURNS TABLE(id integer, mensaje varchar) AS $$
DECLARE
    new_id integer;
BEGIN
    IF opc = 1 THEN -- Alta
        INSERT INTO ubicaciones (
            contrato_id, tipo_esta, calle, colonia, zona, subzona, extencion, acera, inter, inter2, apartir, hacia, usuario_alta, fecha_alta
        ) VALUES (
            contrato_id, tipo_esta, calle, colonia, zona, subzona, extencion, acera, inter, inter2, apartir, hacia, usuario, NOW()
        ) RETURNING id INTO new_id;
        RETURN QUERY SELECT new_id, 'Alta de Ubicación realizada correctamente.';
    ELSE
        RETURN QUERY SELECT NULL::integer, 'Operación no soportada.';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- ============================================

