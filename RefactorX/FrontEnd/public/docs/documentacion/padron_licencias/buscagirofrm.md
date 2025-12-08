# Documentación Técnica: buscagirofrm

## Análisis Técnico

# Documentación Técnica: Buscagiro (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
El módulo **Buscagiro** permite buscar y seleccionar giros comerciales filtrando por descripción, tipo (Licencia/Anuncio), autoevaluación, pacto y permisos del usuario. El formulario original en Delphi se migró a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, componente de página independiente para Buscagiro
- **Base de Datos:** PostgreSQL 14+, lógica de negocio en stored procedures
- **Seguridad:** JWT Auth, validación de permisos por usuario

## 3. Flujo de Datos
1. El usuario accede a la página de búsqueda de giros (`/buscagiro`)
2. El frontend envía una petición POST a `/api/execute` con acción `buscagiro_list` y los parámetros de filtro
3. El backend ejecuta el stored procedure `sp_buscagiro_list` con los parámetros recibidos
4. El resultado se devuelve en formato JSON (eResponse)
5. El usuario puede seleccionar un giro, que se devuelve como objeto JSON

## 4. Endpoint API
- **POST /api/execute**
  - **Body:**
    ```json
    {
      "action": "buscagiro_list",
      "params": {
        "descripcion": "papeleria",
        "tipo": "L",
        "autoev": true,
        "pacto": false
      }
    }
    ```
  - **Respuesta:**
    ```json
    {
      "success": true,
      "message": "Listado de giros obtenido",
      "data": [ ... ]
    }
    ```

## 5. Stored Procedures
- Toda la lógica de filtrado y permisos se implementa en PostgreSQL para máxima eficiencia y seguridad.
- El SP `sp_buscagiro_list` filtra por descripción, tipo, autoevaluación, pacto y permisos del usuario.
- El SP `sp_buscagiro_permisos` obtiene los permisos del usuario para los giros.

## 6. Seguridad y Permisos
- El backend valida el usuario autenticado (JWT) y sus permisos antes de ejecutar la consulta.
- El SP verifica el permiso `giro_a` para el usuario y filtra los giros tipo A si no tiene permiso.

## 7. Integración Frontend
- El componente Vue.js es una página completa, sin tabs, con formulario de búsqueda y tabla de resultados.
- Permite seleccionar un giro y emite el objeto seleccionado para su uso en otros módulos.

## 8. Consideraciones de Migración
- Todas las queries Delphi se migraron a SQL estándar y SPs PostgreSQL.
- El endpoint es unificado y desacoplado de la UI.
- El frontend es desacoplado y puede ser reutilizado en cualquier SPA.

## 9. Extensibilidad
- Se pueden agregar más filtros o acciones en el endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los SPs pueden ser extendidos para nuevos criterios de negocio.

## 10. Pruebas y Validación
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del módulo.

## Casos de Prueba

# Casos de Prueba: Buscagiro

## Caso 1: Búsqueda básica por descripción
- **Entrada:** descripcion = 'papelería', tipo = 'L', autoev = false, pacto = false
- **Acción:** POST /api/execute { action: 'buscagiro_list', params: { ... } }
- **Esperado:** Respuesta JSON con lista de giros que contienen 'papelería' en la descripción

## Caso 2: Filtro solo autoevaluación
- **Entrada:** descripcion = '', tipo = 'L', autoev = true, pacto = false
- **Acción:** POST /api/execute { action: 'buscagiro_list', params: { ... } }
- **Esperado:** Solo giros permitidos para autoevaluación

## Caso 3: Sin resultados
- **Entrada:** descripcion = 'zzzzzz', tipo = 'L', autoev = false, pacto = false
- **Acción:** POST /api/execute { action: 'buscagiro_list', params: { ... } }
- **Esperado:** Respuesta JSON con data: []

## Caso 4: Permisos restringidos
- **Entrada:** usuario sin permiso giro_a, tipo = 'L', descripcion = ''
- **Acción:** POST /api/execute { action: 'buscagiro_list', params: { ... } }
- **Esperado:** No aparecen giros tipo A

## Caso 5: Selección de giro
- **Entrada:** id_giro = 1234
- **Acción:** POST /api/execute { action: 'buscagiro_select', params: { id_giro: 1234 } }
- **Esperado:** Respuesta JSON con los datos completos del giro 1234

## Casos de Uso

# Casos de Uso - buscagirofrm

**Categoría:** Form

## Caso de Uso 1: Búsqueda básica de giros por descripción

**Descripción:** El usuario busca giros comerciales que contengan la palabra 'papelería' en la descripción.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página /buscagiro
2. Escribe 'papelería' en el campo de descripción
3. Presiona 'Buscar'
4. El sistema muestra la lista de giros que contienen 'papelería'

**Resultado esperado:**
Se muestra una tabla con los giros filtrados por la palabra 'papelería'.

**Datos de prueba:**
descripcion: 'papelería', tipo: 'L', autoev: false, pacto: false

---

## Caso de Uso 2: Filtrado de giros solo para autoevaluación

**Descripción:** El usuario requiere ver únicamente los giros disponibles para autoevaluación.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página /buscagiro
2. Marca la casilla 'Solo Autoevaluación'
3. Presiona 'Buscar'
4. El sistema muestra solo los giros permitidos para autoevaluación

**Resultado esperado:**
Se muestran únicamente los giros que están en el catálogo de autoevaluación.

**Datos de prueba:**
descripcion: '', tipo: 'L', autoev: true, pacto: false

---

## Caso de Uso 3: Selección de giro y obtención de detalles

**Descripción:** El usuario selecciona un giro de la lista para ver sus detalles completos.

**Precondiciones:**
El usuario ya realizó una búsqueda y hay resultados.

**Pasos a seguir:**
1. Realiza una búsqueda de giros
2. Da clic en 'Seleccionar' en uno de los resultados
3. El sistema muestra los detalles completos del giro seleccionado

**Resultado esperado:**
Se muestra un panel con los datos completos del giro seleccionado.

**Datos de prueba:**
id_giro: 1234

---
