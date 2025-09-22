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
