# Documentación Técnica: Migración Formulario ActCont_CR (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario "Actualiza Contratos en Cantidad de Recolección" (ActCont_CR) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El formulario permite consultar contratos de recolección filtrados por tipo de aseo.

## 2. Arquitectura
- **Frontend**: Componente Vue.js como página independiente, con selección de tipo de aseo y tabla de resultados.
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` que recibe un `eRequest` y parámetros, y responde con `eResponse`.
- **Base de Datos**: PostgreSQL, con lógica encapsulada en stored procedures (funciones).

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "get_ta_catalog",
    "params": {}
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedure
- **Nombre**: `get_ta_catalog`
- **Tipo**: CATALOG
- **Función**: Devuelve todos los registros de la tabla `ta`.
- **Uso**: El controlador Laravel ejecuta esta función para obtener los datos requeridos.

## 5. Frontend (Vue.js)
- Página independiente con ruta propia.
- Selector de tipo de aseo (con valores: 9, 8, 4).
- Botón para consultar contratos.
- Tabla de resultados filtrada por el tipo de aseo seleccionado.
- Mensajes de carga, error y vacío.

## 6. Seguridad
- El endpoint `/api/execute` debe protegerse según las políticas de autenticación de la aplicación.
- Validar el valor de `eRequest` y los parámetros recibidos.

## 7. Extensibilidad
- Para agregar nuevas operaciones, implementar nuevos stored procedures y ampliar el switch-case en el controlador.

## 8. Notas
- La estructura de la tabla `ta` debe ajustarse según el modelo real de datos.
- El filtrado por tipo de aseo se realiza en frontend, pero puede optimizarse agregando un parámetro al stored procedure si se requiere.
