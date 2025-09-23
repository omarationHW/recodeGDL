# Documentación Técnica: RptCaratulaDatos

## Descripción General
Este módulo corresponde a la migración del formulario "Carátula de Locales" (RptCaratulaDatos) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos). El objetivo es ofrecer una consulta detallada de los datos de un local, incluyendo sus adeudos, recargos, y estado financiero, con lógica de negocio centralizada en stored procedures y un endpoint API unificado.

## Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "getRptCaratulaDatos",
    "params": {
      "id_local": 123,
      "renta": 1000.00,
      "adeudo": 500.00,
      "recargos": 50.00,
      "gastos": 10.00,
      "multa": 0.00,
      "total": 560.00,
      "folios": "1234,1235,",
      "leyenda": "Desc. pronto pago"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": { ... },
    "message": ""
  }
  ```

## Stored Procedures
Toda la lógica de negocio y cálculos (recargos, descuentos, leyendas, etc.) se implementa en stored procedures PostgreSQL. El controlador Laravel solo invoca estos procedimientos y retorna el resultado.

## Seguridad
- Autenticación JWT recomendada para el endpoint
- Validación de parámetros en el backend

## Frontend
- Página Vue.js independiente, sin tabs
- Formulario para ingresar parámetros y consultar la carátula
- Renderizado de los datos y detalle de adeudos

## Navegación
- Breadcrumb simple: Inicio / Carátula de Locales
- Cada formulario es una ruta independiente

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones relacionadas
- Los stored procedures pueden ser reutilizados por otros módulos

## Pruebas
- Casos de uso y escenarios de prueba incluidos en este documento

# Esquema de Base de Datos (relevante)
- ta_11_locales
- ta_11_adeudo_local
- ta_11_mercados
- ta_12_recargos
- ta_11_fecha_desc
- ta_12_passwords

# Notas de Migración
- Los cálculos de recargos y descuentos se centralizan en SPs
- El frontend no realiza lógica de negocio, solo presenta los datos
- El endpoint es agnóstico de la acción, todo se resuelve por el parámetro `action`
