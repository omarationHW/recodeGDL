# INSTALACIÓN DE STORED PROCEDURES - MÓDULO CEMENTERIOS

**Versión:** 1.0
**Fecha:** 2025-11-09
**Base de Datos:** padron_licencias (PostgreSQL)
**Total SPs:** 93 stored procedures

---

## ARCHIVOS DISPONIBLES

Este directorio contiene todos los archivos necesarios para instalar los Stored Procedures del módulo Cementerios:

### 📂 Archivos SQL (directorio `ok/`)
- **39 archivos .sql** con 93 stored procedures listos para instalar
- Compatibles con PostgreSQL
- Organizados en orden de instalación

### 📜 Scripts de Instalación

#### Windows
- **INSTALL_CEMENTERIOS_SPS.ps1** - Script PowerShell automático
  - Instalación con un click
  - Log automático
  - Verificación incluida

#### Linux/Mac
- **INSTALL_CEMENTERIOS_SPS.sh** - Script Bash automático
  - Instalación automatizada
  - Colores en consola
  - Verificación incluida

### 📋 Documentación

- **INFORME_DETALLADO_CEMENTERIOS_SPS.md** - Documentación técnica completa
  - Análisis de cada archivo
  - 93 SPs documentados
  - Dependencias y orden de instalación

- **CHECKLIST_INSTALACION_CEMENTERIOS.md** - Checklist manual paso a paso
  - Para instalación manual
  - Verificaciones detalladas
  - Formulario de seguimiento

### 🔍 Scripts de Verificación

- **VERIFICACION_POST_INSTALACION.sql** - Verificación automática
  - Cuenta SPs instalados
  - Valida existencia de SPs críticos
  - Prueba ejecución

---

## OPCIÓN 1: INSTALACIÓN AUTOMÁTICA (RECOMENDADA)

### Para Windows (PowerShell)

1. **Abrir PowerShell como Administrador**

2. **Navegar al directorio:**
   ```powershell
   cd "C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\cementerios\database"
   ```

3. **Ejecutar el script:**
   ```powershell
   .\INSTALL_CEMENTERIOS_SPS.ps1
   ```

4. **Revisar el log generado:**
   ```powershell
   notepad install_cementerios_YYYYMMDD_HHMMSS.log
   ```

### Para Linux/Mac (Bash)

1. **Dar permisos de ejecución:**
   ```bash
   chmod +x INSTALL_CEMENTERIOS_SPS.sh
   ```

2. **Ejecutar el script:**
   ```bash
   ./INSTALL_CEMENTERIOS_SPS.sh
   ```

3. **Revisar el log generado:**
   ```bash
   cat install_cementerios_*.log
   ```

---

## OPCIÓN 2: INSTALACIÓN MANUAL

### Prerrequisitos

1. **PostgreSQL Client instalado**
   - Comando `psql` disponible en PATH
   - Versión PostgreSQL 12+

2. **Credenciales de acceso:**
   - Host: 192.168.6.146
   - Puerto: 5432
   - Base de datos: padron_licencias
   - Usuario: refact
   - Password: FF)-BQk2

3. **Permisos necesarios:**
   - CREATE FUNCTION
   - CREATE PROCEDURE
   - Acceso a tablas del esquema public

### Pasos de Instalación Manual

#### Paso 1: Conectar a PostgreSQL

```bash
psql -h 192.168.6.146 -p 5432 -U refact -d padron_licencias
```

#### Paso 2: Verificar Estado Inicial

```sql
-- Contar SPs actuales
SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public';
```

#### Paso 3: Instalar Archivos en Orden

**IMPORTANTE:** Instalar en este orden exacto:

##### FASE 1: CORE (3 archivos - 22 SPs)

```bash
# 1. SPs CORE
psql -h 192.168.6.146 -U refact -d padron_licencias -f "ok/01_SP_CEMENTERIOS_CORE_all_procedures.sql"

# 2. SPs GESTIÓN
psql -h 192.168.6.146 -U refact -d padron_licencias -f "ok/02_SP_CEMENTERIOS_GESTION_all_procedures.sql"

# 3. SPs ABC
psql -h 192.168.6.146 -U refact -d padron_licencias -f "ok/03_SP_CEMENTERIOS_ABC_all_procedures.sql"
```

##### FASE 2: EXACTO (36 archivos - 71 SPs)

```bash
# 4-39. Instalar archivos EXACTO en orden numérico
psql -h 192.168.6.146 -U refact -d padron_licencias -f "ok/01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql"
psql -h 192.168.6.146 -U refact -d padron_licencias -f "ok/02_SP_CEMENTERIOS_ABCRECARGOS_EXACTO_all_procedures.sql"
# ... (continuar con el resto de archivos)
```

**Ver orden completo en:** `CHECKLIST_INSTALACION_CEMENTERIOS.md`

#### Paso 4: Verificar Instalación

```bash
psql -h 192.168.6.146 -U refact -d padron_licencias -f "VERIFICACION_POST_INSTALACION.sql"
```

---

## OPCIÓN 3: INSTALACIÓN CON CHECKLIST

**Para instalación manual detallada con seguimiento:**

1. Abrir archivo: `CHECKLIST_INSTALACION_CEMENTERIOS.md`
2. Seguir paso a paso
3. Marcar cada checkbox completado
4. Documentar errores encontrados

---

## VERIFICACIÓN POST-INSTALACIÓN

### Verificación Rápida

```sql
-- Contar SPs instalados
SELECT COUNT(*) as total_sps
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (routine_name LIKE 'sp_%' OR routine_name LIKE 'SP_CEMENTERIOS_%');
```

**Resultado esperado:** 93 SPs (o el total de SPs únicos)

### Verificación Completa

```bash
psql -h 192.168.6.146 -U refact -d padron_licencias -f "VERIFICACION_POST_INSTALACION.sql" > verificacion_resultado.txt
```

### Pruebas de Ejecución

```sql
-- Test 1: Estadísticas generales
SELECT * FROM SP_CEMENTERIOS_ESTADISTICAS();

-- Test 2: Lista de cementerios
SELECT * FROM SP_CEMENTERIOS_CEMENTERIOS_LIST();

-- Test 3: Estadísticas de adeudos
SELECT * FROM sp_estad_adeudo_resumen();

-- Test 4: Dashboard
SELECT * FROM SP_CEMENTERIOS_DASHBOARD_RESUMEN();
```

---

## SOLUCIÓN DE PROBLEMAS

### Error: "psql: command not found"

**Causa:** PostgreSQL Client no está instalado o no está en PATH

**Solución Windows:**
1. Instalar PostgreSQL Client
2. Agregar al PATH: `C:\Program Files\PostgreSQL\15\bin`

**Solución Linux:**
```bash
sudo apt-get install postgresql-client
```

**Solución Mac:**
```bash
brew install postgresql
```

---

### Error: "password authentication failed"

**Causa:** Credenciales incorrectas

**Solución:**
1. Verificar password: `FF)-BQk2`
2. Verificar usuario: `refact`
3. Verificar que el usuario tiene permisos

---

### Error: "relation does not exist"

**Causa:** Tablas necesarias no existen en la base de datos

**Solución:**
1. Verificar qué tabla falta en el mensaje de error
2. Crear la tabla antes de instalar SPs
3. O instalar solo SPs que no dependen de esa tabla

**Tablas críticas:**
- ta_13_datosrcm
- ta_13_adeudosrcm
- ta_13_bonifrcm
- tc_13_cementerios
- difuntos
- cementerios
- lotes

---

### Error: "permission denied"

**Causa:** Usuario no tiene permisos

**Solución:**
```sql
-- Ejecutar como usuario postgres o admin
GRANT ALL PRIVILEGES ON SCHEMA public TO refact;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO refact;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO refact;
```

---

### Archivos duplicados (13-24 vs 01-12)

**Situación:** Algunos archivos parecen duplicados

**Solución:**
1. Instalar solo la primera versión (01-12)
2. O revisar diferencias entre versiones
3. Decidir si ambas versiones son necesarias

**Verificar duplicados:**
```bash
diff ok/01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql ok/13_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql
```

---

## ESTRUCTURA DE ARCHIVOS

```
cementerios/database/
│
├── ok/                                    # Directorio con 39 archivos SQL
│   ├── 01_SP_CEMENTERIOS_CORE_all_procedures.sql
│   ├── 02_SP_CEMENTERIOS_GESTION_all_procedures.sql
│   ├── 03_SP_CEMENTERIOS_ABC_all_procedures.sql
│   ├── 01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql
│   ├── ... (35 archivos más)
│   └── 36_SP_CEMENTERIOS_SFRM_CHGPASS_EXACTO_all_procedures.sql
│
├── INSTALL_CEMENTERIOS_SPS.sh            # Script Bash
├── INSTALL_CEMENTERIOS_SPS.ps1           # Script PowerShell
├── VERIFICACION_POST_INSTALACION.sql     # Verificación automática
├── CHECKLIST_INSTALACION_CEMENTERIOS.md  # Checklist manual
├── INFORME_DETALLADO_CEMENTERIOS_SPS.md  # Documentación completa
└── README_INSTALACION.md                 # Este archivo
```

---

## LOGS DE INSTALACIÓN

Los scripts automáticos generan logs con este formato:

**Nombre:** `install_cementerios_YYYYMMDD_HHMMSS.log`

**Contenido:**
- Timestamp de inicio
- SPs antes de instalar
- Resultado de cada archivo
- Errores encontrados
- Verificaciones
- Resumen final
- Timestamp de fin

**Ubicación:** Mismo directorio donde se ejecutó el script

---

## MÉTRICAS ESPERADAS

| Métrica | Valor Esperado |
|---------|----------------|
| Total archivos | 39 |
| Total SPs | 93 (o menos si hay duplicados) |
| Archivos CORE | 3 |
| Archivos EXACTO | 36 |
| SPs CORE | 22 |
| SPs EXACTO | 71 |
| Tiempo instalación | 5-10 minutos |
| Errores esperados | 0-5 (tablas faltantes) |

---

## PRÓXIMOS PASOS DESPUÉS DE INSTALAR

### 1. Crear Datos de Prueba (si no existen)

```sql
-- Insertar cementerio de prueba
INSERT INTO cementerios (codigo_cementerio, nombre, direccion, capacidad_total, estado, fecha_apertura)
VALUES ('CEM001', 'Cementerio de Prueba', 'Calle Prueba 123', 100, 'ACTIVO', CURRENT_DATE);

-- Verificar
SELECT * FROM SP_CEMENTERIOS_CEMENTERIOS_LIST();
```

### 2. Probar Integración con Backend

**Archivo:** `RefactorX/BackEnd/GenericController.php`

- Verificar que puede conectarse a PostgreSQL
- Probar llamada a SPs desde PHP
- Verificar respuestas JSON

### 3. Probar Integración con Frontend

**Archivo:** `RefactorX/FrontEnd/apiService.js`

- Verificar endpoints activos
- Probar desde componentes Vue
- Verificar renderizado de datos

### 4. Documentar para Desarrolladores

Crear documentación de cada SP con:
- Propósito
- Parámetros de entrada
- Estructura de salida
- Ejemplo de uso
- Casos de error

---

## CONTACTO Y SOPORTE

**Si encuentras problemas:**

1. ✓ Revisar el log de instalación
2. ✓ Consultar sección "Solución de Problemas" arriba
3. ✓ Ejecutar script de verificación
4. ✓ Consultar `INFORME_DETALLADO_CEMENTERIOS_SPS.md`
5. ✓ Documentar el error en el checklist
6. ✓ Contactar al equipo de desarrollo

---

## CHANGELOG

### Versión 1.0 (2025-11-09)
- ✓ Creación inicial de todos los scripts
- ✓ 39 archivos SQL con 93 SPs
- ✓ Scripts de instalación para Windows y Linux
- ✓ Documentación completa
- ✓ Checklist de instalación
- ✓ Script de verificación

---

## LICENCIA Y NOTAS

**RESTRICCIONES:**
- ⚠ **NO MODIFICAR BACKEND** durante instalación
- ⚠ **NO MODIFICAR FRONTEND** durante instalación
- ⚠ **SOLO TRABAJAR CON BASE DE DATOS**
- ⚠ **NO hacer INSERT/UPDATE/DELETE de datos** (solo SELECT en verificación)

**BACKUP:**
- ✓ Siempre hacer backup antes de instalar
- ✓ Comando: `pg_dump -h 192.168.6.146 -U refact padron_licencias > backup_pre_cementerios.sql`

---

**LISTO PARA INSTALACIÓN**

Todos los archivos están preparados y listos para instalar en PostgreSQL.

Selecciona el método de instalación que prefieras (Automático o Manual) y sigue las instrucciones.

¡Buena suerte! 🚀
