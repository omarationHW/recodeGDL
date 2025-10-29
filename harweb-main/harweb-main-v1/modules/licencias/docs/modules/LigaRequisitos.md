# Documentación Técnica: Liga de Requisitos a Giros

## Descripción General
Este módulo permite la administración de los requisitos (requisitos/documentos) que deben cumplir los diferentes giros comerciales. Permite ligar (asignar) o quitar requisitos a cada giro, así como consultar y reportar la configuración actual.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **API**: Todas las operaciones (consulta, alta, baja, reporte) se realizan mediante el endpoint `/api/execute`.

## Flujo de Datos
1. El usuario accede a la página de "Liga de Requisitos a Giros".
2. Se listan los giros disponibles (solo tipo 'L').
3. Al seleccionar un giro, se muestran dos listas:
   - Requisitos ligados (ya asignados a ese giro)
   - Requisitos disponibles (no asignados a ese giro)
4. El usuario puede agregar o quitar requisitos usando los botones correspondientes.
5. Todas las operaciones se ejecutan vía AJAX usando el endpoint `/api/execute`.
6. El usuario puede imprimir un reporte de la configuración actual.

## API (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Acciones soportadas**:
  - `get_giros`: Lista de giros
  - `get_requisitos_ligados`: Requisitos ligados a un giro
  - `get_requisitos_disponibles`: Requisitos no ligados a un giro
  - `add_requisito`: Liga un requisito a un giro
  - `remove_requisito`: Quita un requisito de un giro
  - `search_giros`: Búsqueda de giros por descripción
  - `search_requisitos`: Búsqueda de requisitos por descripción
  - `print_report`: Genera un reporte PDF (simulado)

## Seguridad
- Todas las operaciones de alta/baja requieren autenticación y se recomienda registrar bitácora de usuario.
- Validaciones de existencia y unicidad en los stored procedures.

## Integración Frontend
- El componente Vue.js consume la API vía fetch/AJAX.
- No hay tabs ni subcomponentes: cada formulario es una página independiente.
- Navegación mediante breadcrumbs.

## Consideraciones de Migración
- El diseño desacopla completamente la UI de la lógica de negocio.
- El endpoint único permite fácil integración con otros sistemas.
- Los stored procedures aseguran integridad y reglas de negocio en la base de datos.

## Tablas Relacionadas
- `c_giros`: Catálogo de giros comerciales.
- `c_girosreq`: Catálogo de requisitos/documentos.
- `giro_req`: Relación N:M entre giros y requisitos.

## Ejemplo de Request/Response
### Agregar requisito
```json
{
  "action": "add_requisito",
  "params": { "id_giro": 1234, "req": 5 }
}
```
Respuesta:
```json
{
  "success": true,
  "message": "Requisito agregado"
}
```

### Quitar requisito
```json
{
  "action": "remove_requisito",
  "params": { "id_giro": 1234, "req": 5 }
}
```
Respuesta:
```json
{
  "success": true,
  "message": "Requisito eliminado"
}
```

## Reportes
- El reporte PDF muestra todos los giros y sus requisitos ligados.
- El endpoint `print_report` devuelve una URL de descarga o visualización.
