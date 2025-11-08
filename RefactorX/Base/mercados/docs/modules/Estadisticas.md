# Documentación Técnica: Estadísticas de Adeudos

## Descripción General
Este módulo permite consultar estadísticas de adeudos de locales comerciales, con tres modalidades:

1. **Todos los Adeudos**: Estadística global de adeudos vencidos al periodo seleccionado.
2. **Adeudos ≥ Importe**: Estadística global de adeudos vencidos al periodo, filtrando por importe mínimo.
3. **Desglose Adeudos ≥ Importe**: Desglose de adeudos por año para locales con importe mayor o igual al parámetro.

La solución está compuesta por:
- **Backend Laravel**: Un controlador con endpoint unificado `/api/execute` que recibe eRequest/eResponse.
- **Frontend Vue.js**: Página independiente para consulta y exportación de estadísticas.
- **Stored Procedures PostgreSQL**: Toda la lógica SQL reside en SPs para eficiencia y seguridad.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato**:
  ```json
  {
    "action": "getEstadisticasGlobal|getEstadisticasImporte|getDesgloceAdeudosPorImporte",
    "params": {
      "year": 2024,
      "month": 6,
      "importe": 3000
    }
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
- **sp_estadisticas_global**: Devuelve estadística global de adeudos.
- **sp_estadisticas_importe**: Igual que anterior, pero filtrando por importe.
- **sp_desgloce_adeudos_por_importe**: Devuelve desglose por año de adeudos para locales con importe mayor o igual al parámetro.

## Seguridad
- Todas las consultas usan parámetros para evitar SQL Injection.
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.

## Exportación a Excel
- El frontend exporta los resultados a CSV (puede integrarse con librerías como SheetJS para Excel nativo).

## Navegación
- Cada formulario es una página independiente.
- Breadcrumbs para navegación contextual.

## Integración
- El frontend se comunica con el backend usando Axios y el endpoint unificado.
- El backend ejecuta el SP correspondiente según el tipo de estadística.

## Consideraciones
- Los SPs pueden ser adaptados para optimización según el volumen de datos.
- El frontend es responsivo y puede integrarse en cualquier SPA Vue.js.

# Parámetros de Entrada
- **year**: Año de corte de la estadística.
- **month**: Mes de corte.
- **importe**: Importe mínimo (solo para los modos 2 y 3).

# Parámetros de Salida
- Listado de registros con columnas dinámicas según el SP invocado.

# Errores Comunes
- Si no se selecciona tipo de estadística, el backend responde con error.
- Si los parámetros son inválidos, el backend retorna mensaje de error.

# Pruebas y Validación
- Ver sección de Casos de Uso y Casos de Prueba.
