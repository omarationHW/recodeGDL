# Documentación Técnica: Migración de Formulario fechasegfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `fechasegfrm` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El formulario permite al usuario seleccionar una fecha y capturar un número de oficio, guardando ambos datos en la base de datos y mostrando los registros recientes.

## 2. Estructura de la Solución
- **Backend (Laravel):**
  - Controlador unificado `ExecuteController` que expone el endpoint `/api/execute`.
  - Toda la lógica de negocio se delega a procedimientos almacenados en PostgreSQL.
  - El patrón de comunicación es eRequest/eResponse.
- **Frontend (Vue.js):**
  - Componente de página independiente `FechasegfrmPage`.
  - Formulario para captura de fecha y oficio.
  - Tabla para mostrar los registros recientes.
- **Base de Datos (PostgreSQL):**
  - Tabla `fechasegfrm` (debe existir con campos: id, fecha, oficio, created_at).
  - Procedimientos almacenados: `fechasegfrm_save`, `fechasegfrm_list`.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  - `eRequest`: Nombre de la operación (ej: `fechasegfrm.save`, `fechasegfrm.list`)
  - `params`: Parámetros específicos de la operación
- **Response:**
  - `eResponse`:
    - `success`: true/false
    - `message`: Mensaje de resultado
    - `data`: Datos devueltos (si aplica)

## 4. Stored Procedures
- **fechasegfrm_save(p_fecha DATE, p_oficio VARCHAR):** Inserta un registro y retorna el registro insertado.
- **fechasegfrm_list():** Retorna los últimos 20 registros ordenados por fecha de creación descendente.

## 5. Validaciones
- El campo `fecha` es obligatorio y debe ser una fecha válida.
- El campo `oficio` es obligatorio y de máximo 255 caracteres.

## 6. Frontend
- El formulario es una página completa, no usa tabs.
- Incluye navegación breadcrumb.
- Muestra mensajes de éxito/error.
- Muestra tabla de registros recientes.

## 7. Consideraciones de Seguridad
- Validación de datos en backend y frontend.
- Uso de procedimientos almacenados para evitar SQL Injection.
- El endpoint `/api/execute` debe estar protegido según la política de autenticación/autorización de la aplicación.

## 8. Tabla Base de Datos (Ejemplo)
```sql
CREATE TABLE fechasegfrm (
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    oficio VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## 9. Extensibilidad
- Se pueden agregar más operaciones al endpoint unificado agregando nuevos casos en el switch del controlador y nuevos procedimientos almacenados.

## 10. Flujo de Uso
1. El usuario accede a la página del formulario.
2. Selecciona una fecha y captura el oficio.
3. Al hacer clic en "Aceptar", los datos se envían a `/api/execute` con `eRequest: 'fechasegfrm.save'`.
4. El backend valida y guarda los datos usando el SP correspondiente.
5. Se muestra mensaje de éxito/error y se actualiza la tabla de registros recientes.
