-- Stored Procedure: spd_proveedor_abc
-- Tipo: CRUD
-- Descripción: Alta, modificación y baja de proveedores
-- Generado para formulario: DM_Crbos
-- Fecha: 2025-08-27 13:33:33

-- PostgreSQL stored procedure for CRUD on proveedores
CREATE OR REPLACE FUNCTION spd_proveedor_abc(
    p_idproveedor INTEGER,
    p_denominacion TEXT,
    p_origen VARCHAR(1),
    p_domicilio TEXT,
    p_colonia TEXT,
    p_cod_postal VARCHAR(6),
    p_ciudad TEXT,
    p_tel01 TEXT,
    p_tel02 TEXT,
    p_fax TEXT,
    p_radio TEXT,
    p_rfc VARCHAR(15),
    p_notas TEXT,
    p_fechaingreso DATE,
    p_fechatermino DATE,
    p_parametro SMALLINT,
    p_cuenta TEXT,
    p_banco SMALLINT,
    p_plaza_nom TEXT,
    p_plaza_num SMALLINT
) RETURNS TABLE(result TEXT) AS $$
BEGIN
    IF p_parametro = 1 THEN -- Insert
        INSERT INTO ta_proveedores (
            id_proveedor, denominacion, origen, domicilio_fiscal, colonia, codigo_postal, ciudad, telefono_01, telefono_02, fax, radio_clave, reg_fed_causante, notas, fecha_ingreso, fecha_termino, cuenta, banco, plaza_nom, plaza_num
        ) VALUES (
            p_idproveedor, p_denominacion, p_origen, p_domicilio, p_colonia, p_cod_postal, p_ciudad, p_tel01, p_tel02, p_fax, p_radio, p_rfc, p_notas, p_fechaingreso, p_fechatermino, p_cuenta, p_banco, p_plaza_nom, p_plaza_num
        );
        RETURN QUERY SELECT 'inserted'::TEXT;
    ELSIF p_parametro = 2 THEN -- Update
        UPDATE ta_proveedores SET
            denominacion = p_denominacion,
            origen = p_origen,
            domicilio_fiscal = p_domicilio,
            colonia = p_colonia,
            codigo_postal = p_cod_postal,
            ciudad = p_ciudad,
            telefono_01 = p_tel01,
            telefono_02 = p_tel02,
            fax = p_fax,
            radio_clave = p_radio,
            reg_fed_causante = p_rfc,
            notas = p_notas,
            fecha_ingreso = p_fechaingreso,
            fecha_termino = p_fechatermino,
            cuenta = p_cuenta,
            banco = p_banco,
            plaza_nom = p_plaza_nom,
            plaza_num = p_plaza_num
        WHERE id_proveedor = p_idproveedor;
        RETURN QUERY SELECT 'updated'::TEXT;
    ELSIF p_parametro = 3 THEN -- Delete
        DELETE FROM ta_proveedores WHERE id_proveedor = p_idproveedor;
        RETURN QUERY SELECT 'deleted'::TEXT;
    ELSE
        RETURN QUERY SELECT 'no_action'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;