# Documentación Técnica: Migración Formulario Cons_his (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la consulta y visualización de folios de apremios (historial de acciones de cobro) y sus detalles asociados. La migración transforma el formulario Delphi en una API RESTful con Laravel, un frontend Vue.js y lógica de datos encapsulada en stored procedures PostgreSQL.

## 2. Arquitectura
- **Backend**: Laravel expone un endpoint único `/api/execute` que recibe peticiones con el patrón `eRequest`/`eResponse`.
- **Frontend**: Vue.js implementa una página independiente para la consulta del folio de apremios.
- **Base de Datos**: Toda la lógica SQL se encapsula en stored procedures PostgreSQL.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "getConsHis",
    "params": { "control": 123 }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "error": null
    }
  }
  ```
- **eRequest soportados**:
  - `getConsHis`: Consulta principal del folio de apremios.
  - `getConsHisDetails`: Detalles de periodos asociados.
  - `getAseoReference`: Referencia de aseo para contratos.
  - `getMercadoReference`: Referencia de mercado para locales.

## 4. Stored Procedures
- Toda la lógica de consulta se implementa en funciones PostgreSQL:
  - `sp_get_cons_his(control)`
  - `sp_get_cons_his_details(control_otr)`
  - `sp_get_aseo_reference(contrato)`
  - `sp_get_mercado_reference(local)`

## 5. Frontend Vue.js
- Página independiente `/cons-his/:control`.
- Carga la información principal y detalles vía API.
- Muestra datos generales, importes, fechas, observaciones y detalles en tabla.
- Incluye navegación breadcrumb y botón de salida.

## 6. Seguridad
- Validación de parámetros en backend.
- Manejo de errores y mensajes claros en frontend.

## 7. Consideraciones
- El endpoint es extensible para otros formularios.
- Los stored procedures pueden ser reutilizados por otros módulos.

## 8. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 12

## 9. Instalación
- Crear las funciones SQL en la base de datos destino.
- Registrar la ruta `/api/execute` en Laravel.
- Integrar el componente Vue.js en el router de la aplicación.

## 10. Pruebas
- Ver sección de casos de uso y casos de prueba.
