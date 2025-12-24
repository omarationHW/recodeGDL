# Documentación Técnica: Contratos_UpdxCont

## Análisis

# Documentación Técnica: Migración Formulario Contratos_UpdxCont (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js SPA (Single Page Application), cada formulario es una página independiente
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures
- **Patrón de Comunicación:**
  - Entrada: `{ eRequest: { operation: ..., ...params } }`
  - Salida: `{ eResponse: { ... } }`

## Flujo de Operación
1. **Carga de la Página:**
   - El componente Vue carga los combos de tipo de aseo, zonas, recaudadoras y sectores usando la API.
2. **Búsqueda de Contrato:**
   - El usuario ingresa número de contrato y tipo de aseo, presiona "Buscar Contrato".
   - Se llama a `/api/execute` con `operation: 'buscarContrato'`.
   - El backend ejecuta el SP `sp16_buscar_contrato` y retorna los datos del contrato y combos dependientes.
3. **Edición de Datos:**
   - El usuario puede editar empresa, domicilio, sector, zona, recaudadora.
   - Puede buscar empresa por nombre (abre modal), selecciona o da de alta si no existe.
4. **Actualización:**
   - El usuario ingresa documento y descripción, presiona "Actualizar Contrato".
   - Se llama a `/api/execute` con `operation: 'actualizarContrato'` y todos los datos.
   - El backend ejecuta el SP `sp16_actualizar_contrato`, actualiza el contrato y registra el movimiento en el histórico.

## API Backend (Laravel)
- **Controlador:** `ContratosUpdxContController`
- **Endpoint:** `POST /api/execute`
- **Operaciones soportadas:**
  - `buscarContrato`
  - `buscarEmpresa`
  - `altaEmpresa`
  - `actualizarContrato`
  - `listarTipoAseo`
  - `listarZonas`
  - `listarRecaudadoras`
  - `listarSectores`
- **Validación:**
  - Se valida la presencia y tipo de los parámetros requeridos.
  - Errores se devuelven en `eResponse.error`.

## Frontend (Vue.js)
- **Página independiente** para Contratos_UpdxCont.
- **No usa tabs**: cada formulario es una página completa.
- **Modal** para búsqueda/alta de empresa.
- **Validación** en frontend y backend.
- **Navegación**: Puede integrarse breadcrumb si se requiere.

## Stored Procedures (PostgreSQL)
- Toda la lógica de negocio y validación crítica está en SPs.
- SPs devuelven tablas o registros para facilitar el consumo desde Laravel.
- Se usan transacciones para operaciones críticas.

## Seguridad
- El endpoint debe estar protegido por autenticación (ejemplo: JWT o session).
- El usuario que realiza la operación se pasa como parámetro (`usuario`).

## Consideraciones
- Los combos de sectores son fijos (H, J, R, L).
- El alta de empresa sólo permite empresas privadas (ctrol_emp=9).
- El histórico de cambios se registra en `ta_16_contratos_h`.
- El endpoint es unificado para facilitar integración y pruebas automatizadas.

## Ejemplo de Request/Response
### Buscar Contrato
```json
{
  "eRequest": {
    "operation": "buscarContrato",
    "num_contrato": 1234,
    "ctrol_aseo": 9
  }
}
```

### Actualizar Contrato
```json
{
  "eRequest": {
    "operation": "actualizarContrato",
    "control_contrato": 1,
    "num_empresa": 2,
    "ctrol_emp": 9,
    "domicilio": "Calle 123",
    "sector": "H",
    "ctrol_zona": 1001,
    "id_rec": 1,
    "documento": "DR/2024/001",
    "descripcion_docto": "Cambio de domicilio",
    "usuario": 1
  }
}
```

## Manejo de Errores
- Todos los errores se devuelven en `eResponse.error`.
- Los mensajes de éxito se devuelven en `eResponse.message`.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones sin cambiar la interfaz del endpoint.
- Los SPs pueden ser extendidos para lógica adicional.


## Casos de Uso

# Casos de Uso - Contratos_UpdxCont

**Categoría:** Form

## Caso de Uso 1: Actualización de Domicilio y Zona de un Contrato Existente

**Descripción:** El usuario busca un contrato existente, cambia el domicilio y la zona, y registra el cambio con un documento probatorio.

**Precondiciones:**
El contrato debe existir y estar vigente. El usuario debe estar autenticado.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Presiona 'Buscar Contrato'.
3. El sistema muestra los datos actuales del contrato.
4. El usuario edita el campo 'Domicilio' y selecciona una nueva zona.
5. El usuario ingresa el número de documento y la descripción del cambio.
6. Presiona 'Actualizar Contrato'.

**Resultado esperado:**
El contrato se actualiza en la base de datos, el cambio queda registrado en el histórico, y el usuario recibe un mensaje de éxito.

**Datos de prueba:**
{
  "num_contrato": 1234,
  "ctrol_aseo": 9,
  "nuevo_domicilio": "Av. Reforma 100",
  "nueva_zona": 2002,
  "documento": "DR/2024/002",
  "descripcion_docto": "Cambio de domicilio y zona por reubicación"
}

---

## Caso de Uso 2: Alta de Nueva Empresa desde Búsqueda

**Descripción:** El usuario busca una empresa por nombre, no la encuentra y decide darla de alta automáticamente.

**Precondiciones:**
El usuario debe estar autenticado.

**Pasos a seguir:**
1. El usuario abre el modal de búsqueda de empresa.
2. Ingresa el nombre 'EMPRESA NUEVA S.A.' y presiona 'Buscar'.
3. El sistema indica que no existe y pregunta si desea darla de alta.
4. El usuario confirma.
5. El sistema da de alta la empresa y la selecciona para el contrato.

**Resultado esperado:**
La empresa se crea en la base de datos y se asocia al contrato en edición.

**Datos de prueba:**
{
  "nombre": "EMPRESA NUEVA S.A."
}

---

## Caso de Uso 3: Validación de Campos Obligatorios

**Descripción:** El usuario intenta actualizar un contrato sin llenar todos los campos obligatorios.

**Precondiciones:**
El contrato debe existir. El usuario debe estar autenticado.

**Pasos a seguir:**
1. El usuario busca un contrato y deja vacío el campo 'documento'.
2. Presiona 'Actualizar Contrato'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que falta el campo 'documento'.

**Datos de prueba:**
{
  "control_contrato": 1,
  "num_empresa": 2,
  "ctrol_emp": 9,
  "domicilio": "Calle 123",
  "sector": "H",
  "ctrol_zona": 1001,
  "id_rec": 1,
  "documento": "",
  "descripcion_docto": "Cambio de domicilio",
  "usuario": 1
}

---



## Casos de Prueba

# Casos de Prueba para Contratos_UpdxCont

## 1. Buscar Contrato Existente
- **Entrada:** num_contrato=1234, ctrol_aseo=9
- **Acción:** POST /api/execute { eRequest: { operation: 'buscarContrato', num_contrato: 1234, ctrol_aseo: 9 } }
- **Resultado esperado:** eResponse.found=true, eResponse.contrato contiene los datos del contrato

## 2. Buscar Contrato Inexistente
- **Entrada:** num_contrato=999999, ctrol_aseo=9
- **Acción:** POST /api/execute { eRequest: { operation: 'buscarContrato', num_contrato: 999999, ctrol_aseo: 9 } }
- **Resultado esperado:** eResponse.found=false, eResponse.message='No existe contrato con el dato capturado'

## 3. Alta de Empresa Nueva
- **Entrada:** nombre='EMPRESA NUEVA S.A.'
- **Acción:** POST /api/execute { eRequest: { operation: 'altaEmpresa', nombre: 'EMPRESA NUEVA S.A.' } }
- **Resultado esperado:** eResponse.empresa.num_empresa > 0, eResponse.empresa.descripcion = 'EMPRESA NUEVA S.A.'

## 4. Actualizar Contrato con Datos Correctos
- **Entrada:** control_contrato=1, num_empresa=2, ctrol_emp=9, domicilio='Calle 123', sector='H', ctrol_zona=1001, id_rec=1, documento='DR/2024/001', descripcion_docto='Cambio de domicilio', usuario=1
- **Acción:** POST /api/execute { eRequest: { operation: 'actualizarContrato', ... } }
- **Resultado esperado:** eResponse.updated=true, eResponse.message='Contrato actualizado correctamente'

## 5. Actualizar Contrato con Campo Obligatorio Vacío
- **Entrada:** control_contrato=1, num_empresa=2, ctrol_emp=9, domicilio='Calle 123', sector='H', ctrol_zona=1001, id_rec=1, documento='', descripcion_docto='Cambio de domicilio', usuario=1
- **Acción:** POST /api/execute { eRequest: { operation: 'actualizarContrato', ... } }
- **Resultado esperado:** eResponse.error indica que falta el campo 'documento'

## 6. Listar Tipos de Aseo
- **Acción:** POST /api/execute { eRequest: { operation: 'listarTipoAseo' } }
- **Resultado esperado:** eResponse es un array con los tipos de aseo

## 7. Listar Zonas
- **Acción:** POST /api/execute { eRequest: { operation: 'listarZonas' } }
- **Resultado esperado:** eResponse es un array con las zonas

## 8. Listar Recaudadoras
- **Acción:** POST /api/execute { eRequest: { operation: 'listarRecaudadoras' } }
- **Resultado esperado:** eResponse es un array con las recaudadoras

## 9. Listar Sectores
- **Acción:** POST /api/execute { eRequest: { operation: 'listarSectores' } }
- **Resultado esperado:** eResponse es un array con los sectores ['H','J','R','L']


