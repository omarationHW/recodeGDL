# Documentación Técnica: sQRptAdeudosCond

## Análisis

# Documentación Técnica: Migración de Formulario sQRptAdeudosCond (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte de "Adeudos Condonados de Aseo Contratado". El sistema original en Delphi usaba QuickReport y consultas SQL directas. La migración implementa:
- Backend en Laravel (API REST unificada)
- Frontend en Vue.js (página independiente)
- Lógica SQL en stored procedure PostgreSQL
- API unificada con patrón eRequest/eResponse

## 2. Backend (Laravel)
- **Controlador:** `App\Http\Controllers\Api\ExecuteController`
- **Endpoint:** `POST /api/execute`
- **Patrón:** eRequest/eResponse
- **Método relevante:**
  - `getAdeudosCondonados`: Llama al stored procedure `rpt_adeudos_condonados` con parámetros `control_contrato` y `opcion`.
- **Respuesta:**
  - `success`: boolean
  - `data`: array de resultados
  - `error`: mensaje de error si aplica

## 3. Frontend (Vue.js)
- **Componente:** Página completa `AdeudosCondonadosPage`
- **Ruta:** Independiente (no tab)
- **Funcionalidad:**
  - Formulario para ingresar No. Contrato y opción de clasificación
  - Consulta al endpoint `/api/execute`
  - Renderizado de tabla de resultados y totales por contrato
  - Breadcrumb de navegación

## 4. Stored Procedure (PostgreSQL)
- **Nombre:** `rpt_adeudos_condonados`
- **Parámetros:**
  - `p_control_contrato` (integer)
  - `p_opcion` (smallint): 1=Periodo de Pago, 2=Operación
- **Retorna:** Tabla con todos los campos requeridos para el reporte
- **Lógica:**
  - Realiza los JOINs y filtros equivalentes al SQL Delphi
  - Ordena según la opción seleccionada

## 5. API Unificada
- **Patrón:** eRequest/eResponse
- **Endpoint único:** `/api/execute`
- **Payload ejemplo:**
```json
{
  "eRequest": "getAdeudosCondonados",
  "params": {
    "control_contrato": 1228,
    "opcion": 1
  }
}
```
- **Respuesta:**
```json
{
  "success": true,
  "data": [ ... ],
  "error": null
}
```

## 6. Seguridad
- Validar que el parámetro `control_contrato` sea obligatorio y numérico
- Manejar errores y excepciones en el controlador

## 7. Pruebas
- Casos de uso y pruebas incluidas más abajo

## 8. Consideraciones
- El frontend calcula los totales por contrato de manera similar al reporte original
- El stored procedure puede ser extendido para incluir más lógica de agregados si se requiere

## 9. Extensibilidad
- Se pueden agregar nuevos eRequest fácilmente en el controlador
- El frontend puede ser adaptado para exportar a PDF/Excel si se requiere


## Casos de Uso

# Casos de Uso - sQRptAdeudosCond

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Condonados por Contrato y Periodo de Pago

**Descripción:** El usuario desea obtener el reporte de adeudos condonados para un contrato específico, clasificados por periodo de pago.

**Precondiciones:**
El contrato existe y tiene adeudos condonados registrados.

**Pasos a seguir:**
1. El usuario accede a la página de 'Reporte de Adeudos Condonados'.
2. Ingresa el número de contrato (ejemplo: 1228).
3. Selecciona 'Periodo de Pago' como opción de clasificación.
4. Hace clic en 'Consultar'.
5. El sistema muestra la tabla con los adeudos condonados clasificados por periodo de pago.

**Resultado esperado:**
Se muestra la lista de adeudos condonados para el contrato 1228, ordenados por periodo de pago, junto con los totales por contrato.

**Datos de prueba:**
{ "control_contrato": 1228, "opcion": 1 }

---

## Caso de Uso 2: Consulta de Adeudos Condonados por Contrato y Operación

**Descripción:** El usuario desea obtener el reporte de adeudos condonados para un contrato específico, clasificados por operación.

**Precondiciones:**
El contrato existe y tiene adeudos condonados registrados.

**Pasos a seguir:**
1. El usuario accede a la página de 'Reporte de Adeudos Condonados'.
2. Ingresa el número de contrato (ejemplo: 1228).
3. Selecciona 'Operación' como opción de clasificación.
4. Hace clic en 'Consultar'.
5. El sistema muestra la tabla con los adeudos condonados clasificados por operación.

**Resultado esperado:**
Se muestra la lista de adeudos condonados para el contrato 1228, ordenados por operación, junto con los totales por contrato.

**Datos de prueba:**
{ "control_contrato": 1228, "opcion": 2 }

---

## Caso de Uso 3: Consulta sin resultados

**Descripción:** El usuario consulta un contrato que no tiene adeudos condonados.

**Precondiciones:**
El contrato existe pero no tiene adeudos condonados con status 'S'.

**Pasos a seguir:**
1. El usuario accede a la página de 'Reporte de Adeudos Condonados'.
2. Ingresa el número de contrato (ejemplo: 9999).
3. Selecciona cualquier opción de clasificación.
4. Hace clic en 'Consultar'.
5. El sistema informa que no se encontraron datos.

**Resultado esperado:**
Se muestra un mensaje de advertencia indicando que no hay datos para los criterios seleccionados.

**Datos de prueba:**
{ "control_contrato": 9999, "opcion": 1 }

---



## Casos de Prueba

# Casos de Prueba: Reporte de Adeudos Condonados

## Caso 1: Consulta exitosa por periodo de pago
- **Entrada:**
  - control_contrato: 1228
  - opcion: 1
- **Acción:**
  - POST /api/execute con eRequest=getAdeudosCondonados y los parámetros anteriores
- **Resultado esperado:**
  - success=true
  - data: array con registros ordenados por aso_mes_pago, cve_operacion
  - error=null

## Caso 2: Consulta exitosa por operación
- **Entrada:**
  - control_contrato: 1228
  - opcion: 2
- **Acción:**
  - POST /api/execute con eRequest=getAdeudosCondonados y los parámetros anteriores
- **Resultado esperado:**
  - success=true
  - data: array con registros ordenados por cve_operacion, aso_mes_pago
  - error=null

## Caso 3: Consulta sin resultados
- **Entrada:**
  - control_contrato: 9999 (contrato inexistente o sin adeudos condonados)
  - opcion: 1
- **Acción:**
  - POST /api/execute con eRequest=getAdeudosCondonados y los parámetros anteriores
- **Resultado esperado:**
  - success=true
  - data: array vacío
  - error=null

## Caso 4: Parámetro faltante
- **Entrada:**
  - control_contrato: (no enviado)
  - opcion: 1
- **Acción:**
  - POST /api/execute con eRequest=getAdeudosCondonados y los parámetros anteriores
- **Resultado esperado:**
  - success=false
  - data: null
  - error: 'control_contrato es requerido'

## Caso 5: eRequest no soportado
- **Entrada:**
  - eRequest: 'unknownRequest'
- **Acción:**
  - POST /api/execute con eRequest=unknownRequest
- **Resultado esperado:**
  - success=false
  - data: null
  - error: 'eRequest no soportado'


