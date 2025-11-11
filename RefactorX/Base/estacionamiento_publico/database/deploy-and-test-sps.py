#!/usr/bin/env python3
import psycopg2
import os
import json
import re
from datetime import datetime
from pathlib import Path

DB_CONFIG = {
    'host': '192.168.6.146',
    'port': 5432,
    'database': 'padron_licencias',
    'user': 'refact',
    'password': 'FF)-BQk2'
}

DATABASE_DIR = Path(__file__).parent / 'database'
REPORT_PATH = Path(__file__).parent / 'sp-deployment-report.json'

def extract_procedure_name(sql_content):
    """Extrae el nombre del procedimiento/función del SQL"""
    patterns = [
        r'CREATE\s+OR\s+REPLACE\s+FUNCTION\s+(\w+)\s*\(',
        r'CREATE\s+FUNCTION\s+(\w+)\s*\(',
        r'CREATE\s+OR\s+REPLACE\s+PROCEDURE\s+(\w+)\s*\(',
        r'CREATE\s+PROCEDURE\s+(\w+)\s*\(',
    ]

    for pattern in patterns:
        match = re.search(pattern, sql_content, re.IGNORECASE)
        if match:
            return match.group(1)

    return None

def deploy_stored_procedure(cursor, file_path, file_name):
    """Despliega un stored procedure y retorna el resultado"""
    result = {
        'archivo': file_name,
        'sp_nombre': None,
        'estado': 'error',
        'mensaje_error': None,
        'probado': False,
        'funciona': False,
        'sql_content_length': 0
    }

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()

        result['sql_content_length'] = len(sql_content)
        result['sp_nombre'] = extract_procedure_name(sql_content)

        if not result['sp_nombre']:
            result['mensaje_error'] = 'No se pudo extraer el nombre del procedimiento'
            return result

        # Ejecutar el SQL
        cursor.execute(sql_content)
        result['estado'] = 'exitoso'

        # Verificar que el SP existe
        cursor.execute("""
            SELECT proname, pronargs
            FROM pg_proc
            WHERE proname = %s
        """, (result['sp_nombre'],))

        if cursor.fetchone():
            result['probado'] = True
            result['funciona'] = True
        else:
            result['probado'] = True
            result['funciona'] = False
            result['mensaje_error'] = 'SP no encontrado después de ejecutar'

    except Exception as e:
        result['estado'] = 'error'
        error_msg = str(e)
        result['mensaje_error'] = error_msg

        # Si el error es que ya existe, intentar DROP y recrear
        if 'already exists' in error_msg.lower():
            try:
                if result['sp_nombre']:
                    cursor.execute(f"DROP FUNCTION IF EXISTS {result['sp_nombre']} CASCADE")

                    with open(file_path, 'r', encoding='utf-8') as f:
                        sql_content = f.read()
                    cursor.execute(sql_content)

                    result['estado'] = 'exitoso'
                    result['mensaje_error'] = 'Recreado después de DROP'
                    result['probado'] = True
                    result['funciona'] = True
            except Exception as retry_error:
                result['mensaje_error'] = f'Error al recrear: {str(retry_error)}'

    return result

def main():
    start_time = datetime.now()

    print('[INICIO] Iniciando despliegue de SPs...')
    print(f'[DIR] Directorio: {DATABASE_DIR}')

    try:
        # Conectar a PostgreSQL
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        print('[OK] Conectado a PostgreSQL')

        # Obtener todos los archivos SQL
        sql_files = sorted([f.name for f in DATABASE_DIR.glob('*.sql')])

        # Ordenar: archivos _all_procedures.sql primero
        all_procedures = sorted([f for f in sql_files if f.endswith('_all_procedures.sql')])
        individual = sorted([f for f in sql_files if not f.endswith('_all_procedures.sql')])
        sql_files = all_procedures + individual

        print(f'[INFO] Total de archivos SQL: {len(sql_files)}')

        report = {
            'fecha': start_time.strftime('%Y-%m-%d'),
            'hora_inicio': start_time.isoformat(),
            'total_archivos': len(sql_files),
            'archivos_procesados': 0,
            'sps_ingresados': 0,
            'sps_exitosos': 0,
            'sps_con_errores': 0,
            'detalle': {},
            'errores': []
        }

        for idx, file_name in enumerate(sql_files, 1):
            file_path = DATABASE_DIR / file_name

            print(f'\n[{idx}/{len(sql_files)}] Procesando: {file_name}')

            result = deploy_stored_procedure(cursor, file_path, file_name)

            report['archivos_procesados'] += 1
            report['detalle'][file_name] = result

            if result['sp_nombre']:
                report['sps_ingresados'] += 1

            if result['estado'] == 'exitoso':
                report['sps_exitosos'] += 1
                print(f"  [OK] {result['sp_nombre']} - EXITOSO")
            else:
                report['sps_con_errores'] += 1
                report['errores'].append({
                    'archivo': file_name,
                    'sp': result['sp_nombre'],
                    'error': result['mensaje_error']
                })
                print(f"  [ERROR] {result['sp_nombre'] or 'N/A'} - ERROR: {result['mensaje_error'][:100]}")

        end_time = datetime.now()
        report['hora_fin'] = end_time.isoformat()
        report['duracion_segundos'] = int((end_time - start_time).total_seconds())

        # Guardar reporte
        with open(REPORT_PATH, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)

        print('\n' + '='*80)
        print('[REPORTE] REPORTE FINAL')
        print('='*80)
        print(f"Total archivos procesados: {report['archivos_procesados']}")
        print(f"SPs ingresados: {report['sps_ingresados']}")
        print(f"SPs exitosos: {report['sps_exitosos']}")
        print(f"SPs con errores: {report['sps_con_errores']}")
        print(f"Duracion: {report['duracion_segundos']} segundos")
        print(f"\n[REPORTE] Reporte guardado en: {REPORT_PATH}")

        if report['errores']:
            print('\n[WARNING] ERRORES ENCONTRADOS:')
            for idx, err in enumerate(report['errores'][:10], 1):
                error_preview = err['error'][:100] if err['error'] else 'N/A'
                print(f"  {idx}. {err['archivo']} ({err['sp']}): {error_preview}")
            if len(report['errores']) > 10:
                print(f"  ... y {len(report['errores']) - 10} errores mas")

        cursor.close()
        conn.close()
        print('\n[OK] Conexion cerrada')

    except Exception as e:
        print(f'[ERROR] Error fatal: {e}')
        return 1

    return 0

if __name__ == '__main__':
    exit(main())
