# DocumentaciÃ³n TÃ©cnica: Contratos

## AnÃ¡lisis TÃ©cnico

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


## Casos de Prueba

# Casos de Prueba para Contratos

| Caso | Acción | Parámetros | Resultado Esperado |
|------|--------|------------|--------------------|
| 1 | Listar contratos vigentes de Zona Centro | { tipo: 'C', vigencia: 'V' } | Lista de contratos con status_contrato = 'V' y tipo_aseo = 'C' |
| 2 | Exportar contratos hospitalarios cancelados | { tipo: 'H', vigencia: 'C' } | Archivo Excel descargado con los datos correspondientes |
| 3 | Buscar contrato específico | { contrato: 12345, tipo: 'T', vigencia: 'T' } | Contrato con num_contrato = 12345 mostrado |
| 4 | Listar todos los contratos | { tipo: 'T', vigencia: 'T' } | Lista completa de contratos |
| 5 | Buscar con parámetros inválidos | { tipo: 'X', vigencia: 'Z' } | Mensaje de error o lista vacía |

## Pruebas de Seguridad
- Intentar acceder al endpoint sin autenticación: debe ser rechazado.
- Inyectar SQL en los parámetros: debe ser bloqueado y no ejecutar código malicioso.

## Pruebas de UI
- Cambiar filtros y verificar que la tabla se actualiza correctamente.
- Probar exportación a Excel con diferentes filtros.


## Casos de Uso

# Casos de Uso - Contratos

**Categoría:** Form

## Caso de Uso 1: Consulta de Contratos Vigentes de Zona Centro

**Descripción:** El usuario desea ver todos los contratos vigentes cuyo tipo de aseo es Zona Centro.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página /contratos
2. Selecciona 'Zona Centro' en Tipo de Aseo
3. Selecciona 'Vigente' en Vigencia
4. Da clic en 'Buscar'

**Resultado esperado:**
Se muestra la lista de contratos vigentes de tipo Zona Centro.

**Datos de prueba:**
{ tipo: 'C', vigencia: 'V' }

---

## Caso de Uso 2: Exportar Contratos Hospitalarios Cancelados a Excel

**Descripción:** El usuario requiere exportar a Excel todos los contratos hospitalarios cancelados.

**Precondiciones:**
El usuario está autenticado y tiene permisos de exportación.

**Pasos a seguir:**
1. Accede a la página /contratos
2. Selecciona 'Hospitalario' en Tipo de Aseo
3. Selecciona 'Cancelado' en Vigencia
4. Da clic en 'Exportar Excel'

**Resultado esperado:**
Se descarga un archivo Excel con los contratos hospitalarios cancelados.

**Datos de prueba:**
{ tipo: 'H', vigencia: 'C' }

---

## Caso de Uso 3: Buscar Contrato Específico

**Descripción:** El usuario busca un contrato específico por número.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página /contratos
2. Ingresa el número de contrato en el campo de búsqueda avanzada
3. Da clic en 'Buscar'

**Resultado esperado:**
Se muestra el contrato solicitado si existe.

**Datos de prueba:**
{ contrato: 12345, tipo: 'T', vigencia: 'T' }

---



---
**Componente:** `Contratos.vue`
**MÃ³dulo:** `aseo_contratado`

