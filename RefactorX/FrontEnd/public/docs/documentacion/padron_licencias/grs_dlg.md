# Documentación Técnica: grs_dlg

## Análisis Técnico
# Documentación Técnica: Migración de Formulario grs_dlg (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la funcionalidad de búsqueda rápida de registros en una tabla/campo arbitrario, similar al formulario grs_dlg de Delphi, migrado a una arquitectura moderna:
- **Backend:** Laravel (PHP) + PostgreSQL (Stored Procedure)
- **Frontend:** Vue.js (SPA, página independiente)
- **API:** Unificada, patrón eRequest/eResponse, endpoint único `/api/execute`

## 2. Arquitectura
- **Frontend:**
  - Componente Vue.js como página completa, sin tabs.
  - Permite al usuario seleccionar tabla, campo, valor, y opciones de búsqueda.
  - Muestra resultados en tabla dinámica.
- **Backend:**
  - Controlador Laravel `ExecuteController` con método `execute`.
  - Recibe `eRequest` y `params`, despacha a stored procedure.
- **Base de Datos:**
  - Stored Procedure `sp_grs_dlg_search` realiza la búsqueda dinámica en cualquier tabla/campo.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "eRequest": "grs_dlg_search",
    "params": {
      "table": "nombre_tabla",
      "field": "nombre_campo",
      "value": "texto_busqueda",
      "case_insensitive": true,
      "partial": true
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_grs_dlg_search`
- **Parámetros:**
  - `p_table`: nombre de la tabla
  - `p_field`: nombre del campo
  - `p_value`: valor a buscar
  - `p_case_insensitive`: booleano (ILIKE vs LIKE)
  - `p_partial`: booleano (búsqueda parcial o exacta)
- **Retorno:** SETOF RECORD (todas las columnas de la tabla)
- **Seguridad:**
  - Solo debe usarse para tablas/campos permitidos (validar en producción).

## 5. Validaciones y Seguridad
- El controlador valida que `table` y `field` estén presentes.
- En producción, se recomienda validar que la tabla/campo sean permitidos para evitar SQL Injection.
- El stored procedure usa `format` y parámetros para evitar inyección.

## 6. Frontend
- Página Vue.js independiente, con formulario y tabla de resultados.
- Permite limpiar formulario y volver a buscar.
- Muestra mensajes de error y estados de carga.

## 7. Extensibilidad
- Se pueden agregar más eRequest en el mismo endpoint para otras funcionalidades.

## 8. Instalación
- Crear el stored procedure en PostgreSQL.
- Registrar la ruta en Laravel:
  ```php
  Route::post('/api/execute', [\App\Http\Controllers\Api\ExecuteController::class, 'execute']);
  ```
- Agregar el componente Vue.js en el router de la SPA.

## 9. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.

## Casos de Prueba
## Casos de Prueba para grs_dlg (Laravel + Vue.js + PostgreSQL)

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Búsqueda parcial insensible en clientes | table: clientes, field: nombre, value: juan, case_insensitive: true, partial: true | Lista de clientes con 'juan' en el nombre (mayúsculas/minúsculas indiferente) |
| 2 | Búsqueda exacta sensible en productos | table: productos, field: codigo, value: ABC123, case_insensitive: false, partial: false | Solo el producto con código exactamente 'ABC123' |
| 3 | Búsqueda sin resultados | table: proveedores, field: razon_social, value: ZZZZZZ, case_insensitive: true, partial: true | Mensaje 'No se encontraron resultados.' |
| 4 | Campo tabla vacío | table: '', field: nombre, value: juan | Mensaje de error 'Missing table or field parameter.' |
| 5 | Campo field vacío | table: clientes, field: '', value: juan | Mensaje de error 'Missing table or field parameter.' |
| 6 | Búsqueda con valor vacío | table: clientes, field: nombre, value: '', case_insensitive: true, partial: true | Todos los registros de clientes (búsqueda con '%') |
| 7 | SQL Injection en campo tabla | table: 'clientes; DROP TABLE clientes;', field: nombre, value: juan | Error de SQL o validación (no debe ejecutarse) |

### Notas:
- Probar con y sin mayúsculas/minúsculas.
- Probar con y sin búsqueda parcial.
- Probar con tablas/campos inexistentes para validar manejo de errores.

## Casos de Uso
# Casos de Uso - grs_dlg

**Categoría:** Form

## Caso de Uso 1: Búsqueda parcial insensible a mayúsculas/minúsculas en clientes

**Descripción:** El usuario busca todos los clientes cuyo nombre contiene 'juan', sin importar mayúsculas/minúsculas.

**Precondiciones:**
La tabla 'clientes' existe y tiene un campo 'nombre'.

**Pasos a seguir:**
1. Ingresar 'clientes' en el campo Tabla.
2. Ingresar 'nombre' en el campo Campo.
3. Ingresar 'juan' en el campo Valor a buscar.
4. Seleccionar 'No distinguir' en Mayúsculas/Minúsculas.
5. Seleccionar 'Sí' en Búsqueda parcial.
6. Presionar 'Buscar'.

**Resultado esperado:**
Se muestran todos los registros de clientes cuyo nombre contiene 'juan', como 'Juan Pérez', 'JUANITA', 'María Juan'.

**Datos de prueba:**
Tabla: clientes
Campo: nombre
Valor: juan
case_insensitive: true
partial: true

---

## Caso de Uso 2: Búsqueda exacta y sensible a mayúsculas/minúsculas en productos

**Descripción:** El usuario busca productos cuyo código es exactamente 'ABC123', distinguiendo mayúsculas/minúsculas.

**Precondiciones:**
La tabla 'productos' existe y tiene un campo 'codigo'.

**Pasos a seguir:**
1. Ingresar 'productos' en el campo Tabla.
2. Ingresar 'codigo' en el campo Campo.
3. Ingresar 'ABC123' en el campo Valor a buscar.
4. Seleccionar 'Distinguir' en Mayúsculas/Minúsculas.
5. Seleccionar 'No' en Búsqueda parcial.
6. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra solo el producto cuyo código es exactamente 'ABC123'.

**Datos de prueba:**
Tabla: productos
Campo: codigo
Valor: ABC123
case_insensitive: false
partial: false

---

## Caso de Uso 3: Búsqueda sin resultados

**Descripción:** El usuario busca un valor inexistente en la tabla de proveedores.

**Precondiciones:**
La tabla 'proveedores' existe y tiene un campo 'razon_social'.

**Pasos a seguir:**
1. Ingresar 'proveedores' en el campo Tabla.
2. Ingresar 'razon_social' en el campo Campo.
3. Ingresar 'ZZZZZZ' en el campo Valor a buscar.
4. Presionar 'Buscar'.

**Resultado esperado:**
No se muestran resultados y aparece el mensaje 'No se encontraron resultados.'

**Datos de prueba:**
Tabla: proveedores
Campo: razon_social
Valor: ZZZZZZ
case_insensitive: true
partial: true

---
