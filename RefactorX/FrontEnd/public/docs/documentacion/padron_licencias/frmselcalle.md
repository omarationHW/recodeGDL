# Documentación Técnica: frmselcalle

## Análisis Técnico
# Documentación Técnica: Migración de Formulario frmselcalle (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de selección de calles (`frmselcalle`) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El formulario permite buscar calles por nombre y seleccionar una o varias para su posterior uso.

## 2. Arquitectura
- **Backend:** Laravel, expone un endpoint único `/api/execute` que recibe peticiones con el patrón `eRequest`/`eParams` y responde con `eResponse`.
- **Frontend:** Vue.js, componente de página completa, sin tabs, con tabla de selección múltiple y filtro en tiempo real.
- **Base de Datos:** PostgreSQL, lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "eRequest": "get_calles",
    "eParams": { "filter": "AVENIDA" }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ { "cvecalle": 1, "calle": "AVENIDA CENTRAL" }, ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- **sp_get_calles(filter TEXT):** Devuelve todas las calles o filtra por prefijo.
- **sp_get_calle_by_ids(ids_csv TEXT):** Devuelve las calles cuyos IDs estén en la lista.

## 5. Frontend (Vue.js)
- Página independiente `/frmselcalle`.
- Input para filtrar calles (convierte a mayúsculas automáticamente).
- Tabla con selección múltiple (checkboxes).
- Botón "Aceptar" muestra los IDs seleccionados.
- Breadcrumb de navegación.

## 6. Backend (Laravel)
- Controlador `ExecuteController` maneja todas las operaciones vía `/api/execute`.
- Llama a los stored procedures según el valor de `eRequest`.
- Manejo de errores y logging.

## 7. Seguridad
- Validación básica de parámetros.
- Uso de prepared statements en Laravel para evitar SQL Injection.

## 8. Consideraciones
- El filtro es por prefijo (como `matches` en Delphi), usando `ILIKE` en PostgreSQL.
- La selección múltiple se maneja en frontend y puede ser enviada al backend para obtener detalles si es necesario.

## 9. Extensibilidad
- Se pueden agregar más operaciones en el mismo endpoint agregando nuevos valores de `eRequest` y sus procedimientos asociados.

## Casos de Prueba
# Casos de Prueba para frmselcalle

## Caso 1: Filtro por prefijo
- **Entrada:** filter = 'AVENIDA'
- **Acción:** POST /api/execute { eRequest: 'get_calles', eParams: { filter: 'AVENIDA' } }
- **Esperado:** Solo se devuelven calles cuyo nombre inicia con 'AVENIDA'.

## Caso 2: Sin filtro (todas las calles)
- **Entrada:** filter = ''
- **Acción:** POST /api/execute { eRequest: 'get_calles', eParams: { filter: '' } }
- **Esperado:** Se devuelven todas las calles ordenadas alfabéticamente.

## Caso 3: Selección múltiple
- **Entrada:** El usuario selecciona cvecalle 1 y 3 en la tabla y presiona 'Aceptar'.
- **Acción:** El frontend muestra '1,3' como IDs seleccionados.
- **Esperado:** El mensaje de confirmación muestra los IDs seleccionados correctamente.

## Caso 4: Filtro sin resultados
- **Entrada:** filter = 'ZZZZZ'
- **Acción:** POST /api/execute { eRequest: 'get_calles', eParams: { filter: 'ZZZZZ' } }
- **Esperado:** La tabla muestra 'No hay resultados'.

## Caso 5: Consulta por IDs
- **Entrada:** ids = [2,4]
- **Acción:** POST /api/execute { eRequest: 'get_calle_by_ids', eParams: { ids: [2,4] } }
- **Esperado:** Se devuelven los registros de cvecalle 2 y 4.

## Casos de Uso
# Casos de Uso - frmselcalle

**Categoría:** Form

## Caso de Uso 1: Búsqueda de calles por prefijo

**Descripción:** El usuario ingresa un texto en el campo de búsqueda para filtrar las calles cuyo nombre comienza con ese texto.

**Precondiciones:**
La base de datos contiene varias calles registradas.

**Pasos a seguir:**
1. El usuario accede a la página de selección de calles.
2. Escribe 'AVENIDA' en el campo de búsqueda.
3. El sistema muestra solo las calles que comienzan con 'AVENIDA'.

**Resultado esperado:**
La tabla muestra únicamente las calles cuyo nombre inicia con 'AVENIDA'.

**Datos de prueba:**
c_calles: [ {cvecalle: 1, calle: 'AVENIDA CENTRAL'}, {cvecalle: 2, calle: 'AVENIDA JUAREZ'}, {cvecalle: 3, calle: 'CALLE 5 DE MAYO'} ]

---

## Caso de Uso 2: Selección múltiple de calles

**Descripción:** El usuario selecciona varias calles de la lista y confirma su selección.

**Precondiciones:**
La tabla de calles tiene al menos 3 registros.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Marca las casillas de las calles con cvecalle 1 y 2.
3. Presiona el botón 'Aceptar'.

**Resultado esperado:**
Se muestra un mensaje con los IDs seleccionados: '1,2'.

**Datos de prueba:**
c_calles: [ {cvecalle: 1, calle: 'AVENIDA CENTRAL'}, {cvecalle: 2, calle: 'AVENIDA JUAREZ'}, {cvecalle: 3, calle: 'CALLE 5 DE MAYO'} ]

---

## Caso de Uso 3: Visualización de todas las calles sin filtro

**Descripción:** El usuario deja el campo de búsqueda vacío para ver todas las calles.

**Precondiciones:**
La base de datos contiene al menos 5 calles.

**Pasos a seguir:**
1. El usuario accede a la página.
2. No escribe nada en el campo de búsqueda.
3. El sistema muestra todas las calles.

**Resultado esperado:**
La tabla muestra todas las calles ordenadas alfabéticamente.

**Datos de prueba:**
c_calles: [ {cvecalle: 1, calle: 'AVENIDA CENTRAL'}, {cvecalle: 2, calle: 'AVENIDA JUAREZ'}, {cvecalle: 3, calle: 'CALLE 5 DE MAYO'}, {cvecalle: 4, calle: 'CALLE HIDALGO'}, {cvecalle: 5, calle: 'BOULEVARD NORTE'} ]

---
