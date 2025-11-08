-- Stored Procedure: sp_adeudos_locales_reporte
-- Tipo: Report
-- Descripción: Devuelve los datos para el reporte PDF de adeudos locales.
-- Generado para formulario: AdeudosLocales
-- Fecha: 2025-08-26 19:35:38

CREATE OR REPLACE FUNCTION sp_adeudos_locales_reporte(p_axo INTEGER, p_oficina INTEGER, p_periodo INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR(30),
    superficie NUMERIC(10,2),
    clave_cuota SMALLINT,
    adeudo NUMERIC(14,2),
    recaudadora VARCHAR(50),
    descripcion VARCHAR(30),
    meses TEXT,
    local INTEGER,
    RentaCalc NUMERIC(14,2)
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM sp_adeudos_locales_listar(p_axo, p_oficina, p_periodo);
END;
$$ LANGUAGE plpgsql;