-- Stored Procedure: sp_get_cuota
-- Tipo: Catalog
-- Descripción: Obtiene la cuota del local
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

DROP FUNCTION IF EXISTS sp_get_cuota(SMALLINT, SMALLINT, VARCHAR, SMALLINT);

CREATE OR REPLACE FUNCTION sp_get_cuota(p_axo SMALLINT, p_categoria SMALLINT, p_seccion CHAR(2), p_clave_cuota SMALLINT)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo SMALLINT,
    categoria SMALLINT,
    seccion CHAR(2),
    clave_cuota SMALLINT,
    importe_cuota NUMERIC(16,2),
    renta NUMERIC(16,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_cuotas, a.axo, a.categoria, a.seccion, a.clave_cuota, a.importe_cuota,
        a.importe_cuota AS renta
    FROM publico.ta_11_cuo_locales a
    WHERE a.axo = p_axo AND a.categoria = p_categoria AND a.seccion = p_seccion AND a.clave_cuota = p_clave_cuota;
END;
$$ LANGUAGE plpgsql;