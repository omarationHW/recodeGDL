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
