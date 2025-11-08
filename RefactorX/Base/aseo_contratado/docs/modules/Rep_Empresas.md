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
