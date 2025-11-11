#!/usr/bin/env python3
import psycopg2
import json
from pathlib import Path

DB_CONFIG = {
    'host': '192.168.6.146',
    'port': 5432,
    'database': 'padron_licencias',
    'user': 'refact',
    'password': 'FF)-BQk2'
}

REPORT_PATH = Path(__file__).parent / 'sp-deployment-report.json'

def verify_deployment():
    """Verifica que los SPs reportados como exitosos existan en la BD"""

    print('[VERIFICACION] Iniciando verificacion de deployment...')

    # Cargar reporte
    with open(REPORT_PATH, 'r', encoding='utf-8') as f:
        report = json.load(f)

    # Conectar a BD
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    print(f'[OK] Conectado a PostgreSQL')
    print(f'[INFO] SPs reportados como exitosos: {report["sps_exitosos"]}')
    print(f'[INFO] SPs reportados con errores: {report["sps_con_errores"]}')

    # Obtener lista de SPs exitosos del reporte
    exitosos_reportados = []
    for archivo, detalle in report['detalle'].items():
        if detalle['estado'] == 'exitoso' and detalle['sp_nombre']:
            exitosos_reportados.append(detalle['sp_nombre'])

    print(f'\n[VERIFICACION] Verificando {len(exitosos_reportados)} SPs en la BD...')

    # Verificar cada uno en la BD
    encontrados = 0
    no_encontrados = []

    for sp_name in exitosos_reportados:
        cursor.execute("""
            SELECT COUNT(*) FROM pg_proc WHERE proname = %s
        """, (sp_name,))

        count = cursor.fetchone()[0]
        if count > 0:
            encontrados += 1
        else:
            no_encontrados.append(sp_name)

    print(f'\n[RESULTADO] SPs encontrados en BD: {encontrados}/{len(exitosos_reportados)}')

    if no_encontrados:
        print(f'\n[WARNING] SPs NO encontrados en BD ({len(no_encontrados)}):')
        for sp in no_encontrados[:10]:
            print(f'  - {sp}')
        if len(no_encontrados) > 10:
            print(f'  ... y {len(no_encontrados) - 10} mas')

    # Contar total de funciones en la BD
    cursor.execute("""
        SELECT COUNT(*)
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
    """)
    total_functions = cursor.fetchone()[0]

    print(f'\n[INFO] Total de funciones en la BD (schema public): {total_functions}')

    # Listar algunos SPs clave
    print(f'\n[MUESTRA] Algunos SPs importantes verificados:')
    key_sps = ['sp_login', 'sp14_remesa', 'sp_get_public_parking_list', 'sppubalta', 'ex_propietario_create']

    for sp_name in key_sps:
        cursor.execute("""
            SELECT proname, pronargs
            FROM pg_proc
            WHERE proname = %s
        """, (sp_name,))

        result = cursor.fetchone()
        if result:
            print(f'  [OK] {result[0]} ({result[1]} parametros)')
        else:
            print(f'  [X] {sp_name} - NO ENCONTRADO')

    # Cerrar conexión
    cursor.close()
    conn.close()

    print('\n[OK] Verificacion completada')

    # Retornar estadísticas
    return {
        'exitosos_reportados': len(exitosos_reportados),
        'encontrados_en_bd': encontrados,
        'no_encontrados': len(no_encontrados),
        'total_funciones_bd': total_functions
    }

if __name__ == '__main__':
    stats = verify_deployment()

    print('\n' + '='*60)
    print('[RESUMEN]')
    print(f'  Tasa de verificacion: {stats["encontrados_en_bd"]}/{stats["exitosos_reportados"]} ({100*stats["encontrados_en_bd"]/stats["exitosos_reportados"]:.1f}%)')
    print(f'  Total funciones en BD: {stats["total_funciones_bd"]}')
    print('='*60)
