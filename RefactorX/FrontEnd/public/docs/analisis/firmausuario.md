# Documentación Técnica: Migración Formulario firmausuario (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa el formulario de validación de firma electrónica de usuario, migrado desde Delphi a una arquitectura moderna basada en Laravel (API REST), Vue.js (SPA) y PostgreSQL (lógica de negocio en stored procedures). El flujo permite que un usuario ingrese su nombre de usuario y firma electrónica, y valida estos datos contra la base de datos.

## 2. Arquitectura
- **Frontend:** Componente Vue.js independiente, página completa, sin tabs.
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de validación encapsulada en stored procedure.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "validate_firma_usuario",
      "data": {
        "usuario": "nombre_usuario",
        "firma": "firma_digital"
      }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true/false,
      "message": "Mensaje de validación",
      "usuario": "nombre_usuario" // solo si success=true
    }
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_validate_firma_usuario`
- **Parámetros:**
  - `p_usuario` (VARCHAR): Nombre de usuario
  - `p_firma` (VARCHAR): Firma electrónica
- **Retorno:**
  - `success` (BOOLEAN): true si la validación es correcta
  - `message` (TEXT): Mensaje descriptivo
- **Tabla esperada:** `usuarios(usuario VARCHAR, firma_digital VARCHAR, ...)`

## 5. Flujo de la Aplicación
1. El usuario accede a la página de firma electrónica.
2. Ingresa usuario y firma.
3. Al presionar "Aceptar", se envía la petición a `/api/execute`.
4. Laravel recibe la petición, valida los datos y llama al stored procedure.
5. El resultado se retorna al frontend y se muestra el mensaje correspondiente.

## 6. Validaciones
- Frontend: Campos obligatorios.
- Backend: Validación de presencia y tipo de datos.
- Stored Procedure: Validación de existencia y coincidencia de usuario/firma.

## 7. Seguridad
- La firma se transmite cifrada por HTTPS.
- El campo de firma es tipo password en el frontend.
- Se recomienda almacenar la firma cifrada/hasheada en la base de datos (no incluido en este ejemplo por compatibilidad con Delphi).

## 8. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones fácilmente.
- El frontend puede ser reutilizado en otros módulos.

## 9. Consideraciones
- El icono de firma debe estar disponible en `/public/firma-icon.png`.
- El stored procedure asume que la tabla `usuarios` existe y contiene los campos necesarios.
