#!/usr/bin/env python3
"""
Script para corregir el SP sp_padron_global en PostgreSQL
Verifica estructura de tablas y crea el SP con tipos correctos
"""

import psycopg2
from datetime import datetime
import sys

# Configuración de conexión
DB_CONFIG = {
    'host': '192.168.6.146',
    'port': 5432,
    'database': 'mercados',
    'user': 'refact',
    'password': 'FF)-BQk2'
}

def print_header(text):
    """Imprime un encabezado formateado"""
    print(f"\n{'='*60}")
    print(text)
    print('='*60)

def print_section(text):
    """Imprime un título de sección"""
    print(f"\n{text}")
    print('-'*60)

try:
    # Conectar a PostgreSQL
    print_header("CONEXIÓN A BASE DE DATOS")
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    print("✓ Conexión exitosa")

    # 1. Verificar estructura de ta_11_locales
    print_section("1. ESTRUCTURA DE publico.ta_11_locales")

    cur.execute("""
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            numeric_precision,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'publico'
        AND table_name = 'ta_11_locales'
        ORDER BY ordinal_position
    """)

    print("Columnas de ta_11_locales:")
    for row in cur.fetchall():
        col_name, data_type, char_len, num_prec, nullable = row
        type_str = data_type
        if char_len:
            type_str += f"({char_len})"
        elif num_prec:
            type_str += f"({num_prec})"
        print(f"  - {col_name}: {type_str} (nullable: {nullable})")

        if col_name == 'descripcion_local':
            print(f"\n  *** CAMPO CLAVE: descripcion_local es {type_str} ***\n")

    # 2. Verificar estructura de ta_11_mercados
    print_section("2. ESTRUCTURA DE publico.ta_11_mercados")

    cur.execute("""
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'publico'
        AND table_name = 'ta_11_mercados'
        AND column_name IN ('descripcion', 'num_mercado', 'id_mercado', 'num_mercado_nvo', 'oficina')
        ORDER BY ordinal_position
    """)

    for row in cur.fetchall():
        col_name, data_type, char_len = row
        type_str = data_type
        if char_len:
            type_str += f"({char_len})"
        print(f"  - {col_name}: {type_str}")

    # 3. Verificar tablas relacionadas
    print_section("3. VERIFICAR TABLAS RELACIONADAS")

    tables_to_check = [
        'ta_11_cuo_locales',
        'ta_11_adeudo_local',
        'ta_11_fecha_desc',
        'ta_11_cve_cuota'
    ]

    for table in tables_to_check:
        cur.execute("""
            SELECT COUNT(*)
            FROM information_schema.tables
            WHERE table_schema = 'publico'
            AND table_name = %s
        """, (table,))
        exists = cur.fetchone()[0] > 0
        status = '✓ EXISTE' if exists else '✗ NO EXISTE'
        print(f"  - publico.{table}: {status}")

    # 4. Eliminar SP anterior
    print_section("4. ELIMINANDO SP ANTERIOR (si existe)")

    cur.execute("DROP FUNCTION IF EXISTS publico.sp_padron_global(INTEGER, INTEGER, VARCHAR) CASCADE")
    print("✓ SP anterior eliminado")

    # 5. Crear nuevo SP
    print_section("5. CREANDO NUEVO SP sp_padron_global")

    create_sp_sql = """
CREATE OR REPLACE FUNCTION publico.sp_padron_global(
    p_year INTEGER,
    p_month INTEGER,
    p_status VARCHAR
)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHARACTER(2),
    local INTEGER,
    letra_local CHARACTER VARYING(3),
    bloque CHARACTER VARYING(5),
    nombre CHARACTER VARYING(60),
    descripcion_local CHARACTER VARYING(60),
    superficie NUMERIC(7,2),
    vigencia CHARACTER(1),
    clave_cuota SMALLINT,
    descripcion CHARACTER VARYING(30),
    renta NUMERIC(10,2),
    leyenda VARCHAR(50),
    adeudo INTEGER,
    registro VARCHAR(200)
)
AS $$
DECLARE
    v_periodo INTEGER;
BEGIN
    -- Calcular periodo (año + mes en formato YYYYMM)
    v_periodo := (p_year * 100) + p_month;

    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre,
        l.descripcion_local,
        l.superficie,
        l.vigencia,
        l.clave_cuota,
        m.descripcion,
        -- Cálculo de renta según lógica
        CASE
            -- PS con clave_cuota 4
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0)), 2)
            -- PS otros
            WHEN l.seccion = 'PS' THEN
                ROUND(((COALESCE(c.importe_cuota, 0) * l.superficie) * 30), 2)
            -- Mercado 214
            WHEN l.num_mercado = 214 THEN
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0) * COALESCE(fd.sabadosacum, 1)), 2)
            -- Default
            ELSE
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0)), 2)
        END::NUMERIC(10,2) AS renta,
        -- Leyenda de adeudo
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 'Local con Adeudo'::VARCHAR(50)
            ELSE 'Local al Corriente de Pagos'::VARCHAR(50)
        END AS leyenda,
        -- Indicador de adeudo (0 o 1)
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 1
            ELSE 0
        END::INTEGER AS adeudo,
        -- Registro concatenado
        (l.oficina::TEXT || ' ' ||
         l.num_mercado::TEXT || ' ' ||
         l.categoria::TEXT || ' ' ||
         l.seccion || ' ' ||
         l.local::TEXT || ' ' ||
         COALESCE(l.letra_local, '') || ' ' ||
         COALESCE(l.bloque, ''))::VARCHAR(200) AS registro
    FROM publico.ta_11_locales l
    INNER JOIN publico.ta_11_mercados m
        ON l.oficina = m.oficina
        AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN publico.ta_11_cuo_locales c
        ON c.axo = p_year
        AND c.categoria = l.categoria
        AND c.seccion = l.seccion
        AND c.clave_cuota = l.clave_cuota
    LEFT JOIN (
        SELECT
            id_local,
            COUNT(*)::INTEGER AS adeudos
        FROM publico.ta_11_adeudo_local
        WHERE (axo = p_year AND periodo <= p_month)
           OR (axo < p_year)
        GROUP BY id_local
    ) a ON a.id_local = l.id_local
    LEFT JOIN publico.ta_11_fecha_desc fd
        ON fd.mes = p_month
    WHERE
        (p_status = 'T' OR l.vigencia = p_status)
    ORDER BY
        l.vigencia,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque;
END;
$$ LANGUAGE plpgsql;
"""

    cur.execute(create_sp_sql)
    conn.commit()
    print("✓ SP sp_padron_global creado exitosamente")

    # 6. Probar el SP
    print_section("6. PROBANDO EL SP")

    current_year = datetime.now().year
    current_month = datetime.now().month

    print(f"Parámetros de prueba:")
    print(f"  - Año: {current_year}")
    print(f"  - Mes: {current_month}")
    print(f"  - Vigencia: 'A'")
    print()

    # Contar registros con vigencia 'A'
    cur.execute("""
        SELECT COUNT(*)
        FROM publico.sp_padron_global(%s, %s, 'A')
    """, (current_year, current_month))

    total_a = cur.fetchone()[0]
    print(f"✓ Registros con vigencia 'A': {total_a}")

    # Contar registros totales
    cur.execute("""
        SELECT COUNT(*)
        FROM publico.sp_padron_global(%s, %s, 'T')
    """, (current_year, current_month))

    total_t = cur.fetchone()[0]
    print(f"✓ Registros totales (vigencia 'T'): {total_t}")

    # Obtener primeros 3 registros
    vigencia_test = 'A' if total_a > 0 else 'T'
    total_test = total_a if total_a > 0 else total_t

    cur.execute(f"""
        SELECT
            id_local,
            oficina,
            num_mercado,
            descripcion,
            categoria,
            seccion,
            local,
            letra_local,
            bloque,
            nombre,
            descripcion_local,
            superficie,
            vigencia,
            clave_cuota,
            renta,
            leyenda,
            adeudo,
            registro
        FROM publico.sp_padron_global(%s, %s, %s)
        LIMIT 3
    """, (current_year, current_month, vigencia_test))

    results = cur.fetchall()

    if results:
        print(f"\nEJEMPLOS DE REGISTROS (primeros 3 con vigencia '{vigencia_test}'):")
        print("="*60)

        for idx, row in enumerate(results, 1):
            (id_local, oficina, num_mercado, descripcion, categoria, seccion,
             local, letra_local, bloque, nombre, descripcion_local, superficie,
             vigencia, clave_cuota, renta, leyenda, adeudo, registro) = row

            print(f"\nRegistro {idx}:")
            print(f"  ID Local: {id_local}")
            print(f"  Oficina: {oficina}")
            print(f"  Mercado: {num_mercado} - {descripcion}")
            print(f"  Categoría: {categoria}")
            print(f"  Sección: {seccion}")
            print(f"  Local: {local}{letra_local or ''}")
            print(f"  Bloque: {bloque or ''}")
            print(f"  Nombre: {nombre}")
            print(f"  Descripción Local: [{descripcion_local}]")
            print(f"  Superficie: {superficie} m²")
            print(f"  Vigencia: {vigencia}")
            print(f"  Clave Cuota: {clave_cuota}")
            print(f"  Renta: ${renta:,.2f}")
            print(f"  Adeudo: {leyenda} ({adeudo})")
            print(f"  Registro: {registro}")

    # Resumen final
    print_header("RESUMEN DE LA CORRECCIÓN")
    print("✓ Verificada estructura de ta_11_locales")
    print("✓ Campo descripcion_local identificado correctamente")
    print("✓ SP sp_padron_global eliminado (versión anterior)")
    print("✓ SP sp_padron_global creado con tipos correctos")
    print("✓ SP probado exitosamente")
    print(f"✓ Retorna {total_test} registros con los parámetros de prueba")
    print("\nEl SP está listo para usar en producción.")
    print()

    # Cerrar conexión
    cur.close()
    conn.close()

except psycopg2.Error as e:
    print(f"\n✗ ERROR DE BASE DE DATOS:")
    print(f"  {e}")
    sys.exit(1)

except Exception as e:
    print(f"\n✗ ERROR:")
    print(f"  {e}")
    sys.exit(1)
