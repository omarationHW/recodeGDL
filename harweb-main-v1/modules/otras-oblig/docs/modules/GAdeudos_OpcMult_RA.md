# Documentación Técnica: Migración de Formulario GAdeudos_OpcMult_RA

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `GAdeudos_OpcMult_RA` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad de consulta y re-activación de adeudos/concesiones, centralizando la lógica de negocio en stored procedures y exponiendo la funcionalidad a través de un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3+, SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": "nombre_operacion",
    "params": { ... }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": "..."
    }
  }
  ```
- **Operaciones soportadas:**
  - `get_tabla_info` (par_tab)
  - `get_etiq` (par_tab)
  - `get_recaudadoras` ()
  - `get_operaciones` ()
  - `get_pagados` (p_Control)
  - `get_datos_concesion` (par_tab, par_control)

## 4. Stored Procedures
Toda la lógica de consulta y proceso se implementa en funciones de PostgreSQL (ver sección stored_procedures).

## 5. Frontend (Vue.js)
- Página independiente `/gadeudos-opcmult-ra`.
- Permite búsqueda por número de expediente o local, según el tipo de tabla.
- Muestra los datos generales de la concesión y permite seleccionar la opción de re-activación.
- Manejo de errores y validaciones en el frontend.

## 6. Backend (Laravel)
- Controlador único `ExecuteController`.
- Cada operación del frontend se mapea a una función almacenada en PostgreSQL.
- Manejo de errores y respuesta unificada.

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o sesión según el contexto de la aplicación.
- Validar y sanear todos los parámetros recibidos.

## 8. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad principal.

## 9. Consideraciones
- El frontend asume que la clave de tabla (`glo_Tabla`) se determina por contexto o ruta.
- El endpoint `/api/execute` puede ser extendido para soportar más operaciones en el futuro.

## 10. Extensibilidad
- Para agregar nuevas operaciones, basta con crear un nuevo stored procedure y mapearlo en el switch del controlador.
