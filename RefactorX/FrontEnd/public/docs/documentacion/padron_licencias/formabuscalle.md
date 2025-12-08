# Documentación Técnica: formabuscalle

## Análisis Técnico
# Documentación Técnica: Migración de Formulario Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `formabuscalle` al stack Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es permitir la búsqueda y selección de calles, excluyendo aquellas marcadas como ocultas en la tabla `c_calles_escondidas`.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, página independiente para el formulario de búsqueda de calles.
- **Backend:** Laravel API, endpoint unificado `/api/execute` bajo el patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de negocio encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "buscar_calles", // o "listar_calles"
    "params": {
      "filtro": "texto a buscar" // solo para buscar_calles
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedures
- **sp_buscar_calles(filtro TEXT):** Devuelve las calles cuyo nombre contiene el filtro, excluyendo las ocultas.
- **sp_listar_calles():** Devuelve todas las calles, excluyendo las ocultas.

## 5. Frontend (Vue.js)
- Página independiente con ruta propia.
- Input para filtro de nombre de calle (mayúsculas).
- Tabla con resultados, selección de fila.
- Botón "Aceptar" muestra el ID de la calle seleccionada.
- Breadcrumb de navegación.

## 6. Backend (Laravel)
- Controlador `ExecuteController` con método `execute` que despacha la acción recibida.
- Uso de DB::select para invocar los stored procedures.

## 7. Seguridad
- Validación básica de parámetros.
- El endpoint puede ser protegido por autenticación según la configuración general del API.

## 8. Consideraciones
- El filtro es insensible a mayúsculas/minúsculas (ILIKE en PostgreSQL).
- El frontend asume que el backend retorna los campos de la tabla `c_calles`.
- El formulario es una página completa, no un tab ni modal.

## 9. Tablas involucradas
- `c_calles`: Catálogo de calles.
- `c_calles_escondidas`: Calles ocultas (por vigente = 'V' y num_tag = 8000).

## 10. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el mismo patrón.

## Casos de Prueba
## Casos de Prueba para formabuscalle

### Caso 1: Búsqueda parcial
- **Descripción:** Buscar calles que contengan 'CENTRO'.
- **Pasos:**
  1. Ingresar 'CENTRO' en el campo de filtro.
  2. Verificar que la tabla muestre solo calles con 'CENTRO' en el nombre.
- **Resultado esperado:** Solo aparecen calles con 'CENTRO' en el nombre, excluyendo las ocultas.

### Caso 2: Listado completo
- **Descripción:** Mostrar todas las calles disponibles.
- **Pasos:**
  1. Dejar el campo de filtro vacío.
  2. Verificar que la tabla muestre todas las calles, excluyendo las ocultas.
- **Resultado esperado:** Se listan todas las calles activas.

### Caso 3: Selección y confirmación
- **Descripción:** Seleccionar una calle y confirmar.
- **Pasos:**
  1. Buscar 'REVOLUCIÓN'.
  2. Seleccionar la primera calle de la lista.
  3. Presionar 'Aceptar'.
- **Resultado esperado:** Se muestra el ID de la calle seleccionada.

### Caso 4: Sin resultados
- **Descripción:** Buscar una calle inexistente.
- **Pasos:**
  1. Ingresar 'ZZZZZZ' en el filtro.
  2. Verificar que la tabla muestre mensaje de 'No se encontraron calles'.
- **Resultado esperado:** La tabla está vacía y muestra el mensaje correspondiente.

### Caso 5: Calles ocultas
- **Descripción:** Verificar que las calles ocultas no aparecen.
- **Pasos:**
  1. Buscar una calle que está en `c_calles_escondidas` con vigente = 'V' y num_tag = 8000.
  2. Verificar que no aparece en la tabla.
- **Resultado esperado:** La calle oculta no aparece en los resultados.

## Casos de Uso
# Casos de Uso - formabuscalle

**Categoría:** Form

## Caso de Uso 1: Búsqueda de calles por nombre parcial

**Descripción:** El usuario desea buscar todas las calles que contienen la palabra 'INDEPENDENCIA' en su nombre.

**Precondiciones:**
El usuario tiene acceso al sistema y existen calles con 'INDEPENDENCIA' en su nombre en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda de calles.
2. Escribe 'INDEPENDENCIA' en el campo de filtro.
3. El sistema muestra todas las coincidencias en la tabla.
4. El usuario puede seleccionar una calle de la lista.

**Resultado esperado:**
Se muestran todas las calles que contienen 'INDEPENDENCIA' en su nombre, excluyendo las ocultas.

**Datos de prueba:**
Filtro: 'INDEPENDENCIA'

---

## Caso de Uso 2: Listar todas las calles disponibles

**Descripción:** El usuario desea ver el catálogo completo de calles disponibles.

**Precondiciones:**
El usuario tiene acceso al sistema y existen calles registradas.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda de calles.
2. No escribe nada en el campo de filtro.
3. El sistema muestra todas las calles disponibles en la tabla.

**Resultado esperado:**
Se muestran todas las calles, excluyendo las ocultas.

**Datos de prueba:**
Filtro: '' (vacío)

---

## Caso de Uso 3: Seleccionar una calle y obtener su ID

**Descripción:** El usuario busca una calle, la selecciona y confirma su selección para obtener el ID.

**Precondiciones:**
El usuario tiene acceso al sistema y existen calles en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda de calles.
2. Escribe parte del nombre de una calle.
3. Selecciona una fila de la tabla.
4. Presiona el botón 'Aceptar'.

**Resultado esperado:**
El sistema muestra el ID de la calle seleccionada.

**Datos de prueba:**
Filtro: 'JUAREZ', Selección: primera coincidencia

---
