# Documentación Técnica: Migración Listados_Ade Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse, entrada/salida JSON.

## Flujo de Trabajo
1. **Usuario** accede a la página de Listados de Adeudos.
2. Selecciona la aplicación (Mercados, Aseo, Públicos, Exclusivos, Infracciones).
3. El formulario correspondiente se muestra (cada uno es una página Vue independiente).
4. Al enviar, se construye un eRequest con acción y parámetros.
5. El frontend hace POST a `/api/execute`.
6. El controlador Laravel recibe, despacha al SP adecuado según acción.
7. El resultado del SP se retorna como eResponse.
8. El frontend muestra los resultados en tabla.

## API: /api/execute
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "mercados|aseo|publicos|exclusivos|infracciones",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "data": [ ... ]
    }
  }
  ```

## Stored Procedures
- Cada acción llama a un SP específico, que encapsula la lógica SQL y los filtros.
- Los SPs devuelven un conjunto de resultados (SELECT), no hacen commits ni inserts.
- Los parámetros de los SPs corresponden a los filtros del formulario.

## Frontend Vue.js
- Cada formulario es un componente Vue independiente (ej: ListadosAdeMercadosForm.vue).
- El componente principal ListadosAde.vue selecciona el formulario según la aplicación.
- Cada formulario emite un evento submit con los parámetros, que el padre usa para llamar a la API.
- Los resultados se muestran en una tabla dinámica.
- No se usan tabs ni componentes tabulares: cada formulario es una página completa.

## Seguridad
- Autenticación recomendada vía JWT o Laravel Sanctum.
- Validación de parámetros en el backend antes de ejecutar el SP.
- Los SPs deben validar los parámetros para evitar SQL injection.

## Consideraciones de Migración
- Los nombres de tablas/campos pueden variar según el modelo PostgreSQL final.
- Los SPs deben adaptarse a la estructura real de la base de datos.
- Los reportes impresos (PDF, etc) deben implementarse como endpoints/reportes aparte si se requiere.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los formularios Vue pueden extenderse para nuevos filtros/campos.

# Ejemplo de eRequest/eResponse
```json
{
  "eRequest": {
    "action": "mercados",
    "params": {
      "oficina": 1,
      "num_mercado1": 1,
      "num_mercado2": 10,
      "local1": 1,
      "local2": 99,
      "seccion": "A",
      "axo": 2024,
      "mes": 6
    }
  }
}
```

# Notas
- Los SPs pueden retornar errores usando RAISE EXCEPTION o un campo especial.
- El frontend debe manejar errores y mostrar mensajes amigables.
- El endpoint es único, pero internamente puede despachar a diferentes SPs.
