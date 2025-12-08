# DocumentaciÃ³n TÃ©cnica: Rep_Tipos_Aseo

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Rep_Tipos_Aseo (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa la funcionalidad de impresión y consulta de Tipos de Aseo, migrando el formulario Delphi `Rep_Tipos_Aseo` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Backend**: Laravel Controller expone un endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb y tabla de resultados.
- **Base de Datos**: Toda la lógica SQL se encapsula en stored procedures PostgreSQL.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint**: `POST /api/execute`
- **Request**:
  ```json
  {
    "action": "getTiposAseoReport",
    "params": { "order": 1 }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [ { "ctrol_aseo": 1, "tipo_aseo": "O", "descripcion": "Ordinario" }, ... ],
    "message": ""
  }
  ```

## 4. Stored Procedure
- **sp_rep_tipos_aseo_report(order)**: Devuelve el listado de tipos de aseo ordenado por Control, Tipo o Descripción según parámetro.
- **Parámetro**: `order` (1=Control, 2=Tipo, 3=Descripción)
- **Retorno**: Tabla con columnas `ctrol_aseo`, `tipo_aseo`, `descripcion`.

## 5. Frontend (Vue.js)
- Página independiente `/rep-tipos-aseo`.
- Permite seleccionar el orden del reporte (Control, Tipo, Descripción).
- Botón "Vista Previa" ejecuta la consulta y muestra los resultados en tabla.
- Botón "Salir" regresa a la página anterior.
- Breadcrumb para navegación.
- Mensajes de error y loading.

## 6. Backend (Laravel)
- Controlador `RepTiposAseoController` con método `execute`.
- Llama al stored procedure vía DB::select.
- Soporta acciones:
  - `getTiposAseoReport` (principal)
  - `getTiposAseoOptions` (para combos, si se requiere)
- Manejo de errores y logging.

## 7. Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- Validar que el parámetro `order` sea 1, 2 o 3.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin crear nuevos endpoints.
- El frontend puede extenderse para exportar a Excel, imprimir, etc.

## 9. Consideraciones de Migración
- El reporte QuickReport de Delphi se reemplaza por una tabla HTML en Vue.js.
- No se implementa impresión directa; para impresión avanzada, se recomienda exportar a PDF o usar librerías JS.
- No se usan tabs ni componentes tabulares: cada formulario es una página independiente.

## 10. Ejemplo de Uso
- El usuario accede a `/rep-tipos-aseo`, selecciona el orden, pulsa "Vista Previa" y ve el listado ordenado.



## Casos de Prueba

# Casos de Prueba: Rep_Tipos_Aseo

## Caso 1: Consulta por Control
- **Input:** POST /api/execute { action: 'getTiposAseoReport', params: { order: 1 } }
- **Resultado esperado:** HTTP 200, success: true, data: array ordenada por ctrol_aseo ascendente.

## Caso 2: Consulta por Tipo
- **Input:** POST /api/execute { action: 'getTiposAseoReport', params: { order: 2 } }
- **Resultado esperado:** HTTP 200, success: true, data: array ordenada por tipo_aseo ascendente.

## Caso 3: Consulta por Descripción
- **Input:** POST /api/execute { action: 'getTiposAseoReport', params: { order: 3 } }
- **Resultado esperado:** HTTP 200, success: true, data: array ordenada por descripcion ascendente.

## Caso 4: Parámetro inválido
- **Input:** POST /api/execute { action: 'getTiposAseoReport', params: { order: 99 } }
- **Resultado esperado:** HTTP 200, success: false, message: 'Acción no soportada' o error de parámetro.

## Caso 5: Sin datos
- **Input:** POST /api/execute { action: 'getTiposAseoReport', params: { order: 1 } } (con tabla vacía)
- **Resultado esperado:** HTTP 200, success: true, data: []

## Caso 6: Seguridad
- **Input:** POST /api/execute sin autenticación
- **Resultado esperado:** HTTP 401 Unauthorized


## Casos de Uso

# Casos de Uso - Rep_Tipos_Aseo

**Categoría:** Form

## Caso de Uso 1: Consulta de Tipos de Aseo ordenados por Control

**Descripción:** El usuario desea ver el listado de tipos de aseo ordenados por número de control.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo de reportes.

**Pasos a seguir:**
1. Acceder a la página '/rep-tipos-aseo'.
2. Seleccionar la opción 'Control' en el grupo de ordenamiento.
3. Pulsar el botón 'Vista Previa'.

**Resultado esperado:**
Se muestra una tabla con todos los tipos de aseo ordenados ascendentemente por el campo 'ctrol_aseo'.

**Datos de prueba:**
Tabla ta_16_tipo_aseo con al menos 3 registros distintos.

---

## Caso de Uso 2: Consulta de Tipos de Aseo ordenados por Descripción

**Descripción:** El usuario requiere ver los tipos de aseo ordenados alfabéticamente por descripción.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Acceder a '/rep-tipos-aseo'.
2. Seleccionar 'Descripción' como criterio de orden.
3. Pulsar 'Vista Previa'.

**Resultado esperado:**
La tabla muestra los tipos de aseo ordenados alfabéticamente por el campo 'descripcion'.

**Datos de prueba:**
ta_16_tipo_aseo: {ctrol_aseo: 1, tipo_aseo: 'O', descripcion: 'Ordinario'}, {ctrol_aseo: 2, tipo_aseo: 'H', descripcion: 'Hospitalario'}

---

## Caso de Uso 3: Manejo de error por parámetro inválido

**Descripción:** El usuario o el frontend envía un parámetro de orden inválido.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Realizar una petición POST a /api/execute con {action: 'getTiposAseoReport', params: {order: 99}}.

**Resultado esperado:**
El backend responde con success: false y un mensaje de error indicando que el parámetro es inválido.

**Datos de prueba:**
order=99

---



---
**Componente:** `Rep_Tipos_Aseo.vue`
**MÃ³dulo:** `aseo_contratado`

