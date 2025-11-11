#!/usr/bin/env python3
import psycopg2

DB_CONFIG = {
    'host': '192.168.6.146',
    'port': 5432,
    'database': 'padron_licencias',
    'user': 'refact',
    'password': 'FF)-BQk2'
}

def list_all_sps():
    """Lista todos los SPs del módulo en la BD"""

    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    print('[INFO] Listando todos los Stored Procedures en la BD...\n')

    # Obtener todos los SPs
    cursor.execute("""
        SELECT
            p.proname,
            p.pronargs,
            pg_get_function_arguments(p.oid) as args,
            pg_get_function_result(p.oid) as returns
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        ORDER BY p.proname
    """)

    results = cursor.fetchall()

    print(f'Total de Stored Procedures: {len(results)}\n')
    print('='*100)

    # Agrupar por prefijo
    grupos = {}
    for row in results:
        sp_name = row[0]
        prefix = sp_name.split('_')[0] if '_' in sp_name else 'otros'

        if prefix not in grupos:
            grupos[prefix] = []

        grupos[prefix].append({
            'nombre': sp_name,
            'args': row[1],
            'params': row[2],
            'returns': row[3]
        })

    # Imprimir por grupos
    for prefix in sorted(grupos.keys()):
        sps = grupos[prefix]
        print(f'\n[{prefix.upper()}] - {len(sps)} SPs')
        print('-'*100)

        for sp in sorted(sps, key=lambda x: x['nombre']):
            print(f"  {sp['nombre']} ({sp['args']} params)")
            if sp['params']:
                print(f"    Params: {sp['params'][:80]}")
            print(f"    Returns: {sp['returns'][:80]}")
            print()

    cursor.close()
    conn.close()

if __name__ == '__main__':
    list_all_sps()
