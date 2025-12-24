# Documentación Técnica: Rep_Empresas

## Análisis

# Documentación Técnica: Reporte de Empresas (Rep_Empresas)

## Descripción General
Este módulo permite generar un reporte de empresas, ordenado por diferentes criterios (número, tipo, nombre, representante). Incluye:
- Un endpoint API unificado (`/api/execute`) que recibe acciones y parámetros.
- Un controlador Laravel que ejecuta la lógica y llama al stored procedure en PostgreSQL.
- Un componente Vue.js que representa la página completa del formulario de reporte.
- Un stored procedure en PostgreSQL que realiza la consulta y ordenamiento dinámico.

## Arquitectura
- **Backend:** Laravel Controller (EmpresasReportController)
- **Frontend:** Vue.js Single Page Component (EmpresasReportPage.vue)
- **Base de Datos:** PostgreSQL, con stored procedure `sp_rep_empresas_report`
- **API:** Endpoint único `/api/execute` con patrón eRequest/eResponse

## Flujo de Datos
1. El usuario accede a la página de reporte de empresas.
2. El frontend solicita las opciones de orden al endpoint `/api/execute` con `action: getReportOptions`.
3. El usuario selecciona el criterio de orden y solicita la vista previa.
4. El frontend envía `action: getEmpresasReport` y el criterio seleccionado.
5. El backend ejecuta el stored procedure `sp_rep_empresas_report` con el parámetro de orden.
6. El resultado se muestra en una tabla en la página.

## API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `action`: string (ej: 'getEmpresasReport')
  - `params`: objeto con parámetros específicos (ej: `{ order: 1 }`)
- **Salida:**
  - `status`: 'success' | 'error'
  - `data`: array de resultados o null
  - `message`: string

## Stored Procedure
- **Nombre:** sp_rep_empresas_report
- **Parámetro:** p_order (integer)
- **Ordenamiento:**
  - 1: Número de empresa
  - 2: Tipo de empresa
  - 3: Nombre
  - 4: Representante
- **Retorna:** Tabla con columnas: num_empresa, ctrol_emp, tipo_empresa, descripcion, representante

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel, no mostrado aquí).
- Validar que el parámetro `order` esté en el rango permitido (1-4).

## Consideraciones
- El frontend es una página independiente, no usa tabs.
- El backend puede ser extendido para exportar a PDF/Excel si se requiere.
- El stored procedure puede ser adaptado para incluir más criterios de orden.

## Extensión
- Para agregar más criterios de orden, modificar el stored procedure y el frontend.
- Para exportar, agregar endpoints adicionales o lógica en el controlador.


## Casos de Uso

# Casos de Uso - Rep_Empresas

**Categoría:** Form

## Caso de Uso 1: Generar reporte de empresas ordenado por número

**Descripción:** El usuario desea obtener un listado de todas las empresas ordenadas por su número.

**Precondiciones:**
El usuario está autenticado y tiene permisos para ver reportes.

**Pasos a seguir:**
1. El usuario accede a la página de 'Reporte de Empresas'.
2. Selecciona la opción 'Número' en el formulario.
3. Hace clic en 'Vista Previa'.
4. El sistema muestra la tabla con los datos ordenados por número de empresa.

**Resultado esperado:**
Se muestra una tabla con todas las empresas ordenadas por el campo 'num_empresa'.

**Datos de prueba:**
Empresas con num_empresa: 1, 2, 3, 4, 5.

---

## Caso de Uso 2: Generar reporte de empresas ordenado por tipo de empresa

**Descripción:** El usuario desea ver el reporte agrupado por tipo de empresa.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página de reporte.
2. Selecciona 'Tipo de Empresa'.
3. Hace clic en 'Vista Previa'.

**Resultado esperado:**
La tabla muestra las empresas agrupadas y ordenadas por tipo_empresa.

**Datos de prueba:**
Empresas con tipos: 'Industrial', 'Comercial', 'Servicios'.

---

## Caso de Uso 3: Intentar generar reporte con parámetro inválido

**Descripción:** El usuario manipula el frontend y envía un parámetro de orden inválido.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario envía una petición con order=99.
2. El backend ejecuta el stored procedure.

**Resultado esperado:**
El backend retorna un error o una lista vacía, y el frontend muestra un mensaje de error.

**Datos de prueba:**
order=99

---



## Casos de Prueba

# Casos de Prueba: Reporte de Empresas

## Caso 1: Reporte por Número de Empresa
- **Entrada:** action: getEmpresasReport, params: { order: 1 }
- **Esperado:** Lista de empresas ordenadas por num_empresa ascendente.
- **Validación:** El primer registro tiene el menor num_empresa.

## Caso 2: Reporte por Tipo de Empresa
- **Entrada:** action: getEmpresasReport, params: { order: 2 }
- **Esperado:** Empresas agrupadas por tipo_empresa, ordenadas alfabéticamente.
- **Validación:** Todos los registros de un tipo aparecen juntos.

## Caso 3: Reporte por Nombre
- **Entrada:** action: getEmpresasReport, params: { order: 3 }
- **Esperado:** Empresas ordenadas por descripcion (nombre).
- **Validación:** El orden alfabético es correcto.

## Caso 4: Reporte por Representante
- **Entrada:** action: getEmpresasReport, params: { order: 4 }
- **Esperado:** Empresas ordenadas por representante.
- **Validación:** El campo representante está en orden alfabético.

## Caso 5: Parámetro inválido
- **Entrada:** action: getEmpresasReport, params: { order: 99 }
- **Esperado:** Lista vacía o error controlado.
- **Validación:** El backend retorna status error o data vacía.

## Caso 6: Opciones de orden
- **Entrada:** action: getReportOptions
- **Esperado:** Lista de opciones con id y label.
- **Validación:** Hay al menos 4 opciones y la primera es 'Número'.


