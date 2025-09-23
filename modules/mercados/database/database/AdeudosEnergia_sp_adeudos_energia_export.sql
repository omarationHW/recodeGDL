-- Stored Procedure: sp_adeudos_energia_export
-- Tipo: Report
-- Descripción: Exporta el listado de adeudos de energía eléctrica a Excel.
-- Generado para formulario: AdeudosEnergia
-- Fecha: 2025-08-26 19:34:16

CREATE OR REPLACE FUNCTION sp_adeudos_energia_export(p_axo INTEGER, p_oficina INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    cve_consumo VARCHAR(1),
    local_adicional VARCHAR(50),
    adeudo NUMERIC(12,2),
    id_energia INTEGER,
    meses TEXT,
    nombre VARCHAR(30),
    axo SMALLINT,
    cuota NUMERIC(12,2),
    local INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM sp_adeudos_energia_list(p_axo, p_oficina);
END;
$$ LANGUAGE plpgsql;