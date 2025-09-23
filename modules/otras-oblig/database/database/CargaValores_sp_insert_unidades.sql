-- Stored Procedure: sp_insert_unidades
-- Tipo: CRUD
-- Descripción: Inserta múltiples registros en t34_unidades para carga de valores.
-- Generado para formulario: CargaValores
-- Fecha: 2025-08-27 23:13:46

CREATE OR REPLACE FUNCTION sp_insert_unidades(
  p_cve_tab varchar,
  p_unidades jsonb
) RETURNS text AS $$
DECLARE
  rec jsonb;
  maxid integer;
  i integer := 0;
BEGIN
  SELECT COALESCE(MAX(id_34_unidad),0) INTO maxid FROM t34_unidades;
  FOR i IN 0 .. jsonb_array_length(p_unidades) - 1 LOOP
    rec := p_unidades->i;
    maxid := maxid + 1;
    INSERT INTO t34_unidades (
      id_34_unidad, ejercicio, cve_unidad, cve_operatividad, descripcion, costo, cve_tab
    ) VALUES (
      maxid,
      (rec->>'ejercicio')::integer,
      rec->>'cve_unidad',
      rec->>'cve_operatividad',
      rec->>'descripcion',
      (rec->>'costo')::numeric,
      p_cve_tab
    );
  END LOOP;
  RETURN 'SE CREARON CORRECTAMENTE LOS VALORES';
END;
$$ LANGUAGE plpgsql;