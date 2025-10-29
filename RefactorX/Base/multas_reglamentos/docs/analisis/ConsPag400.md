# Documentación Técnica: Migración de Formulario ConsPag400 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario ConsPag400, originalmente en Delphi, a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad de consulta de pagos, traspasos y observaciones asociadas, permitiendo búsquedas tanto por recaudador/UR/cuenta como por año/folio.

## 2. Arquitectura
- **Frontend**: Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb y tablas para mostrar resultados.
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` que recibe un `eRequest` y parámetros, y responde con un `eResponse`.
- **Base de Datos**: Toda la lógica SQL se encapsula en stored procedures PostgreSQL.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "ConsPag400:searchByRecaudUrCuenta", // o "ConsPag400:searchByAnioFolio"
    "params": { ... }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": {
        "pagos": [...],
        "traspasos": [...],
        "observaciones": [...]
      },
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
Se implementan 5 stored procedures:
- `sp_pagos_400_by_recaud_ur_cuenta(recaud, ur, cuenta)`
- `sp_trasp_400_by_recaud_ur_cuenta(recaud, ur, cuenta)`
- `sp_pagos_400_by_anio_folio(anio, folio)`
- `sp_trasp_400_by_anio_folio(anio, folio)`
- `sp_obs_can_400_by_folio_anio(tfol, tafol)`

## 5. Lógica de Negocio
- Si recaud, ur y cuenta son todos 0, la búsqueda es por año y folio (por comprobante).
- Si alguno de recaud, ur o cuenta es distinto de 0, la búsqueda es por esos campos.
- Siempre que se obtiene un traspaso, se busca la observación asociada usando tfol y tafol del primer traspaso encontrado.

## 6. Frontend (Vue.js)
- Formulario con campos: recaud, ur, cuenta, año, folio.
- Al enfocar recaud/ur/cuenta, se limpian año y folio, y viceversa.
- Al presionar Enter en cada campo, se mueve el foco al siguiente.
- Al buscar, se muestran tres tablas: Pagos, Traspasos y Observaciones.
- Mensajes de error y loading incluidos.

## 7. Backend (Laravel)
- Controlador único `ExecuteController` con método `execute`.
- Selección de lógica según `eRequest`.
- Llamadas a stored procedures usando DB::select.
- Manejo de errores y estructura de respuesta unificada.

## 8. Seguridad
- Validación de parámetros en el frontend.
- El backend espera parámetros numéricos y maneja errores de ejecución.
- Se recomienda proteger el endpoint con autenticación según la política del sistema.

## 9. Pruebas
- Casos de uso y escenarios de prueba incluidos para asegurar la funcionalidad y robustez del sistema.

## 10. Consideraciones
- El frontend y backend están desacoplados y pueden evolucionar de forma independiente.
- El endpoint unificado permite extender la API fácilmente para otros formularios.
- Los stored procedures aseguran que la lógica de consulta es centralizada y reutilizable.
