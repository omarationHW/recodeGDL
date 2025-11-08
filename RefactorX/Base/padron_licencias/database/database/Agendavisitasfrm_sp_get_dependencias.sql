-- Stored Procedure: sp_get_dependencias
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de dependencias disponibles para agendar visitas.
-- Generado para formulario: Agendavisitasfrm
-- Fecha: 2025-08-27 15:54:49

CREATE OR REPLACE FUNCTION sp_get_dependencias()
RETURNS TABLE (
    id_dependencia INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id_dependencia, d.descripcion
    FROM c_dep_horario c
    INNER JOIN c_dependencias d ON c.id_dependencia = d.id_dependencia
    GROUP BY d.id_dependencia, d.descripcion
    ORDER BY d.descripcion;
END;
$$ LANGUAGE plpgsql;