-- Stored Procedure: sp_cuotasmdo_create
-- Tipo: CRUD
-- Descripción: Crea una nueva cuota de mercado
-- Generado para formulario: CuotasMdo
-- Fecha: 2025-08-26 23:34:39

CREATE OR REPLACE FUNCTION sp_cuotasmdo_create(
    p_axo INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR(10),
    p_clave_cuota INTEGER,
    p_importe_cuota NUMERIC(12,2),
    p_id_usuario INTEGER
) RETURNS TABLE (id_cuotas INTEGER) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO ta_11_cuo_locales(axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario)
    VALUES (p_axo, p_categoria, p_seccion, p_clave_cuota, p_importe_cuota, NOW(), p_id_usuario)
    RETURNING id_cuotas INTO new_id;
    RETURN QUERY SELECT new_id;
END;
$$ LANGUAGE plpgsql;