-- Stored Procedure: sp_get_padron_report
-- Tipo: Report
-- Descripción: Obtiene el reporte del padrón vehicular entre dos IDs (id1, id2) inclusive, ordenado por ID.
-- Generado para formulario: sQRt_imp_padron
-- Fecha: 2025-08-27 14:59:31

CREATE OR REPLACE FUNCTION sp_get_padron_report(p_id1 integer, p_id2 integer)
RETURNS TABLE (
    id integer,
    placa varchar(7),
    placaant varchar(7),
    claveveh varchar(7),
    nombre varchar(60),
    municipio varchar(60),
    marca varchar(60),
    linea varchar(60),
    version varchar(60),
    tipo varchar(50),
    clase varchar(50),
    combustible varchar(15),
    modelo varchar(4),
    servicio varchar(60),
    color varchar(60),
    serie varchar,
    motor varchar,
    centimetros varchar(4)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        id,
        placa,
        placaant,
        claveveh,
        nombre,
        municipio,
        marca,
        linea,
        version,
        tipo,
        clase,
        combustible,
        modelo,
        servicio,
        color,
        serie,
        motor,
        centimetros
    FROM ta_padron
    WHERE id >= p_id1 AND id <= p_id2
    ORDER BY id;
END;
$$ LANGUAGE plpgsql;