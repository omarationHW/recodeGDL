# PagosEneCons

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - PagosEneCons

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos de energía eléctrica por local

**Descripción:** El usuario desea consultar todos los pagos registrados para un local específico de energía eléctrica.

**Precondiciones:**
El usuario está autenticado y conoce el ID de energía del local.

**Pasos a seguir:**
1. El usuario accede a la página 'Pagos Energía Eléctrica'.
2. Ingresa el ID de energía en el formulario.
3. Presiona el botón 'Buscar'.
4. El sistema consulta los pagos vía API y muestra la tabla de resultados.

**Resultado esperado:**
Se muestra una tabla con todos los pagos realizados para el ID de energía especificado, incluyendo fecha, importe, usuario, etc.

**Datos de prueba:**
{ "id_energia": 123 }

---

## Caso de Uso 2: Registro de un nuevo pago de energía eléctrica

**Descripción:** El usuario registra un nuevo pago para un local de energía eléctrica.

**Precondiciones:**
El usuario está autenticado y tiene permisos de captura.

**Pasos a seguir:**
1. El usuario accede a la página de registro de pagos (no incluida en este formulario, pero soportada por el API).
2. Ingresa los datos requeridos: id_energia, año, periodo, fecha_pago, oficina, caja, operación, importe, consumo, cantidad, folio.
3. Envía el formulario.
4. El sistema valida y registra el pago vía API.

**Resultado esperado:**
El pago queda registrado y puede ser consultado posteriormente.

**Datos de prueba:**
{ "id_energia": 123, "axo": 2024, "periodo": 6, "fecha_pago": "2024-06-10", "oficina_pago": 2, "caja_pago": "A", "operacion_pago": 4567, "importe_pago": 1500.00, "cve_consumo": "F", "cantidad": 100.0, "folio": "FOL123" }

---

## Caso de Uso 3: Eliminación de un pago de energía eléctrica

**Descripción:** El usuario elimina un pago registrado por error.

**Precondiciones:**
El usuario está autenticado y tiene permisos de eliminación.

**Pasos a seguir:**
1. El usuario consulta los pagos de un local.
2. Identifica el pago a eliminar (por id_pago_energia).
3. Solicita la eliminación vía API.

**Resultado esperado:**
El pago es eliminado de la base de datos y ya no aparece en la consulta.

**Datos de prueba:**
{ "id_pago_energia": 789 }

---



## Casos de Prueba

# Casos de Prueba para PagosEneCons

## Caso 1: Consulta de pagos de energía eléctrica
- **Entrada:** id_energia = 123
- **Acción:** POST /api/execute { action: 'getPagosEnergia', params: { id_energia: 123 } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: Array de pagos con campos correctos

## Caso 2: Registro de un nuevo pago
- **Entrada:**
  - id_energia: 123
  - axo: 2024
  - periodo: 6
  - fecha_pago: '2024-06-10'
  - oficina_pago: 2
  - caja_pago: 'A'
  - operacion_pago: 4567
  - importe_pago: 1500.00
  - cve_consumo: 'F'
  - cantidad: 100.0
  - folio: 'FOL123'
- **Acción:** POST /api/execute { action: 'addPagoEnergia', params: { ... } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: registro insertado

## Caso 3: Eliminación de un pago
- **Entrada:** id_pago_energia = 789
- **Acción:** POST /api/execute { action: 'deletePagoEnergia', params: { id_pago_energia: 789 } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: [{ deleted: true }]

## Caso 4: Error por falta de parámetro obligatorio
- **Entrada:** POST /api/execute { action: 'getPagosEnergia', params: { } }
- **Resultado esperado:**
  - HTTP 422
  - success: false
  - message: 'Parámetro id_energia requerido.'

## Caso 5: Error por acción no soportada
- **Entrada:** POST /api/execute { action: 'unknownAction', params: { } }
- **Resultado esperado:**
  - HTTP 400
  - success: false
  - message: 'Acción no soportada.'



