-- Stored Procedure: ins34_status
-- Tipo: Catalog
-- Descripción: Inserta un status para un rubro en t34_status.
-- Generado para formulario: Rubros
-- Fecha: 2025-08-28 13:48:30

CREATE OR REPLACE PROCEDURE ins34_status(
    par_cve_tab INTEGER,
    par_cve_stat VARCHAR,
    par_descripcion VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO t34_status (id_34_stat, cve_tab, cve_stat, descripcion, usuario)
    VALUES (
        DEFAULT,
        par_cve_tab,
        par_cve_stat,
        par_descripcion,
        current_user
    );
END;
$$;