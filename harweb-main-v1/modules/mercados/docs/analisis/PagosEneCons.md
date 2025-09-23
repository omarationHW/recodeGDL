# Documentación Técnica: Migración de PagosEneCons (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario de consulta de pagos de energía eléctrica (PagosEneCons) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de negocio y acceso a datos se implementa mediante stored procedures en PostgreSQL y un endpoint API unificado `/api/execute` que sigue el patrón eRequest/eResponse.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente (no tabs), navegación tipo breadcrumb.
- **Backend:** Laravel, controlador único para el endpoint `/api/execute` que enruta acciones según el parámetro `action`.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "getPagosEnergia",
    "params": { "id_energia": 123 }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ]
  }
  ```

### Acciones soportadas
- `getPagosEnergia`: Consulta pagos por id_energia
- `addPagoEnergia`: Agrega un pago de energía eléctrica
- `deletePagoEnergia`: Elimina un pago de energía eléctrica

## 4. Stored Procedures
Toda la lógica de acceso y manipulación de datos se realiza mediante stored procedures:
- `sp_get_pagos_energia`: Consulta pagos
- `sp_add_pago_energia`: Inserta un pago
- `sp_delete_pago_energia`: Elimina un pago

## 5. Seguridad
- El endpoint requiere autenticación (Laravel Sanctum/JWT recomendado).
- El id de usuario se obtiene del contexto de autenticación y se pasa a los stored procedures para auditoría.

## 6. Frontend (Vue.js)
- Página independiente para PagosEneCons.
- Formulario para ingresar el ID de energía y consultar pagos.
- Tabla de resultados con paginación y formato amigable.
- Mensajes de error y loading.
- Navegación breadcrumb.

## 7. Backend (Laravel)
- Controlador `PagosEneConsController` con método `execute` que enruta según el parámetro `action`.
- Validación de parámetros y errores claros.
- Uso de DB::select para llamar stored procedures.

## 8. Base de Datos (PostgreSQL)
- Tablas: `ta_11_pago_energia`, `ta_12_passwords` (usuarios)
- Todos los accesos y mutaciones de datos se hacen vía stored procedures.

## 9. Extensibilidad
- Para agregar nuevas acciones, basta con añadir el case correspondiente en el controlador y el stored procedure en la base de datos.

## 10. Pruebas
- Casos de uso y pruebas detalladas en la sección correspondiente.

---
