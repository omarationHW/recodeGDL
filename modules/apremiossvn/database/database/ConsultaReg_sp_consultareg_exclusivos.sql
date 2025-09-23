-- Stored Procedure: sp_consultareg_exclusivos
-- Tipo: Catalog
-- Descripción: Busca un registro de estacionamiento exclusivo por número.
-- Generado para formulario: ConsultaReg
-- Fecha: 2025-08-27 13:40:42

CREATE OR REPLACE FUNCTION sp_consultareg_exclusivos(
    p_no_exclusivo integer
) RETURNS TABLE (
    id integer,
    ex_propietario_id integer,
    no_exclusivo integer,
    zona varchar,
    total_bateria float,
    total_cordon float,
    solicitud integer,
    control integer,
    folio_cancelacion integer,
    estatus varchar,
    factor float,
    fecha_in timestamp,
    fecha_at timestamp,
    id_clasificacion integer,
    vialidad varchar,
    fecha_inicial date,
    usuario integer,
    pc varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ex_contrato WHERE no_exclusivo = p_no_exclusivo LIMIT 1;
END;
$$ LANGUAGE plpgsql;