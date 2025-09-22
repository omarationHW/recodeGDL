# Documentación Técnica: Migración Formulario TitulosSin (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), PostgreSQL 13+
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **API:** Unificada, endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de Datos:** Todas las operaciones de negocio encapsuladas en Stored Procedures (SP) PostgreSQL

## Flujo de Trabajo
1. **El usuario accede a la página TitulosSin**
2. **Llena los campos requeridos:** Fecha, Ofna, Caja, Operación, Folio
3. **Presiona 'Buscar Ingresos':**
   - Vue llama a `/api/execute` con action `getIngresos`
   - Laravel ejecuta el SP `sp_titulosin_get_ingresos`
   - Si hay datos, muestra campos adicionales (Título, Partida, Teléfono)
4. **Presiona 'Imprimir Título':**
   - Vue llama a `/api/execute` con action `printTituloSin`
   - Laravel ejecuta el SP `sp_titulosin_print`
   - Devuelve los datos para impresión (puede ser JSON, PDF, etc.)

## API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "nombreAccion",
    "payload": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": { ... },
    "message": "..."
  }
  ```

## Stored Procedures
- Toda la lógica de negocio y acceso a datos está en SPs PostgreSQL
- El controlador Laravel sólo invoca los SPs y retorna el resultado
- Los SPs devuelven datos en formato tabla o JSON según el caso

## Seguridad
- Validación de parámetros en backend y frontend
- El endpoint puede protegerse con middleware de autenticación JWT o session

## Manejo de Errores
- Todos los errores se devuelven en el campo `message` del response
- El frontend muestra los mensajes de error al usuario

## Extensibilidad
- Para agregar nuevas acciones, sólo se requiere:
  - Crear el SP correspondiente
  - Agregar el case en el controlador Laravel
  - Consumirlo desde Vue.js

## Consideraciones de Migración
- Los nombres de tablas y campos se mantienen para compatibilidad
- Las operaciones de impresión pueden devolver JSON o un enlace a PDF generado
- El frontend no usa tabs ni componentes tabulares: cada formulario es una página

## Ejemplo de Llamada API
```js
// Buscar ingresos
axios.post('/api/execute', {
  action: 'getIngresos',
  payload: {
    fecha: '2024-06-01',
    ofna: 1,
    caja: 'A',
    operacion: 12345
  }
})
```

## Ejemplo de Respuesta
```json
{
  "success": true,
  "data": {
    "fecha": "2024-06-01",
    "id_rec": 1,
    ...
  },
  "message": "Ingreso encontrado."
}
```

## Estructura de Carpetas
- `app/Http/Controllers/Api/TitulosSinController.php`
- `resources/js/pages/TituloSinPage.vue`
- `database/migrations/` (para tablas si es necesario)
- `database/functions/` (para SPs)

## Pruebas y Validación
- Se recomienda usar Postman para pruebas de API
- El frontend puede probarse con Cypress o Jest
