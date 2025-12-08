# Documentación Técnica: dictamenusodesuelo

## Análisis Técnico

# Documentación Técnica: Dictamen de Uso de Suelo (constancias)

## Arquitectura General
- **Backend:** Laravel (PHP) + PostgreSQL
- **Frontend:** Vue.js SPA (Single Page Application)
- **API:** Único endpoint `/api/execute` con patrón eRequest/eResponse
- **Base de datos:** PostgreSQL, toda la lógica SQL en stored procedures

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "list|search|create|update|cancel|print|listado",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "error": "mensaje de error si aplica"
    }
  }
  ```

## Acciones soportadas
- `list`: Listado general de constancias
- `search`: Búsqueda avanzada por filtros
- `create`: Alta de constancia (dictamen)
- `update`: Modificación de constancia
- `cancel`: Cancelación (vigente = 'C')
- `print`: Generación de PDF (devuelve URL/base64)
- `listado`: Listado filtrado para impresión masiva

## Seguridad
- Autenticación por token Laravel (middleware `auth:api` sugerido)
- Validación de datos en el controlador antes de llamar SP
- Los stored procedures validan integridad de datos

## Integración Vue.js
- Cada formulario es una página independiente
- Navegación por rutas (ej: `/dictamenusodesuelo`)
- No se usan tabs, cada formulario es una vista
- El componente consume `/api/execute` para todas las operaciones
- Mensajes de error y éxito se muestran en la UI

## Base de Datos
- Tabla principal: `constancias`
- Tabla de parámetros: `parametros` (para folio)
- Relación con licencias: `id_licencia` (FK)

## Generación de PDF
- El SP `dictamenusodesuelo_print` debe integrarse con un microservicio o proceso batch que genere el PDF y lo almacene en `/storage/constancias/`.
- El frontend abre la URL devuelta en una nueva ventana.

## Validaciones
- No se puede cancelar una constancia ya cancelada
- No se puede imprimir una constancia cancelada
- El folio se incrementa automáticamente en el alta

## Ejemplo de flujo
1. Usuario entra a `/dictamenusodesuelo`
2. Ve listado de constancias
3. Da clic en "Nueva Constancia"
4. Llena formulario y guarda (POST `create`)
5. El backend incrementa folio y guarda
6. Puede imprimir o cancelar desde el listado

## Consideraciones
- El frontend debe manejar loading y errores de red
- El backend debe registrar usuario/capturista
- El SP de impresión puede devolver base64 si no hay microservicio de PDF

## Casos de Prueba

# Casos de Prueba para Dictamen de Uso de Suelo

## 1. Alta de constancia exitosa
- **Entrada:** Datos completos y válidos
- **Acción:** POST /api/execute { action: 'create', data: {...} }
- **Resultado esperado:** success=true, folio incrementado, constancia visible en listado

## 2. Alta de constancia con licencia inexistente
- **Entrada:** id_licencia no existe
- **Acción:** POST /api/execute { action: 'create', data: {..., id_licencia: 999999} }
- **Resultado esperado:** success=false, error de integridad referencial

## 3. Cancelación de constancia vigente
- **Entrada:** axo y folio de constancia vigente
- **Acción:** POST /api/execute { action: 'cancel', data: {...} }
- **Resultado esperado:** success=true, vigente='C', observacion actualizado

## 4. Cancelación de constancia ya cancelada
- **Entrada:** axo y folio de constancia con vigente='C'
- **Acción:** POST /api/execute { action: 'cancel', data: {...} }
- **Resultado esperado:** success=false, error "Ya está cancelada"

## 5. Impresión de constancia vigente
- **Entrada:** axo y folio de constancia vigente
- **Acción:** POST /api/execute { action: 'print', data: {...} }
- **Resultado esperado:** success=true, data contiene pdf_url

## 6. Impresión de constancia cancelada
- **Entrada:** axo y folio de constancia con vigente='C'
- **Acción:** POST /api/execute { action: 'print', data: {...} }
- **Resultado esperado:** success=false, error "Constancia cancelada, no se puede imprimir"

## 7. Listado filtrado por licencia
- **Entrada:** licencia existente
- **Acción:** POST /api/execute { action: 'listado', data: { licencia: 1001 } }
- **Resultado esperado:** success=true, listado solo de esa licencia

## Casos de Uso

# Casos de Uso - dictamenusodesuelo

**Categoría:** Form

## Caso de Uso 1: Alta de nueva constancia de uso de suelo

**Descripción:** El usuario registra una nueva constancia (dictamen) de uso de suelo para una licencia existente.

**Precondiciones:**
El usuario está autenticado y tiene permisos. Existe la licencia a la que se liga la constancia.

**Pasos a seguir:**
- El usuario accede a la página de Dictamen de Uso de Suelo.
- Da clic en 'Nueva Constancia'.
- Llena los campos requeridos (Solicita, Partida de Pago, Observación, Domicilio, Licencia, Tipo).
- Da clic en 'Guardar'.
- El sistema valida y envía la petición a `/api/execute` con acción `create`.
- El backend incrementa el folio, guarda la constancia y responde éxito.

**Resultado esperado:**
La constancia queda registrada, aparece en el listado y puede ser impresa.

**Datos de prueba:**
{
  "solicita": "Juan Pérez",
  "partidapago": "12345",
  "observacion": "Para trámite de licencia",
  "domicilio": "Av. Juárez 123",
  "id_licencia": 1001,
  "capturista": "admin",
  "tipo": 0
}

---

## Caso de Uso 2: Cancelación de una constancia vigente

**Descripción:** El usuario cancela una constancia que aún está vigente.

**Precondiciones:**
Existe una constancia con vigente = 'V'.

**Pasos a seguir:**
- El usuario busca la constancia en el listado.
- Da clic en 'Cancelar'.
- Confirma la cancelación.
- El sistema envía la petición a `/api/execute` con acción `cancel`.
- El backend actualiza la constancia a vigente = 'C' y guarda el motivo.

**Resultado esperado:**
La constancia aparece como cancelada y ya no puede ser impresa.

**Datos de prueba:**
{ "axo": 2024, "folio": 123, "motivo": "Cancelada por error" }

---

## Caso de Uso 3: Impresión de constancia

**Descripción:** El usuario imprime una constancia vigente.

**Precondiciones:**
Existe una constancia con vigente = 'V'.

**Pasos a seguir:**
- El usuario localiza la constancia en el listado.
- Da clic en 'Imprimir'.
- El sistema envía la petición a `/api/execute` con acción `print`.
- El backend genera el PDF y devuelve la URL/base64.
- El frontend abre el PDF en una nueva ventana.

**Resultado esperado:**
El usuario visualiza el PDF de la constancia.

**Datos de prueba:**
{ "axo": 2024, "folio": 123 }

---
