-- Stored Procedure: sp_gconsulta2_busca_coincide
-- Tipo: CRUD
-- Descripción: Busca controles coincidentes según el tipo de búsqueda y dato
-- Generado para formulario: GConsulta2
-- Fecha: 2025-08-28 13:11:34

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_coincide(
  par_tab integer,
  tipo_busqueda integer,
  dato_busqueda varchar
)
RETURNS TABLE (control varchar) AS $$
BEGIN
  IF tipo_busqueda < 4 THEN
    RETURN QUERY EXECUTE format(
      'SELECT control FROM t34_datos WHERE cve_tab = %L AND %I ILIKE %L ORDER BY control',
      par_tab::text,
      CASE tipo_busqueda
        WHEN 1 THEN 'control'
        WHEN 2 THEN 'concesionario'
        WHEN 3 THEN 'ubicacion'
      END,
      '%' || dato_busqueda || '%'
    );
  ELSE
    RETURN QUERY EXECUTE format(
      'SELECT a.control FROM t34_datos a JOIN t34_conceptos c ON c.id_datos = a.id_34_datos WHERE a.cve_tab = %L AND c.tipo = %L AND c.concepto ILIKE %L ORDER BY a.control',
      par_tab::text,
      CASE tipo_busqueda
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'L'
        WHEN 6 THEN 'O'
      END,
      '%' || dato_busqueda || '%'
    );
  END IF;
END;
$$ LANGUAGE plpgsql;