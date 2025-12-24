# DocumentaciÃ³n TÃ©cnica: Rep_PadronContratos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de Formulario Rep_PadronContratos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el reporte de Padrón de Contratos, permitiendo filtrar por tipo de aseo, vigencia, y periodo. El backend está en Laravel, el frontend en Vue.js, y la lógica de negocio SQL reside en stored procedures de PostgreSQL. Toda la comunicación se realiza mediante un endpoint API unificado `/api/execute` usando el patrón eRequest/eResponse.

## 2. Arquitectura
- **Backend:** Laravel Controller (`PadronContratosController`) con endpoint único `/api/execute`.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación y filtros.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures (`sp16_contratos`, `con16_detade_01`).
- **API:** Todas las operaciones se realizan mediante POST a `/api/execute` con parámetros `action` y `params`.

## 3. API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "getPadronContratos",
    "params": {
      "tipo": "T",
      "vigencia": "V"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedures
- **sp16_contratos:** Devuelve el padrón de contratos filtrado por tipo y vigencia.
- **con16_detade_01:** Devuelve el detalle de adeudos por contrato, periodo y tipo de reporte.
- **ta_16_dia_limite:** Tabla de días límite por mes (no SP, pero se consulta desde el backend).

## 5. Flujo de la Aplicación
1. El usuario accede a la página de Padrón de Contratos.
2. Selecciona filtros (tipo de aseo, vigencia, periodo).
3. Al hacer clic en "Buscar", el frontend envía un eRequest a `/api/execute` con `action: getPadronContratos`.
4. El backend ejecuta el SP `sp16_contratos` y retorna los contratos.
5. El usuario puede ver el detalle de adeudos de cada contrato, que dispara un eRequest con `action: getDetalleAdeudos`.
6. El backend ejecuta el SP `con16_detade_01` y retorna el detalle.

## 6. Seguridad
- Todas las operaciones requieren autenticación (middleware Laravel).
- Validación de parámetros en el backend.

## 7. Consideraciones de Migración
- Los combos Delphi se migran a `<select>` en Vue.js.
- El reporte Delphi se convierte en tabla HTML con totales.
- El cálculo de totales se realiza en el frontend.
- El endpoint es único y multipropósito.

## 8. Extensibilidad
- Para agregar nuevos reportes, basta con agregar nuevos SP y acciones en el controlador.

## 9. Pruebas
- Ver sección de casos de uso y casos de prueba.



## Casos de Prueba

# Casos de Prueba: Padrón de Contratos

## Caso 1: Consulta de contratos vigentes ordinarios
- **Entrada:**
  - tipo: 'O'
  - vigencia: 'V'
- **Acción:** POST /api/execute { action: 'getPadronContratos', params: { tipo: 'O', vigencia: 'V' } }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: Array de contratos con tipo_aseo = 'O' y status_vigencia = 'V'

## Caso 2: Detalle de adeudos de contrato
- **Entrada:**
  - control: 12345
  - rep: 'V'
  - fecha: '2024-06'
- **Acción:** POST /api/execute { action: 'getDetalleAdeudos', params: { control: 12345, rep: 'V', fecha: '2024-06' } }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: Array con campos concepto, importe_adeudos, importe_recargos, importe_multa, importe_gastos

## Caso 3: Consulta de contratos por periodo personalizado
- **Entrada:**
  - tipo: 'T'
  - vigencia: 'T'
  - anio: '2023'
  - mes: '03'
- **Acción:** POST /api/execute { action: 'getPadronContratos', params: { tipo: 'T', vigencia: 'T', anio: '2023', mes: '03' } }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: Array de contratos activos en marzo 2023

## Caso 4: Error por falta de parámetros
- **Entrada:**
  - action: 'getDetalleAdeudos', params: { control: null, fecha: null }
- **Esperado:**
  - HTTP 200
  - success: false
  - message: 'Parámetros requeridos: control, fecha'

## Caso 5: Día límite del mes
- **Entrada:**
  - mes: 6
- **Acción:** POST /api/execute { action: 'getDiaLimite', params: { mes: 6 } }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: Array con campos mes, dia


## Casos de Uso

# Casos de Uso - Rep_PadronContratos

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Contratos Vigentes de Tipo Ordinario

**Descripción:** El usuario desea obtener el listado de todos los contratos vigentes de tipo ordinario.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página de Padrón de Contratos.
2. Selecciona 'O = Ordinario' en Tipo de Aseo.
3. Selecciona 'V = VIGENTE' en Vigencia.
4. Selecciona 'Periodos Vencidos' en Periodo.
5. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los contratos vigentes de tipo ordinario, incluyendo empresa, domicilio, inicio y fin de obligación.

**Datos de prueba:**
{ "tipo": "O", "vigencia": "V" }

---

## Caso de Uso 2: Detalle de Adeudos de un Contrato Específico

**Descripción:** El usuario consulta el detalle de adeudos de un contrato seleccionado.

**Precondiciones:**
El usuario ya visualizó el padrón de contratos y seleccionó uno.

**Pasos a seguir:**
1. En la tabla de contratos, da clic en 'Ver' en la fila del contrato deseado.
2. El sistema muestra el detalle de adeudos (adeudos, recargos, multas, gastos) para ese contrato.

**Resultado esperado:**
Se muestra el detalle de adeudos correctamente sumados y desglosados.

**Datos de prueba:**
{ "control": 12345, "rep": "V", "fecha": "2024-06" }

---

## Caso de Uso 3: Consulta de Padrón de Contratos por Periodo Personalizado

**Descripción:** El usuario desea consultar el padrón de contratos para un periodo específico.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página de Padrón de Contratos.
2. Selecciona 'T = TODOS' en Tipo de Aseo.
3. Selecciona 'T = TODOS' en Vigencia.
4. Selecciona 'Otro Periodo' en Periodo.
5. Ingresa año '2023' y mes '03'.
6. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra la lista de contratos activos en el periodo seleccionado.

**Datos de prueba:**
{ "tipo": "T", "vigencia": "T", "anio": "2023", "mes": "03" }

---



---
**Componente:** `Rep_PadronContratos.vue`
**MÃ³dulo:** `aseo_contratado`

