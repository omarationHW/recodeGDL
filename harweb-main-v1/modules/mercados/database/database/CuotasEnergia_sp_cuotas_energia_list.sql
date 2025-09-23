-- Stored Procedure: sp_cuotas_energia_list
-- Tipo: Catalog
-- Descripción: Lista todas las cuotas de energía eléctrica con usuario.
-- Generado para formulario: CuotasEnergia
-- Fecha: 2025-08-26 23:31:39

CREATE OR REPLACE FUNCTION sp_cuotas_energia_list()
RETURNS TABLE (
    id_kilowhatts INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC(18,6),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_kilowhatts, a.axo, a.periodo, a.importe, a.fecha_alta, a.id_usuario, b.usuario
    FROM ta_11_kilowhatts a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    ORDER BY a.axo DESC, a.periodo DESC;
END;
$$ LANGUAGE plpgsql;