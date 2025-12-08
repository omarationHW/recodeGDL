-- Stored Procedure: sp_get_padron_report
-- Tipo: Report
-- Descripción: Obtiene el reporte del padrón vehicular entre dos IDs (id1, id2) inclusive, ordenado por ID.
-- Generado para formulario: sQRt_imp_padron
-- Fecha: 2025-08-27 14:59:31
-- Actualizado: 2025-12-06 - Corregido columnas ambiguas con alias 't' y prefijo 'out_'

CREATE OR REPLACE FUNCTION sp_get_padron_report(p_id1 integer, p_id2 integer)
RETURNS TABLE (
    out_id integer,
    out_placa varchar(7),
    out_placaant varchar(7),
    out_claveveh varchar(7),
    out_nombre varchar(60),
    out_municipio varchar(60),
    out_marca varchar(60),
    out_linea varchar(60),
    out_version varchar(60),
    out_tipo varchar(50),
    out_clase varchar(50),
    out_combustible varchar(15),
    out_modelo varchar(4),
    out_servicio varchar(60),
    out_color varchar(60),
    out_serie varchar,
    out_motor varchar,
    out_centimetros varchar(4)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id,
        t.placa,
        t.placaant,
        t.claveveh,
        t.nombre,
        t.municipio,
        t.marca,
        t.linea,
        t.version,
        t.tipo,
        t.clase,
        t.combustible,
        t.modelo,
        t.servicio,
        t.color,
        t.serie,
        t.motor,
        t.centimetros
    FROM ta_padron t
    WHERE t.id >= p_id1 AND t.id <= p_id2
    ORDER BY t.id;
END;
$$ LANGUAGE plpgsql;
