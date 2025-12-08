# DocumentaciÃ³n TÃ©cnica: Contratos_Adeudos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Contratos con Adeudos

## Descripción General
Este módulo permite consultar la relación de contratos con adeudos, mostrando información relevante del contrato, empresa, tipo de aseo, unidad de recolección, periodos de adeudo, recargos, multas, gastos, documentos y licencias asociadas. El formulario permite filtrar por tipo de aseo, vigencia, tipo de reporte (periodos vencidos u otro periodo) y periodo de corte.

## Arquitectura
- **Backend:** Laravel Controller expone un endpoint unificado `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, con navegación y tabla de resultados.
- **Base de Datos:** Toda la lógica SQL se implementa en stored procedures de PostgreSQL.
- **API:** El endpoint `/api/execute` recibe un objeto con `action` y `params` y responde con un objeto eResponse.

## Flujo de Datos
1. El usuario selecciona los filtros y ejecuta la búsqueda.
2. El frontend envía una petición POST a `/api/execute` con la acción `get_contratos_adeudos` y los parámetros seleccionados.
3. El backend ejecuta el stored procedure `sp16_contratos_adeudo` con los parámetros recibidos.
4. El resultado se devuelve al frontend y se muestra en una tabla.
5. El usuario puede exportar los resultados a Excel (requiere implementación adicional).

## Parámetros de Consulta
- `parTipo`: Tipo de aseo (C, H, O, T)
- `parVigencia`: Vigencia del contrato (V, N, C, S, T)
- `parReporte`: Tipo de reporte (V = vencidos, T = otro periodo)
- `pref`: Periodo de corte en formato `YYYY-MM`

## Stored Procedure
El stored procedure `sp16_contratos_adeudo` recibe los parámetros anteriores y retorna una tabla con los campos requeridos. Los cálculos de adeudos, recargos, multas, etc., deben implementarse en el SP según la lógica de negocio.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o similar.
- Validar y sanear todos los parámetros recibidos.

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los stored procedures pueden evolucionar para incluir más lógica o cálculos.

## Consideraciones
- La exportación a Excel puede implementarse en backend (generando archivo y devolviendo URL) o frontend (usando librerías JS).
- El frontend debe manejar errores y mostrar mensajes claros al usuario.


## Casos de Prueba

# Casos de Prueba: Contratos con Adeudos

## Caso 1: Consulta básica de contratos con adeudos vencidos
- **Entrada:**
  - parTipo: 'O'
  - parVigencia: 'V'
  - parReporte: 'V'
  - pref: '2024-06'
- **Acción:** POST /api/execute con action=get_contratos_adeudos
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: array de contratos con campos completos

## Caso 2: Consulta por periodo específico
- **Entrada:**
  - parTipo: 'H'
  - parVigencia: 'N'
  - parReporte: 'T'
  - pref: '2023-03'
- **Acción:** POST /api/execute con action=get_contratos_adeudos
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: array de contratos filtrados por periodo

## Caso 3: Exportar a Excel
- **Entrada:**
  - Mismos parámetros que una consulta
- **Acción:** POST /api/execute con action=export_excel
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: archivo Excel o URL de descarga

## Caso 4: Parámetros inválidos
- **Entrada:**
  - parTipo: 'X'
  - parVigencia: 'Z'
  - parReporte: 'Q'
  - pref: 'abcd-ef'
- **Acción:** POST /api/execute con action=get_contratos_adeudos
- **Resultado esperado:**
  - HTTP 200
  - success: false
  - message: 'Error al consultar.' o mensaje de validación

## Caso 5: Sin resultados
- **Entrada:**
  - parTipo: 'O'
  - parVigencia: 'C'
  - parReporte: 'T'
  - pref: '1990-01'
- **Acción:** POST /api/execute con action=get_contratos_adeudos
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: []


## Casos de Uso

# Casos de Uso - Contratos_Adeudos

**Categoría:** Form

## Caso de Uso 1: Consulta de contratos con adeudos vencidos

**Descripción:** El usuario desea obtener la lista de contratos con adeudos vencidos para el tipo de aseo Ordinario y vigencia Vigente.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar contratos.

**Pasos a seguir:**
1. El usuario accede a la página de Contratos con Adeudos.
2. Selecciona 'Ordinario' en Tipo de Aseo.
3. Selecciona 'Vigente' en Vigencia.
4. Selecciona 'Periodos Vencidos' en Tipo Reporte.
5. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los contratos que cumplen los filtros, incluyendo todos los campos relevantes.

**Datos de prueba:**
parTipo: 'O', parVigencia: 'V', parReporte: 'V', pref: '2024-06'

---

## Caso de Uso 2: Consulta de contratos con adeudos en un periodo específico

**Descripción:** El usuario desea consultar contratos con adeudos para el periodo de marzo 2023, tipo de aseo Hospitalario y vigencia Conveniado.

**Precondiciones:**
El usuario tiene acceso y existen contratos con esos filtros.

**Pasos a seguir:**
1. Accede a la página.
2. Selecciona 'Hospitalario' en Tipo de Aseo.
3. Selecciona 'Conveniado' en Vigencia.
4. Selecciona 'Otro Periodo' en Tipo Reporte.
5. Ingresa '2023' en Año y '03' en Mes.
6. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestran los contratos filtrados por periodo, tipo y vigencia.

**Datos de prueba:**
parTipo: 'H', parVigencia: 'N', parReporte: 'T', pref: '2023-03'

---

## Caso de Uso 3: Exportar resultados a Excel

**Descripción:** El usuario desea exportar la lista de contratos con adeudos a un archivo Excel.

**Precondiciones:**
El usuario ha realizado una búsqueda y hay resultados en pantalla.

**Pasos a seguir:**
1. Realiza una búsqueda con los filtros deseados.
2. Da clic en el botón 'Exportar Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos mostrados.

**Datos de prueba:**
parTipo: 'C', parVigencia: 'T', parReporte: 'V', pref: '2024-06'

---



---
**Componente:** `Contratos_Adeudos.vue`
**MÃ³dulo:** `aseo_contratado`

