# EnergiaModif

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario EnergiaModif (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse, todas las operaciones pasan por un solo endpoint.

## Flujo de Trabajo
1. **Frontend** solicita catálogos (`catalogos`), muestra combos.
2. Usuario ingresa datos de búsqueda y ejecuta "Buscar".
3. Frontend envía eRequest con acción `buscar` y datos del local.
4. Backend ejecuta `sp_energia_modif_buscar` y retorna datos de energía.
5. Usuario edita/modifica datos y ejecuta "Modificar".
6. Frontend envía eRequest con acción `modificar` y datos completos.
7. Backend ejecuta `sp_energia_modif_modificar`, que:
   - Valida reglas de negocio.
   - Inserta en historial.
   - Actualiza registro principal.
   - Borra/actualiza/crea adeudos según movimiento.
8. Backend responde con mensaje de éxito o error.

## Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "buscar|modificar|catalogos",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## Validaciones Clave
- No se permite modificar si la cantidad es cero o vacía.
- Movimiento y vigencia deben ser coherentes.
- Si es baja, debe capturarse periodo de baja.
- Todas las operaciones de modificación son transaccionales.

## Seguridad
- El usuario debe estar autenticado (no implementado en ejemplo, pero debe usarse Auth en producción).
- Los IDs de usuario se pasan explícitamente.
- Todas las entradas se validan en backend y frontend.

## Stored Procedures
- Toda la lógica de negocio y reglas reside en los SPs de PostgreSQL.
- El controlador Laravel solo orquesta y valida.

## Frontend
- Página Vue.js independiente, sin tabs.
- Navegación y breadcrumbs opcionales.
- Validaciones en tiempo real.
- Mensajes de error y éxito claros.

## Extensibilidad
- Se pueden agregar más acciones al endpoint único.
- Los catálogos se pueden cachear en frontend.

# Estructura de la Base de Datos
- `ta_11_locales`: Locales de mercado.
- `ta_11_energia`: Datos de energía por local.
- `ta_11_energia_hist`: Historial de cambios.
- `ta_11_adeudo_energ`: Adeudos de energía.
- `ta_12_recaudadoras`: Catálogo de recaudadoras.
- `ta_11_secciones`: Catálogo de secciones.

# Seguridad y Transacciones
- Todas las operaciones de modificación usan transacciones.
- Los SPs devuelven mensajes claros de error.

# Pruebas y Auditoría
- El historial de cambios se almacena en `ta_11_energia_hist`.
- Los cambios de adeudos se reflejan automáticamente según reglas.

# Consideraciones
- El frontend debe manejar correctamente los estados de error y éxito.
- El backend debe validar exhaustivamente los datos recibidos.
- Los SPs deben ser revisados y optimizados para concurrencia y performance.


## Casos de Uso

# Casos de Uso - EnergiaModif

**Categoría:** Form

## Caso de Uso 1: Modificación de cantidad de energía para un local vigente

**Descripción:** El usuario busca un local vigente y modifica la cantidad de kilowhatts.

**Precondiciones:**
El local existe, tiene registro de energía vigente, el usuario tiene permisos.

**Pasos a seguir:**
1. El usuario ingresa los datos del local y selecciona 'Cambio de Datos Generales'.
2. Presiona 'Buscar'.
3. El sistema muestra los datos actuales de energía.
4. El usuario cambia el valor de 'Cantidad' y presiona 'Modificar'.

**Resultado esperado:**
El registro de energía se actualiza, se inserta en historial, los adeudos se recalculan si aplica.

**Datos de prueba:**
{
  "oficina": 1,
  "num_mercado": 34,
  "categoria": 1,
  "seccion": "SS",
  "local": 1202,
  "letra_local": null,
  "bloque": null,
  "movimiento": "C",
  "cantidad": 150.5
}

---

## Caso de Uso 2: Baja total de energía para un local

**Descripción:** El usuario da de baja el registro de energía de un local.

**Precondiciones:**
El local existe, tiene registro de energía vigente.

**Pasos a seguir:**
1. El usuario ingresa los datos del local y selecciona 'Baja Total'.
2. Ingresa periodo de baja (año y mes).
3. Presiona 'Buscar' y luego 'Modificar'.

**Resultado esperado:**
El registro de energía se marca como baja, los adeudos posteriores al periodo de baja se eliminan.

**Datos de prueba:**
{
  "oficina": 1,
  "num_mercado": 34,
  "categoria": 1,
  "seccion": "SS",
  "local": 1202,
  "letra_local": null,
  "bloque": null,
  "movimiento": "B",
  "periodo_baja_axo": 2024,
  "periodo_baja_mes": 6
}

---

## Caso de Uso 3: Cambio de cuota de energía para un local

**Descripción:** El usuario realiza un cambio de cuota (cantidad) para un local y actualiza los adeudos en el rango correspondiente.

**Precondiciones:**
El local existe, tiene registro de energía vigente.

**Pasos a seguir:**
1. El usuario ingresa los datos del local y selecciona 'Cambio de Cuota'.
2. Ingresa periodo de baja (año y mes) para el rango de actualización.
3. Cambia el valor de 'Cantidad'.
4. Presiona 'Modificar'.

**Resultado esperado:**
Los adeudos en el rango especificado se actualizan con la nueva cantidad.

**Datos de prueba:**
{
  "oficina": 1,
  "num_mercado": 34,
  "categoria": 1,
  "seccion": "SS",
  "local": 1202,
  "letra_local": null,
  "bloque": null,
  "movimiento": "D",
  "periodo_baja_axo": 2024,
  "periodo_baja_mes": 3,
  "cantidad": 200.0
}

---



## Casos de Prueba

# Casos de Prueba: EnergiaModif

## Caso 1: Modificación exitosa de cantidad
- **Entrada:**
  - Local existente, movimiento 'C', cantidad válida (>0)
- **Pasos:**
  1. Buscar local existente y vigente
  2. Modificar cantidad a un valor válido
  3. Enviar acción 'modificar'
- **Esperado:**
  - Respuesta success true, mensaje de éxito
  - Registro actualizado en BD
  - Historial actualizado

## Caso 2: Error por cantidad vacía o cero
- **Entrada:**
  - Local existente, cantidad = 0
- **Pasos:**
  1. Buscar local
  2. Modificar cantidad a 0
  3. Enviar acción 'modificar'
- **Esperado:**
  - Respuesta success false, mensaje de error 'La cantidad de kilowhatts/cuota fija no tiene información'

## Caso 3: Baja total sin periodo de baja
- **Entrada:**
  - Movimiento 'B', periodo_baja_axo o periodo_baja_mes vacío
- **Pasos:**
  1. Buscar local
  2. Seleccionar movimiento 'Baja Total'
  3. No ingresar periodo de baja
  4. Enviar acción 'modificar'
- **Esperado:**
  - Respuesta success false, mensaje de error 'Falta capturar el periodo de baja'

## Caso 4: Baja total exitosa
- **Entrada:**
  - Movimiento 'B', periodo_baja_axo y periodo_baja_mes válidos
- **Pasos:**
  1. Buscar local
  2. Seleccionar movimiento 'Baja Total'
  3. Ingresar periodo de baja
  4. Enviar acción 'modificar'
- **Esperado:**
  - Respuesta success true, mensaje de éxito
  - Adeudos posteriores eliminados

## Caso 5: Cambio de cuota actualiza adeudos
- **Entrada:**
  - Movimiento 'D', periodo_baja_axo y periodo_baja_mes válidos, cantidad nueva
- **Pasos:**
  1. Buscar local
  2. Seleccionar movimiento 'Cambio de Cuota'
  3. Ingresar periodo de baja
  4. Cambiar cantidad
  5. Enviar acción 'modificar'
- **Esperado:**
  - Respuesta success true, mensaje de éxito
  - Adeudos en rango actualizados



