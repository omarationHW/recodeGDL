# Documentación Técnica: Migración de Formulario ReactivaTramite

## 1. Descripción General
Este módulo permite la reactivación de trámites previamente cancelados o rechazados en el sistema. La migración transforma la lógica Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend) y PostgreSQL (Stored Procedures).

## 2. Arquitectura
- **Frontend:** Vue.js SPA, página independiente para Reactivación de Trámites.
- **Backend:** Laravel API con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. Flujo de Trabajo
1. El usuario ingresa el número de trámite y consulta los datos.
2. Si el trámite está cancelado ('C') o rechazado ('R'), puede reactivarlo ingresando un motivo.
3. El sistema actualiza el estatus del trámite y de sus revisiones asociadas.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "get_tramite" | "reactivar_tramite",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": { ... },
    "message": "..."
  }
  ```

## 5. Stored Procedures
- **get_tramite:** Devuelve todos los datos del trámite, incluyendo giro y nombre completo del propietario.
- **reactivar_tramite:** Realiza la reactivación del trámite y actualiza revisiones y seg_revision.

## 6. Seguridad
- Validación de parámetros en backend.
- Solo permite reactivar trámites con estatus 'C' (cancelado) o 'R' (rechazado).

## 7. Consideraciones
- El frontend es una página completa, no usa tabs.
- El motivo de reactivación es obligatorio.
- El proceso es atómico: si falla alguna actualización, no se realiza ningún cambio.

## 8. Integración
- El componente Vue puede integrarse en cualquier SPA con Vue Router.
- El endpoint `/api/execute` debe estar protegido según las políticas de autenticación del sistema.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar la estructura del endpoint.

---
