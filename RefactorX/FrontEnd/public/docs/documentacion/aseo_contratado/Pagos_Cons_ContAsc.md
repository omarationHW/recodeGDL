# DocumentaciÃ³n TÃ©cnica: Pagos_Cons_ContAsc

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Pagos_Cons_ContAsc

## Descripción General
Este módulo permite consultar los pagos asociados a contratos de recolección de residuos, filtrando por número de contrato (mayor o igual) y tipo de aseo, mostrando los pagos en orden ascendente. Incluye:
- Backend API (Laravel Controller)
- Frontend (Vue.js)
- Stored Procedures PostgreSQL
- API unificada eRequest/eResponse

## Arquitectura
- **Backend**: Laravel 10+, endpoint único `/api/execute`.
- **Frontend**: Vue.js 2/3 SPA, componente de página independiente.
- **Base de datos**: PostgreSQL, lógica en stored procedures.
- **Patrón API**: eRequest/eResponse, acción y parámetros.

## Flujo de Datos
1. El usuario ingresa un número de contrato y selecciona tipo de aseo.
2. El frontend llama a `/api/execute` con acción `buscarContratos`.
3. El backend ejecuta `sp_buscar_contratos_asc` y retorna los contratos.
4. El usuario selecciona un contrato y el frontend llama a `/api/execute` con acción `pagosPorContrato`.
5. El backend ejecuta `sp_pagos_por_contrato_asc` y retorna los pagos.

## API eRequest/eResponse
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "buscarContratos",
    "params": { "contrato": 123, "ctrol_aseo": 8 }
  }
  ```
- **Respuesta**:
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## Stored Procedures
- `sp_get_tipo_aseo()`: Catálogo de tipos de aseo.
- `sp_buscar_contratos_asc(p_num_contrato, p_ctrol_aseo)`: Contratos >= número y tipo aseo.
- `sp_pagos_por_contrato_asc(p_control_contrato)`: Pagos del contrato (vigencia 'P').

## Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación si es necesario.

## Validaciones
- El número de contrato debe ser numérico y mayor a cero.
- El tipo de aseo debe existir en catálogo.
- El control de errores se maneja en el backend y se muestra en el frontend.

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón.
- Los stored procedures pueden ampliarse para incluir más filtros o lógica.

## Integración
- El componente Vue puede integrarse en cualquier SPA.
- El backend puede ser consumido por otros sistemas vía REST.

## Notas
- No se usan tabs ni subcomponentes: cada formulario es una página independiente.
- El frontend muestra mensajes de error y validación amigables.


## Casos de Prueba

# Casos de Prueba: Pagos_Cons_ContAsc

| Caso | Entrada | Acción | Resultado Esperado |
|------|---------|--------|--------------------|
| 1 | contrato=1803, ctrol_aseo=8 | Buscar contratos, ver pagos | Lista de pagos mostrada correctamente |
| 2 | contrato=999999, ctrol_aseo=8 | Buscar contratos | Mensaje de error: 'No se encontraron contratos' |
| 3 | contrato=1804, ctrol_aseo=8 | Buscar contratos, ver pagos | Mensaje de error: 'No se encontraron pagos' |
| 4 | contrato vacío | Buscar contratos | Mensaje de error: 'Debe ingresar el número de contrato y tipo de aseo' |
| 5 | contrato=1803, ctrol_aseo vacío | Buscar contratos | Mensaje de error: 'Debe ingresar el número de contrato y tipo de aseo' |
| 6 | contrato=abc, ctrol_aseo=8 | Buscar contratos | Mensaje de error: 'Debe ingresar el número de contrato y tipo de aseo' |
| 7 | contrato=1803, ctrol_aseo=8 | Buscar contratos, seleccionar contrato, ver pagos | Pagos mostrados, columnas: Periodo, Operación, Exed., Importe, Status, Fecha Pago, Ofna, Caja, Consec. Operación, Folio Rcbo |


## Casos de Uso

# Casos de Uso - Pagos_Cons_ContAsc

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos de un contrato específico

**Descripción:** El usuario desea consultar todos los pagos asociados a un contrato a partir de un número dado y un tipo de aseo.

**Precondiciones:**
El usuario tiene acceso al sistema y existen contratos y pagos en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página 'Pagos por Contrato Ascendente'.
2. Ingresa el número de contrato '1803'.
3. Selecciona el tipo de aseo '8 - O - Ordinario'.
4. Presiona 'Buscar'.
5. El sistema muestra los contratos encontrados.
6. El usuario presiona 'Ver Pagos' en el contrato deseado.
7. El sistema muestra la lista de pagos asociados.

**Resultado esperado:**
Se muestran los pagos del contrato 1803, tipo de aseo 8, con todos los campos relevantes.

**Datos de prueba:**
contrato: 1803, ctrol_aseo: 8

---

## Caso de Uso 2: Validación de contrato inexistente

**Descripción:** El usuario intenta buscar un contrato que no existe.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Ingresa el número de contrato '999999'.
3. Selecciona cualquier tipo de aseo.
4. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no se encontraron contratos.

**Datos de prueba:**
contrato: 999999, ctrol_aseo: 8

---

## Caso de Uso 3: Consulta de pagos sin pagos registrados

**Descripción:** El usuario busca un contrato válido pero que no tiene pagos con status 'P'.

**Precondiciones:**
El contrato existe pero no tiene pagos con status 'P'.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Ingresa el número de contrato correspondiente.
3. Selecciona el tipo de aseo.
4. Presiona 'Buscar'.
5. El usuario presiona 'Ver Pagos'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron pagos.

**Datos de prueba:**
contrato: 1804, ctrol_aseo: 8 (suponiendo que no tiene pagos 'P')

---



---
**Componente:** `Pagos_Cons_ContAsc.vue`
**MÃ³dulo:** `aseo_contratado`

