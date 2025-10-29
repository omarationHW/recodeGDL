# Documentación Técnica: Migración de Formulario funcion_abstencion

## 1. Descripción General
Este módulo permite la gestión de abstenciones de movimientos sobre cuentas catastrales. Incluye:
- Registro de abstenciones por cuenta, año y bimestre.
- Consulta y eliminación de abstenciones.
- API unificada para operaciones CRUD.
- Interfaz Vue.js como página independiente.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` que recibe un objeto eRequest con acción y parámetros.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación breadcrumb.
- **Base de Datos:** PostgreSQL con stored procedures para lógica de negocio y persistencia.

## 3. API Unificada
- **Endpoint:** `/api/execute` (POST)
- **Entrada:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Salida:**
  ```json
  {
    "status": "success|error",
    "data": [ ... ],
    "message": "..."
  }
  ```

### Acciones soportadas
- `get_abstenciones`: Lista todas las abstenciones.
- `get_abstencion_by_cuenta`: Lista abstenciones de una cuenta específica.
- `add_abstencion`: Agrega una abstención.
- `remove_abstencion`: Elimina una abstención.

## 4. Stored Procedures
- **funcion_abstencion_get_abstenciones:** Devuelve todas las abstenciones.
- **funcion_abstencion_get_by_cuenta:** Devuelve abstenciones de una cuenta.
- **funcion_abstencion_add:** Inserta una abstención (valida duplicados).
- **funcion_abstencion_remove:** Elimina una abstención.

### Tabla sugerida
```sql
CREATE TABLE abstencion_movimientos (
    id serial PRIMARY KEY,
    cvecuenta integer NOT NULL,
    anio integer NOT NULL,
    bimestre integer NOT NULL,
    observacion text,
    usuario varchar(100),
    fecha timestamp DEFAULT now()
);
CREATE UNIQUE INDEX abstencion_mov_idx ON abstencion_movimientos (cvecuenta, anio, bimestre);
```

## 5. Frontend Vue.js
- Página independiente, sin tabs.
- Permite buscar por cuenta, agregar y eliminar abstenciones.
- Usa axios para consumir el endpoint `/api/execute`.
- Muestra mensajes de éxito/error.
- Navegación breadcrumb.

## 6. Seguridad
- Validación de parámetros en backend.
- El usuario se toma del store Vuex o se envía explícitamente.
- Eliminar y agregar requieren usuario autenticado.

## 7. Pruebas y Casos de Uso
- Ver sección de casos de uso y pruebas.

## 8. Consideraciones
- El endpoint es genérico y puede ser extendido para otras acciones.
- El frontend es desacoplado y puede integrarse en cualquier SPA Vue.js.
- Los stored procedures pueden ser versionados y auditados.
