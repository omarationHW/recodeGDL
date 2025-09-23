-- Stored Procedure: spd_17_buscaregistro
-- Tipo: CRUD
-- Descripción: Busca un registro de acuerdo al módulo y parámetros variables (Predial, Licencias, Mercados, etc.) y retorna el id_registro y datos principales.
-- Generado para formulario: SimuladorConvenio
-- Fecha: 2025-08-27 15:57:10

-- PostgreSQL version of spd_17_buscaregistro
CREATE OR REPLACE FUNCTION spd_17_buscaregistro(
    pmod integer,
    p1 text, p2 text, p3 text, p4 text, p5 text, p6 text, p7 text
) RETURNS TABLE(
    id_registro integer,
    id_control integer,
    nombre text,
    calle text,
    exterior text,
    interior text,
    recaudadora integer,
    zona integer,
    axodsd integer,
    mesdsd integer,
    axohst integer,
    meshst integer
) AS $$
BEGIN
    -- Ejemplo para Predial (modulo=5)
    IF pmod = 5 THEN
        RETURN QUERY
        SELECT id_registro, id_control, nombre, calle, exterior, interior, recaudadora, zona, axodsd, mesdsd, axohst, meshst
        FROM ta_11_predial
        WHERE rec = p1::int AND ur = p2 AND cuenta = p3::int
        LIMIT 1;
    ELSIF pmod = 9 THEN
        RETURN QUERY
        SELECT id_registro, id_control, nombre, calle, exterior, interior, recaudadora, zona, axodsd, mesdsd, axohst, meshst
        FROM ta_11_licencias
        WHERE licencia = p1::int
        LIMIT 1;
    ELSIF pmod = 10 THEN
        RETURN QUERY
        SELECT id_registro, id_control, nombre, calle, exterior, interior, recaudadora, zona, axodsd, mesdsd, axohst, meshst
        FROM ta_11_anuncios
        WHERE anuncio = p1::int
        LIMIT 1;
    -- ... otros módulos ...
    ELSE
        RETURN QUERY SELECT NULL::integer, NULL::integer, NULL::text, NULL::text, NULL::text, NULL::text, NULL::integer, NULL::integer, NULL::integer, NULL::integer, NULL::integer, NULL::integer;
    END IF;
END;
$$ LANGUAGE plpgsql;