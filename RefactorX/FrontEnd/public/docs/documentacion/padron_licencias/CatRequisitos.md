# Documentación Técnica: CatRequisitos

## Análisis Técnico

# Catálogo de Requisitos (CatRequisitos)

## Descripción General
Este módulo permite la administración del catálogo de requisitos para giros comerciales. Incluye operaciones de alta, edición, eliminación, búsqueda y listado, así como la impresión del catálogo. La solución está compuesta por:

- **Backend Laravel**: Controlador único que expone un endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend Vue.js**: Componente de página independiente para la gestión de requisitos.
- **Base de Datos PostgreSQL**: Lógica de negocio encapsulada en stored procedures.

## Arquitectura
- **API Unificada**: Todas las operaciones se realizan mediante un único endpoint POST `/api/execute`.
- **Patrón eRequest/eResponse**: El frontend envía un objeto `eRequest` con los parámetros de acción y datos. El backend responde con `eResponse`.
- **Stored Procedures**: Toda la lógica de acceso y manipulación de datos reside en funciones SQL (PostgreSQL).

## Flujo de Operación
1. El usuario accede a la página de Catálogo de Requisitos.
2. Vue.js carga el listado de requisitos mediante `action: list`.
3. El usuario puede buscar, agregar, editar o eliminar requisitos:
   - **Agregar**: Abre formulario, envía `action: create`.
   - **Editar**: Abre formulario con datos, envía `action: update`.
   - **Eliminar**: Confirma y envía `action: delete`.
   - **Buscar**: Envía `action: search` con el texto.
   - **Imprimir**: Muestra listado para impresión (puede exportar a PDF desde el navegador).
4. Todas las acciones se comunican vía `/api/execute`.

## Seguridad
- Validación de datos en backend (Laravel Validator).
- Solo se permite manipulación de campos permitidos.
- El endpoint puede protegerse con middleware de autenticación si es necesario.

## Integración
- El componente Vue.js puede integrarse en cualquier SPA o sistema de rutas.
- El backend puede ser extendido para auditar cambios o agregar logs.

## Consideraciones
- El campo `req` es autoincremental (no serial, sino calculado como MAX+1 para compatibilidad con el sistema original).
- La eliminación es física (no lógica), pero puede adaptarse a soft-delete si se requiere.
- El listado para impresión es el mismo que el listado general.

## Ejemplo de eRequest/eResponse

### Solicitud (Agregar requisito)
```json
{
  "eRequest": {
    "module": "cat_requisitos",
    "action": "create",
    "data": {
      "descripcion": "Copia de identificación oficial vigente"
    }
  }
}
```

### Respuesta
```json
{
  "eResponse": {
    "success": true,
    "data": { "req": 12, "descripcion": "Copia de identificación oficial vigente" },
    "message": ""
  }
}
```

## Estructura de la Tabla

```sql
CREATE TABLE c_girosreq (
  req integer PRIMARY KEY,
  descripcion varchar(255) NOT NULL
);
```

## API
- **/api/execute** (POST)
  - Entrada: `{ eRequest: { module: 'cat_requisitos', action: 'list|search|create|update|delete|print', data: {...} } }`
  - Salida: `{ eResponse: { success, data, message } }`

## Validaciones
- Descripción: Obligatoria, máximo 255 caracteres.
- Número de requisito: Solo para edición/eliminación.

## Extensibilidad
- Puede integrarse con otros módulos de catálogos.
- Puede auditarse con triggers o logs en base de datos.

## Casos de Prueba

# Casos de Prueba Catálogo de Requisitos

## 1. Alta de requisito válido
- **Entrada:** { "descripcion": "Copia de comprobante de domicilio reciente" }
- **Acción:** create
- **Resultado esperado:** success=true, data contiene nuevo req y descripción

## 2. Alta de requisito sin descripción
- **Entrada:** { "descripcion": "" }
- **Acción:** create
- **Resultado esperado:** success=false, message indica que la descripción es obligatoria

## 3. Edición de requisito existente
- **Entrada:** { "req": 2, "descripcion": "Copia de acta constitutiva actualizada" }
- **Acción:** update
- **Resultado esperado:** success=true, data contiene req=2 y nueva descripción

## 4. Eliminación de requisito existente
- **Entrada:** { "req": 4 }
- **Acción:** delete
- **Resultado esperado:** success=true, data contiene req eliminado

## 5. Búsqueda de requisitos por texto
- **Entrada:** { "descripcion": "copia" }
- **Acción:** search
- **Resultado esperado:** success=true, data contiene todos los requisitos que contienen 'copia' en la descripción

## 6. Listado general
- **Entrada:** {}
- **Acción:** list
- **Resultado esperado:** success=true, data contiene todos los requisitos ordenados por número

## 7. Impresión de listado
- **Entrada:** {}
- **Acción:** print
- **Resultado esperado:** success=true, data contiene todos los requisitos (igual que list)

## Casos de Uso

# Casos de Uso - CatRequisitos

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo requisito

**Descripción:** El usuario desea agregar un nuevo requisito al catálogo.

**Precondiciones:**
El usuario tiene acceso al módulo Catálogo de Requisitos.

**Pasos a seguir:**
- El usuario hace clic en 'Agregar'.
- Ingresa la descripción del requisito.
- Hace clic en 'Guardar'.
- El sistema envía un eRequest con action 'create'.
- El backend valida y agrega el requisito.

**Resultado esperado:**
El requisito aparece en el listado con un número asignado automáticamente.

**Datos de prueba:**
{ "descripcion": "Copia de comprobante de domicilio reciente" }

---

## Caso de Uso 2: Editar un requisito existente

**Descripción:** El usuario necesita corregir la descripción de un requisito.

**Precondiciones:**
Existe al menos un requisito en el catálogo.

**Pasos a seguir:**
- El usuario localiza el requisito y hace clic en 'Editar'.
- Modifica la descripción.
- Hace clic en 'Guardar'.
- El sistema envía un eRequest con action 'update'.

**Resultado esperado:**
La descripción del requisito se actualiza en el listado.

**Datos de prueba:**
{ "req": 3, "descripcion": "Copia de acta constitutiva actualizada" }

---

## Caso de Uso 3: Eliminar un requisito

**Descripción:** El usuario desea eliminar un requisito que ya no aplica.

**Precondiciones:**
El requisito existe y no está ligado a ningún proceso crítico.

**Pasos a seguir:**
- El usuario hace clic en 'Eliminar' junto al requisito.
- Confirma la eliminación.
- El sistema envía un eRequest con action 'delete'.

**Resultado esperado:**
El requisito desaparece del listado.

**Datos de prueba:**
{ "req": 5 }

---

