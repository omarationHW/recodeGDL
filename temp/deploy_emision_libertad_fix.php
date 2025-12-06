<?php
/**
 * DEPLOY: Stored Procedures EmisionLibertad (CORREGIDOS)
 * Despliega SPs en dos bases diferentes:
 * - padron_licencias: sp_get_recaudadoras, sp_get_mercados_by_recaudadora
 * - mercados: generar_emision_libertad, exportar_emision_libertad, get_emision_libertad_detalle
 */

// Conexión directa a PostgreSQL
$host = 'localhost';
$port = '5432';
$user = 'postgres';
$password = 'sistemas';

echo "========================================\n";
echo "DEPLOY: EmisionLibertad SPs (CORREGIDOS)\n";
echo "========================================\n\n";

// SPs para PADRON_LICENCIAS
$padron_sps = [
    [
        'name' => 'sp_get_recaudadoras',
        'sql' => "
DROP FUNCTION IF EXISTS sp_get_recaudadoras();
CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(id_rec INT, recaudadora TEXT) AS \$\$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora::TEXT FROM comun.ta_12_recaudadoras WHERE id_rec >= 1 ORDER BY id_rec;
END;
\$\$ LANGUAGE plpgsql;"
    ],
    [
        'name' => 'sp_get_mercados_by_recaudadora',
        'sql' => "
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(INT);
CREATE OR REPLACE FUNCTION sp_get_mercados_by_recaudadora(p_oficina INT)
RETURNS TABLE(num_mercado_nvo INT, descripcion TEXT) AS \$\$
BEGIN
  RETURN QUERY
    SELECT num_mercado_nvo, descripcion::TEXT
    FROM comun.ta_11_mercados
    WHERE oficina = p_oficina AND tipo_emision = 'D'
    ORDER BY num_mercado_nvo;
END;
\$\$ LANGUAGE plpgsql;"
    ]
];

// SPs para MERCADOS
$mercados_sps = [
    [
        'name' => 'generar_emision_libertad',
        'sql' => "
DROP FUNCTION IF EXISTS generar_emision_libertad(INT, JSON, INT, INT, INT);
CREATE OR REPLACE FUNCTION generar_emision_libertad(
  p_oficina INT,
  p_mercados JSON,
  p_axo INT,
  p_periodo INT,
  p_usuario_id INT
) RETURNS TABLE(
  id_local INT,
  nombre TEXT,
  descripcion TEXT,
  descripcion_local TEXT,
  oficina INT,
  num_mercado INT,
  categoria INT,
  seccion TEXT,
  local INT,
  letra_local TEXT,
  bloque TEXT,
  renta NUMERIC,
  descuento NUMERIC,
  adeudos NUMERIC,
  recargos NUMERIC,
  subtotal NUMERIC,
  multas NUMERIC,
  gastos NUMERIC,
  folios TEXT
) AS \$\$
DECLARE
  mercado_ids INT[];
  rec RECORD;
  meses TEXT;
  folios_req TEXT;
  total_adeudos NUMERIC;
  total_recargos NUMERIC;
  total_multas NUMERIC;
  total_gastos NUMERIC;
  v_subtotal NUMERIC;
  v_renta NUMERIC;
  v_descuento NUMERIC;
BEGIN
  SELECT ARRAY(SELECT json_array_elements_text(p_mercados)::INT) INTO mercado_ids;
  FOR rec IN
    SELECT
      a.*,
      b.descripcion as mercado_desc,
      c.importe_cuota,
      c.clave_cuota,
      c.seccion as cuo_seccion
    FROM comun.ta_11_locales a
    JOIN comun.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN comun.ta_11_cuo_locales c ON a.categoria = c.categoria
      AND a.seccion = c.seccion
      AND a.clave_cuota = c.clave_cuota
      AND c.axo = p_axo
    WHERE a.oficina = p_oficina
      AND a.num_mercado = ANY(mercado_ids)
      AND a.vigencia = 'A'
      AND a.bloqueo < 4
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque
  LOOP
    IF rec.seccion = 'PS' THEN
      IF rec.clave_cuota = 4 THEN
        v_renta := rec.superficie * rec.importe_cuota;
      ELSE
        v_renta := rec.importe_cuota * rec.superficie * 30;
      END IF;
    ELSE
      v_renta := rec.superficie * rec.importe_cuota;
    END IF;
    v_descuento := round(v_renta * 0.90, 2);
    SELECT COALESCE(SUM(importe),0), COALESCE(SUM(recargos),0)
    INTO total_adeudos, total_recargos
    FROM comun.ta_11_adeudo_local
    WHERE id_local = rec.id_local
      AND (axo < p_axo OR (axo = p_axo AND periodo < p_periodo));
    SELECT string_agg(folio::TEXT, ','), COALESCE(SUM(importe_multa),0), COALESCE(SUM(importe_gastos),0)
    INTO folios_req, total_multas, total_gastos
    FROM comun.ta_15_apremios
    WHERE modulo = 11 AND control_otr = rec.id_local AND vigencia = '1' AND clave_practicado = 'P';
    v_subtotal := total_adeudos + total_recargos;
    RETURN QUERY SELECT
      rec.id_local, rec.nombre::TEXT, rec.mercado_desc::TEXT, rec.descripcion_local::TEXT,
      rec.oficina, rec.num_mercado, rec.categoria, rec.seccion::TEXT, rec.local,
      rec.letra_local::TEXT, rec.bloque::TEXT, v_renta, v_descuento,
      total_adeudos, total_recargos, v_subtotal, total_multas, total_gastos, folios_req;
  END LOOP;
END;
\$\$ LANGUAGE plpgsql;"
    ],
    [
        'name' => 'exportar_emision_libertad',
        'sql' => "
DROP FUNCTION IF EXISTS exportar_emision_libertad(INT, JSON, INT, INT, INT);
CREATE OR REPLACE FUNCTION exportar_emision_libertad(
  p_oficina INT,
  p_mercados JSON,
  p_axo INT,
  p_periodo INT,
  p_usuario_id INT
) RETURNS TABLE(file_url TEXT) AS \$\$
DECLARE
  row RECORD;
  file_name TEXT;
  out_txt TEXT;
BEGIN
  file_name := 'RecibosMdo_' || p_oficina || '_' || p_axo || '-' || p_periodo || '.txt';
  out_txt := '';
  FOR row IN SELECT * FROM generar_emision_libertad(p_oficina, p_mercados, p_axo, p_periodo, p_usuario_id) LOOP
    out_txt := out_txt || row.id_local || '|' || COALESCE(row.nombre, '') || '|' ||
      COALESCE(row.descripcion, '') || '|' || row.renta || '|' || row.descuento || '|' ||
      row.adeudos || '|' || row.recargos || '|' || row.subtotal || '|' ||
      row.multas || '|' || row.gastos || '|' || COALESCE(row.folios, '') || E'\n';
  END LOOP;
  RETURN QUERY SELECT out_txt;
END;
\$\$ LANGUAGE plpgsql;"
    ],
    [
        'name' => 'get_emision_libertad_detalle',
        'sql' => "
DROP FUNCTION IF EXISTS get_emision_libertad_detalle(INT, JSON, INT, INT);
CREATE OR REPLACE FUNCTION get_emision_libertad_detalle(
  p_oficina INT,
  p_mercados JSON,
  p_axo INT,
  p_periodo INT
) RETURNS TABLE(
  id_local INT, nombre TEXT, descripcion TEXT, descripcion_local TEXT,
  oficina INT, num_mercado INT, categoria INT, seccion TEXT, local INT,
  letra_local TEXT, bloque TEXT, renta NUMERIC, descuento NUMERIC,
  adeudos NUMERIC, recargos NUMERIC, subtotal NUMERIC, multas NUMERIC,
  gastos NUMERIC, folios TEXT
) AS \$\$
BEGIN
  RETURN QUERY SELECT * FROM generar_emision_libertad(p_oficina, p_mercados, p_axo, p_periodo, 0);
END;
\$\$ LANGUAGE plpgsql;"
    ]
];

function deployToDatabase($dbname, $sps) {
    global $host, $port, $user, $password;

    try {
        $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
        $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

        echo "Base de datos: $dbname\n";
        echo str_repeat("-", 40) . "\n";

        $success = 0;
        $failed = 0;

        foreach ($sps as $sp) {
            try {
                $pdo->exec($sp['sql']);
                echo "   ✓ {$sp['name']}\n";
                $success++;
            } catch (PDOException $e) {
                echo "   ✗ {$sp['name']}: " . $e->getMessage() . "\n";
                $failed++;
            }
        }

        echo "\nResultado: $success exitosos, $failed fallidos\n\n";

        return $success;

    } catch (PDOException $e) {
        echo "ERROR al conectar a $dbname: " . $e->getMessage() . "\n\n";
        return 0;
    }
}

// Desplegar en padron_licencias
$success_padron = deployToDatabase('padron_licencias', $padron_sps);

// Desplegar en mercados
$success_mercados = deployToDatabase('mercados', $mercados_sps);

echo "========================================\n";
echo "RESUMEN FINAL\n";
echo "========================================\n";
echo "padron_licencias: $success_padron SPs desplegados\n";
echo "mercados: $success_mercados SPs desplegados\n";
echo "Total: " . ($success_padron + $success_mercados) . " SPs\n";

if (($success_padron + $success_mercados) === 5) {
    echo "\n✅ TODOS LOS SPs DESPLEGADOS CORRECTAMENTE\n";
} else {
    echo "\n⚠️ ALGUNOS SPs NO SE DESPLEGARON\n";
}
