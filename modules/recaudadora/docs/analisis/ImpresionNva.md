# Documentación Técnica: Migración de Formulario ImpresionNva (Delphi a Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
El formulario **ImpresionNva** es una pantalla vacía en Delphi, migrada como una página independiente en Vue.js, con backend en Laravel y lógica de integración con PostgreSQL. Se implementa un endpoint API unificado `/api/execute` que recibe un objeto `eRequest` y retorna un objeto `eResponse`.

## 2. Arquitectura
- **Frontend**: Vue.js (Single File Component), página independiente.
- **Backend**: Laravel Controller (ImpresionNvaController), endpoint `/api/execute`.
- **Base de Datos**: PostgreSQL, con stored procedures para cada acción.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**: `{ eRequest: { action: string, params: object } }`
- **Response**: `{ eResponse: { success: bool, data: object, message: string } }`

### Acciones soportadas
- `getFormData`: Carga inicial del formulario (sin datos).
- `submitForm`: Procesa el envío del formulario (sin datos).

## 4. Stored Procedures
- `sp_impresionnva_get_form_data()`: Devuelve datos iniciales (vacío).
- `sp_impresionnva_submit_form()`: Procesa el envío (retorna éxito).

## 5. Flujo de Trabajo
1. El componente Vue carga la página y llama a `getFormData` para inicializar.
2. Al presionar "Enviar", se llama a `submitForm`.
3. El backend responde con éxito y mensaje.

## 6. Consideraciones
- El formulario original no tiene campos, por lo que la migración mantiene la funcionalidad vacía.
- El endpoint es extensible para futuras acciones.

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación (no implementado en este ejemplo).

## 8. Extensibilidad
- Para agregar campos, modificar el stored procedure y el controlador para manejar los nuevos datos.
