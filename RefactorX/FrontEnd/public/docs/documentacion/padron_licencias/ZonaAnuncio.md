# Documentación Técnica: ZonaAnuncio

## Análisis Técnico
# Documentación Técnica: Migración Formulario ZonaAnuncio Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la actualización de la zona, subzona y recaudadora asociada a un anuncio publicitario. El formulario original en Delphi ha sido migrado a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos), usando procedimientos almacenados y un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador `ZonaAnuncioController`.
- **Frontend:** Vue.js 3+ (SPA), componente de página independiente `ZonaAnuncioPage.vue`.
- **Base de datos:** PostgreSQL, con procedimientos almacenados para toda la lógica CRUD y catálogos.
- **API:** Endpoint único `/api/execute` que recibe un objeto eRequest con acción y parámetros, y responde con eResponse.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "zonaanuncio.create|update|get|list|delete|catalogs",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "data": { ... },
    "success": true|false,
    "error": "mensaje"
  }
  ```

## 4. Métodos soportados
- `zonaanuncio.list`: Lista zonas de un anuncio
- `zonaanuncio.get`: Obtiene zona de un anuncio
- `zonaanuncio.create`: Crea zona para anuncio
- `zonaanuncio.update`: Actualiza zona de anuncio
- `zonaanuncio.delete`: Elimina zona de anuncio
- `zonaanuncio.catalogs`: Devuelve catálogos de zonas, subzonas y recaudadoras

## 5. Seguridad
- El controlador asume autenticación Laravel (middleware `auth:api` recomendado).
- El campo `capturista` se toma del usuario autenticado (`$user->username`), o 'system' si no hay usuario.

## 6. Validaciones
- Todos los campos requeridos son validados en backend y frontend.
- No se permite duplicar zonas para el mismo anuncio.

## 7. Frontend (Vue.js)
- Página independiente, sin tabs.
- Navegación por rutas (ejemplo: `/anuncios/:anuncio/zona` para edición).
- Catálogos cargados vía API.
- Mensajes de éxito/error amigables.
- Navegación a listado de anuncios tras cancelar.

## 8. Stored Procedures
- Toda la lógica SQL reside en funciones/procedimientos almacenados en PostgreSQL.
- Los catálogos se devuelven como tablas con un campo `tipo` para distinguir zona/subzona/recaudadora.

## 9. Integración
- El frontend llama a `/api/execute` con la acción y parámetros.
- El backend enruta la acción al método correspondiente y ejecuta el SP adecuado.

## 10. Consideraciones
- El formulario es atómico: cada acción es una página/vista completa.
- El endpoint es extensible para otros formularios.
- El código es desacoplado y preparado para pruebas unitarias y de integración.

# Diagrama de Flujo
1. Usuario navega a la página de Zona de Anuncio
2. Vue carga catálogos vía `zonaanuncio.catalogs`
3. Si es edición, carga datos vía `zonaanuncio.get`
4. Usuario edita y guarda (llama `zonaanuncio.update` o `zonaanuncio.create`)
5. Backend ejecuta SP correspondiente y responde
6. Frontend muestra mensaje y navega según resultado

# Ejemplo de eRequest/eResponse
```json
{
  "action": "zonaanuncio.update",
  "params": {
    "anuncio": 1234,
    "zona": 2,
    "subzona": 5,
    "recaud": 3
  }
}
```

## 11. Migración de lógica Delphi
- Los eventos de scroll, afterpost, etc. se traducen a lógica de actualización de combos y validación en frontend.
- El control de inserción/edición se maneja por existencia de registro en la tabla.
- El campo `feccap` se actualiza automáticamente en cada cambio.

# 12. Pruebas y Casos de Uso
Ver secciones siguientes.

## Casos de Prueba
# Casos de Prueba para ZonaAnuncio

## Caso 1: Crear zona para anuncio nuevo
- **Entrada:** { "anuncio": 2001, "zona": 1, "subzona": 2, "recaud": 3 }
- **Acción:** zonaanuncio.create
- **Esperado:** Registro creado en anuncios_zona, respuesta success.

## Caso 2: Actualizar zona de anuncio existente
- **Precondición:** El anuncio 2001 tiene registro en anuncios_zona.
- **Entrada:** { "anuncio": 2001, "zona": 2, "subzona": 4, "recaud": 1 }
- **Acción:** zonaanuncio.update
- **Esperado:** Registro actualizado, respuesta success.

## Caso 3: Obtener zona de anuncio
- **Entrada:** { "anuncio": 2001 }
- **Acción:** zonaanuncio.get
- **Esperado:** Devuelve datos actuales de zona, subzona y recaud.

## Caso 4: Eliminar zona de anuncio
- **Entrada:** { "anuncio": 2001 }
- **Acción:** zonaanuncio.delete
- **Esperado:** Registro eliminado, respuesta success.

## Caso 5: Validación de campos obligatorios
- **Entrada:** { "anuncio": null, "zona": null, "subzona": null, "recaud": null }
- **Acción:** zonaanuncio.create
- **Esperado:** Error de validación, respuesta 422.

## Caso 6: Catálogos
- **Entrada:** {}
- **Acción:** zonaanuncio.catalogs
- **Esperado:** Devuelve listas de zonas, subzonas y recaudadoras.

## Casos de Uso
# Casos de Uso - ZonaAnuncio

**Categoría:** Form

## Caso de Uso 1: Registrar zona para un anuncio nuevo

**Descripción:** El usuario desea asignar zona, subzona y recaudadora a un anuncio que aún no tiene registro en anuncios_zona.

**Precondiciones:**
El anuncio existe en la tabla anuncios y no tiene registro en anuncios_zona.

**Pasos a seguir:**
1. El usuario navega a la página de Zona de Anuncio para el anuncio.
2. El sistema carga los catálogos de zonas, subzonas y recaudadoras.
3. El usuario selecciona la zona, subzona y recaudadora deseada.
4. El usuario presiona 'Guardar'.
5. El sistema envía la acción 'zonaanuncio.create' con los datos.
6. El backend crea el registro y responde éxito.

**Resultado esperado:**
El registro se crea correctamente y el usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "anuncio": 1001, "zona": 2, "subzona": 5, "recaud": 3 }

---

## Caso de Uso 2: Actualizar zona de un anuncio existente

**Descripción:** El usuario necesita modificar la zona, subzona o recaudadora de un anuncio ya registrado.

**Precondiciones:**
El anuncio tiene un registro existente en anuncios_zona.

**Pasos a seguir:**
1. El usuario navega a la página de Zona de Anuncio para el anuncio.
2. El sistema carga los datos actuales y catálogos.
3. El usuario cambia la zona, subzona o recaudadora.
4. El usuario presiona 'Guardar'.
5. El sistema envía la acción 'zonaanuncio.update' con los datos.
6. El backend actualiza el registro y responde éxito.

**Resultado esperado:**
El registro se actualiza correctamente y el usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "anuncio": 1001, "zona": 3, "subzona": 7, "recaud": 2 }

---

## Caso de Uso 3: Eliminar zona de un anuncio

**Descripción:** El usuario desea eliminar la asignación de zona/subzona/recaudadora de un anuncio.

**Precondiciones:**
El anuncio tiene un registro en anuncios_zona.

**Pasos a seguir:**
1. El usuario accede a la página de Zona de Anuncio para el anuncio.
2. El usuario presiona el botón de eliminar.
3. El sistema envía la acción 'zonaanuncio.delete' con el id del anuncio.
4. El backend elimina el registro y responde éxito.

**Resultado esperado:**
El registro se elimina correctamente y el usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "anuncio": 1001 }

---
