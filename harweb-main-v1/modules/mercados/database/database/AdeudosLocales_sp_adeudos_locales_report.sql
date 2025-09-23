-- Stored Procedure: sp_adeudos_locales_report
-- Tipo: Report
-- Descripción: Genera el reporte de adeudos locales para impresión/exportación.
-- Generado para formulario: AdeudosLocales
-- Fecha: 2025-08-26 20:22:20

CREATE OR REPLACE FUNCTION sp_adeudos_locales_report(p_year integer, p_oficina integer, p_periodo integer)
RETURNS TABLE(
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    letra_local varchar(1),
    bloque varchar(1),
    nombre varchar(30),
    superficie float,
    clave_cuota smallint,
    adeudo numeric,
    recaudadora varchar(50),
    descripcion varchar(30),
    meses varchar(26),
    datoslocal varchar(19),
    renta numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM sp_adeudos_locales_list(p_year, p_oficina, p_periodo);
END;
$$ LANGUAGE plpgsql;