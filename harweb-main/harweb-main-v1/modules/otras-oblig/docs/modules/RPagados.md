# Documentación Técnica: Migración de Formulario RPagados (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario **RPagados** de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario permite consultar los pagos realizados (pagados) asociados a un identificador de control (`id_datos`).

## 2. Arquitectura
- **Backend:** Laravel API con endpoint unificado `/api/execute` bajo el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, con navegación y tabla de resultados.
- **Base de Datos:** Lógica SQL encapsulada en un stored procedure PostgreSQL.

## 3. Detalle de Componentes

### 3.1. Stored Procedure PostgreSQL
- **Nombre:** `sp_rpagados_get_pagados_by_control`
- **Tipo:** REPORT
- **Parámetro:** `p_control` (integer) — ID de control a consultar.
- **Retorna:** Todos los campos relevantes de la tabla `t34_pagos` para ese control, filtrando por status válidos (`P`, `S`, `R`, `D`).

### 3.2. Laravel Controller
- **Ruta:** `/api/execute` (POST)
- **Método:** `execute`
- **Patrón:** eRequest/eResponse
- **Operación relevante:** `getPagadosByControl`
- **Lógica:**
  - Recibe un JSON con `eRequest.operation` y `eRequest.params`.
  - Llama al stored procedure con el parámetro recibido.
  - Devuelve los resultados en `eResponse.data`.

### 3.3. Vue.js Component
- **Nombre:** `RPagadosPage`
- **Funcionalidad:**
  - Permite ingresar el ID de control (`p_Control`).
  - Envía la consulta al endpoint `/api/execute`.
  - Muestra los resultados en una tabla.
  - Incluye navegación breadcrumb y botón de salida.
  - Página completamente independiente.

## 4. Flujo de Datos
1. Usuario ingresa el ID de control y envía la consulta.
2. Vue.js envía un POST a `/api/execute` con la operación `getPagadosByControl` y el parámetro `p_Control`.
3. Laravel recibe la solicitud, ejecuta el stored procedure y retorna los datos.
4. Vue.js muestra los resultados en una tabla.

## 5. Seguridad
- Validación de parámetros en backend.
- Manejo de errores y mensajes claros en frontend y backend.

## 6. Consideraciones
- El endpoint `/api/execute` puede ser extendido para otras operaciones.
- El componente Vue.js es una página completa, no un tab ni modal.
- El stored procedure puede ser reutilizado por otros módulos.

## 7. Tablas Involucradas
- `t34_pagos`: Tabla principal de pagos.
- `t34_status`: Tabla de status de pagos.

## 8. Ejemplo de eRequest/eResponse
**Request:**
```json
{
  "eRequest": {
    "operation": "getPagadosByControl",
    "params": {
      "p_Control": 12345
    }
  }
}
```
**Response:**
```json
{
  "eResponse": {
    "success": true,
    "data": [ ... ],
    "message": "",
    "errors": null
  }
}
```
