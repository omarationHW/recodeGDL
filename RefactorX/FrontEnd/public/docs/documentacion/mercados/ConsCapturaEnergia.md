# ConsCapturaEnergia

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - ConsCapturaEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos capturados de energía eléctrica para un local

**Descripción:** El usuario desea visualizar todos los pagos de energía eléctrica registrados para un local específico.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. El id_energia es válido.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de pagos de energía eléctrica.
2. El sistema solicita el parámetro id_energia (por ruta o query).
3. El frontend llama a la API con action 'getPagosEnergia' y el id_energia.
4. El backend ejecuta el stored procedure y devuelve la lista de pagos.
5. El frontend muestra la tabla con los pagos.

**Resultado esperado:**
Se muestra una tabla con todos los pagos capturados para el local/contrato seleccionado.

**Datos de prueba:**
{ "id_energia": 123 }

---

## Caso de Uso 2: Eliminación de un pago de energía eléctrica y restauración del adeudo

**Descripción:** El usuario desea eliminar un pago capturado por error y restaurar el adeudo correspondiente.

**Precondiciones:**
El usuario está autenticado y tiene permisos de eliminación. El pago existe.

**Pasos a seguir:**
1. El usuario visualiza la tabla de pagos y selecciona el pago a eliminar.
2. El usuario hace clic en 'Borrar'.
3. El frontend llama a la API con action 'restoreAdeudoEnergia' (si no existe el adeudo).
4. Luego llama a 'deletePagoEnergia' para eliminar el pago.
5. El backend ejecuta ambos stored procedures.
6. El frontend actualiza la tabla.

**Resultado esperado:**
El pago es eliminado y el adeudo es restaurado si no existía. La tabla se actualiza.

**Datos de prueba:**
{ "id_energia": 123, "axo": 2024, "periodo": 6, "cve_consumo": "F", "cantidad": 100, "importe": 500.00, "usuario_id": 1 }

---

## Caso de Uso 3: Intento de restaurar un adeudo ya existente

**Descripción:** El usuario intenta restaurar un adeudo que ya existe para el periodo dado.

**Precondiciones:**
El adeudo ya existe en la tabla ta_11_adeudo_energ para ese periodo.

**Pasos a seguir:**
1. El usuario intenta borrar un pago.
2. El frontend llama a 'restoreAdeudoEnergia'.
3. El stored procedure detecta que ya existe el adeudo y no lo duplica.
4. El proceso continúa normalmente.

**Resultado esperado:**
El sistema no duplica el adeudo y muestra un mensaje informativo.

**Datos de prueba:**
{ "id_energia": 123, "axo": 2024, "periodo": 6, "cve_consumo": "F", "cantidad": 100, "importe": 500.00, "usuario_id": 1 }

---



## Casos de Prueba

# Casos de Prueba para ConsCapturaEnergia

## Caso 1: Consulta de pagos de energía eléctrica
- **Entrada:** id_energia válido
- **Acción:** Llamar a la API con action 'getPagosEnergia'
- **Esperado:** Respuesta success=true, data es un array de pagos, cada pago tiene los campos requeridos.

## Caso 2: Eliminación de pago y restauración de adeudo
- **Entrada:** id_energia, axo, periodo, cve_consumo, cantidad, importe, usuario_id
- **Acción:**
  1. Llamar a 'restoreAdeudoEnergia' con los datos.
  2. Llamar a 'deletePagoEnergia' con id_energia, axo, periodo, usuario_id.
- **Esperado:**
  - Si el adeudo no existe, se inserta y se elimina el pago.
  - Si el adeudo ya existe, sólo se elimina el pago.
  - Respuesta success=true en ambos casos.

## Caso 3: Intento de restaurar adeudo duplicado
- **Entrada:** Adeudo ya existente para ese periodo
- **Acción:** Llamar a 'restoreAdeudoEnergia'
- **Esperado:** Respuesta success=true, mensaje 'Ya existe el adeudo para este periodo'.

## Caso 4: Error de parámetros
- **Entrada:** id_energia nulo o inválido
- **Acción:** Llamar a cualquier acción
- **Esperado:** Respuesta success=false, mensaje de error descriptivo.

## Caso 5: Seguridad
- **Entrada:** Usuario no autenticado
- **Acción:** Llamar a la API
- **Esperado:** Respuesta HTTP 401 Unauthorized.



