# Documentación Técnica: Migración de Formulario repavance (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario de avance de recaudación de multas (repavance) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

- **Backend**: Laravel expone un endpoint unificado `/api/execute` que recibe peticiones eRequest/eResponse y ejecuta la lógica de negocio, incluyendo la invocación de stored procedures en PostgreSQL.
- **Frontend**: Un componente Vue.js representa la página completa del formulario, permitiendo seleccionar mes, año, recaudadora y tipo, y mostrando el reporte generado.
- **Base de Datos**: Toda la lógica de agregación y reporte se implementa en stored procedures PostgreSQL.

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato de entrada**: `{ eRequest: { action: string, params: object } }`
- **Formato de salida**: `{ eResponse: { success: bool, data: object, message: string } }`

### Ejemplo de eRequest
```json
{
  "eRequest": {
    "action": "repavance_generate_report",
    "params": {
      "mes": 0,
      "anio": 2024,
      "recaudadora_id": 1,
      "tipo": "M"
    }
  }
}
```

## 3. Lógica de Negocio
- El usuario selecciona mes, año, recaudadora y tipo (municipal/federal).
- El backend calcula las fechas de inicio y fin del mes.
- Se invoca el stored procedure `repavance_generate_report` con los parámetros.
- El SP retorna un JSON con el detalle por dependencia (actas y totales en diferentes categorías).
- El frontend muestra el reporte en tabla, con totales.

## 4. Stored Procedure Principal
- **Nombre**: `repavance_generate_report`
- **Entradas**: recaudadora_id, fecha mínima, fecha máxima, tipo, año
- **Salida**: JSON con array de objetos por dependencia, cada uno con los campos: id_dependencia, descripcion, cuantos1, total1, cuantos2, total2, cuantos3, total3, cuantos4, total4
- **Notas**: La lógica de agregación puede adaptarse según la estructura real de las tablas.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para selección de parámetros.
- Tabla de resultados con totales.
- Manejo de errores y estados de carga.

## 6. Seguridad
- Validación de parámetros en backend.
- El SP sólo retorna datos agregados, no datos sensibles.

## 7. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- El SP puede extenderse para incluir más métricas o filtros.

## 8. Consideraciones de Migración
- Los nombres de tablas y campos pueden necesitar ajuste según el modelo real.
- La lógica de filtrado y agregación se centraliza en el SP para eficiencia y mantenibilidad.

## 9. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.
