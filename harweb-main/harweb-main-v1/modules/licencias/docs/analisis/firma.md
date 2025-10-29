# Documentación Técnica: Migración Formulario Firma Electrónica (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa el formulario de ingreso de firma electrónica, migrado desde Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (Base de datos). El flujo permite validar y guardar la firma digital de un usuario, usando un endpoint API unificado y procedimientos almacenados.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, página independiente para el formulario de firma electrónica.
- **Backend**: Laravel API, controlador único para todas las operaciones (patrón eRequest/eResponse).
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: Objeto `eRequest` con campos:
  - `operation`: Nombre de la operación (ej: `firma_validate`, `firma_save`)
  - `data`: Datos requeridos por la operación
- **Salida**: Objeto `eResponse` con:
  - `success`: boolean
  - `message`: string
  - `data`: objeto con datos adicionales

## 4. Operaciones Soportadas
- `firma_validate`: Valida la firma digital ingresada.
- `firma_save`: Guarda o actualiza la firma digital de un usuario.

## 5. Stored Procedures
- **sp_firma_validate**: Recibe la firma digital, retorna si es válida y datos del usuario.
- **sp_firma_save**: Recibe usuario y firma, actualiza la firma en la tabla de usuarios.

## 6. Seguridad
- La firma digital se transmite encriptada por HTTPS.
- El campo de firma es tipo password en el frontend.
- Se recomienda almacenar la firma digital hasheada en la base de datos.

## 7. Flujo de Usuario
1. El usuario accede a la página de firma electrónica.
2. Ingresa su firma digital (campo password).
3. Al presionar "Aceptar", se envía a `/api/execute` con operación `firma_validate`.
4. El backend valida la firma y responde si es válida o no.
5. Si es válida, se puede proceder a guardar o permitir acceso.

## 8. Integración
- El componente Vue puede ser usado como página independiente.
- El controlador Laravel puede ser extendido para más operaciones.
- Los stored procedures pueden ser adaptados según la estructura real de la tabla de usuarios.

## 9. Consideraciones
- El endpoint es genérico y puede manejar múltiples operaciones.
- El frontend puede ser adaptado para usarse como modal o página según la navegación de la aplicación.

## 10. Dependencias
- Laravel 8+
- Vue.js 2/3
- PostgreSQL 12+
- Axios (para llamadas HTTP en Vue)

