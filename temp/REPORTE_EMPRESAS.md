# Reporte de Corrección: Módulo Empresas

## Problema Identificado

Al hacer clic en el botón "Buscar" en el módulo Empresas.vue, se recibía el siguiente error:

```
"message": "El Stored Procedure 'recaudadora_empresas' no existe en el esquema 'public'. Esquemas disponibles: catastro_gdl, cnx_com, cnx_merca, comun, comunX, db_egresos, db_gasto2002, db_ingresos, dbestacion, dbingresosvw, guadalajara, informix, informix_migration, multas_reglamentos, padron_licencias, public, publicX. El SP no existe en ningún esquema."
```

## Solución Implementada

### 1. Stored Procedure Creado

**Archivo**: `RefactorX/Base/multas_reglamentos/database/generated/recaudadora_empresas.sql`

**Schema**: `multas_reglamentos`

**Nombre**: `recaudadora_empresas`

**Parámetros**:
- `p_q` (VARCHAR): Filtro de búsqueda (nombre, categoría, ID o clave)
- `p_offset` (INTEGER): Offset para paginación (default: 0)
- `p_limit` (INTEGER): Límite de registros por página (default: 10)

**Retorna**: Tabla con las siguientes columnas
- `empresa` (TEXT): Nombre de la empresa/ejecutor
- `nombre` (TEXT): Nombre de la empresa/ejecutor (duplicado para compatibilidad)
- `rfc` (TEXT): Clave del ejecutor (usado como RFC)
- `contacto` (TEXT): Categoría del ejecutor (usado como contacto)
- `estatus` (TEXT): Estatus ("Activo" o "Inactivo")
- `id_ejecutor` (INTEGER): ID del ejecutor
- `cve_ejecutor` (TEXT): Clave del ejecutor
- `observacion` (TEXT): Observaciones
- `oficio` (TEXT): Número de oficio
- `total_count` (BIGINT): Total de registros que coinciden con el filtro

**Tabla origen**: `comun.ta_15_ejecutores`

**Lógica de búsqueda**:
- Busca en los campos: nombre, categoría, id_ejecutor, cve_eje
- Case-insensitive (no distingue mayúsculas/minúsculas)
- Soporta búsqueda parcial (LIKE '%query%')
- Ordenado alfabéticamente por nombre
- Con paginación (LIMIT y OFFSET)

### 2. Archivo Vue Actualizado

**Archivo**: `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/Empresas.vue`

**Cambio realizado**: Se actualizó la función `reload()` para manejar correctamente el campo `total_count` que viene en cada fila del resultado del SP.

```javascript
// Antes:
total.value = Number(data?.total ?? rows.value.length)

// Después:
total.value = rows.value.length > 0 && rows.value[0].total_count
  ? Number(rows.value[0].total_count)
  : Number(data?.total ?? rows.value.length)
```

### 3. Scripts de Despliegue y Prueba

Se crearon dos scripts para facilitar el despliegue y prueba:

#### a) `temp/deploy_empresas.php`
- Despliega el SP en la base de datos `padron_licencias`
- Verifica que el SP se haya creado correctamente
- Ejecuta 3 ejemplos de prueba

#### b) `temp/test_api_empresas.php`
- Prueba la API genérica llamando al SP
- Simula las llamadas que hace el formulario Vue
- Muestra los resultados de 3 ejemplos

## Pasos para Desplegar

### 1. Iniciar PostgreSQL (si no está corriendo)

### 2. Desplegar el Stored Procedure

```bash
php temp/deploy_empresas.php
```

**Salida esperada**:
```
✅ Conectado a PostgreSQL (DB: padron_licencias)

📄 Desplegando SP: recaudadora_empresas
📂 Desde: [ruta del archivo]

✅ SP recaudadora_empresas desplegado exitosamente

🔍 Verificando existencia del SP...
✅ SP encontrado: multas_reglamentos.recaudadora_empresas(...)

🧪 Probando el SP con ejemplos:
[... resultados de los ejemplos ...]
```

### 3. Verificar que el Backend está corriendo

```bash
# En el directorio RefactorX/BackEnd
php artisan serve
```

El servidor debe estar corriendo en `http://localhost:8000`

### 4. Verificar que el Frontend está corriendo

```bash
# En el directorio RefactorX/FrontEnd
npm run dev
```

El frontend debe estar corriendo en `http://localhost:5173` (o el puerto configurado)

## 3 Ejemplos para Probar el Formulario

### EJEMPLO 1: Buscar todos los registros (Primera página)

**Campo Nombre**: [Dejar vacío o presionar Buscar directamente]

**Resultado esperado**:
- Se muestran los primeros 10 registros de empresas/ejecutores
- La paginación muestra el total de registros disponibles
- Se pueden ver campos como: Empresa, RFC, Contacto, Estatus

**Qué hacer**:
1. Abrir el módulo Empresas en el navegador
2. Dejar el campo "Nombre" vacío
3. Hacer clic en el botón "Buscar"
4. Verificar que se muestran registros en la tabla
5. Verificar que la paginación funciona correctamente

---

### EJEMPLO 2: Buscar por nombre "EJECUTOR"

**Campo Nombre**: EJECUTOR

**Resultado esperado**:
- Se muestran solo los registros que contienen "EJECUTOR" en su nombre o categoría
- El total se actualiza para reflejar solo los registros filtrados
- Los resultados están ordenados alfabéticamente

**Qué hacer**:
1. En el campo "Nombre", escribir: `EJECUTOR`
2. Hacer clic en el botón "Buscar"
3. Verificar que todos los resultados contienen "EJECUTOR" en algún campo
4. Probar la paginación si hay más de 10 resultados

---

### EJEMPLO 3: Buscar por categoría "NOTIFICADOR"

**Campo Nombre**: NOTIFICADOR

**Resultado esperado**:
- Se muestran solo los registros que contienen "NOTIFICADOR" en su nombre o categoría
- El contacto/categoría debería mostrar "NOTIFICADOR" en los resultados
- Si no hay resultados, se muestra "Sin registros"

**Qué hacer**:
1. En el campo "Nombre", escribir: `NOTIFICADOR`
2. Hacer clic en el botón "Buscar"
3. Verificar que todos los resultados tienen relación con "NOTIFICADOR"
4. Si no hay resultados, verificar que se muestre el mensaje "Sin registros"

---

## Prueba Adicional: Botón de Detalle

Para cualquiera de los registros mostrados en los ejemplos anteriores:

1. Hacer clic en el botón con ícono de ojo (👁️) en la columna "Detalle"
2. Debería abrirse un modal mostrando toda la información del registro en formato JSON
3. Verificar que se muestran todos los campos: id_ejecutor, cve_ejecutor, observacion, oficio, etc.
4. Cerrar el modal

## Prueba de Paginación

1. Buscar todos los registros (campo vacío)
2. En el selector "Mostrar", cambiar de 10 a 25 registros
3. Verificar que se muestran 25 registros por página
4. Usar los botones de navegación (◀ ▶) para ir a la siguiente página
5. Verificar que el contador "Mostrando X a Y de Z" se actualiza correctamente

## Estructura de Datos

Cada registro en la tabla tiene la siguiente estructura:

```json
{
  "empresa": "NOMBRE DE LA EMPRESA",
  "nombre": "NOMBRE DE LA EMPRESA",
  "rfc": "CLAVE_RFC",
  "contacto": "CATEGORÍA/TIPO",
  "estatus": "Activo",
  "id_ejecutor": 123,
  "cve_ejecutor": "CLAVE",
  "observacion": "Observaciones adicionales",
  "oficio": "Número de oficio",
  "total_count": 100
}
```

## Notas Técnicas

1. **Schema**: El SP está en el schema `multas_reglamentos`, que es uno de los schemas permitidos en la configuración de `GenericController.php`

2. **Base de datos**: Aunque el módulo es `multas_reglamentos`, usa la base de datos `padron_licencias` según la configuración del backend

3. **Tabla origen**: Los datos vienen de `comun.ta_15_ejecutores`, que contiene el catálogo de ejecutores/empresas externas

4. **Compatibilidad**: El SP usa los mismos campos que `recaudadora_ejecutores` pero con una estructura adaptada para el componente Vue de Empresas

5. **Paginación**: El total de registros se incluye en cada fila mediante el campo `total_count`, lo que permite al frontend mostrar correctamente la paginación sin necesidad de hacer una segunda consulta

## Verificación de Éxito

El despliegue y configuración son exitosos si:

✅ El SP se crea sin errores en el schema `multas_reglamentos`
✅ El script de prueba muestra registros en los 3 ejemplos
✅ El formulario Vue carga sin errores
✅ El botón "Buscar" retorna registros
✅ La paginación funciona correctamente
✅ El modal de detalle muestra la información completa
✅ Los filtros de búsqueda funcionan correctamente

## Archivos Modificados/Creados

### Creados:
- `RefactorX/Base/multas_reglamentos/database/generated/recaudadora_empresas.sql` - SP principal
- `temp/deploy_empresas.php` - Script de despliegue
- `temp/test_api_empresas.php` - Script de prueba de API
- `temp/REPORTE_EMPRESAS.md` - Este documento

### Modificados:
- `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/Empresas.vue` - Actualización de la función reload()

## Comandos Útiles

```bash
# Desplegar el SP
php temp/deploy_empresas.php

# Probar la API directamente
php temp/test_api_empresas.php

# Verificar el SP en la BD (requiere psql)
psql -U postgres -d padron_licencias -c "SELECT * FROM multas_reglamentos.recaudadora_empresas('', 0, 5);"

# Ver la definición del SP (requiere psql)
psql -U postgres -d padron_licencias -c "\df+ multas_reglamentos.recaudadora_empresas"
```

---

**Fecha de creación**: 2025-12-01
**Autor**: Sistema RefactorX / Claude Code
**Módulo**: multas_reglamentos
**Componente**: Empresas.vue
