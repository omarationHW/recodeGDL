<?php
/**
 * Verificar estructura de ta_11_fecha_desc y crear SPs
 * para Mantenimiento de Fechas de Descuento
 */

// Configuración de conexión
$config = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'dbname' => 'mercados',
    'user' => 'refact',
    'password' => 'FF)-BQk2'
];

// Función para conectar
function conectar($config) {
    $connStr = sprintf(
        "host=%s port=%s dbname=%s user=%s password=%s",
        $config['host'],
        $config['port'],
        $config['dbname'],
        $config['user'],
        $config['password']
    );

    $conn = pg_connect($connStr);

    if (!$conn) {
        die("❌ Error de conexión a PostgreSQL\n");
    }

    return $conn;
}

// Función para ejecutar query
function ejecutarQuery($conn, $sql) {
    $result = pg_query($conn, $sql);
    if (!$result) {
        echo "❌ Error en query: " . pg_last_error($conn) . "\n";
        echo "SQL: " . substr($sql, 0, 200) . "...\n\n";
        return false;
    }
    return $result;
}

echo "╔════════════════════════════════════════════════════════════════════════════╗\n";
echo "║       VERIFICACIÓN Y CREACIÓN DE SPs - FECHAS DE DESCUENTO                ║\n";
echo "╚════════════════════════════════════════════════════════════════════════════╝\n\n";

$conn = conectar($config);

echo "✅ Conexión exitosa a PostgreSQL\n\n";

// ============================================================================
// PASO 1: Buscar la tabla ta_11_fecha_desc
// ============================================================================

echo "═══════════════════════════════════════════════════════════════════════════\n";
echo "PASO 1: BÚSQUEDA DE TABLA ta_11_fecha_desc\n";
echo "═══════════════════════════════════════════════════════════════════════════\n\n";

$sql = "
    SELECT
        table_schema,
        table_name,
        table_type
    FROM information_schema.tables
    WHERE table_name = 'ta_11_fecha_desc'
    AND table_schema NOT IN ('pg_catalog', 'information_schema')
    ORDER BY table_schema
";

$result = ejecutarQuery($conn, $sql);
$tables = [];

while ($row = pg_fetch_assoc($result)) {
    $tables[] = $row;
    echo "📋 Tabla encontrada: {$row['table_schema']}.{$row['table_name']} ({$row['table_type']})\n";
}

if (empty($tables)) {
    die("❌ No se encontró la tabla ta_11_fecha_desc\n");
}

echo "\n";

// ============================================================================
// PASO 2: Verificar estructura de cada tabla encontrada
// ============================================================================

echo "═══════════════════════════════════════════════════════════════════════════\n";
echo "PASO 2: VERIFICACIÓN DE ESTRUCTURA\n";
echo "═══════════════════════════════════════════════════════════════════════════\n\n";

$tablaCorrecta = null;

foreach ($tables as $table) {
    $schema = $table['table_schema'];
    $tableName = $table['table_name'];

    echo "📊 Estructura de {$schema}.{$tableName}:\n";
    echo str_repeat("-", 79) . "\n";

    $sql = "
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_schema = '$schema'
        AND table_name = '$tableName'
        ORDER BY ordinal_position
    ";

    $result = ejecutarQuery($conn, $sql);
    $columns = [];

    while ($col = pg_fetch_assoc($result)) {
        $columns[] = $col;
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
        $default = $col['column_default'] ? " DEFAULT {$col['column_default']}" : '';

        printf("  %-25s %-30s %-10s%s\n",
            $col['column_name'],
            $type,
            $nullable,
            $default
        );
    }

    // Contar registros
    $sql = "SELECT COUNT(*) as total FROM {$schema}.{$tableName}";
    $result = ejecutarQuery($conn, $sql);
    $count = pg_fetch_assoc($result);

    echo "\n📊 Total de registros: {$count['total']}\n";

    // Mostrar datos si hay pocos registros
    if ($count['total'] > 0 && $count['total'] <= 15) {
        echo "\n📄 Datos existentes:\n";
        $sql = "SELECT * FROM {$schema}.{$tableName} ORDER BY mes";
        $result = ejecutarQuery($conn, $sql);

        $rows = [];
        while ($row = pg_fetch_assoc($result)) {
            $rows[] = $row;
        }

        if (!empty($rows)) {
            // Headers
            $headers = array_keys($rows[0]);
            echo "  " . implode(" | ", $headers) . "\n";
            echo "  " . str_repeat("-", 100) . "\n";

            foreach ($rows as $row) {
                $values = array_map(function($v) {
                    return $v === null ? 'NULL' : $v;
                }, $row);
                echo "  " . implode(" | ", $values) . "\n";
            }
        }
    }

    // Si tiene datos, es la tabla correcta
    if ($count['total'] > 0) {
        $tablaCorrecta = ['schema' => $schema, 'table' => $tableName];
        echo "\n✅ Esta tabla tiene datos - se usará para los SPs\n";
    }

    echo "\n";
}

if (!$tablaCorrecta) {
    // Usar la primera tabla encontrada
    $tablaCorrecta = ['schema' => $tables[0]['table_schema'], 'table' => $tables[0]['table_name']];
    echo "⚠️  Ninguna tabla tiene datos. Se usará: {$tablaCorrecta['schema']}.{$tablaCorrecta['table']}\n\n";
}

$schemaTabla = $tablaCorrecta['schema'];
$nombreTabla = $tablaCorrecta['table'];

// ============================================================================
// PASO 3: Verificar tabla de usuarios
// ============================================================================

echo "═══════════════════════════════════════════════════════════════════════════\n";
echo "PASO 3: VERIFICACIÓN DE TABLA DE USUARIOS\n";
echo "═══════════════════════════════════════════════════════════════════════════\n\n";

// Buscar tabla usuarios
$sql = "
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name = 'usuarios'
    AND table_schema NOT IN ('pg_catalog', 'information_schema')
    ORDER BY table_schema
";

$result = ejecutarQuery($conn, $sql);
$usuariosTablas = [];

while ($row = pg_fetch_assoc($result)) {
    $usuariosTablas[] = $row;
    echo "📋 Tabla usuarios encontrada: {$row['table_schema']}.{$row['table_name']}\n";
}

$tablaUsuarios = null;

// Verificar cuál tiene la columna 'usuario'
foreach ($usuariosTablas as $tbl) {
    $sql = "
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = '{$tbl['table_schema']}'
        AND table_name = '{$tbl['table_name']}'
        AND column_name = 'usuario'
    ";

    $result = ejecutarQuery($conn, $sql);
    if (pg_num_rows($result) > 0) {
        $tablaUsuarios = $tbl;
        echo "✅ Tabla con columna 'usuario': {$tbl['table_schema']}.{$tbl['table_name']}\n";
        break;
    }
}

if (!$tablaUsuarios) {
    echo "⚠️  No se encontró tabla usuarios con columna 'usuario'. Se usará public.usuarios\n";
    $tablaUsuarios = ['table_schema' => 'public', 'table_name' => 'usuarios'];
}

$schemaUsuarios = $tablaUsuarios['table_schema'];
$nombreUsuarios = $tablaUsuarios['table_name'];

echo "\n";

// ============================================================================
// PASO 4: Crear/Actualizar Stored Procedures
// ============================================================================

echo "═══════════════════════════════════════════════════════════════════════════\n";
echo "PASO 4: CREACIÓN DE STORED PROCEDURES\n";
echo "═══════════════════════════════════════════════════════════════════════════\n\n";

// SP 1: fechas_descuento_get_all (alias: sp_fechadescuento_list)
echo "📝 Creando SP 1/2: fechas_descuento_get_all()...\n";

$sp1 = "
-- ============================================================================
-- SP: fechas_descuento_get_all (alias: sp_fechadescuento_list)
-- Descripción: Lista todas las fechas de descuento (12 meses)
-- Retorna: mes, fecha_descuento, fecha_recargos, fecha_alta, id_usuario, usuario
-- ============================================================================

DROP FUNCTION IF EXISTS fechas_descuento_get_all();
DROP FUNCTION IF EXISTS sp_fechadescuento_list();

CREATE OR REPLACE FUNCTION fechas_descuento_get_all()
RETURNS TABLE (
    mes SMALLINT,
    fecha_descuento DATE,
    fecha_recargos DATE,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        a.mes,
        a.fecha_descuento,
        a.fecha_recargos,
        a.fecha_alta,
        a.id_usuario,
        COALESCE(b.usuario, 'SISTEMA')::VARCHAR(50) as usuario
    FROM {$schemaTabla}.{$nombreTabla} a
    LEFT JOIN {$schemaUsuarios}.{$nombreUsuarios} b ON a.id_usuario = b.id
    ORDER BY a.mes ASC;
END;
\$\$ LANGUAGE plpgsql;

-- Crear alias para compatibilidad
CREATE OR REPLACE FUNCTION sp_fechadescuento_list()
RETURNS TABLE (
    mes SMALLINT,
    fecha_descuento DATE,
    fecha_recargos DATE,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS \$\$
BEGIN
    RETURN QUERY SELECT * FROM fechas_descuento_get_all();
END;
\$\$ LANGUAGE plpgsql;
";

$result = ejecutarQuery($conn, $sp1);
if ($result) {
    echo "✅ SP fechas_descuento_get_all() creado exitosamente\n";
    echo "✅ Alias sp_fechadescuento_list() creado exitosamente\n\n";
} else {
    echo "❌ Error al crear SP fechas_descuento_get_all()\n\n";
}

// SP 2: fechas_descuento_update
echo "📝 Creando SP 2/2: fechas_descuento_update()...\n";

$sp2 = "
-- ============================================================================
-- SP: fechas_descuento_update (alias: sp_fechadescuento_update)
-- Descripción: Actualiza o inserta fechas de descuento para un mes
-- Parámetros:
--   p_mes: Número del mes (1-12)
--   p_fecha_descuento: Nueva fecha de descuento
--   p_fecha_recargos: Nueva fecha de recargos
--   p_id_usuario: ID del usuario que realiza el cambio
-- Retorna: success (boolean), message (text)
-- ============================================================================

DROP FUNCTION IF EXISTS fechas_descuento_update(SMALLINT, DATE, DATE, INTEGER);
DROP FUNCTION IF EXISTS sp_fechadescuento_update(SMALLINT, DATE, DATE, INTEGER);

CREATE OR REPLACE FUNCTION fechas_descuento_update(
    p_mes SMALLINT,
    p_fecha_descuento DATE,
    p_fecha_recargos DATE,
    p_id_usuario INTEGER
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS \$\$
DECLARE
    v_count INTEGER;
BEGIN
    -- Validar mes
    IF p_mes < 1 OR p_mes > 12 THEN
        RETURN QUERY SELECT false::BOOLEAN, 'El mes debe estar entre 1 y 12'::TEXT;
        RETURN;
    END IF;

    -- Verificar si existe el mes
    SELECT COUNT(*) INTO v_count
    FROM {$schemaTabla}.{$nombreTabla}
    WHERE mes = p_mes;

    IF v_count = 0 THEN
        -- Insertar nuevo registro
        INSERT INTO {$schemaTabla}.{$nombreTabla} (
            mes,
            fecha_descuento,
            fecha_recargos,
            fecha_alta,
            id_usuario
        ) VALUES (
            p_mes,
            p_fecha_descuento,
            p_fecha_recargos,
            NOW(),
            p_id_usuario
        );

        RETURN QUERY SELECT true::BOOLEAN, 'Fecha de descuento creada exitosamente'::TEXT;
    ELSE
        -- Actualizar registro existente
        UPDATE {$schemaTabla}.{$nombreTabla}
        SET
            fecha_descuento = p_fecha_descuento,
            fecha_recargos = p_fecha_recargos,
            fecha_alta = NOW(),
            id_usuario = p_id_usuario
        WHERE mes = p_mes;

        RETURN QUERY SELECT true::BOOLEAN, 'Fecha de descuento actualizada exitosamente'::TEXT;
    END IF;
END;
\$\$ LANGUAGE plpgsql;

-- Crear alias para compatibilidad
CREATE OR REPLACE FUNCTION sp_fechadescuento_update(
    p_mes SMALLINT,
    p_fecha_descuento DATE,
    p_fecha_recargos DATE,
    p_id_usuario INTEGER
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS \$\$
BEGIN
    RETURN QUERY SELECT * FROM fechas_descuento_update(p_mes, p_fecha_descuento, p_fecha_recargos, p_id_usuario);
END;
\$\$ LANGUAGE plpgsql;
";

$result = ejecutarQuery($conn, $sp2);
if ($result) {
    echo "✅ SP fechas_descuento_update() creado exitosamente\n";
    echo "✅ Alias sp_fechadescuento_update() creado exitosamente\n\n";
} else {
    echo "❌ Error al crear SP fechas_descuento_update()\n\n";
}

// ============================================================================
// PASO 5: Probar los Stored Procedures
// ============================================================================

echo "═══════════════════════════════════════════════════════════════════════════\n";
echo "PASO 5: PRUEBAS DE STORED PROCEDURES\n";
echo "═══════════════════════════════════════════════════════════════════════════\n\n";

// Prueba 1: fechas_descuento_get_all()
echo "🧪 Prueba 1: fechas_descuento_get_all()\n";
echo str_repeat("-", 79) . "\n";

$sql = "SELECT * FROM fechas_descuento_get_all() ORDER BY mes";
$result = ejecutarQuery($conn, $sql);

if ($result) {
    $rows = [];
    while ($row = pg_fetch_assoc($result)) {
        $rows[] = $row;
    }

    if (empty($rows)) {
        echo "⚠️  No hay datos en la tabla\n";
    } else {
        echo "✅ SP ejecutado correctamente. Registros encontrados: " . count($rows) . "\n\n";

        // Mostrar headers
        $headers = array_keys($rows[0]);
        echo "  " . implode(" | ", $headers) . "\n";
        echo "  " . str_repeat("-", 120) . "\n";

        foreach ($rows as $row) {
            $values = array_map(function($v) {
                return $v === null ? 'NULL' : $v;
            }, $row);
            echo "  " . implode(" | ", $values) . "\n";
        }
    }
} else {
    echo "❌ Error al ejecutar SP\n";
}

echo "\n";

// Prueba 2: Verificar si hay datos para actualizar
echo "🧪 Prueba 2: fechas_descuento_update()\n";
echo str_repeat("-", 79) . "\n";

$sql = "SELECT mes, fecha_descuento, fecha_recargos FROM {$schemaTabla}.{$nombreTabla} WHERE mes = 1";
$result = ejecutarQuery($conn, $sql);

if ($result && pg_num_rows($result) > 0) {
    $mesData = pg_fetch_assoc($result);
    echo "📋 Datos actuales del mes 1:\n";
    echo "   Mes: {$mesData['mes']}\n";
    echo "   Fecha Descuento: {$mesData['fecha_descuento']}\n";
    echo "   Fecha Recargos: {$mesData['fecha_recargos']}\n\n";

    // Probar actualización (sin cambiar realmente)
    echo "🔄 Probando actualización del mes 1 (sin cambios)...\n";
    $sql = "SELECT * FROM fechas_descuento_update(1, '{$mesData['fecha_descuento']}'::DATE, '{$mesData['fecha_recargos']}'::DATE, 1)";
    $result = ejecutarQuery($conn, $sql);

    if ($result) {
        $response = pg_fetch_assoc($result);
        $status = $response['success'] === 't' ? '✅' : '❌';
        echo "{$status} Success: {$response['success']}\n";
        echo "   Message: {$response['message']}\n";
    }
} else {
    echo "⚠️  No hay datos en el mes 1 para probar actualización\n";
    echo "🔄 Probando inserción de nuevo mes...\n";

    $sql = "SELECT * FROM fechas_descuento_update(1, '2025-12-05'::DATE, '2025-12-10'::DATE, 1)";
    $result = ejecutarQuery($conn, $sql);

    if ($result) {
        $response = pg_fetch_assoc($result);
        $status = $response['success'] === 't' ? '✅' : '❌';
        echo "{$status} Success: {$response['success']}\n";
        echo "   Message: {$response['message']}\n";
    }
}

echo "\n";

// ============================================================================
// PASO 6: Guardar SPs en archivos
// ============================================================================

echo "═══════════════════════════════════════════════════════════════════════════\n";
echo "PASO 6: GUARDAR STORED PROCEDURES EN ARCHIVOS\n";
echo "═══════════════════════════════════════════════════════════════════════════\n\n";

$dirBase = "C:\\guadalajara\\code\\recodeGDLCurrent\\recodeGDL\\temp\\";

// Guardar SP1
$file1 = $dirBase . "sp_fechas_descuento_get_all.sql";
file_put_contents($file1, $sp1);
echo "📄 Archivo creado: {$file1}\n";

// Guardar SP2
$file2 = $dirBase . "sp_fechas_descuento_update.sql";
file_put_contents($file2, $sp2);
echo "📄 Archivo creado: {$file2}\n";

// Crear archivo consolidado
$consolidado = "-- ============================================================================\n";
$consolidado .= "-- STORED PROCEDURES: Mantenimiento de Fechas de Descuento\n";
$consolidado .= "-- Base de Datos: mercados\n";
$consolidado .= "-- Esquema: public\n";
$consolidado .= "-- Tabla: {$schemaTabla}.{$nombreTabla}\n";
$consolidado .= "-- Fecha: " . date('Y-m-d H:i:s') . "\n";
$consolidado .= "-- Total SPs: 2 (+ 2 alias)\n";
$consolidado .= "-- ============================================================================\n\n";
$consolidado .= "\\c mercados;\n";
$consolidado .= "SET search_path TO public;\n\n";
$consolidado .= $sp1 . "\n\n";
$consolidado .= $sp2 . "\n\n";
$consolidado .= "-- ============================================================================\n";
$consolidado .= "-- FIN DE ARCHIVO\n";
$consolidado .= "-- ============================================================================\n";

$fileConsolidado = $dirBase . "fechas_descuento_all_sps.sql";
file_put_contents($fileConsolidado, $consolidado);
echo "📄 Archivo consolidado creado: {$fileConsolidado}\n";

echo "\n";

// ============================================================================
// RESUMEN FINAL
// ============================================================================

echo "╔════════════════════════════════════════════════════════════════════════════╗\n";
echo "║                            RESUMEN FINAL                                   ║\n";
echo "╚════════════════════════════════════════════════════════════════════════════╝\n\n";

echo "✅ Tabla encontrada: {$schemaTabla}.{$nombreTabla}\n";
echo "✅ Tabla usuarios: {$schemaUsuarios}.{$nombreUsuarios}\n";
echo "✅ Stored Procedures creados: 2 (+ 2 alias)\n\n";

echo "📝 SPs Principales:\n";
echo "   1. fechas_descuento_get_all()  - Lista todas las fechas (12 meses)\n";
echo "   2. fechas_descuento_update()   - Actualiza/Inserta fechas por mes\n\n";

echo "📝 SPs Alias (compatibilidad):\n";
echo "   1. sp_fechadescuento_list()    - Alias de fechas_descuento_get_all()\n";
echo "   2. sp_fechadescuento_update()  - Alias de fechas_descuento_update()\n\n";

echo "📄 Archivos generados:\n";
echo "   - sp_fechas_descuento_get_all.sql\n";
echo "   - sp_fechas_descuento_update.sql\n";
echo "   - fechas_descuento_all_sps.sql (consolidado)\n\n";

echo "🎯 Ejemplos de uso:\n\n";

echo "   -- Listar todas las fechas de descuento\n";
echo "   SELECT * FROM fechas_descuento_get_all();\n";
echo "   SELECT * FROM sp_fechadescuento_list();\n\n";

echo "   -- Actualizar fecha del mes 1\n";
echo "   SELECT * FROM fechas_descuento_update(1, '2025-12-05', '2025-12-10', 1);\n";
echo "   SELECT * FROM sp_fechadescuento_update(1, '2025-12-05', '2025-12-10', 1);\n\n";

echo "╔════════════════════════════════════════════════════════════════════════════╗\n";
echo "║                   ✅ PROCESO COMPLETADO EXITOSAMENTE                       ║\n";
echo "╚════════════════════════════════════════════════════════════════════════════╝\n";

pg_close($conn);
