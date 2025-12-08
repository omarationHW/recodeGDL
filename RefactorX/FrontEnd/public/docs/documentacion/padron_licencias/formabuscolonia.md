# Documentación Técnica: formabuscolonia

## Análisis Técnico
# Documentación Técnica: Migración de Formulario formabuscolonia (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la búsqueda y selección de colonias (asentamientos) para un municipio específico (c_mnpio=39) usando una arquitectura moderna:
- **Backend:** Laravel (API RESTful, endpoint unificado `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de Datos:** PostgreSQL (con stored procedures)

## 2. Arquitectura
- **API Unificada:** Todas las operaciones se realizan mediante el endpoint `/api/execute` usando el patrón `eRequest`/`eResponse`.
- **Stored Procedures:** Toda la lógica SQL reside en funciones de PostgreSQL, facilitando el mantenimiento y la seguridad.
- **Frontend:** El componente Vue.js es una página completa, sin tabs, con navegación breadcrumb y UX amigable.

## 3. Endpoints y Protocolo
- **POST /api/execute**
  - **Body:**
    ```json
    {
      "eRequest": "buscar_colonias", // o "obtener_colonia_seleccionada"
      "params": { ... } // parámetros según la operación
    }
    ```
  - **Response:**
    ```json
    {
      "eResponse": {
        "success": true|false,
        "data": [ ... ],
        "message": "..."
      }
    }
    ```

## 4. Stored Procedures
- **sp_buscar_colonias(p_c_mnpio integer, p_filtro text):**
  - Devuelve todas las colonias del municipio cuyo nombre contiene el filtro (insensible a mayúsculas/minúsculas).
- **sp_obtener_colonia_seleccionada(p_c_mnpio integer, p_colonia text):**
  - Devuelve los datos de la colonia seleccionada (nombre exacto).

## 5. Flujo de la Aplicación
1. **Carga inicial:** Se muestran todas las colonias del municipio 39.
2. **Filtrado:** Al escribir en el campo de texto, se filtran las colonias por nombre.
3. **Selección:** El usuario selecciona una colonia de la tabla.
4. **Aceptar:** Al hacer clic en "Aceptar", se muestran los datos de la colonia seleccionada.

## 6. Seguridad
- Todas las consultas usan parámetros para evitar SQL Injection.
- El endpoint está preparado para autenticación si se requiere.

## 7. Consideraciones de Migración
- El filtro de búsqueda es insensible a mayúsculas/minúsculas (como en Delphi con `LIKE "%...%"`).
- El municipio está fijo en 39, pero puede parametrizarse en el futuro.
- El frontend es completamente independiente y puede integrarse en cualquier SPA Vue.js.

## 8. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 11

## 9. Extensibilidad
- Se pueden agregar más stored procedures y eRequests para otras operaciones CRUD sobre colonias.

## Casos de Prueba
## Casos de Prueba para formabuscolonia

| # | Descripción | Entrada | Acción | Resultado Esperado |
|---|-------------|---------|--------|--------------------|
| 1 | Listado inicial de colonias | filtro: "" | Cargar página | Se muestran todas las colonias de c_mnpio=39 |
| 2 | Filtrado por texto existente | filtro: "CENTRO" | Escribir en campo filtro | Solo aparecen colonias con 'CENTRO' en el nombre |
| 3 | Filtrado por texto inexistente | filtro: "XYZ" | Escribir en campo filtro | Tabla muestra 'No se encontraron colonias' |
| 4 | Selección de colonia y confirmación | filtro: "CENTRO", seleccionar 'CENTRO', click 'Aceptar' | Seleccionar y aceptar | Se muestra nombre y código postal de 'CENTRO' |
| 5 | Selección sin elegir colonia | filtro: "CENTRO", no seleccionar, click 'Aceptar' | Click 'Aceptar' | No ocurre nada, botón deshabilitado |
| 6 | Sensibilidad a mayúsculas/minúsculas | filtro: "centro" | Escribir en campo filtro | Coincide igual que 'CENTRO' |
| 7 | Filtro con espacios | filtro: "  CENTRO  " | Escribir en campo filtro | Coincide igual que 'CENTRO' |

## Casos de Uso
# Casos de Uso - formabuscolonia

**Categoría:** Form

## Caso de Uso 1: Búsqueda de colonias sin filtro

**Descripción:** El usuario accede a la página y visualiza todas las colonias del municipio 39 sin aplicar ningún filtro.

**Precondiciones:**
La tabla cp_correos contiene colonias para c_mnpio=39.

**Pasos a seguir:**
1. El usuario navega a la página de búsqueda de colonias.
2. No ingresa ningún texto en el campo de filtro.
3. El sistema muestra todas las colonias del municipio 39.

**Resultado esperado:**
Se listan todas las colonias disponibles para c_mnpio=39 en la tabla.

**Datos de prueba:**
cp_correos con al menos 3 colonias para c_mnpio=39.

---

## Caso de Uso 2: Filtrado de colonias por nombre parcial

**Descripción:** El usuario ingresa un texto parcial en el campo de filtro para buscar colonias cuyo nombre lo contenga.

**Precondiciones:**
La tabla cp_correos contiene colonias con nombres que incluyan el texto 'CENTRO' para c_mnpio=39.

**Pasos a seguir:**
1. El usuario navega a la página de búsqueda de colonias.
2. Ingresa 'CENTRO' en el campo de filtro.
3. El sistema filtra y muestra solo las colonias cuyo nombre contiene 'CENTRO'.

**Resultado esperado:**
Solo se muestran las colonias que contienen 'CENTRO' en su nombre.

**Datos de prueba:**
cp_correos con colonias 'CENTRO', 'CENTRO SUR', 'NORTE' para c_mnpio=39.

---

## Caso de Uso 3: Selección y confirmación de colonia

**Descripción:** El usuario selecciona una colonia de la lista y confirma su selección haciendo clic en 'Aceptar'.

**Precondiciones:**
La tabla cp_correos contiene la colonia 'CENTRO' para c_mnpio=39.

**Pasos a seguir:**
1. El usuario filtra por 'CENTRO'.
2. Selecciona la colonia 'CENTRO' de la tabla.
3. Hace clic en 'Aceptar'.
4. El sistema muestra los datos de la colonia seleccionada.

**Resultado esperado:**
Se muestra el nombre y código postal de la colonia 'CENTRO'.

**Datos de prueba:**
cp_correos con colonia 'CENTRO', d_codigopostal=12345, d_tipo_asenta='URBANO', c_mnpio=39.

---
