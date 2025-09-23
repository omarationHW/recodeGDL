-- Stored Procedure: ins34_rubro_status
-- Tipo: Catalog
-- Descripción: Inserta un status para un rubro en t34_status.
-- Generado para formulario: Rubros
-- Fecha: 2025-08-27 14:25:12

CREATE OR REPLACE FUNCTION ins34_rubro_status(par_cve_tab INTEGER, par_cve_stat VARCHAR, par_descripcion VARCHAR)
RETURNS VOID AS $$
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
$$ LANGUAGE plpgsql;