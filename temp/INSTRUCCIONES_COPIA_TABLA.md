# INSTRUCCIONES: Copiar Tabla ta_11_cuo_locales

## OBJETIVO

Copiar la tabla `ta_11_cuo_locales` desde:
- **Origen**: Base `mercados`, Schema `public`
- **Destino**: Base `padron_licencias`, Schema `comun`

---

## MÉTODOS DISPONIBLES

### Método 1: Script PHP (RECOMENDADO)

Este método es automático y maneja todo el proceso:
- Verifica que la tabla origen existe
- Crea el schema `comun` si no existe
- Crea la tabla con la estructura correcta
- Copia todos los datos
- Copia índices y constraints
- Verifica que todo se copió correctamente

#### Ejecución:

**Opción A - Usando .bat:**
```bash
temp\COPIAR_TA_11_CUO_LOCALES.bat
```

**Opción B - Directamente con PHP:**
```bash
c:\xampp\php\php.exe temp/copiar_ta_11_cuo_locales.php
```

#### Requisitos:
- PostgreSQL debe estar corriendo
- Credenciales: postgres/sistemas
- Puerto: 5432

---

### Método 2: Script SQL con dblink

Este método usa la extensión `dblink` de PostgreSQL para copiar entre bases.

#### Pasos:

1. **Conectar a PostgreSQL:**
   ```bash
   psql -U postgres -d padron_licencias
   ```

2. **Ejecutar script:**
   ```bash
   \i temp/copiar_ta_11_cuo_locales.sql
   ```

#### Nota Importante:
El script SQL con dblink requiere que definas manualmente la estructura de la tabla. Necesitarás obtener primero la estructura real de la tabla con:

```sql
\c mercados
\d public.ta_11_cuo_locales
```

Luego actualiza el script SQL con las columnas correctas.

---

### Método 3: pg_dump y pg_restore (Línea de comandos)

Este es el método más directo si tienes acceso a las herramientas de PostgreSQL.

#### Paso 1: Exportar estructura de la tabla
```bash
pg_dump -U postgres -h localhost -p 5432 -d mercados -t public.ta_11_cuo_locales --schema-only -f temp/ta_11_cuo_locales_estructura.sql
```

#### Paso 2: Editar el archivo para cambiar el schema
Abrir `temp/ta_11_cuo_locales_estructura.sql` y reemplazar:
- `public.ta_11_cuo_locales` → `comun.ta_11_cuo_locales`
- Agregar `CREATE SCHEMA IF NOT EXISTS comun;` al inicio

#### Paso 3: Crear la tabla en destino
```bash
psql -U postgres -d padron_licencias -f temp/ta_11_cuo_locales_estructura.sql
```

#### Paso 4: Copiar los datos
```bash
pg_dump -U postgres -h localhost -p 5432 -d mercados -t public.ta_11_cuo_locales --data-only | sed 's/public\./comun\./g' | psql -U postgres -d padron_licencias
```

---

### Método 4: SQL Manual (Más control)

#### Paso 1: Conectar a mercados y obtener estructura
```sql
\c mercados
\d public.ta_11_cuo_locales
```

#### Paso 2: Crear tabla en destino
```sql
\c padron_licencias
CREATE SCHEMA IF NOT EXISTS comun;

-- Copiar el CREATE TABLE que obtuviste en paso 1
-- y cambiar public.ta_11_cuo_locales por comun.ta_11_cuo_locales
CREATE TABLE comun.ta_11_cuo_locales (
  -- ... columnas aquí ...
);
```

#### Paso 3: Copiar datos usando COPY
```bash
# Exportar datos
psql -U postgres -d mercados -c "\COPY public.ta_11_cuo_locales TO 'temp/ta_11_cuo_locales_data.csv' WITH CSV HEADER"

# Importar datos
psql -U postgres -d padron_licencias -c "\COPY comun.ta_11_cuo_locales FROM 'temp/ta_11_cuo_locales_data.csv' WITH CSV HEADER"
```

---

## VERIFICACIÓN POST-COPIA

Después de copiar, verifica que todo esté correcto:

```sql
-- En mercados (origen)
\c mercados
SELECT COUNT(*) as total_origen FROM public.ta_11_cuo_locales;
\d public.ta_11_cuo_locales

-- En padron_licencias (destino)
\c padron_licencias
SELECT COUNT(*) as total_destino FROM comun.ta_11_cuo_locales;
\d comun.ta_11_cuo_locales

-- Comparar estructura
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'comun' AND table_name = 'ta_11_cuo_locales'
ORDER BY ordinal_position;
```

---

## SOLUCIÓN DE PROBLEMAS

### Error: "Connection refused"
**Problema**: PostgreSQL no está corriendo
**Solución**: Inicia PostgreSQL o verifica que esté corriendo en el puerto 5432

### Error: "Schema comun does not exist"
**Problema**: El schema comun no existe en padron_licencias
**Solución**: El script PHP lo crea automáticamente. Si usas SQL manual, ejecuta:
```sql
CREATE SCHEMA IF NOT EXISTS comun;
```

### Error: "Table already exists"
**Problema**: La tabla ya existe en destino
**Solución**: El script PHP pregunta si quieres eliminarla. Si usas SQL manual:
```sql
DROP TABLE IF EXISTS comun.ta_11_cuo_locales CASCADE;
```

### Error: "Permission denied"
**Problema**: El usuario no tiene permisos
**Solución**: Asegúrate de usar el usuario `postgres` con contraseña `sistemas`

---

## ARCHIVOS CREADOS

1. **temp/copiar_ta_11_cuo_locales.php** - Script PHP automatizado (RECOMENDADO)
2. **temp/COPIAR_TA_11_CUO_LOCALES.bat** - Ejecutable para Windows
3. **temp/copiar_ta_11_cuo_locales.sql** - Script SQL con dblink (requiere ajustes)
4. **temp/INSTRUCCIONES_COPIA_TABLA.md** - Este documento

---

## RECOMENDACIÓN

**Usa el Método 1 (Script PHP)** porque:
- Es completamente automático
- Maneja errores
- Verifica la copia
- Copia índices y constraints
- Muestra progreso
- No requiere configuración manual

Simplemente ejecuta:
```bash
temp\COPIAR_TA_11_CUO_LOCALES.bat
```

Cuando PostgreSQL esté disponible.

---

## CONTEXTO

Esta copia es necesaria porque los stored procedures de EmisionLibertad necesitan acceder a `ta_11_cuo_locales` desde la base `padron_licencias` con schema `comun`, según el patrón de referencia que hemos corregido en otros SPs.
