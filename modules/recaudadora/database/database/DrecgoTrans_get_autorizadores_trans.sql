-- Stored Procedure: get_autorizadores_trans
-- Tipo: Catalog
-- Descripción: Obtiene lista de funcionarios autorizados para descuentos en transmisión según permisos
-- Generado para formulario: DrecgoTrans
-- Fecha: 2025-08-27 01:13:21

CREATE OR REPLACE FUNCTION get_autorizadores_trans(p_usuario text)
RETURNS TABLE(cveautoriza integer, descripcion text, nombre text, porcentajetope integer) AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM autoriza a, usuarios b, deptos d WHERE a.usuario = p_usuario AND a.num_tag IN (1319,1320) AND b.usuario = a.usuario AND d.cvedepto = b.cvedepto) THEN
    RETURN QUERY SELECT cveautoriza, descripcion, nombre, porcentajetope FROM c_autdescrec WHERE funcionario = 'N' AND vigencia = 'V';
  ELSE
    RETURN QUERY SELECT cveautoriza, descripcion, nombre, porcentajetope FROM c_autdescrec WHERE vigencia = 'V' ORDER BY cveautoriza DESC;
  END IF;
END;
$$ LANGUAGE plpgsql;