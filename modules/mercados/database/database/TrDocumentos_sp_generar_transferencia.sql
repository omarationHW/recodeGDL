-- Stored Procedure: sp_generar_transferencia
-- Tipo: CRUD
-- Descripción: Genera el archivo de transferencia electrónica para los documentos seleccionados y retorna la URL de descarga.
-- Generado para formulario: TrDocumentos
-- Fecha: 2025-08-27 01:34:50

CREATE OR REPLACE FUNCTION sp_generar_transferencia(
    p_tipo_doc VARCHAR, -- 'C', 'P', 'O'
    p_fecha DATE,
    p_moneda INTEGER,
    p_cta_mayor INTEGER,
    p_cta_sub01 INTEGER,
    p_cta_sub02 INTEGER,
    p_documentos JSON
) RETURNS TABLE(archivo_url TEXT) AS $$
DECLARE
    cuenta_trans VARCHAR;
    doc RECORD;
    file_content TEXT := '';
    file_name TEXT;
    base_path TEXT := '/var/www/storage/transferencias/';
    full_path TEXT;
    impauxd NUMERIC;
    impaux INTEGER;
    impcad TEXT;
    dia TEXT;
    mes TEXT;
    anio TEXT;
    fechalim DATE;
    txt_line TEXT;
    txtbenef TEXT;
    banco_dest TEXT;
    plaza_num TEXT;
    sucursal TEXT;
    -- ... otros campos según tipo_doc
BEGIN
    -- Obtener cuenta de transferencia
    SELECT nombre INTO cuenta_trans FROM ta_cuentastrans
    WHERE moneda = p_moneda AND cta_mayor = p_cta_mayor AND cta_sub01 = p_cta_sub01 AND cta_sub02 = p_cta_sub02 AND cta_sub03 = p_cta_sub02
    LIMIT 1;
    IF cuenta_trans IS NULL THEN
        RAISE EXCEPTION 'No se encontró la cuenta de transferencia';
    END IF;
    -- Definir nombre de archivo
    file_name := CASE p_tipo_doc
        WHEN 'C' THEN 'TrCheques' || TO_CHAR(p_fecha, 'DD-MM') || '.txt'
        WHEN 'P' THEN 'BANC' || TO_CHAR(p_fecha, 'DD-MM') || '.txt'
        WHEN 'O' THEN 'OBAN' || TO_CHAR(p_fecha, 'DD-MM') || '.txt'
        ELSE 'Transferencia' || TO_CHAR(p_fecha, 'DD-MM') || '.txt'
    END;
    full_path := base_path || file_name;
    -- Procesar cada documento
    FOR doc IN SELECT * FROM json_to_recordset(p_documentos) AS (
        id_ctrl_cheque INTEGER,
        cheque INTEGER,
        fecha_elaboracion DATE,
        importe NUMERIC,
        ejercicio SMALLINT,
        procedencia SMALLINT,
        contrarecibo INTEGER,
        beneficiario VARCHAR,
        forma_pago VARCHAR,
        nombre VARCHAR,
        id_proveedor INTEGER
    ) LOOP
        IF p_tipo_doc = 'C' THEN
            -- Cheques
            txt_line := LPAD(TRIM(cuenta_trans), 16, ' ') ||
                        LPAD(doc.cheque::TEXT, 7, '0') ||
                        LPAD('', 13, ' ') ||
                        RPAD('PROVEEDOR O PRESTADOR DE SERVICIOS', 60, ' ') ||
                        LPAD((doc.importe * 100)::INTEGER::TEXT, 16, '0') ||
                        TO_CHAR(doc.fecha_elaboracion, 'DD/MM/YYYY');
            -- Fecha límite (3 meses después)
            fechalim := doc.fecha_elaboracion + INTERVAL '3 months';
            dia := TO_CHAR(fechalim, 'DD');
            mes := TO_CHAR(fechalim, 'MM');
            anio := TO_CHAR(fechalim, 'YYYY');
            txt_line := txt_line || dia || '/' || mes || '/' || anio;
        ELSIF p_tipo_doc = 'P' THEN
            -- Elec. Bco. Pagador
            SELECT cuenta INTO txtbenef FROM ta_proveedores WHERE id_proveedor = doc.id_proveedor;
            txt_line := LPAD(txtbenef, 18, '0') ||
                        LPAD(TRIM(cuenta_trans), 18, '0') ||
                        'MXP' ||
                        LPAD(doc.importe::TEXT, 16, '0') ||
                        LPAD(doc.cheque::TEXT, 6, '0') || ' - CONTRA-RECIBO: ' ||
                        LPAD(doc.contrarecibo::TEXT, 6, '0');
        ELSIF p_tipo_doc = 'O' THEN
            -- Elec. Otros Bancos
            SELECT cuenta, banco, plaza_num, sucursal INTO txtbenef, banco_dest, plaza_num, sucursal FROM ta_proveedores WHERE id_proveedor = doc.id_proveedor;
            txt_line := LPAD(txtbenef, 18, '0') ||
                        LPAD(TRIM(cuenta_trans), 18, '0') ||
                        LPAD(doc.id_ctrl_cheque::TEXT, 6, '0') ||
                        'MXP' ||
                        LPAD(doc.importe::TEXT, 16, '0') ||
                        RPAD(doc.beneficiario, 35, ' ') ||
                        LPAD(banco_dest, 3, '0') ||
                        LPAD(plaza_num, 4, '0') ||
                        LPAD(doc.cheque::TEXT, 6, '0') || ' - CONTRA-RECIBO: ' ||
                        LPAD(doc.contrarecibo::TEXT, 6, '0') ||
                        LPAD(sucursal, 4, '0');
        END IF;
        file_content := file_content || txt_line || E'\n';
    END LOOP;
    -- Guardar archivo
    PERFORM pg_catalog.pg_file_write(full_path, file_content, false);
    RETURN QUERY SELECT '/storage/transferencias/' || file_name;
END;
$$ LANGUAGE plpgsql;