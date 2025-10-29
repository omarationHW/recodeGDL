-- Stored Procedure: sp_get_documentos
-- Tipo: Report
-- Descripción: Obtiene los documentos (cheques/transferencias) filtrados por fecha, cuenta y tipo de documento.
-- Generado para formulario: TrDocumentos
-- Fecha: 2025-08-27 01:34:50

CREATE OR REPLACE FUNCTION sp_get_documentos(
    p_fecha_elaboracion DATE,
    p_moneda INTEGER,
    p_cta_mayor INTEGER,
    p_cta_sub01 INTEGER,
    p_cta_sub02 INTEGER,
    p_cta_sub03 INTEGER,
    p_forma_pago VARCHAR,
    p_banco INTEGER DEFAULT NULL
)
RETURNS TABLE (
    id_ctrl_cheque INTEGER,
    cheque INTEGER,
    fecha_elaboracion DATE,
    importe NUMERIC,
    ejercicio SMALLINT,
    procedencia SMALLINT,
    contrarecibo INTEGER,
    fecha_firma DATE,
    fecha_pago DATE,
    fecha_cancelacion DATE,
    abono_cuenta VARCHAR,
    codigo_extra VARCHAR,
    beneficiario VARCHAR,
    forma_pago VARCHAR,
    nombre VARCHAR,
    moneda SMALLINT,
    cta_mayor SMALLINT,
    cta_sub01 SMALLINT,
    cta_sub02 SMALLINT,
    cta_sub03 INTEGER,
    id_proveedor INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_ctrl_cheque, a.cheque, a.fecha_elaboracion, a.importe, a.ejercicio, a.procedencia, a.contrarecibo,
           a.fecha_firma, a.fecha_pago, a.fecha_cancelacion, a.abono_cuenta, a.codigo_extra, a.beneficiario, a.forma_pago,
           a.nombre, a.moneda, a.cta_mayor, a.cta_sub01, a.cta_sub02, a.cta_sub03, a.id_proveedor
    FROM ta_cheques a
    JOIN ta_cuentas b ON a.moneda = b.moneda AND a.cta_mayor = b.cta_mayor AND a.cta_sub01 = b.cta_sub01 AND a.cta_sub02 = b.cta_sub02 AND a.cta_sub03 = b.cta_sub03
    JOIN ta_proveedores p ON a.id_proveedor = p.id_proveedor
    WHERE a.fecha_elaboracion = p_fecha_elaboracion
      AND a.fecha_cancelacion IS NULL
      AND a.cheque > 0
      AND a.moneda = p_moneda
      AND a.cta_mayor = p_cta_mayor
      AND a.cta_sub01 = p_cta_sub01
      AND a.cta_sub02 = p_cta_sub02
      AND a.cta_sub03 = p_cta_sub03
      AND (
        (p_forma_pago = 'C' AND a.forma_pago = 'C') OR
        (p_forma_pago = 'P' AND a.forma_pago = 'E' AND p.banco = p_banco) OR
        (p_forma_pago = 'O' AND a.forma_pago = 'E' AND p.banco > 0 AND p.banco <> p_banco)
      )
    ORDER BY a.cheque;
END;
$$ LANGUAGE plpgsql;