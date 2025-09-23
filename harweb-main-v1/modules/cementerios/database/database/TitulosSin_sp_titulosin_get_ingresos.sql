-- Stored Procedure: sp_titulosin_get_ingresos
-- Tipo: CRUD
-- Descripción: Obtiene los datos de ingresos para la impresión del título.
-- Generado para formulario: TitulosSin
-- Fecha: 2025-08-27 14:58:45

CREATE OR REPLACE FUNCTION sp_titulosin_get_ingresos(
    p_fecha DATE,
    p_ofna SMALLINT,
    p_caja VARCHAR,
    p_operacion INTEGER
) RETURNS TABLE(
    fecha DATE,
    id_rec SMALLINT,
    caja VARCHAR,
    operacion INTEGER,
    importe NUMERIC,
    cvepago VARCHAR,
    id_modulo INTEGER,
    id_regmodulo INTEGER,
    id_rec_cta SMALLINT,
    regmunur VARCHAR,
    mesdesde SMALLINT,
    axodesde SMALLINT,
    meshasta SMALLINT,
    axohasta SMALLINT,
    nombre VARCHAR,
    domicilio VARCHAR,
    concepto VARCHAR,
    rfcini VARCHAR,
    rfcnumero INTEGER,
    rfccolonia SMALLINT,
    obra SMALLINT,
    axofolio INTEGER,
    id_usuario INTEGER,
    fecha_act TIMESTAMP,
    cajero VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.*, (SELECT nombre FROM ta_12_passwords WHERE id_usuario = a.id_usuario) as cajero
    FROM ta_12_recibos a
    WHERE a.fecha = p_fecha
      AND a.id_rec = p_ofna
      AND a.caja = p_caja
      AND a.operacion = p_operacion
      AND a.id_modulo = 12
      AND (
        SELECT COUNT(*) FROM ta_12_recibosdet
        WHERE fecha = a.fecha AND a.id_rec = id_rec AND a.caja = caja AND a.operacion = operacion
          AND cuenta IN (44304, 44301, 44307, 44314, 44311, 44310, 44450)
      ) > 0;
END;
$$ LANGUAGE plpgsql;