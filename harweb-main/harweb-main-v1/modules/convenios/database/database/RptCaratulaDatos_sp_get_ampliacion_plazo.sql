-- Stored Procedure: sp_get_ampliacion_plazo
-- Tipo: Report
-- Descripción: Obtiene la última ampliación de plazo vigente para un contrato.
-- Generado para formulario: RptCaratulaDatos
-- Fecha: 2025-08-27 15:34:13

CREATE OR REPLACE FUNCTION sp_get_ampliacion_plazo(p_contrato integer)
RETURNS TABLE (
    id_convenio integer,
    axo_oficio smallint,
    folio_oficio varchar,
    total numeric,
    fecha_inicio date,
    fecha_fin date
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_convenio, axo_oficio, folio_oficio, total, fecha_inicio, fecha_fin
  FROM ta_17_amp_plazo
  WHERE id_convenio = p_contrato AND vigencia = 'A'
  ORDER BY axo_oficio DESC, folio_oficio DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;