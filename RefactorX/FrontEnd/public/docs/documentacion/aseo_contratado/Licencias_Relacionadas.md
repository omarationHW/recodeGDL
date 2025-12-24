# Documentación Técnica: Licencias_Relacionadas

## Análisis

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


## Casos de Uso

# Casos de Uso - Licencias_Relacionadas

**Categoría:** Form

## Caso de Uso 1: Consulta de todas las licencias relacionadas

**Descripción:** El usuario desea ver todas las licencias relacionadas a contratos.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo.

**Pasos a seguir:**
1. El usuario accede a la página de Licencias Relacionadas.
2. Selecciona la opción 'Todas'.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todas las licencias relacionadas a contratos.

**Datos de prueba:**
No se requiere dato específico.

---

## Caso de Uso 2: Búsqueda de licencias relacionadas por número de licencia

**Descripción:** El usuario busca las relaciones de una licencia específica.

**Precondiciones:**
El usuario está autenticado y conoce el número de licencia.

**Pasos a seguir:**
1. El usuario accede a la página de Licencias Relacionadas.
2. Selecciona la opción 'Por Licencia'.
3. Ingresa el número de licencia (ejemplo: 12345).
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestran las relaciones de la licencia 12345 con contratos.

**Datos de prueba:**
num_licencia: 12345

---

## Caso de Uso 3: Desligar una licencia de un contrato

**Descripción:** El usuario desea eliminar la relación entre una licencia y un contrato.

**Precondiciones:**
Existe una relación entre la licencia 12345 y el contrato 3215.

**Pasos a seguir:**
1. El usuario busca por contrato 3215.
2. En la tabla, localiza la fila con licencia 12345.
3. Presiona el botón 'Desligar'.
4. Confirma la acción.

**Resultado esperado:**
La relación es eliminada y la tabla se actualiza.

**Datos de prueba:**
num_licencia: 12345, control_contrato: 3215

---



## Casos de Prueba

# Casos de Prueba: Licencias Relacionadas

## Caso 1: Consulta de todas las licencias relacionadas
- **Entrada:**
  - action: listar_licencias_relacionadas
  - params: { opcion: 0 }
- **Esperado:**
  - status: success
  - data: Array con registros de licencias relacionadas

## Caso 2: Consulta por número de licencia
- **Entrada:**
  - action: listar_licencias_relacionadas
  - params: { opcion: 1, num_licencia: 12345 }
- **Esperado:**
  - status: success
  - data: Array con relaciones de la licencia 12345

## Caso 3: Consulta por contrato
- **Entrada:**
  - action: listar_licencias_relacionadas
  - params: { opcion: 2, control_contrato: 3215 }
- **Esperado:**
  - status: success
  - data: Array con relaciones del contrato 3215

## Caso 4: Desligar licencia de contrato
- **Entrada:**
  - action: desligar_licencia
  - params: { num_licencia: 12345, control_contrato: 3215 }
- **Esperado:**
  - status: success
  - message: 'Licencia desligada correctamente'

## Caso 5: Error por parámetros inválidos
- **Entrada:**
  - action: desligar_licencia
  - params: { num_licencia: 'abc', control_contrato: null }
- **Esperado:**
  - status: error
  - message: 'Parámetros inválidos'

## Caso 6: Listar tipos de aseo
- **Entrada:**
  - action: listar_tipos_aseo
  - params: { }
- **Esperado:**
  - status: success
  - data: Array de tipos de aseo


