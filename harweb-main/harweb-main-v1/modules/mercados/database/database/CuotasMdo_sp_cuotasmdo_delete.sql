-- Stored Procedure: sp_cuotasmdo_delete
-- Tipo: CRUD
-- Descripción: Elimina una cuota de mercado por ID
-- Generado para formulario: CuotasMdo
-- Fecha: 2025-08-26 23:34:39

CREATE OR REPLACE FUNCTION sp_cuotasmdo_delete(p_id_cuotas INTEGER)
RETURNS VOID AS $$
BEGIN
    DELETE FROM ta_11_cuo_locales WHERE id_cuotas = p_id_cuotas;
END;
$$ LANGUAGE plpgsql;