# Documentación Técnica: Migración Formulario Mensajes (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa el formulario de mensajes originalmente en Delphi, migrado a una arquitectura moderna con Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (almacenamiento). El formulario permite mostrar mensajes modales, guardar mensajes y listar el historial de mensajes.

## 2. Arquitectura
- **Backend:** Laravel API con endpoint unificado `/api/execute` usando el patrón `eRequest`/`eResponse`.
- **Frontend:** Componente Vue.js como página independiente, con navegación y visualización de mensajes.
- **Base de Datos:** PostgreSQL, con procedimientos almacenados para operaciones CRUD.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  - `eRequest`: Identificador de la operación (ej: `mensaje.show`, `mensaje.save`, `mensaje.list`)
  - `params`: Parámetros específicos de la operación
- **Response:**
  - `eResponse`:
    - `success`: booleano
    - `data`: datos de respuesta
    - `message`: mensaje de estado

### Ejemplo de Request
```json
{
  "eRequest": "mensaje.save",
  "params": {
    "imagen": 1,
    "mensaje": "Mensaje de prueba"
  }
}
```

### Ejemplo de Response
```json
{
  "eResponse": {
    "success": true,
    "data": { "id": 1, "imagen": 1, "mensaje": "Mensaje de prueba", "fecha": "2024-06-10T12:00:00Z" },
    "message": "Mensaje guardado correctamente."
  }
}
```

## 4. Stored Procedures
- **sp_mensaje_save:** Inserta un mensaje en la tabla `mensajes`.
- **sp_mensaje_list:** Devuelve todos los mensajes guardados.

## 5. Frontend (Vue.js)
- Página independiente `/mensajes`
- Muestra mensaje, imagen asociada (según código), botón OK, opción para guardar mensaje y ver historial.
- Usa Bootstrap para estilos y breadcrumbs para navegación.

## 6. Seguridad
- Validación de parámetros en backend.
- Sanitización de entradas.
- No requiere autenticación para este formulario (puede adaptarse).

## 7. Extensibilidad
- Se pueden agregar más tipos de mensajes, imágenes, o funcionalidades (editar, eliminar, etc.)

## 8. Consideraciones
- Las imágenes se asocian por código (1=info, 2=warning, 3=error). Se pueden ampliar.
- El historial de mensajes se muestra sólo si se solicita.

## 9. Instalación
- Crear las funciones y tabla en PostgreSQL usando los scripts proporcionados.
- Registrar la ruta `/api/execute` en Laravel y asociarla al controlador.
- Incluir el componente Vue.js en el router SPA.

