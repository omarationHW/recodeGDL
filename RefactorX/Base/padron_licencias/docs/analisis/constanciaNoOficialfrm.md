# Documentación Técnica: Migración de Formulario constanciaNoOficialfrm

## Descripción General
Este módulo corresponde a la migración del formulario de "Solicitud de Número Oficial" (constanciaNoOficialfrm) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos y lógica de negocio). Se implementa un endpoint API unificado bajo el patrón eRequest/eResponse y toda la lógica SQL relevante se encapsula en stored procedures.

## Arquitectura
- **Backend:** Laravel 10+, PHP 8+, PostgreSQL 13+
- **Frontend:** Vue.js 3 SPA (Single Page Application)
- **API:** Endpoint único `/api/execute` que recibe eRequest/eResponse
- **Base de datos:** PostgreSQL, con stored procedures para toda la lógica de negocio

## Endpoints y Protocolo
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: string, params: object } }`
  - Salida: `{ eResponse: { success: bool, message: string, data: any } }`

### Acciones soportadas
- `list`: Lista todas las solicitudes
- `search`: Busca por propietario o ubicación
- `get`: Obtiene una solicitud específica
- `create`: Crea una nueva solicitud
- `update`: Modifica una solicitud existente
- `cancel`: Cancela una solicitud
- `print`: Genera el PDF de la solicitud

## Stored Procedures
- **sp_solicnooficial_create:** Inserta una nueva solicitud, asignando folio y año automáticamente.
- **sp_solicnooficial_update:** Actualiza los campos editables de una solicitud.
- **sp_solicnooficial_cancel:** Marca la solicitud como cancelada ('C').
- **sp_solicnooficial_print:** Devuelve la URL del PDF generado (la generación real puede ser por microservicio o batch).

## Seguridad
- Todas las acciones requieren autenticación JWT (Laravel Sanctum o Passport recomendado).
- Los logs de auditoría deben implementarse en triggers o middleware.

## Frontend (Vue.js)
- Página independiente, sin tabs ni componentes tabulares.
- Tabla de solicitudes con selección de fila.
- Formulario modal para alta/modificación.
- Navegación breadcrumb.
- Acciones: Nueva, Modificar, Cancelar, Imprimir.
- Validación de campos en frontend y backend.

## Integración
- El frontend se comunica únicamente con `/api/execute`.
- El backend traduce la acción a la llamada al stored procedure correspondiente.
- La impresión genera un PDF y devuelve la URL para abrirlo en una nueva pestaña.

## Consideraciones
- El folio es incremental por año.
- No se permite modificar solicitudes canceladas.
- El campo 'vigente' indica el estado ('V' = vigente, 'C' = cancelada).
- El campo 'capturista' se toma del usuario autenticado.

# Diagrama de Flujo
1. Usuario accede a la página de solicitudes.
2. Puede buscar por propietario o ubicación.
3. Puede crear una nueva solicitud (formulario).
4. Puede seleccionar una solicitud y modificarla (si está vigente).
5. Puede cancelar una solicitud vigente.
6. Puede imprimir la solicitud (PDF).

# Ejemplo de eRequest/eResponse
```json
{
  "eRequest": {
    "action": "create",
    "params": {
      "data": {
        "propietario": "JUAN PEREZ",
        "actividad": "COMERCIO",
        "ubicacion": "AV. JUAREZ 123",
        "zona": 1,
        "subzona": 2
      }
    }
  }
}
```

# Validaciones
- Todos los campos son obligatorios en alta/modificación.
- Zona y subzona deben ser enteros positivos.
- No se permite cancelar una solicitud ya cancelada.

# Errores comunes
- Folio no encontrado: retorna success=false, message="No encontrado".
- Campos obligatorios faltantes: retorna success=false, message="Campo X requerido".

# Auditoría
- Se recomienda agregar triggers para registrar cambios en la tabla solicnooficial_audit.

# Pruebas
- Ver sección de casos de uso y casos de prueba.
