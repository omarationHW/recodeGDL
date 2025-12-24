# Documentación: newsfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario newsfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario `newsfrm` de Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (Base de datos). El formulario muestra los cambios/notas de versión del sistema y permite al usuario "aceptar" o reconocer los cambios.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Vue.js 3+, componente de página independiente, sin tabs, con breadcrumbs y botón de aceptación.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  - `eRequest`: Nombre de la operación (ej: `get_news_changes`, `acknowledge_news_changes`)
  - `params`: Objeto con parámetros necesarios para la operación
- **Response:**
  - `eResponse`: Objeto con `success`, `data`, `message`

## 4. Stored Procedures
- `get_news_changes()`: Devuelve un listado de los cambios/notas de versión.
- `acknowledge_news_changes(p_user_id)`: Registra que un usuario ha leído los cambios (puede expandirse para auditoría real).

## 5. Frontend (Vue.js)
- Página independiente `/news`.
- Muestra los cambios en formato lista.
- Botón para "Aceptar Cambios" (simula registro de aceptación).
- Breadcrumb de navegación.

## 6. Seguridad
- El endpoint puede protegerse con middleware de autenticación (ej: Sanctum, JWT) si se requiere.
- El parámetro `user_id` debe obtenerse del contexto de usuario autenticado en producción.

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones sin crear nuevos endpoints.
- Los stored procedures pueden expandirse para registrar auditoría real, logs, etc.

## 8. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

## Casos de Uso

# Casos de Uso - newsfrm

**Categoría:** Form

## Caso de Uso 1: Visualización de Cambios del Módulo

**Descripción:** El usuario accede a la página de cambios del módulo y visualiza la lista de notas de versión.

**Precondiciones:**
El usuario tiene acceso a la aplicación y está autenticado.

**Pasos a seguir:**
1. El usuario navega a la ruta /news.
2. El sistema consulta el endpoint /api/execute con eRequest 'get_news_changes'.
3. El sistema muestra la lista de cambios.

**Resultado esperado:**
El usuario ve la lista completa de cambios/notas de versión.

**Datos de prueba:**
No se requiere data específica, solo acceso a la app.

---

## Caso de Uso 2: Aceptar Cambios del Módulo

**Descripción:** El usuario acepta los cambios del módulo presionando el botón correspondiente.

**Precondiciones:**
El usuario ha visualizado la lista de cambios.

**Pasos a seguir:**
1. El usuario presiona el botón 'Aceptar Cambios'.
2. El sistema envía eRequest 'acknowledge_news_changes' con el user_id.
3. El sistema muestra que los cambios han sido aceptados.

**Resultado esperado:**
El botón cambia a 'Cambios Aceptados' y se deshabilita.

**Datos de prueba:**
user_id = 1

---

## Caso de Uso 3: Error por Falta de user_id al Aceptar Cambios

**Descripción:** El sistema maneja el caso en que no se envía user_id al intentar aceptar los cambios.

**Precondiciones:**
El usuario intenta aceptar cambios sin estar autenticado o sin user_id.

**Pasos a seguir:**
1. El usuario presiona 'Aceptar Cambios' sin que el sistema tenga user_id.
2. El sistema envía eRequest 'acknowledge_news_changes' sin user_id.
3. El backend responde con error.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que user_id es requerido.

**Datos de prueba:**
user_id = null

---

## Casos de Prueba

## Casos de Prueba para newsfrm

### Caso 1: Visualización de Cambios
- **Descripción:** El usuario accede a la página y visualiza la lista de cambios.
- **Pasos:**
  1. Acceder a /news
  2. Verificar que se muestra la lista de cambios
- **Resultado esperado:** Se muestran todas las notas de versión correctamente.

### Caso 2: Aceptar Cambios Correctamente
- **Descripción:** El usuario acepta los cambios y el sistema lo registra.
- **Pasos:**
  1. Acceder a /news
  2. Presionar 'Aceptar Cambios'
  3. Verificar que el botón cambia a 'Cambios Aceptados' y se deshabilita
- **Resultado esperado:** El sistema responde con éxito y el botón se actualiza.

### Caso 3: Error por Falta de user_id
- **Descripción:** El usuario intenta aceptar cambios sin user_id.
- **Pasos:**
  1. Acceder a /news
  2. Simular ausencia de user_id en el frontend
  3. Presionar 'Aceptar Cambios'
  4. Verificar que el sistema muestra un mensaje de error
- **Resultado esperado:** El sistema muestra un error indicando que user_id es requerido.

### Caso 4: API - eRequest desconocido
- **Descripción:** Se envía un eRequest no soportado.
- **Pasos:**
  1. POST a /api/execute con eRequest: 'unknown_request'
  2. Verificar respuesta
- **Resultado esperado:** El sistema responde con mensaje de error 'Unknown eRequest: unknown_request'.

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

