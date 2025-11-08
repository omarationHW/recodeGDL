-- Stored Procedure: sp_cuotasmdo_update
-- Tipo: CRUD
-- Descripción: Actualiza una cuota de mercado existente
-- Generado para formulario: CuotasMdo
-- Fecha: 2025-08-26 23:34:39

CREATE OR REPLACE FUNCTION sp_cuotasmdo_update(
    p_id_cuotas INTEGER,
    p_axo INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR(10),
    p_clave_cuota INTEGER,
    p_importe_cuota NUMERIC(12,2),
    p_id_usuario INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_11_cuo_locales
    SET axo = p_axo,
        categoria = p_categoria,
        seccion = p_seccion,
        clave_cuota = p_clave_cuota,
        importe_cuota = p_importe_cuota,
        fecha_alta = NOW(),
        id_usuario = p_id_usuario
    WHERE id_cuotas = p_id_cuotas;
END;
$$ LANGUAGE plpgsql;