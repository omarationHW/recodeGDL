# Documentación Técnica: Módulo de Responsivas

## Arquitectura General
- **Backend**: Laravel (PHP) + PostgreSQL
- **Frontend**: Vue.js SPA (Single Page Application)
- **API**: Único endpoint `/api/execute` (patrón eRequest/eResponse)
- **Base de datos**: PostgreSQL, toda la lógica de negocio en stored procedures

## Flujo de Datos
1. **Frontend** (Vue.js) envía peticiones POST a `/api/execute` con `{action, payload}`
2. **Laravel Controller** recibe la petición, despacha según `action` y llama el stored procedure correspondiente
3. **Stored Procedure** ejecuta la lógica y retorna los datos
4. **Laravel Controller** retorna la respuesta en formato JSON
5. **Frontend** muestra los datos y permite interacción (alta, baja, búsqueda, impresión)

## Endpoints y Acciones
- `/api/execute` (POST)
  - `action: buscarLicencia` → Busca licencia por número
  - `action: listarResponsivas` → Lista responsivas/supervisiones por tipo
  - `action: crearResponsiva` → Crea nueva responsiva/supervisión
  - `action: cancelarResponsiva` → Cancela una responsiva/supervisión
  - `action: buscarPorFolio` → Busca responsiva por año y folio
  - `action: buscarPorLicencia` → Busca responsivas por número de licencia

## Seguridad
- El usuario debe estar autenticado (en este ejemplo, se simula con localStorage, pero debe integrarse con el sistema real de autenticación de Laravel)
- Todas las operaciones de alta/baja registran el usuario
- Los stored procedures validan y actualizan los folios de manera transaccional

## Integración con Vue.js
- Cada formulario es una página independiente (no tabs)
- Navegación por rutas (ejemplo: `/responsivas`)
- El componente Vue consume la API y muestra mensajes de error/éxito
- Modal para cancelación con motivo

## Consideraciones de Migración
- Los queries SQL de Delphi se migran a stored procedures PostgreSQL
- El control de folios se realiza en la tabla `parametros_lic` (responsiva/supervision)
- El reporte PDF/impresión debe implementarse en backend o con integración a un sistema de reportes
- El frontend no implementa tabs ni subformularios: cada formulario es una página

## Estructura de la Tabla `responsivas`
- axo (año)
- folio
- id_licencia
- tipo ('R' = Responsiva, 'S' = Supervisión)
- observacion
- vigente ('V' = Vigente, 'C' = Cancelada)
- feccap (fecha de captura)
- capturista

## Ejemplo de Payloads
- Buscar licencia:
  ```json
  {"action": "buscarLicencia", "payload": {"licencia": 12345}}
  ```
- Crear responsiva:
  ```json
  {"action": "crearResponsiva", "payload": {"id_licencia": 1, "tipo": "R", "usuario": "admin"}}
  ```
- Cancelar responsiva:
  ```json
  {"action": "cancelarResponsiva", "payload": {"axo": 2024, "folio": 12, "motivo": "Por error", "usuario": "admin"}}
  ```

## Validaciones
- No se puede imprimir/cancelar una responsiva cancelada
- No se puede crear responsiva si no existe la licencia
- El folio se incrementa automáticamente por tipo y año

## Extensibilidad
- El endpoint `/api/execute` puede despachar a cualquier acción de negocio
- Los stored procedures pueden ser extendidos para lógica adicional (auditoría, logs, etc)

# Despliegue
- Los stored procedures deben cargarse en la base de datos PostgreSQL
- El controlador debe estar registrado en Laravel y la ruta `/api/execute` definida
- El componente Vue debe estar registrado en el router principal y ser una página independiente

# Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute` con los distintos payloads
- El frontend puede ser probado con datos reales y simulados
