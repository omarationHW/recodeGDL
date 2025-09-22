# Documentación Técnica: Licencias Relacionadas

## Descripción General
El módulo "Licencias Relacionadas" permite consultar, listar y gestionar la relación entre licencias de giro y contratos de recolección de residuos. Incluye la funcionalidad para buscar por todas, por licencia o por contrato, y permite desligar (eliminar) la relación entre una licencia y un contrato.

## Arquitectura
- **Backend:** Laravel (PHP) con un único endpoint `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, toda la lógica de negocio relevante se implementa en stored procedures.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Acciones soportadas:**
  - `listar_tipos_aseo`: Devuelve catálogo de tipos de aseo.
  - `buscar_contrato`: Busca un contrato por número y tipo de aseo.
  - `listar_licencias_relacionadas`: Lista licencias relacionadas según opción (todas, por licencia, por contrato).
  - `desligar_licencia`: Desliga (elimina) la relación entre una licencia y un contrato.

## Stored Procedures
- **sp16_licenciagiro_abc:** Alta, baja (desligar), o actualización de relación entre licencia y contrato.
- **sp16_licencias_relacionadas:** Consulta de licencias relacionadas a contratos según opción.
- **sp16_tipos_aseo:** Catálogo de tipos de aseo.

## Seguridad
- Todas las operaciones de modificación requieren autenticación (Laravel auth middleware).
- Validación de parámetros en backend.

## Flujo de la Página Vue.js
1. Al cargar, obtiene el catálogo de tipos de aseo.
2. El usuario selecciona el tipo de búsqueda (todas, por licencia, por contrato).
3. Al buscar, llama a la API y muestra los resultados en tabla.
4. Permite exportar a Excel.
5. Permite desligar una licencia de un contrato (con confirmación).

## Consideraciones
- El endpoint es único y recibe la acción y parámetros.
- El frontend es desacoplado y puede ser integrado en cualquier SPA Vue.js.
- Los stored procedures están optimizados para PostgreSQL.

# Parámetros de API
- **listar_tipos_aseo**: sin parámetros.
- **buscar_contrato**: `{ num_contrato: int, ctrol_aseo: int }`
- **listar_licencias_relacionadas**: `{ opcion: 0|1|2, num_licencia?: int, control_contrato?: int }`
- **desligar_licencia**: `{ num_licencia: int, control_contrato: int }`

# Respuestas de API
- Siempre en formato `{ status: 'success'|'error', message: string, data: any }`

# Errores Comunes
- Parámetros inválidos: status 'error', message descriptivo.
- Operación no soportada: status 'error', message descriptivo.

# Ejemplo de eRequest/eResponse
```json
{
  "action": "listar_licencias_relacionadas",
  "params": { "opcion": 2, "control_contrato": 1234 }
}
```

# Casos de Uso
Ver sección correspondiente.
