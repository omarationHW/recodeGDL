<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

echo "=== Corrigiendo SPs con tipos exactos ===\n\n";

try {
    $pdo = new PDO("pgsql:host={$host};port={$port};dbname={$dbname}", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Error: " . $e->getMessage() . "\n");
}

$sps = [
    'sp_cuotasmdo_list' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_cuotasmdo_list(p_axo INTEGER)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo SMALLINT,
    categoria SMALLINT,
    seccion CHAR(2),
    clave_cuota SMALLINT,
    importe_cuota NUMERIC,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(20),
    descripcion VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_cuotas, a.axo, a.categoria, a.seccion, a.clave_cuota,
           a.importe_cuota, a.fecha_alta, a.id_usuario,
           COALESCE(b.usuario, 'N/A')::VARCHAR(20) as usuario,
           c.descripcion
    FROM ta_11_cuo_locales a
    LEFT JOIN usuarios b ON a.id_usuario = b.id
    JOIN ta_11_cve_cuota c ON a.clave_cuota = c.clave_cuota
    WHERE a.axo >= p_axo
    ORDER BY a.axo DESC, a.categoria DESC, a.seccion DESC, a.clave_cuota DESC;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_categorias_list' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_categorias_list()
RETURNS TABLE (categoria SMALLINT, descripcion VARCHAR(50)) AS $$
BEGIN
    RETURN QUERY SELECT a.categoria, a.descripcion FROM ta_11_categoria a ORDER BY a.categoria;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_secciones_list' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_secciones_list()
RETURNS TABLE (seccion CHAR(2), descripcion VARCHAR(50)) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT a.seccion, ('Sección ' || TRIM(a.seccion))::VARCHAR(50) as descripcion
    FROM ta_11_cuo_locales a
    WHERE a.seccion IS NOT NULL
    ORDER BY a.seccion;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_clavescuota_list' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_clavescuota_list()
RETURNS TABLE (clave_cuota SMALLINT, descripcion VARCHAR(50)) AS $$
BEGIN
    RETURN QUERY SELECT a.clave_cuota, a.descripcion FROM ta_11_cve_cuota a ORDER BY a.clave_cuota;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_cuotasmdo_create' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_cuotasmdo_create(
    p_axo SMALLINT,
    p_categoria SMALLINT,
    p_seccion CHAR(2),
    p_clave_cuota SMALLINT,
    p_importe_cuota NUMERIC,
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
    p_axo SMALLINT,
    p_categoria SMALLINT,
    p_seccion CHAR(2),
    p_clave_cuota SMALLINT,
    p_importe_cuota NUMERIC,
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

foreach ($sps as $nombre => $sql) {
    echo "Desplegando: {$nombre}... ";
    try {
        $pdo->exec($sql);
        echo "OK\n";
    } catch (PDOException $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
    }
}

// Probar
echo "\n=== Probando sp_cuotasmdo_list(2020) ===\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_cuotasmdo_list(2020) LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros: " . count($rows) . "\n";
    if (count($rows) > 0) {
        print_r($rows[0]);
    }
} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}

echo "\n=== Probando sp_categorias_list() ===\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_categorias_list()");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Categorias: " . count($rows) . "\n";
    foreach ($rows as $r) {
        echo "  {$r['categoria']}: {$r['descripcion']}\n";
    }
} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}

echo "\n=== Probando sp_secciones_list() ===\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_secciones_list() LIMIT 10");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Secciones: " . count($rows) . "\n";
} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}

echo "\n=== Probando sp_clavescuota_list() ===\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_clavescuota_list()");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Claves cuota: " . count($rows) . "\n";
} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
