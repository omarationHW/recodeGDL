-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsultaReg
-- Generado: 2025-08-27 13:40:42
-- Total SPs: 7
-- ============================================

-- SP 1/7: sp_consultareg_mercados
-- Tipo: Catalog
-- Descripción: Busca un registro de mercado por oficina, mercado, sección, local, letra y bloque.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultareg_mercados(
    p_oficina integer,
    p_num_mercado integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
) RETURNS TABLE (
    id_local integer,
    oficina integer,
    num_mercado integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    descripcion_local varchar,
    superficie float,
    giro integer,
    fecha_alta date,
    fecha_baja date,
    fecha_modificacion timestamp,
    vigencia varchar,
    id_usuario integer,
    clave_cuota integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND seccion = p_seccion
      AND local = p_local
      AND (CASE WHEN p_letra_local IS NULL OR p_letra_local = '' THEN letra_local IS NULL ELSE letra_local = p_letra_local END)
      AND (CASE WHEN p_bloque IS NULL OR p_bloque = '' THEN bloque IS NULL ELSE bloque = p_bloque END)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_consultareg_aseo
-- Tipo: Catalog
-- Descripción: Busca un registro de aseo por número de contrato y tipo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultareg_aseo(
    p_contrato integer,
    p_tipo varchar
) RETURNS TABLE (
    control_contrato integer,
    num_contrato integer,
    ctrol_aseo integer,
    id_rec smallint,
    num_empresa integer,
    ctrol_recolec integer,
    cantidad_recolec smallint,
    fecha_hora_alta timestamp,
    status_vigencia varchar,
    aso_mes_oblig timestamp,
    cve varchar,
    usuario integer,
    fecha_hora_baja timestamp,
    tipo_aseo varchar,
    descripcion varchar,
    cta_aplicacion integer,
    num_empresa_1 integer,
    ctrol_emp integer,
    descripcion_1 varchar,
    representante varchar,
    domicilio varchar,
    sector varchar,
    ctrol_zona integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.*, c.*, d.*
    FROM ta_16_contratos a
    JOIN ta_16_tipo_aseo c ON a.ctrol_aseo = c.ctrol_aseo
    JOIN ta_16_empresas d ON a.num_empresa = d.num_empresa
    WHERE a.num_contrato = p_contrato AND c.tipo_aseo = p_tipo
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_consultareg_publicos
-- Tipo: Catalog
-- Descripción: Busca un registro de estacionamiento público por número.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultareg_publicos(
    p_numesta integer
) RETURNS TABLE (
    id integer,
    pubcategoria_id integer,
    numesta integer,
    sector varchar,
    zona integer,
    subzona integer,
    numlicencia integer,
    axolicencias integer,
    cvecuenta integer,
    nombre varchar,
    calle varchar,
    numext varchar,
    telefono varchar,
    cupo integer,
    fecha_at date,
    fecha_inicial date,
    fecha_vencimiento date,
    rfc varchar,
    solicitud integer,
    control integer,
    movtos_no integer,
    movto_cve varchar,
    movto_usr integer,
    folio_baja integer,
    fecha_baja date
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM pubmain WHERE numesta = p_numesta LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_consultareg_exclusivos
-- Tipo: Catalog
-- Descripción: Busca un registro de estacionamiento exclusivo por número.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultareg_exclusivos(
    p_no_exclusivo integer
) RETURNS TABLE (
    id integer,
    ex_propietario_id integer,
    no_exclusivo integer,
    zona varchar,
    total_bateria float,
    total_cordon float,
    solicitud integer,
    control integer,
    folio_cancelacion integer,
    estatus varchar,
    factor float,
    fecha_in timestamp,
    fecha_at timestamp,
    id_clasificacion integer,
    vialidad varchar,
    fecha_inicial date,
    usuario integer,
    pc varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ex_contrato WHERE no_exclusivo = p_no_exclusivo LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_consultareg_infracciones
-- Tipo: Catalog
-- Descripción: Busca un registro de infracción por placa.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultareg_infracciones(
    p_placa varchar
) RETURNS TABLE (
    id integer,
    placa varchar,
    placaant varchar,
    claveveh varchar,
    nombre varchar,
    municipio varchar,
    marca varchar,
    modelo varchar,
    color varchar,
    serie varchar,
    pagados integer,
    vigentes integer,
    domicilio varchar,
    num_ext varchar,
    num_int1 varchar,
    num_int2 varchar,
    colonia varchar,
    entrecalles varchar,
    actualizado varchar,
    fecactualizado date
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_padron WHERE placa = p_placa LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp_consultareg_cementerios
-- Tipo: Catalog
-- Descripción: Busca un registro de cementerio por folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultareg_cementerios(
    p_folio integer
) RETURNS TABLE (
    control_rcm integer,
    cementerio varchar,
    clase smallint,
    clase_alfa varchar,
    seccion smallint,
    seccion_alfa varchar,
    linea smallint,
    linea_alfa varchar,
    fosa smallint,
    fosa_alfa varchar,
    axo_pagado integer,
    metros float,
    nombre varchar,
    domicilio varchar,
    exterior varchar,
    interior varchar,
    colonia varchar,
    observaciones varchar,
    usuario integer,
    fecha_mov date,
    tipo varchar,
    fecha_alta date,
    vigencia varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_13_datosrcm WHERE control_rcm = p_folio LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: sp_consultareg_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de requerimientos para un módulo y control dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultareg_detalle(
    p_modulo integer,
    p_contro integer
) RETURNS TABLE (
    id_control integer,
    zona smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado varchar,
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    clave_secuestro smallint,
    clave_remate varchar,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar,
    fecha_pago date,
    recaudadora smallint,
    caja varchar,
    operacion integer,
    importe_pago numeric,
    vigencia varchar,
    fecha_actualiz date,
    usuario integer,
    clave_mov varchar,
    hora_practicado timestamp,
    importe_actualizacion numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_15_apremios WHERE modulo = p_modulo AND control_otr = p_contro;
END;
$$ LANGUAGE plpgsql;

-- ============================================

