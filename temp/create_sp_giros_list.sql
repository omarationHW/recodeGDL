-- SP: sp_get_giros_vigentes
-- Descripción: Retorna el listado de giros vigentes para selects
-- Base: padron_licencias
-- Filtra solo giros cuyo ID cabe en SMALLINT (rango: -32768 a 32767)

CREATE OR REPLACE FUNCTION sp_get_giros_vigentes()
RETURNS TABLE(
    id_giro INTEGER,
    descripcion VARCHAR(100)
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id_giro,
        TRIM(g.descripcion)::VARCHAR(100) as descripcion
    FROM comun.c_giros g
    WHERE g.vigente = 'V'
      AND g.id_giro >= -32768
      AND g.id_giro <= 32767
    ORDER BY TRIM(g.descripcion) ASC;
END;
$$;
