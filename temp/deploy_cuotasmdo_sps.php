<?php
/**
 * Script para desplegar los SPs de CuotasMdo a PostgreSQL
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

echo "=== Desplegando SPs de CuotasMdo ===\n\n";

try {
    $dsn = "pgsql:host={$host};port={$port};dbname={$dbname}";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    echo "Conexion exitosa a la base de datos\n\n";
} catch (PDOException $e) {
    die("Error de conexion: " . $e->getMessage() . "\n");
}

// Definir los SPs a desplegar
$sps = [
    'sp_cuotasmdo_list' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_cuotasmdo_list(p_axo INTEGER)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo INTEGER,
    categoria INTEGER,
    seccion VARCHAR(10),
    clave_cuota INTEGER,
    importe_cuota NUMERIC(12,2),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50),
    descripcion VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_cuotas, a.axo, a.categoria, a.seccion, a.clave_cuota, a.importe_cuota, a.fecha_alta, a.id_usuario, b.usuario, c.descripcion
    FROM ta_11_cuo_locales a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN ta_11_cve_cuota c ON a.clave_cuota = c.clave_cuota
    WHERE a.axo >= p_axo
    ORDER BY a.axo DESC, a.categoria DESC, a.seccion DESC, a.clave_cuota DESC;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_categorias_list' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_categorias_list()
RETURNS TABLE (categoria INTEGER, descripcion VARCHAR(100)) AS $$
BEGIN
    RETURN QUERY SELECT a.categoria, a.descripcion FROM ta_11_categoria a ORDER BY a.categoria;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_secciones_list' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_secciones_list()
RETURNS TABLE (seccion VARCHAR(10), descripcion VARCHAR(100)) AS $$
BEGIN
    RETURN QUERY SELECT a.seccion, a.descripcion FROM ta_11_secciones a ORDER BY a.seccion;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_clavescuota_list' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_clavescuota_list()
RETURNS TABLE (clave_cuota INTEGER, descripcion VARCHAR(100)) AS $$
BEGIN
    RETURN QUERY SELECT a.clave_cuota, a.descripcion FROM ta_11_cve_cuota a ORDER BY a.clave_cuota;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_cuotasmdo_create' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_cuotasmdo_create(
    p_axo INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR(10),
    p_clave_cuota INTEGER,
    p_importe_cuota NUMERIC(12,2),
    p_id_usuario INTEGER
)
RETURNS TABLE (id_cuotas INTEGER, mensaje VARCHAR(100)) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO ta_11_cuo_locales (axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario)
    VALUES (p_axo, p_categoria, p_seccion, p_clave_cuota, p_importe_cuota, NOW(), p_id_usuario)
    RETURNING ta_11_cuo_locales.id_cuotas INTO v_id;

    RETURN QUERY SELECT v_id, 'Cuota creada exitosamente'::VARCHAR(100);
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_cuotasmdo_update' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_cuotasmdo_update(
    p_id_cuotas INTEGER,
    p_axo INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR(10),
    p_clave_cuota INTEGER,
    p_importe_cuota NUMERIC(12,2),
    p_id_usuario INTEGER
)
RETURNS TABLE (filas_afectadas INTEGER, mensaje VARCHAR(100)) AS $$
DECLARE
    v_rows INTEGER;
BEGIN
    UPDATE ta_11_cuo_locales
    SET axo = p_axo,
        categoria = p_categoria,
        seccion = p_seccion,
        clave_cuota = p_clave_cuota,
        importe_cuota = p_importe_cuota,
        id_usuario = p_id_usuario
    WHERE id_cuotas = p_id_cuotas;

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN QUERY SELECT v_rows, 'Cuota actualizada exitosamente'::VARCHAR(100);
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_cuotasmdo_delete' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_cuotasmdo_delete(p_id_cuotas INTEGER)
RETURNS TABLE (filas_afectadas INTEGER, mensaje VARCHAR(100)) AS $$
DECLARE
    v_rows INTEGER;
BEGIN
    DELETE FROM ta_11_cuo_locales WHERE id_cuotas = p_id_cuotas;
    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN QUERY SELECT v_rows, 'Cuota eliminada exitosamente'::VARCHAR(100);
END;
$$ LANGUAGE plpgsql;
SQL

];

$exitosos = 0;
$fallidos = 0;

foreach ($sps as $nombre => $sql) {
    echo "Desplegando: {$nombre}... ";
    try {
        $pdo->exec($sql);
        echo "OK\n";
        $exitosos++;
    } catch (PDOException $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
        $fallidos++;
    }
}

echo "\n=== Resumen ===\n";
echo "Exitosos: {$exitosos}\n";
echo "Fallidos: {$fallidos}\n";

// Verificar que existen
echo "\n=== Verificando SPs en la BD ===\n";
$query = "SELECT routine_name FROM information_schema.routines
          WHERE routine_schema = 'public'
          AND routine_name LIKE 'sp_%'
          AND routine_name IN ('sp_cuotasmdo_list', 'sp_categorias_list', 'sp_secciones_list', 'sp_clavescuota_list', 'sp_cuotasmdo_create', 'sp_cuotasmdo_update', 'sp_cuotasmdo_delete')
          ORDER BY routine_name";

$stmt = $pdo->query($query);
$found = $stmt->fetchAll(PDO::FETCH_COLUMN);

echo "SPs encontrados en BD:\n";
foreach ($found as $sp) {
    echo "  - {$sp}\n";
}
