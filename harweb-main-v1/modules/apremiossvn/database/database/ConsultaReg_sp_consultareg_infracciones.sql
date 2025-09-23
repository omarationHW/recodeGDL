-- Stored Procedure: sp_consultareg_infracciones
-- Tipo: Catalog
-- Descripción: Busca un registro de infracción por placa.
-- Generado para formulario: ConsultaReg
-- Fecha: 2025-08-27 13:40:42

CREATE OR REPLACE FUNCTION sp_consultareg_infracciones(
    p_placa varchar
) RETURNS TABLE (
    id integer,
    placa varchar,
    placaant varchar,
    claveveh varchar,
    nombre varchar,
    municipio varchar,
    marca varchar,
    modelo varchar,
    color varchar,
    serie varchar,
    pagados integer,
    vigentes integer,
    domicilio varchar,
    num_ext varchar,
    num_int1 varchar,
    num_int2 varchar,
    colonia varchar,
    entrecalles varchar,
    actualizado varchar,
    fecactualizado date
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_padron WHERE placa = p_placa LIMIT 1;
END;
$$ LANGUAGE plpgsql;