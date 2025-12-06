-- Stored Procedure: sp_cuotas_energia_get
-- Tipo: Catalog
-- Descripción: Obtiene una cuota de energía eléctrica por ID.
-- Generado para formulario: CuotasEnergia
-- Fecha: 2025-08-26 23:31:39

CREATE OR REPLACE FUNCTION sp_cuotas_energia_get(
    p_id_kilowhatts INTEGER
) RETURNS TABLE (
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
    FROM public.ta_11_kilowhatts a
    LEFT JOIN public.usuarios b ON a.id_usuario = b.id
    WHERE a.id_kilowhatts = p_id_kilowhatts;
END;
$$ LANGUAGE plpgsql;