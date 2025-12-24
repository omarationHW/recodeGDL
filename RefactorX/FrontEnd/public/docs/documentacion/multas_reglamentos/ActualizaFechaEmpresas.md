# Documentación: ActualizaFechaEmpresas

## Análisis Técnico

# Documentación Técnica: Actualiza Fecha de Práctica de Empresas

## Descripción General
Este módulo permite cargar un archivo de texto con folios de empresas y actualizar en lote la fecha de práctica (`fecent`) de los folios de requerimientos de empresas en la base de datos PostgreSQL. La migración respeta la lógica original Delphi, pero modernizada para Laravel + Vue.js + PostgreSQL.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js de página completa (sin tabs)
- **Base de Datos:** PostgreSQL con stored procedure para actualización
- **API:** Todas las acciones se ejecutan vía `/api/execute` con parámetros `action` y `params`

## Flujo de Trabajo
1. **Carga de Archivo:** El usuario selecciona un archivo de texto plano con los folios a procesar.
2. **Parseo:** El archivo se parsea y se muestra una tabla con los folios y sus datos.
3. **Actualización:** El usuario puede actualizar individualmente o en lote la fecha de práctica de los folios seleccionados.
4. **Resultados:** Se muestran los folios procesados, correctos, incorrectos y los errores encontrados.

## API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Métodos soportados:**
  - `parse_file`: Parsea el archivo de texto y devuelve los folios
  - `get_empresa_info`: Obtiene información de la empresa por folio/cuenta
  - `actualiza_fechas`: Actualiza la fecha de práctica de uno o varios folios

### Ejemplo de Request
```json
{
  "action": "actualiza_fechas",
  "params": {
    "folios": [
      { "clave_cuenta": 12345, "folio": 678, "anio_folio": 2023, "fecha_practica": "2024-06-01" }
    ]
  }
}
```

### Ejemplo de Response
```json
{
  "success": true,
  "message": "Actualización finalizada",
  "data": {
    "aplicados": 1,
    "pendientes": 0,
    "errores": []
  }
}
```

## Stored Procedure
- **sp_actualiza_fecha_practica**: Actualiza el campo `fecent` en la tabla `reqpredial` para el folio indicado.

## Seguridad
- Todas las acciones requieren autenticación Laravel (middleware estándar).
- Validación de parámetros en backend.

## Consideraciones
- El archivo de texto debe estar delimitado por `|` y contener los campos en el orden esperado.
- El proceso es idempotente: si un folio no existe, se reporta como error pero no detiene el proceso.
- El frontend permite ver el resultado de cada folio y los errores detallados.

## Extensibilidad
- Se pueden agregar más stored procedures para otras operaciones relacionadas con empresas.
- El endpoint `/api/execute` puede ser extendido para otras acciones del sistema.

## Casos de Uso

# Casos de Uso - ActualizaFechaEmpresas

**Categoría:** Form

## Caso de Uso 1: Carga y actualización masiva de fechas de práctica para empresas

**Descripción:** El usuario carga un archivo de texto con folios de empresas y actualiza en lote la fecha de práctica de todos los folios.

**Precondiciones:**
El usuario tiene permisos de acceso y el archivo de texto está correctamente formateado.

**Pasos a seguir:**
1. El usuario accede a la página de Actualiza Fecha de Empresas.
2. Selecciona el ejecutor y la fecha de corte.
3. Selecciona el archivo de texto y lo carga.
4. Visualiza la tabla de folios parseados.
5. Presiona 'Actualizar Todos'.
6. El sistema procesa y actualiza los folios en la base de datos.

**Resultado esperado:**
Todos los folios existentes se actualizan correctamente. Se muestra un resumen de folios aplicados, pendientes y errores.

**Datos de prueba:**
Archivo de texto con 10 folios válidos y 2 con cuentas inexistentes.

---

## Caso de Uso 2: Actualización individual de fecha de práctica para un folio

**Descripción:** El usuario actualiza la fecha de práctica de un solo folio desde la tabla.

**Precondiciones:**
El folio existe en la base de datos.

**Pasos a seguir:**
1. El usuario carga el archivo de texto.
2. Visualiza la tabla de folios.
3. Presiona 'Actualizar' en la fila deseada.
4. El sistema actualiza solo ese folio.

**Resultado esperado:**
El folio seleccionado se actualiza y su estado cambia a 'ACTUALIZADO'.

**Datos de prueba:**
Archivo de texto con al menos un folio válido.

---

## Caso de Uso 3: Manejo de errores al actualizar folios inexistentes

**Descripción:** El sistema debe manejar correctamente los folios que no existen en la base de datos.

**Precondiciones:**
El archivo contiene folios con cuentas inexistentes.

**Pasos a seguir:**
1. El usuario carga el archivo de texto.
2. Presiona 'Actualizar Todos'.
3. El sistema procesa y reporta los folios inexistentes como errores.

**Resultado esperado:**
Los folios inexistentes aparecen en la lista de errores y no se actualizan.

**Datos de prueba:**
Archivo de texto con 5 folios válidos y 3 inválidos.

---

## Casos de Prueba

# Casos de Prueba: Actualiza Fecha de Práctica de Empresas

## Caso 1: Carga y actualización masiva exitosa
- **Precondición:** Archivo de texto con 10 folios válidos
- **Pasos:**
  1. Cargar archivo
  2. Seleccionar ejecutor y fecha
  3. Presionar 'Actualizar Todos'
- **Resultado esperado:**
  - 10 folios actualizados
  - 0 errores
  - Resumen correcto

## Caso 2: Error en folios inexistentes
- **Precondición:** Archivo con 5 folios válidos y 3 inválidos
- **Pasos:**
  1. Cargar archivo
  2. Seleccionar ejecutor y fecha
  3. Presionar 'Actualizar Todos'
- **Resultado esperado:**
  - 5 folios actualizados
  - 3 errores reportados en la lista de errores

## Caso 3: Actualización individual
- **Precondición:** Archivo con al menos 1 folio válido
- **Pasos:**
  1. Cargar archivo
  2. Seleccionar ejecutor y fecha
  3. Presionar 'Actualizar' en la fila del folio
- **Resultado esperado:**
  - El folio cambia a estado 'ACTUALIZADO'
  - Resumen actualizado correctamente

## Caso 4: Validación de campos obligatorios
- **Precondición:** No se selecciona archivo o fecha
- **Pasos:**
  1. Intentar actualizar sin archivo o sin fecha
- **Resultado esperado:**
  - Mensaje de error indicando campos obligatorios

## Caso 5: Archivo malformado
- **Precondición:** Archivo de texto con líneas vacías o delimitadores incorrectos
- **Pasos:**
  1. Cargar archivo
  2. Intentar parsear
- **Resultado esperado:**
  - Mensaje de error o líneas ignoradas correctamente

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

