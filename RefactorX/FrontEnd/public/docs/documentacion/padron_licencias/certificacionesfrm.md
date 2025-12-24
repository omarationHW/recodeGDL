# Documentación Técnica: certificacionesfrm

## Análisis Técnico

# Documentación Técnica: Módulo de Certificaciones

## Descripción General
Este módulo permite la gestión de certificaciones de licencias y anuncios, incluyendo:
- Alta de certificaciones
- Modificación
- Cancelación
- Búsqueda avanzada
- Listado e impresión

La arquitectura sigue el patrón eRequest/eResponse con un endpoint único `/api/execute` que recibe la acción y los parámetros. Toda la lógica de negocio relevante se implementa en stored procedures de PostgreSQL.

## Estructura de la Solución

### Backend (Laravel)
- **Controlador:** `CertificacionesController`
- **Endpoint:** `/api/execute` (POST)
- **Acciones soportadas:**
  - `certificaciones.list` — Listado por tipo
  - `certificaciones.create` — Alta
  - `certificaciones.update` — Modificación
  - `certificaciones.cancel` — Cancelación
  - `certificaciones.print` — Datos para impresión
  - `certificaciones.search` — Búsqueda avanzada
  - `certificaciones.listado` — Listado para impresión
- **Validaciones:** Se realizan en el controlador antes de llamar a los SP.
- **Transacciones:** Usadas en operaciones críticas (alta).

### Frontend (Vue.js)
- **Componente:** `CertificacionesPage.vue`
- **Rutas:** Página independiente `/certificaciones`
- **Funcionalidad:**
  - Listado principal
  - Formulario de alta/modificación
  - Cancelación con motivo
  - Impresión (muestra JSON, puede integrarse con PDF)
  - Búsqueda avanzada
- **UX:** No usa tabs, cada formulario es una página completa.

### Base de Datos (PostgreSQL)
- **Stored Procedures:**
  - Listado, alta, modificación, cancelación, búsqueda, impresión
- **Tablas involucradas:**
  - `certificaciones`, `parametros_lic`, `licencias`, `pagos`

### API Unificada
- **Patrón:** eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Formato:**
  ```json
  {
    "action": "certificaciones.create",
    "params": { ... }
  }
  ```

## Seguridad
- El usuario autenticado se utiliza para registrar el capturista.
- Validaciones de entrada en backend y frontend.

## Manejo de Errores
- Errores de validación devuelven HTTP 422.
- Errores de base de datos devuelven HTTP 500.
- Mensajes claros para el usuario final.

## Integración
- El frontend se comunica con el backend usando Axios y el endpoint `/api/execute`.
- Los stored procedures encapsulan la lógica SQL y pueden ser reutilizados por otros módulos.

## Extensibilidad
- Se pueden agregar nuevos tipos de certificaciones o ampliar la lógica de impresión sin romper la API.

# Diagrama de Flujo (Resumen)

1. Usuario accede a la página de certificaciones
2. Se muestra listado (consulta a `/api/execute` con `certificaciones.list`)
3. Usuario puede:
   - Crear nueva certificación (formulario)
   - Modificar una existente
   - Cancelar (con motivo)
   - Imprimir (consulta a `/api/execute` con `certificaciones.print`)
   - Buscar/listar por filtros avanzados

# Notas de Migración
- Los triggers de folio y lógica de folio se migran a stored procedures.
- El concepto de "vigente" se mantiene como campo de estado ('V' = vigente, 'C' = cancelada).
- Los reportes pueden ser implementados como generación de PDF en backend o frontend.

# Pruebas y Validación
- Se recomienda usar Postman para probar el endpoint `/api/execute` con diferentes acciones y parámetros.
- El frontend debe manejar correctamente los estados de carga, error y éxito.

## Casos de Prueba

# Casos de Prueba Certificaciones

## Caso 1: Alta de Certificación
- **Entrada:** tipo='L', id_licencia=12345, observacion='Certificación para trámite externo', partidapago='123456'
- **Acción:** POST /api/execute { action: 'certificaciones.create', params: {...} }
- **Resultado esperado:** status 200, success true, folio asignado, registro en base de datos.

## Caso 2: Modificación de Observación
- **Entrada:** id=100, observacion='Nueva observación', partidapago='654321'
- **Acción:** POST /api/execute { action: 'certificaciones.update', params: {...} }
- **Resultado esperado:** status 200, success true, campo observacion actualizado.

## Caso 3: Cancelación de Certificación
- **Entrada:** id=100, motivo='Error en datos del propietario'
- **Acción:** POST /api/execute { action: 'certificaciones.cancel', params: {...} }
- **Resultado esperado:** status 200, success true, vigente='C', observacion actualizado.

## Caso 4: Búsqueda Avanzada
- **Entrada:** axo=2024, folio=10, tipo='A'
- **Acción:** POST /api/execute { action: 'certificaciones.search', params: {...} }
- **Resultado esperado:** status 200, listado solo con registros que cumplen filtros.

## Caso 5: Impresión de Certificación
- **Entrada:** id=100
- **Acción:** POST /api/execute { action: 'certificaciones.print', params: {id:100} }
- **Resultado esperado:** status 200, JSON con datos de certificación, licencia y pagos.

## Casos de Uso

# Casos de Uso - certificacionesfrm

**Categoría:** Form

## Caso de Uso 1: Alta de Certificación de Licencia

**Descripción:** Un usuario de Padrón y Licencias requiere emitir una certificación para una licencia vigente.

**Precondiciones:**
El usuario está autenticado y conoce el ID de la licencia.

**Pasos a seguir:**
[
  "El usuario accede a la página de certificaciones.",
  "Hace clic en 'Nueva'.",
  "Selecciona 'Licencia' como tipo.",
  "Ingresa el ID de la licencia.",
  "Agrega una observación y la partida de pago si aplica.",
  "Hace clic en 'Aceptar'."
]

**Resultado esperado:**
La certificación se crea, se asigna un folio único, y aparece en el listado.

**Datos de prueba:**
{
  "tipo": "L",
  "id_licencia": 12345,
  "observacion": "Certificación para trámite externo",
  "partidapago": "123456"
}

---

## Caso de Uso 2: Cancelación de Certificación

**Descripción:** Un usuario necesita cancelar una certificación emitida por error.

**Precondiciones:**
Existe una certificación vigente.

**Pasos a seguir:**
[
  "El usuario selecciona la certificación en el listado.",
  "Hace clic en 'Cancelar Certificación'.",
  "Ingresa el motivo de cancelación.",
  "Confirma la cancelación."
]

**Resultado esperado:**
La certificación cambia su estado a 'C' (cancelada) y el motivo queda registrado.

**Datos de prueba:**
{
  "id": 100,
  "motivo": "Error en datos del propietario"
}

---

## Caso de Uso 3: Búsqueda Avanzada de Certificaciones

**Descripción:** Un usuario requiere filtrar certificaciones por año, folio y tipo.

**Precondiciones:**
Existen certificaciones de varios años y tipos.

**Pasos a seguir:**
[
  "El usuario accede a la búsqueda avanzada.",
  "Ingresa el año (2024), folio (10), y selecciona tipo 'Anuncio'.",
  "Hace clic en 'Buscar'."
]

**Resultado esperado:**
Se muestran solo las certificaciones que cumplen con los filtros.

**Datos de prueba:**
{
  "axo": 2024,
  "folio": 10,
  "tipo": "A"
}

---

