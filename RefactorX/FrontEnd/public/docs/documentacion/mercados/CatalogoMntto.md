# CatalogoMntto

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario CatalogoMntto (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Patrón de Comunicación:** eRequest/eResponse (JSON)

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [ ... ],
    "message": "..."
  }
  ```

## Controlador Laravel
- Un solo controlador (`CatalogoMnttoController`) maneja todas las acciones relacionadas con el catálogo de mercados.
- Cada acción del frontend se traduce en un `action` y se ejecuta el stored procedure correspondiente.
- Validación de parámetros con `Validator`.
- Manejo de errores y mensajes amigables.

## Stored Procedures PostgreSQL
- Toda la lógica de inserción, actualización y consulta está en stored procedures.
- Los procedimientos devuelven siempre un resultado estructurado (éxito, mensaje, datos).
- Se usan transacciones y manejo de errores SQL.

## Componente Vue.js
- Página independiente (`CatalogoMnttoPage.vue`):
  - Formulario de alta/edición de mercados.
  - Listado de mercados con opción de editar.
  - Navegación breadcrumb.
  - Validación de campos en frontend y backend.
  - Mensajes de éxito/error.
- El formulario es reactivo y cambia entre modo alta/edición.
- El listado se actualiza automáticamente tras cada operación.

## Seguridad
- Todas las operaciones pasan por validación de datos.
- El backend valida que no existan claves duplicadas.
- Los stored procedures previenen SQL injection y errores de lógica.

## Flujo de Datos
1. El usuario accede a la página de Catálogo de Mercados.
2. El frontend carga listas de recaudadoras, categorías, zonas y cuentas vía API.
3. El usuario llena el formulario y envía (alta o edición).
4. El frontend envía la petición a `/api/execute` con la acción y los parámetros.
5. El backend ejecuta el stored procedure correspondiente y devuelve el resultado.
6. El frontend muestra el mensaje y actualiza la lista.

## Integración
- El endpoint `/api/execute` puede ser usado por cualquier frontend compatible.
- Los stored procedures pueden ser reutilizados por otros sistemas.

## Extensibilidad
- Para agregar nuevos formularios, basta con crear nuevos stored procedures y acciones en el controlador y frontend.

# Esquema de Base de Datos (relevante)
- **ta_11_mercados**: Catálogo de mercados
- **ta_12_recaudadoras**: Catálogo de recaudadoras
- **ta_11_categoria**: Catálogo de categorías
- **ta_12_zonas**: Catálogo de zonas
- **ta_12_cuentas**: Catálogo de cuentas de ingreso

# Validaciones
- No se permite insertar mercados duplicados (clave compuesta oficina + num_mercado_nvo).
- Todos los campos requeridos deben estar presentes.
- Si el mercado no cobra energía, la cuenta de energía debe ser NULL.

# Errores Comunes
- Si se intenta insertar un mercado existente, se devuelve un mensaje de error.
- Si falta algún campo requerido, el backend lo reporta.

# Pruebas
- Se recomienda probar inserción, edición, y validación de duplicados y campos requeridos.

# Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar en producción.


## Casos de Uso

# Casos de Uso - CatalogoMntto

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo mercado con energía eléctrica

**Descripción:** El usuario desea agregar un nuevo mercado que sí cobra energía eléctrica.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para agregar mercados.

**Pasos a seguir:**
1. Accede a la página Catálogo de Mercados.
2. Llena el formulario con:
   - Oficina: 2
   - Mercado: 101
   - Nombre: 'Mercado San Juan'
   - Categoría: 1
   - Zona: 3
   - Cuenta Ingreso: 44501
   - ¿Cobra energía?: Sí
   - Cuenta Energía: 44550
   - Tipo de Emisión: MASIVA
3. Da clic en 'Agregar'.

**Resultado esperado:**
El mercado se inserta correctamente y aparece en el listado.

**Datos de prueba:**
{ "oficina": 2, "num_mercado_nvo": 101, "categoria": 1, "descripcion": "Mercado San Juan", "cuenta_ingreso": 44501, "pregunta": "S", "cuenta_energia": 44550, "zona": 3, "emision": "MASIVA" }

---

## Caso de Uso 2: Edición de un mercado existente para quitar energía eléctrica

**Descripción:** El usuario edita un mercado para indicar que ya no cobra energía eléctrica.

**Precondiciones:**
El mercado ya existe y el usuario tiene permisos de edición.

**Pasos a seguir:**
1. Accede a la página Catálogo de Mercados.
2. Busca el mercado 'Mercado San Juan' (Oficina 2, Mercado 101).
3. Da clic en 'Editar'.
4. Cambia la opción '¿Cobra energía?' a 'No'.
5. Da clic en 'Actualizar'.

**Resultado esperado:**
El campo cuenta_energia se actualiza a NULL y el mercado se muestra actualizado.

**Datos de prueba:**
{ "oficina": 2, "num_mercado_nvo": 101, "categoria": 1, "descripcion": "Mercado San Juan", "cuenta_ingreso": 44501, "pregunta": "N", "cuenta_energia": null, "zona": 3, "emision": "MASIVA" }

---

## Caso de Uso 3: Intento de alta de mercado duplicado

**Descripción:** El usuario intenta agregar un mercado con la misma clave que uno existente.

**Precondiciones:**
Ya existe un mercado con oficina 2 y mercado 101.

**Pasos a seguir:**
1. Accede a la página Catálogo de Mercados.
2. Llena el formulario con los mismos datos de un mercado existente.
3. Da clic en 'Agregar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que ya existe un mercado con esa clave.

**Datos de prueba:**
{ "oficina": 2, "num_mercado_nvo": 101, "categoria": 1, "descripcion": "Mercado San Juan", "cuenta_ingreso": 44501, "pregunta": "S", "cuenta_energia": 44550, "zona": 3, "emision": "MASIVA" }

---



## Casos de Prueba

## Casos de Prueba para Catálogo de Mercados

### 1. Alta de mercado válido
- **Entrada:** Todos los campos requeridos, mercado no existente
- **Acción:** insertCatalogo
- **Esperado:** success=true, message='Mercado insertado correctamente', aparece en listado

### 2. Alta de mercado duplicado
- **Entrada:** Clave compuesta (oficina, num_mercado_nvo) ya existente
- **Acción:** insertCatalogo
- **Esperado:** success=false, message='Ya existe un mercado con esa clave'

### 3. Alta de mercado sin cuenta de energía (pregunta='N')
- **Entrada:** cuenta_energia=null
- **Acción:** insertCatalogo
- **Esperado:** success=true, cuenta_energia en NULL en base de datos

### 4. Edición de mercado existente
- **Entrada:** Modificar nombre y/o cuenta_ingreso
- **Acción:** updateCatalogo
- **Esperado:** success=true, message='Mercado actualizado correctamente', datos actualizados

### 5. Edición de mercado inexistente
- **Entrada:** Clave compuesta no existente
- **Acción:** updateCatalogo
- **Esperado:** success=false, message='No se encontró el mercado para actualizar'

### 6. Listado de mercados
- **Acción:** getCatalogoList
- **Esperado:** success=true, data contiene lista de mercados

### 7. Validación de campos requeridos
- **Entrada:** Falta algún campo obligatorio
- **Acción:** insertCatalogo o updateCatalogo
- **Esperado:** success=false, message de validación



