-- Stored Procedure: sp_get_locales_by_id
-- Tipo: Catalog
-- Descripción: Obtiene los datos completos del local por ID
-- Generado para formulario: RptCaratulaDatos
-- Fecha: 2025-08-27 00:44:44

CREATE OR REPLACE FUNCTION sp_get_locales_by_id(p_id_local INTEGER)
RETURNS TABLE(
  id_local INTEGER,
  oficina SMALLINT,
  num_mercado SMALLINT,
  categoria SMALLINT,
  seccion VARCHAR,
  letra_local VARCHAR,
  bloque VARCHAR,
  id_contribuy_prop INTEGER,
  id_contribuy_renta INTEGER,
  nombre VARCHAR,
  arrendatario VARCHAR,
  domicilio VARCHAR,
  sector VARCHAR,
  zona SMALLINT,
  descripcion_local VARCHAR,
  superficie FLOAT,
  giro SMALLINT,
  fecha_alta DATE,
  fecha_baja DATE,
  fecha_modificacion TIMESTAMP,
  vigencia VARCHAR,
  id_usuario INTEGER,
  clave_cuota SMALLINT,
  descripcion VARCHAR,
  usuario VARCHAR,
  vigdescripcion VARCHAR,
  renta NUMERIC,
  adeudo NUMERIC,
  recargos NUMERIC,
  gastos NUMERIC,
  multa NUMERIC,
  total NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT l.*, m.descripcion, u.usuario,
    CASE l.vigencia
      WHEN 'B' THEN 'BAJA'
      WHEN 'C' THEN 'BAJA POR ACUERDO'
      WHEN 'D' THEN 'BAJA ADMINISTRATIVA'
      ELSE 'VIGENTE'
    END AS vigdescripcion,
    0::NUMERIC AS renta, 0::NUMERIC AS adeudo, 0::NUMERIC AS recargos, 0::NUMERIC AS gastos, 0::NUMERIC AS multa, 0::NUMERIC AS total
  FROM ta_11_locales l
  JOIN ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
  JOIN ta_12_passwords u ON l.id_usuario = u.id_usuario
  WHERE l.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;