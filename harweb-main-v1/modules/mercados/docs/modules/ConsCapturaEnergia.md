# Documentación Técnica: Migración de ConsCapturaEnergia (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite consultar, visualizar y eliminar pagos capturados de energía eléctrica para un local/contrato específico. La lógica original en Delphi se ha migrado a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos), centralizando la lógica de negocio en stored procedures y exponiendo la funcionalidad a través de un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador único (`ConsCapturaEnergiaController`) que expone un endpoint `/api/execute` para todas las operaciones (patrón eRequest/eResponse).
- **Frontend:** Vue.js 3+ SPA, componente de página independiente (`ConsCapturaEnergia.vue`) que consume la API y muestra la información en tabla, permitiendo borrar pagos.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures (`sp_get_pagos_energia`, `sp_delete_pago_energia`, `sp_restore_adeudo_energia`).

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Formato de entrada:**
  ```json
  {
    "eRequest": {
      "action": "getPagosEnergia", // o deletePagoEnergia, restoreAdeudoEnergia
      "params": { ... }
    }
  }
  ```
- **Formato de salida:**
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
- **sp_get_pagos_energia:** Devuelve todos los pagos de energía para un id_energia, incluyendo datos del local y usuario.
- **sp_delete_pago_energia:** Elimina el pago de energía para el periodo especificado.
- **sp_restore_adeudo_energia:** Si no existe el adeudo para ese periodo, lo inserta de nuevo (restauración lógica).

## 5. Flujo de la Página
1. El usuario accede a la página de consulta de pagos de energía eléctrica.
2. El componente Vue obtiene el parámetro `id_energia` (por ruta o query) y llama a la API con `action: getPagosEnergia`.
3. Se muestran los pagos en una tabla. Cada fila tiene un botón "Borrar".
4. Al borrar, se llama primero a `restoreAdeudoEnergia` (para restaurar el adeudo si no existe), luego a `deletePagoEnergia`.
5. La tabla se actualiza automáticamente.

## 6. Seguridad
- Todas las operaciones requieren autenticación JWT (middleware Laravel, no mostrado aquí).
- Validación de parámetros en backend y frontend.
- Los stored procedures validan existencia antes de insertar/restaurar.

## 7. Consideraciones
- El endpoint es único y flexible, permitiendo agregar más acciones en el futuro.
- El frontend es una página independiente, sin tabs ni componentes compartidos.
- El borrado es "seguro": primero restaura el adeudo si no existe, luego elimina el pago.

## 8. Extensibilidad
- Se pueden agregar más acciones (consultas, reportes, etc.) siguiendo el mismo patrón.
- El frontend puede ser extendido fácilmente para agregar filtros, exportar, etc.

## 9. Dependencias
- Laravel 10+, PHP 8+
- Vue.js 3+, axios
- PostgreSQL 13+

## 10. Ejemplo de llamada API
```json
{
  "eRequest": {
    "action": "getPagosEnergia",
    "params": { "id_energia": 123 }
  }
}
```

## 11. Ejemplo de respuesta
```json
{
  "eResponse": {
    "success": true,
    "data": [ { ... } ],
    "message": ""
  }
}
```
