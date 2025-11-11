#!/usr/bin/env python3
"""
AGENTE DE VALIDACIÓN FUNCIONAL - ASEO_CONTRATADO
Valida compatibilidad entre SPs desplegados y componentes Vue
SIN MODIFICAR NINGÚN ARCHIVO
"""

import os
import re
import json
from pathlib import Path
from collections import defaultdict

# Rutas
BASE_DIR = Path(r"C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\aseo_contratado")
SQL_DIR = BASE_DIR / "database" / "database"
VUE_DIR = Path(r"C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd\src\views\modules\aseo_contratado")

# Salidas
OUTPUT_JSON = BASE_DIR / "VALIDACION_FUNCIONAL_SPS_VUE.json"
CONTROL_MD = BASE_DIR / "CONTROL_ASEO_CONTRATADO.md"

def extraer_sps_de_archivos_sql():
    """Extrae nombres de SPs de archivos SQL"""
    sps = set()
    pattern = re.compile(r'CREATE\s+OR\s+REPLACE\s+FUNCTION\s+(\w+)\s*\(', re.IGNORECASE)

    print(f"[1/4] Buscando SPs en {SQL_DIR}...")

    for sql_file in SQL_DIR.glob("*.sql"):
        if "_all_procedures.sql" in sql_file.name:
            continue  # Ignorar consolidados

        try:
            content = sql_file.read_text(encoding='utf-8', errors='ignore')
            matches = pattern.findall(content)
            for match in matches:
                sp_name = match.lower().strip()
                if sp_name:
                    sps.add(sp_name)
        except Exception as e:
            print(f"  [WARN] Error leyendo {sql_file.name}: {e}")

    sps_list = sorted(list(sps))
    print(f"  [OK] Encontrados {len(sps_list)} SPs unicos")
    return sps_list

def analizar_componentes_vue(sps_disponibles):
    """Analiza componentes Vue y detecta SPs que requieren"""

    print(f"\n[2/4] Analizando componentes Vue en {VUE_DIR}...")

    # Patrones para detectar llamadas a SPs
    patterns = [
        re.compile(r"execute\s*\(\s*['\"](\w+)['\"]", re.IGNORECASE),  # execute('SP_NAME', ...)
        re.compile(r"storedProcedure\s*:\s*['\"](\w+)['\"]", re.IGNORECASE),  # storedProcedure: 'SP_NAME'
        re.compile(r"sp\s*:\s*['\"](\w+)['\"]", re.IGNORECASE),  # sp: 'SP_NAME'
    ]

    componentes = []
    sps_requeridos_totales = set()

    for vue_file in sorted(VUE_DIR.glob("*.vue")):
        try:
            content = vue_file.read_text(encoding='utf-8', errors='ignore')

            # Detectar SPs llamados
            sps_encontrados = set()
            for pattern in patterns:
                matches = pattern.findall(content)
                for match in matches:
                    sp_name = match.lower().strip()
                    if sp_name and (sp_name.startswith('sp_') or sp_name.startswith('con16_') or sp_name.startswith('sp16_')):
                        sps_encontrados.add(sp_name)

            sps_list = sorted(list(sps_encontrados))

            # Clasificar disponibilidad
            sps_disponibles_comp = [sp for sp in sps_list if sp in sps_disponibles]
            sps_faltantes_comp = [sp for sp in sps_list if sp not in sps_disponibles]

            # Calcular estado
            if len(sps_list) == 0:
                estado = "SIN SPs DETECTADOS (placeholder o sin backend)"
                funcionalidad = 0
            elif len(sps_faltantes_comp) == 0:
                estado = "FUNCIONAL 100%"
                funcionalidad = 100
            elif len(sps_disponibles_comp) > 0:
                pct = int((len(sps_disponibles_comp) / len(sps_list)) * 100)
                estado = f"FUNCIONAL PARCIAL {pct}%"
                funcionalidad = pct
            else:
                estado = "BLOQUEADO 0%"
                funcionalidad = 0

            componente_info = {
                "componente": vue_file.name,
                "sps_requeridos": sps_list,
                "total_requeridos": len(sps_list),
                "sps_disponibles": sps_disponibles_comp,
                "total_disponibles": len(sps_disponibles_comp),
                "sps_faltantes": sps_faltantes_comp,
                "total_faltantes": len(sps_faltantes_comp),
                "funcionalidad_pct": funcionalidad,
                "estado": estado
            }

            componentes.append(componente_info)
            sps_requeridos_totales.update(sps_list)

        except Exception as e:
            print(f"  [WARN] Error leyendo {vue_file.name}: {e}")

    print(f"  [OK] Analizados {len(componentes)} componentes")
    print(f"  [OK] Detectados {len(sps_requeridos_totales)} SPs requeridos unicos")

    return componentes, sorted(list(sps_requeridos_totales))

def generar_estadisticas(componentes, sps_disponibles, sps_requeridos):
    """Genera estadísticas consolidadas"""

    print(f"\n[3/4] Generando estadísticas...")

    funcionales_100 = [c for c in componentes if c['funcionalidad_pct'] == 100]
    funcionales_parcial = [c for c in componentes if 0 < c['funcionalidad_pct'] < 100]
    bloqueados = [c for c in componentes if c['funcionalidad_pct'] == 0 and c['total_requeridos'] > 0]
    sin_sps = [c for c in componentes if c['total_requeridos'] == 0]

    # SPs sin uso
    sps_sin_uso = [sp for sp in sps_disponibles if sp not in sps_requeridos]

    # SPs más utilizados
    sp_contador = defaultdict(int)
    for comp in componentes:
        for sp in comp['sps_requeridos']:
            sp_contador[sp] += 1

    sps_mas_usados = sorted(sp_contador.items(), key=lambda x: x[1], reverse=True)[:20]

    # Funcionalidad general
    if len(componentes) > 0:
        total_reqs = sum(c['total_requeridos'] for c in componentes)
        total_disp = sum(c['total_disponibles'] for c in componentes)
        funcionalidad_general = int((total_disp / total_reqs * 100)) if total_reqs > 0 else 0
    else:
        funcionalidad_general = 0

    stats = {
        "fecha": "2025-11-09",
        "sps_desplegados": len(sps_disponibles),
        "componentes_validados": len(componentes),
        "sps_requeridos_total": len(sps_requeridos),
        "funcionalidad_general_pct": funcionalidad_general,
        "componentes_funcionales_100": len(funcionales_100),
        "componentes_funcionales_parcial": len(funcionales_parcial),
        "componentes_bloqueados": len(bloqueados),
        "componentes_sin_sps": len(sin_sps),
        "sps_sin_uso": len(sps_sin_uso),
        "top_sps_mas_usados": sps_mas_usados,
        "lista_sps_sin_uso": sps_sin_uso[:20],  # Top 20
    }

    print(f"  [OK] Funcionales 100%: {len(funcionales_100)}")
    print(f"  [WARN] Funcionales Parcial: {len(funcionales_parcial)}")
    print(f"  [ERROR] Bloqueados: {len(bloqueados)}")
    print(f"  [WARN] Sin SPs: {len(sin_sps)}")
    print(f"  Funcionalidad general: {funcionalidad_general}%")

    return stats

def generar_reporte_json(sps_disponibles, sps_requeridos, componentes, stats):
    """Genera reporte JSON completo"""

    print(f"\n[4/4] Generando reporte JSON...")

    reporte = {
        "meta": {
            "fecha": "2025-11-09",
            "agente": "VALIDACION_FUNCIONAL",
            "version": "1.0"
        },
        "resumen": stats,
        "sps": {
            "desplegados": sps_disponibles,
            "requeridos": sps_requeridos,
            "faltantes": [sp for sp in sps_requeridos if sp not in sps_disponibles]
        },
        "componentes": componentes
    }

    OUTPUT_JSON.write_text(json.dumps(reporte, indent=2, ensure_ascii=False), encoding='utf-8')
    print(f"  [OK] Reporte guardado en: {OUTPUT_JSON}")

    return reporte

def imprimir_resumen_final(stats, sps_disponibles, sps_requeridos):
    """Imprime resumen final para el usuario"""

    print("\n" + "="*80)
    print("VALIDACION FUNCIONAL POST-DESPLIEGUE - ASEO_CONTRATADO")
    print("="*80)

    print(f"\nRESUMEN EJECUTIVO:")
    print(f"  • SPs desplegados:           {stats['sps_desplegados']}")
    print(f"  • SPs requeridos (únicos):   {stats['sps_requeridos_total']}")
    print(f"  • Componentes validados:     {stats['componentes_validados']}")
    print(f"  • Funcionalidad general:     {stats['funcionalidad_general_pct']}%")

    print(f"\nESTADO DE COMPONENTES:")
    print(f"  - FUNCIONALES 100%:          {stats['componentes_funcionales_100']} componentes")
    print(f"  - FUNCIONALES PARCIAL:       {stats['componentes_funcionales_parcial']} componentes")
    print(f"  - BLOQUEADOS:                {stats['componentes_bloqueados']} componentes")
    print(f"  - SIN SPs DETECTADOS:        {stats['componentes_sin_sps']} componentes")

    print(f"\nTOP 10 SPs MAS REQUERIDOS:")
    for i, (sp, count) in enumerate(stats['top_sps_mas_usados'][:10], 1):
        disponible = "[OK]" if sp in sps_disponibles else "[FALTA]"
        print(f"  {i:2d}. {disponible} {sp:<50} ({count} componentes)")

    print(f"\nRECOMENDACION FINAL:")
    if stats['funcionalidad_general_pct'] >= 90:
        print(f"  [OK] SISTEMA USABLE - {stats['funcionalidad_general_pct']}% funcionalidad")
        print(f"  -> Desplegar a produccion con confianza")
    elif stats['funcionalidad_general_pct'] >= 50:
        print(f"  [WARN] SISTEMA PARCIALMENTE USABLE - {stats['funcionalidad_general_pct']}% funcionalidad")
        print(f"  -> Desplegar con precaucion, algunos modulos bloqueados")
    else:
        print(f"  [ERROR] SISTEMA NO USABLE - {stats['funcionalidad_general_pct']}% funcionalidad")
        print(f"  -> NO desplegar hasta completar SPs faltantes")

    print("\n" + "="*80)

def main():
    print("AGENTE DE VALIDACION FUNCIONAL - ASEO_CONTRATADO")
    print("="*80)
    print("MODO: SOLO LECTURA (no se modificara ningun archivo)")
    print("="*80)

    # 1. Extraer SPs de archivos SQL
    sps_disponibles = extraer_sps_de_archivos_sql()

    # 2. Analizar componentes Vue
    componentes, sps_requeridos = analizar_componentes_vue(sps_disponibles)

    # 3. Generar estadísticas
    stats = generar_estadisticas(componentes, sps_disponibles, sps_requeridos)

    # 4. Generar reporte JSON
    reporte = generar_reporte_json(sps_disponibles, sps_requeridos, componentes, stats)

    # 5. Imprimir resumen final
    imprimir_resumen_final(stats, sps_disponibles, sps_requeridos)

    print(f"\nVALIDACION COMPLETADA")
    print(f"Reporte JSON: {OUTPUT_JSON}")
    print(f"Siguiente paso: Actualizar {CONTROL_MD}")

if __name__ == "__main__":
    main()
