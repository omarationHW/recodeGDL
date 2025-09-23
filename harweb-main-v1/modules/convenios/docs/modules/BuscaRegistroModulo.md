# Documentación Técnica: Migración BuscaRegistroModulo (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs).
- **Base de Datos:** PostgreSQL 14+, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse (entrada/salida JSON estructurado).

## 2. Flujo de Trabajo
1. El usuario accede a la página de búsqueda y selecciona el tipo de registro (multas, licencias, predial, etc.).
2. El frontend muestra el formulario correspondiente (cada uno es un componente Vue independiente).
3. Al enviar el formulario, Vue.js envía un POST a `/api/execute` con un `eRequest` que indica la acción (`buscarRegistro`) y los parámetros del formulario.
4. El controlador Laravel recibe la petición, despacha la acción y llama el stored procedure correspondiente según el tipo de búsqueda.
5. El resultado se retorna en `eResponse` y se muestra en la tabla de resultados.

## 3. Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "buscarRegistro",
      "tipo": "multas|lic_construccion|predial|...",
      "form": { ...campos... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ...resultados... ],
      "message": ""
    }
  }
  ```

## 4. Seguridad
- Autenticación recomendada vía JWT o Laravel Sanctum.
- Validación de parámetros en el controlador antes de ejecutar SP.
- Manejo de errores y logging en Laravel.

## 5. Componentes Vue.js
- Cada formulario es un componente Vue independiente (ej: MultasForm.vue, LicConstruccionForm.vue, etc.).
- El componente principal (`BuscaRegistroModulo.vue`) selecciona el formulario según el tipo.
- Los catálogos (mercados, aseo, dependencias) se cargan dinámicamente vía API.
- Resultados se muestran en tabla responsive.

## 6. Stored Procedures
- Cada tipo de búsqueda tiene su propio SP en PostgreSQL.
- Los SP devuelven tablas con los campos estándar: control, calcregistro, nombre, modulo, ubicacion.
- SPs deben ser idempotentes y seguros ante SQL Injection (usar parámetros).

## 7. Extensibilidad
- Para agregar un nuevo tipo de búsqueda:
  1. Crear el SP correspondiente en PostgreSQL.
  2. Agregar el caso en el controlador Laravel.
  3. Crear el formulario Vue.js.
  4. Registrar la opción en el selector de tipo.

## 8. Pruebas y Validación
- Casos de uso y pruebas unitarias en backend y frontend.
- Validación de datos de entrada y salida.
- Pruebas de integración con datos reales y simulados.

## 9. Consideraciones de Migración
- Los nombres de campos y lógica de negocio deben mapearse fielmente del Delphi original.
- Los SP pueden ser optimizados para PostgreSQL (uso de COALESCE, CONCAT, etc.).
- El endpoint `/api/execute` centraliza toda la lógica y facilita la integración con otros módulos.

## 10. Ejemplo de eRequest/eResponse
```json
{
  "eRequest": {
    "action": "buscarRegistro",
    "tipo": "mercados",
    "form": {
      "oficina": 1,
      "num_mercado": 2,
      "categoria": 3,
      "seccion": "A",
      "local": 10,
      "letra_local": "B",
      "bloque": "1"
    }
  }
}
```

## 11. Referencias
- [Laravel Controllers](https://laravel.com/docs/controllers)
- [Vue.js Components](https://vuejs.org/guide/components/)
- [PostgreSQL Stored Procedures](https://www.postgresql.org/docs/current/plpgsql.html)
