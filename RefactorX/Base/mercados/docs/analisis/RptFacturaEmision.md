# Documentación Técnica: RptFacturaEmision

## Descripción General
El formulario **RptFacturaEmision** permite generar la facturación de estados de cuenta para locales de mercados municipales, filtrando por oficina recaudadora, año, periodo y mercado. Incluye lógica de cálculo de importes y reglas de negocio específicas según el tipo de local y mercado.

## Arquitectura
- **Backend (Laravel):**
  - Un único controlador (`RptFacturaEmisionController`) expone el endpoint `/api/execute`.
  - Todas las acciones se envían como un objeto `eRequest` con los campos `action` y `params`.
  - El controlador invoca stored procedures PostgreSQL para obtener los datos requeridos.

- **Frontend (Vue.js):**
  - Un componente de página independiente (`RptFacturaEmisionPage.vue`) permite al usuario ingresar los parámetros y visualizar los resultados en una tabla.
  - No utiliza tabs ni componentes tabulares; cada formulario es una página completa.

- **Base de Datos (PostgreSQL):**
  - Toda la lógica SQL se implementa en stored procedures (`sp_rpt_factura_emision`, `sp_get_vencimiento_rec`).
  - Los cálculos de campos como `importe` y `datoslocal` se realizan en el SP.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "action": "getFacturaEmision",
    "params": {
      "oficina": 1,
      "axo": 2024,
      "periodo": 6,
      "mercado": 5,
      "opc": 1
    }
  }
  ```
- **Salida:**
  ```json
  {
    "status": "success",
    "data": [ ... ],
    "message": "Datos de facturación obtenidos correctamente"
  }
  ```

## Stored Procedures
- **sp_rpt_factura_emision:**
  - Parámetros: oficina, año, periodo, mercado, opción (1=solo mercado, 2=todos)
  - Devuelve: lista de locales con datos calculados y reglas de negocio.
- **sp_get_vencimiento_rec:**
  - Parámetro: mes
  - Devuelve: fechas de vencimiento y acumulados de sábados para el cálculo de importes.

## Validaciones
- Todos los parámetros son requeridos y validados en el backend.
- El frontend valida que los campos sean numéricos y requeridos antes de enviar la petición.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej: JWT o session).
- Los parámetros son validados y sanitizados antes de ejecutar los SP.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ser reutilizados por otros módulos.

## Navegación
- El componente Vue incluye breadcrumbs para navegación clara.
- Cada formulario es una página independiente y funcional.

## Pruebas
- Se incluyen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del sistema.
