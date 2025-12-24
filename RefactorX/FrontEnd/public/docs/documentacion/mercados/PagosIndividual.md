# PagosIndividual

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Consulta Individual de Pagos del Local

## Descripción General
Este módulo permite consultar la información detallada de un pago individual realizado por un local en un mercado municipal. Incluye datos del pago, del local, del mercado y del usuario que realizó la operación.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.
- **API:** Todas las operaciones se realizan mediante el endpoint `/api/execute`.

## Flujo de Datos
1. El usuario ingresa el ID del local, año y mes (periodo) y solicita la consulta.
2. El frontend envía una petición POST a `/api/execute` con el action `getPagoIndividual` y los parámetros requeridos.
3. El backend ejecuta el stored procedure `pagos_individual_get` y retorna la información completa del pago, local, mercado y usuario.
4. El frontend muestra la información en una página dedicada.

## Endpoint API
- **POST** `/api/execute`
- **Body:**
  ```json
  {
    "action": "getPagoIndividual",
    "params": {
      "id_local": 123,
      "axo": 2024,
      "periodo": 6
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": { ... },
    "message": ""
  }
  ```

## Stored Procedures
- `pagos_individual_get`: Devuelve toda la información relevante de un pago individual.
- `mercado_info_get`: Devuelve información de un mercado.
- `usuario_info_get`: Devuelve información de usuario.

## Validaciones
- Todos los parámetros son obligatorios y validados en el backend.
- Si no se encuentra información, se retorna un mensaje de error.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- Los parámetros son validados y sanitizados.

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el mismo patrón.
- Los stored procedures pueden ser extendidos para incluir más información si es necesario.

## Frontend
- El componente Vue.js es una página independiente, sin tabs.
- Permite ingresar los parámetros y muestra la información en tablas.
- Maneja estados de carga y error.

## Ejemplo de Uso
1. El usuario ingresa: ID Local = 123, Año = 2024, Mes = 6.
2. El sistema muestra todos los datos del pago, local, mercado y usuario.

## Consideraciones
- Los nombres de los campos y tablas deben coincidir con la estructura de la base de datos PostgreSQL.
- El stored procedure puede ser adaptado para devolver más campos si se requiere.


## Casos de Uso

# Casos de Uso - PagosIndividual

**Categoría:** Form

## Caso de Uso 1: Consulta de Pago Individual Existente

**Descripción:** El usuario consulta el pago de un local que existe y tiene pagos registrados.

**Precondiciones:**
El local con ID 123 tiene un pago registrado para el año 2024 y mes 6.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta Individual de Pagos del Local.
2. Ingresa ID Local = 123, Año = 2024, Mes = 6.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra la información completa del pago, local, mercado y usuario.

**Datos de prueba:**
{ "id_local": 123, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 2: Consulta de Pago Individual Inexistente

**Descripción:** El usuario consulta un pago que no existe para el local y periodo especificados.

**Precondiciones:**
El local con ID 999 no tiene pagos registrados para el año 2024 y mes 6.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta Individual de Pagos del Local.
2. Ingresa ID Local = 999, Año = 2024, Mes = 6.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que no se encontró el pago.

**Datos de prueba:**
{ "id_local": 999, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 3: Consulta con Parámetros Inválidos

**Descripción:** El usuario intenta consultar sin ingresar todos los parámetros requeridos.

**Precondiciones:**
El usuario deja vacío el campo 'Año'.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta Individual de Pagos del Local.
2. Ingresa ID Local = 123, deja vacío el campo Año, Mes = 6.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los parámetros son inválidos.

**Datos de prueba:**
{ "id_local": 123, "axo": "", "periodo": 6 }

---



## Casos de Prueba

## Casos de Prueba para Consulta Individual de Pagos del Local

### Caso 1: Consulta Exitosa
- **Entrada:** id_local=123, axo=2024, periodo=6
- **Acción:** POST /api/execute { action: 'getPagoIndividual', params: { id_local: 123, axo: 2024, periodo: 6 } }
- **Esperado:** Respuesta success=true, data contiene información del pago

### Caso 2: Pago No Encontrado
- **Entrada:** id_local=999, axo=2024, periodo=6
- **Acción:** POST /api/execute { action: 'getPagoIndividual', params: { id_local: 999, axo: 2024, periodo: 6 } }
- **Esperado:** Respuesta success=false, message indica que no se encontró el pago

### Caso 3: Parámetros Inválidos
- **Entrada:** id_local=123, axo='', periodo=6
- **Acción:** POST /api/execute { action: 'getPagoIndividual', params: { id_local: 123, axo: '', periodo: 6 } }
- **Esperado:** Respuesta success=false, message indica error de validación

### Caso 4: SQL Injection Attempt
- **Entrada:** id_local="1; DROP TABLE ta_11_pagos_local;--", axo=2024, periodo=6
- **Acción:** POST /api/execute { action: 'getPagoIndividual', params: { id_local: "1; DROP TABLE ta_11_pagos_local;--", axo: 2024, periodo: 6 } }
- **Esperado:** Respuesta success=false, message indica error de validación

### Caso 5: Consulta de Mercado
- **Entrada:** oficina=1, num_mercado_nvo=10
- **Acción:** POST /api/execute { action: 'getMercadoInfo', params: { oficina: 1, num_mercado_nvo: 10 } }
- **Esperado:** Respuesta success=true, data contiene información del mercado



