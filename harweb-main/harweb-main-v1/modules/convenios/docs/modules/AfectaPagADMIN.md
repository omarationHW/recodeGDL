# Documentación Técnica: Migración Formulario AfectaPagADMIN (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 (Composition API), página independiente para el formulario.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Comunicación:** Patrón eRequest/eResponse (JSON), desacoplado de la UI.

## 2. API Unificada
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "listar|afectar|cancelar|licencias|predial",
      ...otros parámetros...
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": [ ... ]
    }
  }
  ```

## 3. Stored Procedures
- Toda la lógica de negocio (afectación, cancelación, licencias, predial) se implementa en SPs de PostgreSQL.
- Los SPs devuelven JSON para facilitar el manejo de errores y mensajes.
- El controlador Laravel solo orquesta la llamada y retorna la respuesta.

## 4. Controlador Laravel
- Un solo método `execute(Request $request)` que despacha según `eRequest.action`.
- Cada acción llama al SP correspondiente.
- Manejo de errores y logging centralizado.

## 5. Componente Vue.js
- Página independiente, sin tabs.
- Consulta pagos por fecha, muestra tabla editable.
- Botones "Afectar" y "Cancelar" por pago, con confirmación.
- Mensajes de éxito/error y loading.
- Navegación breadcrumb.

## 6. Seguridad
- Autenticación recomendada vía JWT o Laravel Sanctum.
- Validación de usuario en el backend.
- Los SPs deben validar permisos si es necesario.

## 7. Consideraciones de Migración
- Todos los queries SQL y lógica de negocio Delphi se migran a SPs.
- El frontend nunca accede directo a la BD, solo vía API.
- El endpoint es genérico y desacoplado de la UI.

## 8. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para QA.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los SPs pueden evolucionar sin romper la API.

## 10. Ejemplo de llamada desde frontend
```js
await axios.post('/api/execute', {
  eRequest: {
    action: 'afectar',
    fecha: '2024-06-01',
    usuario: 'admin'
  }
});
```
