# DocumentaciÃ³n TÃ©cnica: Adeudos_Venc

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de Formulario Adeudos_Venc (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (no tabs), navegación por rutas.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## Flujo de Trabajo
1. **Carga de Tipos de Aseo**: Al cargar la página, el frontend solicita los tipos de aseo disponibles.
2. **Búsqueda de Contrato**: El usuario ingresa número de contrato y tipo de aseo, el frontend llama a `buscar_contrato_adeudos_vencidos`.
3. **Consulta de Adeudos**: Al seleccionar un contrato, el frontend llama a `get_adeudos_vencidos` para obtener los adeudos vencidos.
4. **Reporte/Resumen**: El usuario puede solicitar un resumen, que llama a `reporte_adeudos_vencidos`.
5. **Apremios**: Si se requiere, se puede consultar los apremios asociados con `get_apremios_adeudos_vencidos`.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "getTipoAseo|buscarContrato|getAdeudos|getReporte|getDiaLimite|getApremios",
      "params": { ... }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": { ... } // array o error
  }
  ```

## Stored Procedures
- Toda la lógica de negocio y reportes se implementa en stored procedures PostgreSQL.
- Los procedimientos devuelven tablas (RETURNS TABLE) para fácil consumo desde Laravel.

## Seguridad
- Validación de parámetros en el backend.
- El endpoint puede protegerse con middleware de autenticación si se requiere.

## Frontend (Vue.js)
- Cada formulario es una página independiente.
- No se usan tabs ni componentes tabulares.
- Navegación por rutas.
- Breadcrumb para navegación contextual.
- Manejo de errores y mensajes amigables.

## Backend (Laravel)
- Un solo controlador maneja todas las acciones relacionadas con Adeudos Vencidos.
- Uso de DB::select para ejecutar stored procedures.
- Manejo de errores y respuestas unificadas.

## Base de Datos
- Tablas principales: ta_16_contratos, ta_16_tipo_aseo, ta_16_pagos, ta_15_apremios, ta_16_recargos, etc.
- Todos los cálculos de recargos, multas, gastos, etc., se hacen en los stored procedures.

## Extensibilidad
- Para agregar nuevas acciones, basta con agregar un nuevo case en el controlador y un nuevo stored procedure.

# Ejemplo de Flujo
1. Usuario ingresa contrato y tipo de aseo → `/api/execute` action: buscarContrato
2. Usuario consulta adeudos → `/api/execute` action: getAdeudos
3. Usuario solicita reporte → `/api/execute` action: getReporte

# Validaciones
- El frontend valida campos obligatorios antes de enviar.
- El backend valida tipos y existencia de datos.

# Errores
- Todos los errores se devuelven en `eResponse.error`.

# Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute` con diferentes acciones y parámetros.


## Casos de Prueba

# Casos de Prueba para Adeudos_Venc

## Caso 1: Consulta de Adeudos Vencidos Vigentes
- **Entrada:**
  ```json
  { "eRequest": { "action": "buscarContrato", "params": { "num_contrato": 12345, "ctrol_aseo": 9 } } }
  ```
- **Esperado:**
  - Respuesta contiene datos del contrato.
  - Posterior consulta a `getAdeudos` devuelve lista de adeudos con status 'V'.

## Caso 2: Consulta de Adeudos de Otro Periodo
- **Entrada:**
  ```json
  { "eRequest": { "action": "getAdeudos", "params": { "control_contrato": 12345, "vigencia": "O", "aso": 2023, "mes": 5 } } }
  ```
- **Esperado:**
  - Respuesta contiene lista de adeudos para el periodo 2023-05.

## Caso 3: Generación de Reporte de Adeudos Vencidos
- **Entrada:**
  ```json
  { "eRequest": { "action": "getReporte", "params": { "control_contrato": 12345, "vigencia": "V" } } }
  ```
- **Esperado:**
  - Respuesta contiene resumen de requerimientos, importe multa, gastos, recargos y total.

## Caso 4: Error por Contrato Inexistente
- **Entrada:**
  ```json
  { "eRequest": { "action": "buscarContrato", "params": { "num_contrato": 999999, "ctrol_aseo": 9 } } }
  ```
- **Esperado:**
  - Respuesta contiene error o array vacío.

## Caso 5: Error por Parámetros Faltantes
- **Entrada:**
  ```json
  { "eRequest": { "action": "getAdeudos", "params": { } } }
  ```
- **Esperado:**
  - Respuesta contiene error indicando parámetros requeridos.


## Casos de Uso

# Casos de Uso - Adeudos_Venc

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Vencidos Vigentes

**Descripción:** El usuario consulta los adeudos vencidos vigentes de un contrato específico.

**Precondiciones:**
El contrato existe y tiene adeudos vencidos vigentes.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. El usuario deja la opción 'Periodos Vigentes' seleccionada.
3. El usuario hace clic en 'Buscar'.
4. El sistema muestra los datos del contrato.
5. El usuario hace clic en 'Consultar Adeudos'.
6. El sistema muestra la lista de adeudos vencidos.

**Resultado esperado:**
Se muestra la lista de adeudos vencidos vigentes para el contrato seleccionado.

**Datos de prueba:**
{ "contrato": "12345", "ctrol_aseo": 9 }

---

## Caso de Uso 2: Consulta de Adeudos de Otro Periodo

**Descripción:** El usuario consulta los adeudos de un contrato para un periodo específico (año y mes).

**Precondiciones:**
El contrato existe y tiene adeudos en el periodo seleccionado.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. El usuario selecciona 'Otro Periodo' y elige año y mes.
3. El usuario hace clic en 'Buscar'.
4. El sistema muestra los datos del contrato.
5. El usuario hace clic en 'Consultar Adeudos'.
6. El sistema muestra la lista de adeudos para el periodo seleccionado.

**Resultado esperado:**
Se muestra la lista de adeudos para el periodo seleccionado.

**Datos de prueba:**
{ "contrato": "12345", "ctrol_aseo": 9, "aso": 2023, "mes": 5 }

---

## Caso de Uso 3: Generación de Reporte de Adeudos Vencidos

**Descripción:** El usuario genera un reporte resumen de los adeudos vencidos de un contrato.

**Precondiciones:**
El contrato existe y tiene adeudos vencidos.

**Pasos a seguir:**
1. El usuario realiza una búsqueda de contrato y consulta los adeudos.
2. El usuario hace clic en 'Ver Reporte'.
3. El sistema genera y muestra el resumen de adeudos (multas, recargos, gastos, total).

**Resultado esperado:**
Se muestra el resumen de adeudos con los totales correspondientes.

**Datos de prueba:**
{ "contrato": "12345", "ctrol_aseo": 9 }

---



---
**Componente:** `Adeudos_Venc.vue`
**MÃ³dulo:** `aseo_contratado`

