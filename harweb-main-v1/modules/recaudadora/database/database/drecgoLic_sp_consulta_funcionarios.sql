-- Stored Procedure: sp_consulta_funcionarios
-- Tipo: Catalog
-- Descripción: Consulta funcionarios autorizados para descuentos de recargo o multa
-- Generado para formulario: drecgoLic
-- Fecha: 2025-08-27 00:52:37

CREATE OR REPLACE FUNCTION sp_consulta_funcionarios(p_tipo VARCHAR) RETURNS TABLE(
  cveautoriza INTEGER,
  descripcion VARCHAR,
  nombre VARCHAR,
  porcentajetope INTEGER
) AS $$
BEGIN
  IF p_tipo = 'recargo' THEN
    RETURN QUERY SELECT cveautoriza, descripcion, nombre, porcentajetope FROM c_autdescrec WHERE vigencia='V' ORDER BY cveautoriza DESC;
  ELSE
    RETURN QUERY SELECT cveautoriza, descripcion, nombre, porcentajetope FROM c_autdescmul WHERE vigencia='V' ORDER BY cveautoriza DESC;
  END IF;
END;
$$ LANGUAGE plpgsql;