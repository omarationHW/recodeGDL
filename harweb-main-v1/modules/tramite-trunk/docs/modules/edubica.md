# Documentación Técnica: Migración Formulario Edubica (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos:** PostgreSQL 13+, lógica de negocio crítica en stored procedures

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": { ... },
    "message": "Mensaje de resultado"
  }
  ```

## 3. Controlador Laravel
- Un solo controlador (`EdubicaController`) maneja todas las acciones relacionadas con el formulario de ubicación.
- Cada acción se identifica por el campo `action` en el request.
- Validaciones y errores se devuelven en el campo `message`.
- Acceso a stored procedures mediante DB::statement/DB::select.

## 4. Componente Vue.js
- Página independiente `/edubica`.
- Formulario reactivo con validación básica.
- Llama a `/api/execute` para cargar catálogos y guardar cambios.
- Mensajes de éxito/error en pantalla.
- No usa tabs ni componentes tabulares.

## 5. Stored Procedures PostgreSQL
- Toda la lógica de actualización y consulta de ubicaciones está en SPs.
- `sp_actualiza_catastro_ubicacion`: Cierra vigencia anterior, inserta nueva ubicación y actualiza catastro.
- Catálogos de calles y colonias expuestos como funciones.

## 6. Seguridad
- Validación de usuario en el backend (campo `usuario` obligatorio).
- Validación de datos en backend y frontend.
- Solo usuarios autenticados pueden modificar datos.

## 7. Flujo de Edición
1. El usuario ingresa la cuenta catastral y selecciona la nueva ubicación.
2. El sistema cierra la vigencia anterior y registra la nueva ubicación.
3. Se actualiza el registro de catastro con el nuevo `cveubic`, bimestre y año de efectos, y observaciones.
4. Se registra el movimiento en la bitácora (catastro).

## 8. Consideraciones de Integridad
- No se permite guardar si falta algún campo obligatorio.
- El número exterior se rellena a 6 dígitos si es necesario.
- El año de efectos debe ser >= 1900, bimestre entre 1 y 6.

## 9. Pruebas y Casos de Uso
- Ver sección de casos de uso y pruebas.

## 10. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otros formularios.
- Los SPs pueden ser reutilizados por otros módulos.
