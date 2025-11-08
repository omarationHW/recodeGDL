# Documentación Técnica: Migración Formulario Contratos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL 13+ (todas las consultas complejas y reportes en stored procedures)
- **Patrón API:** eRequest/eResponse (entrada y salida JSON)

## API Unificada
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "listar|buscar|excel",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [...],
      "message": "..."
    }
  }
  ```

## Controlador Laravel
- Un solo controlador (`ContratosController`) maneja todas las acciones relacionadas con contratos.
- Utiliza stored procedures PostgreSQL para lógica de negocio y reportes.
- Métodos principales:
  - `listar`: Lista contratos filtrando por tipo y vigencia.
  - `buscar`: Busca un contrato específico.
  - `excel`: Exporta los datos (simulado, puede retornar base64 o URL).
- Todas las respuestas siguen el patrón eResponse.

## Componente Vue.js
- Página independiente `/contratos`.
- Filtros para tipo de aseo y vigencia.
- Tabla responsive con todos los campos relevantes.
- Botón para exportar a Excel (simulado, puede integrarse con backend real).
- Navegación breadcrumb.
- No usa tabs ni subcomponentes tabulares.

## Stored Procedures PostgreSQL
- Toda la lógica de consulta y reporte está en SPs.
- Ejemplo: `sp16_contratos(parTipo, parVigencia)` retorna todos los contratos filtrados.
- Los SPs devuelven tablas completas para facilitar el consumo por el frontend.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o similar.
- Validar y sanitizar todos los parámetros recibidos.

## Consideraciones de Migración
- Los combos Delphi se migran a `<select>` en Vue.
- El grid Delphi se migra a `<table>` HTML.
- Exportación a Excel puede hacerse en backend o frontend (aquí se simula en backend).
- Los stored procedures deben mapear los mismos campos y lógica que el Delphi original.

## Estructura de Carpetas
- `app/Http/Controllers/Api/ContratosController.php`
- `resources/js/pages/ContratosPage.vue`
- `database/migrations/` y `database/functions/` para SPs

## Ejemplo de Llamada API
```js
// Axios desde Vue
await axios.post('/api/execute', {
  eRequest: {
    action: 'listar',
    params: { tipo: 'C', vigencia: 'V' }
  }
});
```

# Notas
- Cada formulario Delphi debe migrarse a una página Vue independiente.
- El endpoint `/api/execute` puede ser extendido para otros formularios.
- Los SPs deben ser revisados y optimizados para PostgreSQL.
