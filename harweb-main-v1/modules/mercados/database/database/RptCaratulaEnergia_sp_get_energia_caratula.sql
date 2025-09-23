-- Stored Procedure: sp_get_energia_caratula
-- Tipo: Report
-- Descripción: Obtiene la carátula de energía para un local
-- Generado para formulario: RptCaratulaEnergia
-- Fecha: 2025-08-27 00:46:24

CREATE OR REPLACE FUNCTION sp_get_energia_caratula(p_id_local INTEGER)
RETURNS TABLE (
    id_energia INTEGER,
    id_local INTEGER,
    cve_consumo VARCHAR,
    local_adicional VARCHAR,
    cantidad NUMERIC,
    vigencia VARCHAR,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local SMALLINT,
    letra_local VARCHAR,
    bloque VARCHAR,
    nombre VARCHAR,
    descripcion VARCHAR,
    usuario VARCHAR,
    vigdescripcion VARCHAR,
    consumodescr VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id_energia,
        e.id_local,
        e.cve_consumo,
        e.local_adicional,
        e.cantidad,
        e.vigencia,
        e.fecha_alta,
        e.fecha_baja,
        e.fecha_modificacion,
        e.id_usuario,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre,
        m.descripcion,
        u.usuario,
        CASE e.vigencia
            WHEN 'B' THEN 'BAJA'
            WHEN 'E' THEN 'VIGENTE / PARA EMISION'
            ELSE 'VIGENTE'
        END AS vigdescripcion,
        CASE e.cve_consumo
            WHEN 'F' THEN 'Precio Fijo / Servicio Normal'
            WHEN 'K' THEN 'Precio Kilowhatts / Servicio Medido'
            ELSE ''
        END AS consumodescr
    FROM ta_11_energia e
    JOIN ta_11_locales l ON l.id_local = e.id_local
    JOIN ta_11_mercados m ON m.oficina = l.oficina AND m.num_mercado_nvo = l.num_mercado
    JOIN ta_12_passwords u ON u.id_usuario = e.id_usuario
    WHERE e.id_local = p_id_local
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;