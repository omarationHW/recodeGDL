# Documentación Técnica: Migración Formulario DatosConvenio (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde a la migración del formulario "DatosConvenio" de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, presentando los datos generales de un convenio y sus parcialidades, con acceso unificado vía API REST.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3+, componente de página independiente.
- **Base de Datos:** PostgreSQL, lógica de consulta encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": "getDatosConvenio", // o "getParcialidadesConvenio", "getPagoParcialidad"
    "params": { "control": 123, "parcial": 1 }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- Toda la lógica SQL se encapsula en funciones PostgreSQL:
  - `sp_get_datos_convenio(p_id_conv_resto INTEGER)`
  - `sp_get_parcialidades_convenio(p_id_conv_resto INTEGER)`
  - `sp_get_pago_parcialidad(p_id_conv_resto INTEGER, p_parcial INTEGER)`

## 5. Controlador Laravel
- El controlador `ExecuteController` recibe el `eRequest` y los parámetros, despacha la llamada al stored procedure correspondiente y retorna el resultado en el formato estándar.
- Maneja errores y validaciones de parámetros.

## 6. Componente Vue.js
- Página independiente, recibe `convenio` y `control` como props (por ejemplo, desde la ruta).
- Al montar, consulta datos generales y parcialidades vía `/api/execute`.
- Presenta los datos en formularios y tablas de solo lectura, siguiendo el layout original.
- Incluye navegación breadcrumb y botón de salida.

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validar y sanear todos los parámetros recibidos.

## 8. Pruebas
- Casos de uso y pruebas detalladas incluidas para asegurar la funcionalidad y robustez del módulo.

## 9. Consideraciones de Migración
- Los nombres de campos y lógica de negocio se mantienen fieles al original Delphi.
- El layout visual se adapta a Bootstrap para una experiencia moderna y responsiva.
- El endpoint es extensible para futuras funcionalidades.

## 10. Ejemplo de Uso
- Para obtener los datos generales de un convenio:
  ```json
  {
    "eRequest": "getDatosConvenio",
    "params": { "control": 123 }
  }
  ```
- Para obtener las parcialidades:
  ```json
  {
    "eRequest": "getParcialidadesConvenio",
    "params": { "control": 123 }
  }
  ```

## 11. Extensibilidad
- Se pueden agregar nuevos eRequest fácilmente en el controlador y nuevos stored procedures en PostgreSQL.
