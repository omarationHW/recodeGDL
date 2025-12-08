<?php
/**
 * ============================================
 * DEPLOYMENT SCRIPT - ABC CATALOG PROCEDURES
 * Module: aseo_contratado
 * Database: padron_licencias at 192.168.6.146
 * Date: 2025-12-07
 * ============================================
 *
 * Este script despliega todos los stored procedures consolidados
 * para los componentes ABC del módulo aseo_contratado
 *
 * COMPONENTES A DESPLEGAR:
 * 1. ABC_Cves_Operacion - Claves de operación
 * 2. ABC_Empresas - Empresas
 * 3. ABC_Gastos - Gastos de ejecución
 * 4. ABC_Recargos - Recargos
 * 5. ABC_Recaudadoras - Recaudadoras
 * 6. ABC_Tipos_Aseo - Tipos de aseo
 * 7. ABC_Tipos_Emp - Tipos de empresa
 * 8. ABC_Und_Recolec - Unidades de recolección
 * 9. ABC_Zonas - Zonas
 */

// Configuración de base de datos
$host = '192.168.6.146';
$db = 'padron_licencias';
$user = 'refact';
$pass = 'FF)-BQk2';
$schema = 'public';

// Directorio base
$baseDir = __DIR__ . '/database';

// Componentes a desplegar
$components = [
    'ABC_Cves_Operacion' => [
        'file' => 'ABC_Cves_Operacion_all_procedures.sql',
        'description' => 'Claves de Operación',
        'table' => 'ta_16_operacion'
    ],
    'ABC_Empresas' => [
        'file' => 'ABC_Empresas_all_procedures.sql',
        'description' => 'Empresas',
        'table' => 'ta_16_empresas'
    ],
    'ABC_Gastos' => [
        'file' => 'ABC_Gastos_all_procedures.sql',
        'description' => 'Gastos de Ejecución',
        'table' => 'ta_16_gastos',
        'fix_procedures' => true // Necesita corrección PROCEDURE -> FUNCTION
    ],
    'ABC_Recargos' => [
        'file' => 'ABC_Recargos_all_procedures.sql',
        'description' => 'Recargos',
        'table' => 'ta_16_recargos'
    ],
    'ABC_Recaudadoras' => [
        'file' => 'ABC_Recaudadoras_all_procedures.sql',
        'description' => 'Recaudadoras',
        'table' => 'ta_16_recaudadoras'
    ],
    'ABC_Tipos_Aseo' => [
        'file' => 'ABC_Tipos_Aseo_all_procedures.sql',
        'description' => 'Tipos de Aseo',
        'table' => 'ta_16_tipo_aseo'
    ],
    'ABC_Tipos_Emp' => [
        'file' => 'ABC_Tipos_Emp_all_procedures.sql',
        'description' => 'Tipos de Empresa',
        'table' => 'ta_16_tipos_emp'
    ],
    'ABC_Und_Recolec' => [
        'file' => 'ABC_Und_Recolec_all_procedures.sql',
        'description' => 'Unidades de Recolección',
        'table' => 'ta_16_unidades'
    ],
    'ABC_Zonas' => [
        'file' => 'ABC_Zonas_all_procedures.sql',
        'description' => 'Zonas',
        'table' => 'ta_16_zonas'
    ]
];

// Conectar a la base de datos
echo "===============================================\n";
echo "DEPLOYMENT - ABC CATALOG STORED PROCEDURES\n";
echo "Module: aseo_contratado\n";
echo "Database: {$db} @ {$host}\n";
echo "===============================================\n\n";

$connString = "host={$host} dbname={$db} user={$user} password={$pass}";
$conn = @pg_connect($connString);

if (!$conn) {
    die("ERROR: No se pudo conectar a la base de datos.\n" . pg_last_error() . "\n");
}

echo "✓ Conexión establecida exitosamente\n\n";

// Estadísticas
$totalComponents = count($components);
$successCount = 0;
$errorCount = 0;
$deploymentLog = [];

// Desplegar cada componente
foreach ($components as $componentName => $config) {
    echo "-----------------------------------------------\n";
    echo "Procesando: {$componentName}\n";
    echo "Descripción: {$config['description']}\n";
    echo "Tabla: {$config['table']}\n";

    $filePath = $baseDir . '/' . $config['file'];

    // Verificar que el archivo existe
    if (!file_exists($filePath)) {
        echo "✗ ERROR: Archivo no encontrado: {$filePath}\n";
        $errorCount++;
        $deploymentLog[] = [
            'component' => $componentName,
            'status' => 'ERROR',
            'message' => 'Archivo no encontrado'
        ];
        continue;
    }

    // Leer el contenido del archivo
    $sql = file_get_contents($filePath);

    if (empty($sql)) {
        echo "✗ ERROR: Archivo vacío\n";
        $errorCount++;
        $deploymentLog[] = [
            'component' => $componentName,
            'status' => 'ERROR',
            'message' => 'Archivo vacío'
        ];
        continue;
    }

    // Fix para ABC_Gastos: reemplazar PROCEDURE por FUNCTION
    if (isset($config['fix_procedures']) && $config['fix_procedures']) {
        echo "→ Aplicando fix: PROCEDURE -> FUNCTION\n";

        // Reemplazar el contenido completo con la versión corregida
        $sql = <<<'EOFGASTOS'
-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ABC_Gastos
-- Base de datos: aseo_contratado
-- Tabla: ta_16_gastos
-- Actualizado: 2025-12-07
-- Total SPs: 5
-- ============================================

DROP FUNCTION IF EXISTS public.sp_gastos_list();
CREATE OR REPLACE FUNCTION public.sp_gastos_list()
RETURNS TABLE (
    ctrol_gasto INTEGER,
    sdzmg NUMERIC,
    porc1_req NUMERIC,
    porc2_embargo NUMERIC,
    porc3_secuestro NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT g.ctrol_gasto, g.sdzmg, g.porc1_req, g.porc2_embargo, g.porc3_secuestro
    FROM ta_16_gastos g
    ORDER BY g.ctrol_gasto;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION public.sp_gastos_list() TO PUBLIC;

DROP FUNCTION IF EXISTS public.sp_gastos_get();
CREATE OR REPLACE FUNCTION public.sp_gastos_get()
RETURNS TABLE (
    ctrol_gasto INTEGER,
    sdzmg NUMERIC,
    porc1_req NUMERIC,
    porc2_embargo NUMERIC,
    porc3_secuestro NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT g.ctrol_gasto, g.sdzmg, g.porc1_req, g.porc2_embargo, g.porc3_secuestro
    FROM ta_16_gastos g
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION public.sp_gastos_get() TO PUBLIC;

DROP FUNCTION IF EXISTS public.sp_gastos_insert(NUMERIC, NUMERIC, NUMERIC, NUMERIC);
CREATE OR REPLACE FUNCTION public.sp_gastos_insert(
    p_sdzmg NUMERIC,
    p_porc1_req NUMERIC,
    p_porc2_embargo NUMERIC,
    p_porc3_secuestro NUMERIC
)
RETURNS TABLE (success BOOLEAN, message TEXT, ctrol_gasto INTEGER) AS $$
DECLARE
    v_count INTEGER;
    v_new_id INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_16_gastos;
    IF v_count > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe un registro de gastos. Use UPDATE para modificarlo.'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;
    INSERT INTO ta_16_gastos (sdzmg, porc1_req, porc2_embargo, porc3_secuestro)
    VALUES (p_sdzmg, p_porc1_req, p_porc2_embargo, p_porc3_secuestro)
    RETURNING ta_16_gastos.ctrol_gasto INTO v_new_id;
    RETURN QUERY SELECT true, 'Registro de gastos creado correctamente'::TEXT, v_new_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION public.sp_gastos_insert(NUMERIC, NUMERIC, NUMERIC, NUMERIC) TO PUBLIC;

DROP FUNCTION IF EXISTS public.sp_gastos_update(INTEGER, NUMERIC, NUMERIC, NUMERIC, NUMERIC);
CREATE OR REPLACE FUNCTION public.sp_gastos_update(
    p_ctrol_gasto INTEGER,
    p_sdzmg NUMERIC,
    p_porc1_req NUMERIC,
    p_porc2_embargo NUMERIC,
    p_porc3_secuestro NUMERIC
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_id_to_update INTEGER;
BEGIN
    IF p_ctrol_gasto IS NULL THEN
        SELECT g.ctrol_gasto INTO v_id_to_update FROM ta_16_gastos g LIMIT 1;
    ELSE
        v_id_to_update := p_ctrol_gasto;
    END IF;
    IF v_id_to_update IS NULL THEN
        RETURN QUERY SELECT false, 'No existe ningún registro de gastos para actualizar'::TEXT;
        RETURN;
    END IF;
    UPDATE ta_16_gastos g
    SET sdzmg = p_sdzmg,
        porc1_req = p_porc1_req,
        porc2_embargo = p_porc2_embargo,
        porc3_secuestro = p_porc3_secuestro
    WHERE g.ctrol_gasto = v_id_to_update;
    IF FOUND THEN
        RETURN QUERY SELECT true, 'Registro de gastos actualizado correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No se encontró el registro de gastos'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION public.sp_gastos_update(INTEGER, NUMERIC, NUMERIC, NUMERIC, NUMERIC) TO PUBLIC;

DROP FUNCTION IF EXISTS public.sp_gastos_delete_all();
CREATE OR REPLACE FUNCTION public.sp_gastos_delete_all()
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_16_gastos;
    DELETE FROM ta_16_gastos;
    RETURN QUERY SELECT true, ('Se eliminaron ' || v_count || ' registro(s) de gastos')::TEXT;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION public.sp_gastos_delete_all() TO PUBLIC;
EOFGASTOS;
    }

    // Ejecutar el SQL
    echo "→ Ejecutando script SQL...\n";

    // Iniciar transacción
    pg_query($conn, 'BEGIN');

    $result = @pg_query($conn, $sql);

    if ($result === false) {
        $error = pg_last_error($conn);
        echo "✗ ERROR al ejecutar SQL:\n";
        echo "  {$error}\n";
        pg_query($conn, 'ROLLBACK');
        $errorCount++;
        $deploymentLog[] = [
            'component' => $componentName,
            'status' => 'ERROR',
            'message' => $error
        ];
    } else {
        pg_query($conn, 'COMMIT');
        echo "✓ Stored procedures desplegados exitosamente\n";
        $successCount++;
        $deploymentLog[] = [
            'component' => $componentName,
            'status' => 'SUCCESS',
            'message' => 'Desplegado correctamente'
        ];
    }

    echo "\n";
}

// Cerrar conexión
pg_close($conn);

// Resumen final
echo "===============================================\n";
echo "RESUMEN DEL DEPLOYMENT\n";
echo "===============================================\n";
echo "Total de componentes: {$totalComponents}\n";
echo "Exitosos: {$successCount}\n";
echo "Con errores: {$errorCount}\n";
echo "\n";

// Detalle del log
echo "DETALLE:\n";
echo "-----------------------------------------------\n";
foreach ($deploymentLog as $entry) {
    $statusIcon = $entry['status'] === 'SUCCESS' ? '✓' : '✗';
    echo "{$statusIcon} {$entry['component']}: {$entry['message']}\n";
}

echo "\n===============================================\n";

if ($errorCount === 0) {
    echo "✓ DEPLOYMENT COMPLETADO EXITOSAMENTE\n";
    exit(0);
} else {
    echo "✗ DEPLOYMENT COMPLETADO CON ERRORES\n";
    exit(1);
}
