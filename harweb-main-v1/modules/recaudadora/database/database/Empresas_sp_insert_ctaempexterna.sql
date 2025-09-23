-- Stored Procedure: sp_insert_ctaempexterna
-- Tipo: CRUD
-- Descripción: Inserta una nueva cuenta en ctaempexterna.
-- Generado para formulario: Empresas
-- Fecha: 2025-08-27 01:35:17

CREATE OR REPLACE FUNCTION sp_insert_ctaempexterna(
  vcta INTEGER,
  veje INTEGER,
  vfec DATE
) RETURNS TABLE(inserted BOOLEAN) AS $$
BEGIN
  INSERT INTO ctaempexterna (cvecuenta, cveejecutor, fecha_trabajo)
  VALUES (vcta, veje, vfec);
  RETURN QUERY SELECT TRUE;
EXCEPTION WHEN OTHERS THEN
  RETURN QUERY SELECT FALSE;
END;
$$ LANGUAGE plpgsql;