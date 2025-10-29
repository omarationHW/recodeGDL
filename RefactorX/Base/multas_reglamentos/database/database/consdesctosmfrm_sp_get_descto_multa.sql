-- Stored Procedure: sp_get_descto_multa
-- Tipo: Catalog
-- Descripción: Obtiene un descuento específico por folio.
-- Generado para formulario: consdesctosmfrm
-- Fecha: 2025-08-26 23:23:39

CREATE OR REPLACE FUNCTION sp_get_descto_multa(p_folio_descto INTEGER)
RETURNS TABLE (
  folio_descto INTEGER,
  datos_descto TEXT,
  fecha_inicio DATE,
  fecha_fin DATE,
  por_aut INTEGER,
  monto_aut NUMERIC,
  fecha_act DATE,
  user_cap TEXT,
  us_aplico TEXT,
  fe_aplico DATE,
  vigencia TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT folio_descto, datos_descto, fecha_inicio, fecha_fin, por_aut, monto_aut, fecha_act, user_cap, us_aplico, fe_aplico, vigencia
    FROM descmultampal
    WHERE folio_descto = p_folio_descto;
END;
$$ LANGUAGE plpgsql;