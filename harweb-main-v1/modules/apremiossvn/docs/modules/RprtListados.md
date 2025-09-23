# Documentación Técnica: Migración de Formulario RprtListados (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de reportes de requerimientos de folios (RprtListados) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es mantener la lógica de negocio y la funcionalidad original, pero adaptada a tecnologías web y mejores prácticas actuales.

## 2. Arquitectura
- **Frontend:** Vue.js SPA (Single Page Application), cada formulario es una página independiente.
- **Backend:** Laravel API, con un endpoint unificado `/api/execute` que recibe peticiones con el patrón `eRequest`/`eResponse`.
- **Base de Datos:** PostgreSQL, con lógica de negocio encapsulada en stored procedures (funciones).

## 3. Flujo de Datos
1. El usuario accede a la página de "Listado de Requerimientos".
2. Ingresa los filtros requeridos (zona, módulo, folios, clave, vigencia, fechas).
3. El frontend envía una petición POST a `/api/execute` con `eRequest: 'getRprtListados'` y los parámetros.
4. El backend llama al stored procedure `rprt_listados` en PostgreSQL, pasando los parámetros.
5. El stored procedure ejecuta la lógica de filtrado y cálculo de campos, devolviendo los resultados.
6. El backend retorna los datos en el campo `data` de la respuesta JSON.
7. El frontend muestra los resultados en una tabla y calcula totales.

## 4. Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "eRequest": "getRprtListados",
    "params": {
      "vrec": 1,
      "vmod": 11,
      "vfol1": 100,
      "vfol2": 200,
      "vcve": "todas",
      "vvig": "todas",
      "vfdsd": null,
      "vfhst": null
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 5. Stored Procedure
- **Nombre:** `rprt_listados`
- **Tipo:** REPORT
- **Parámetros:**
  - `vrec` (integer): Zona/Oficina
  - `vmod` (integer): Módulo (11=Mercados, 16=Aseo, etc.)
  - `vfol1`, `vfol2` (integer): Rango de folios
  - `vcve` (text): Clave practicado ('todas', 'P', etc.)
  - `vvig` (text): Vigencia ('todas', '1', '2', etc.)
  - `vfdsd`, `vfhst` (date): Fechas (solo si `vcve` = 'P')
- **Retorna:** Tabla con todos los campos requeridos, incluyendo el campo calculado `datos` según el módulo.

## 6. Frontend (Vue.js)
- Página independiente con formulario de filtros.
- Tabla de resultados con totales.
- Navegación breadcrumb.
- Lógica para mostrar/ocultar fechas según selección de clave.

## 7. Backend (Laravel)
- Controlador `ExecuteController` con método `handle` para enrutar según `eRequest`.
- Llama al stored procedure usando DB::select.
- Devuelve respuesta unificada con `success`, `data`, `message`.

## 8. Seguridad
- Validar y sanear los parámetros recibidos.
- (Opcional) Autenticación de usuario para acceso al endpoint.

## 9. Consideraciones
- El campo `datos` se calcula en el stored procedure según el módulo, replicando la lógica de Delphi.
- Los totales se calculan en frontend para mejor experiencia de usuario.
- El endpoint es extensible para otros formularios/futuros reportes.

## 10. Pruebas
- Casos de uso y pruebas detallados en las secciones siguientes.
