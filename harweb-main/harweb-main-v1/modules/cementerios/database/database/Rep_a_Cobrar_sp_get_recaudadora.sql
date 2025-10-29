-- Stored Procedure: sp_get_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora (nombre, zona, etc) por id_rec.
-- Generado para formulario: Rep_a_Cobrar
-- Fecha: 2025-08-27 14:47:41

-- PostgreSQL stored procedure for recaudadora info
CREATE OR REPLACE FUNCTION sp_get_recaudadora(par_id_rec integer)
RETURNS TABLE(
    id_rec integer,
    nomre text,
    titulo text,
    d_zona text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.nomre, a.titulo, upper(c.zona) as d_zona
    FROM ta_12_nombrerec a
    JOIN ta_12_recaudadoras b ON a.recing = b.id_rec
    JOIN ta_12_zonas c ON b.id_zona = c.id_zona
    WHERE a.recing = par_id_rec;
END;
$$ LANGUAGE plpgsql;