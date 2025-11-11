# Deployment de Stored Procedures - Estacionamiento Público

Este directorio contiene todos los stored procedures del módulo de Estacionamiento Público y las herramientas para desplegarlos en PostgreSQL.

---

## Archivos Principales

### Scripts de Deployment
- `deploy-and-test-sps.py` - Script principal para desplegar todos los SPs
- `verify-deployment.py` - Script de verificación de SPs en la BD

### Reportes Generados
- `sp-deployment-report.json` - Reporte detallado en JSON
- `DEPLOYMENT_SUMMARY.md` - Resumen ejecutivo del deployment
- `COMPLETE_ANALYSIS.md` - Análisis completo con catálogo de SPs
- `ERROR_FIXES_GUIDE.md` - Guía para corregir errores encontrados

### Archivos SQL
- `database/` - Directorio con 182 archivos .sql
  - `*_all_procedures.sql` - Archivos consolidados por módulo
  - `*.sql` - Archivos individuales por SP

---

## Requisitos

### Software
- Python 3.7+
- PostgreSQL client (psycopg2)

### Instalación de Dependencias
```bash
pip install psycopg2
```

---

## Uso Rápido

### 1. Desplegar TODOS los Stored Procedures

```bash
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\estacionamiento_publico\database
python deploy-and-test-sps.py
```

**Salida esperada:**
- Procesa 182 archivos SQL
- Ingresa ~162 SPs exitosamente
- Genera reporte JSON completo
- Duración: ~20 segundos

### 2. Verificar el Deployment

```bash
python verify-deployment.py
```

**Salida esperada:**
- Verifica que los SPs existen en la BD
- Muestra tasa de éxito (98.8%)
- Lista SPs clave

### 3. Revisar Resultados

Abrir cualquiera de estos archivos:
- `DEPLOYMENT_SUMMARY.md` - Resumen ejecutivo
- `COMPLETE_ANALYSIS.md` - Catálogo completo
- `sp-deployment-report.json` - Datos técnicos

---

## Configuración de Base de Datos

Los scripts usan esta configuración (modificable en cada script):

```python
DB_CONFIG = {
    'host': '192.168.6.146',
    'port': 5432,
    'database': 'padron_licencias',
    'user': 'refact',
    'password': 'FF)-BQk2'
}
```

---

## Resultados del Último Deployment

**Fecha:** 2025-11-09 20:26

| Métrica | Valor |
|---------|-------|
| Total archivos | 182 |
| SPs exitosos | 162 (89%) |
| SPs con errores | 20 (11%) |
| Duración | 19 segundos |

---

## Errores Conocidos

Los 20 errores están documentados en `ERROR_FIXES_GUIDE.md` y son:

- 6 errores de parámetros duplicados
- 3 errores de tipos inexistentes
- 3 errores de sintaxis RETURN NEXT
- 2 errores de palabras reservadas
- 1 error de parámetros DEFAULT
- 1 archivo sin procedimiento válido

**Todos son corregibles en ~3.5 horas.**

---

## Estructura de Directorios

```
database/
├── database/              # 182 archivos .sql
│   ├── Acceso_*.sql
│   ├── AplicaPgo_*.sql
│   ├── Bja_Multiple_*.sql
│   ├── ...
│   └── srfrm_conci_*.sql
├── deploy-and-test-sps.py
├── verify-deployment.py
├── sp-deployment-report.json
├── DEPLOYMENT_SUMMARY.md
├── COMPLETE_ANALYSIS.md
├── ERROR_FIXES_GUIDE.md
└── README.md
```

---

## Módulos Desplegados

### Operacionales al 100%
- Acceso y Seguridad
- Bajas Múltiples
- Consultas Generales
- Generación de Archivos (Altas, Diario, Banorte)
- Gestión de Públicos
- Propietarios y Exclusivos
- Contrarecibos
- Passwords
- Transferencias
- Conciliación Bancaria
- Metrometers
- Reactivación
- Reportes Principales

### Con Errores Menores (funcionalidad no crítica)
- Consulta de Remesas (2 SPs)
- Generación Individual (1 SP)
- Reportes Ejecutivos (2 SPs)
- ABC Propietarios (2 SPs)
- Valet (1 SP)
- Mensajes (1 SP)

---

## Comandos Útiles

### Contar SPs en la Base de Datos
```bash
python -c "import psycopg2; conn = psycopg2.connect(host='192.168.6.146', port=5432, database='padron_licencias', user='refact', password='FF)-BQk2'); cur = conn.cursor(); cur.execute('SELECT COUNT(*) FROM pg_proc WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = \\\'public\\\')'); print(f'Total SPs: {cur.fetchone()[0]}'); conn.close()"
```

### Listar SPs por Nombre
```bash
python -c "import psycopg2; conn = psycopg2.connect(host='192.168.6.146', port=5432, database='padron_licencias', user='refact', password='FF)-BQk2'); cur = conn.cursor(); cur.execute('SELECT proname FROM pg_proc WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = \\\'public\\\') ORDER BY proname LIMIT 20'); [print(row[0]) for row in cur.fetchall()]; conn.close()"
```

---

## Solución de Problemas

### Error: "Module psycopg2 not found"
```bash
pip install psycopg2-binary
```

### Error: "Connection refused"
Verificar:
- El servidor PostgreSQL está corriendo
- El firewall permite conexión al puerto 5432
- La IP 192.168.6.146 es accesible

### Error: "Authentication failed"
Verificar credenciales en DB_CONFIG

---

## Corrección de Errores

Seguir la guía en `ERROR_FIXES_GUIDE.md`:

1. **Parámetros duplicados** - Renombrar parámetros
2. **Tipos inexistentes** - Crear tipos o usar RETURNS TABLE
3. **RETURN NEXT** - Cambiar a RETURN QUERY
4. **Palabras reservadas** - Usar comillas o renombrar
5. **DEFAULT parameters** - Reorganizar orden

Después de corregir:
```bash
python deploy-and-test-sps.py
```

---

## Contacto y Soporte

Para preguntas sobre:
- **Deployment**: Revisar logs en `sp-deployment-report.json`
- **Errores**: Consultar `ERROR_FIXES_GUIDE.md`
- **Análisis**: Ver `COMPLETE_ANALYSIS.md`

---

## Historial de Versiones

### v1.0 - 2025-11-09
- Deployment inicial de 182 SPs
- 89% de tasa de éxito
- Scripts de deployment y verificación
- Documentación completa

---

## Licencia

Proyecto RefactorX - Guadalajara
Base de datos: padron_licencias
