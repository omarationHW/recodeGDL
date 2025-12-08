# DocumentaciÃ³n TÃ©cnica: Adeudos_UpdExed

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario Adeudos_UpdExed (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario **Adeudos_UpdExed** permite buscar y modificar la cantidad de excedencias (exedencias) para un contrato, periodo y tipo de operación específicos. El proceso implica:
- Búsqueda de la excedencia vigente para un contrato, periodo y tipo de operación.
- Actualización de la cantidad y el importe asociado.

La migración implementa:
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: Stored Procedures en PostgreSQL para lógica de negocio.

## 2. API (Laravel Controller)
- **Ruta**: `/api/execute` (POST)
- **Entrada**: `{ "eRequest": { "action": "search|update|reset|catalogs", ...params } }`
- **Salida**: `{ "eResponse": { "success": bool, "message": string, "data": ... } }`

### Acciones soportadas:
- `catalogs`: Devuelve catálogos de tipos de aseo, tipos de operación y meses.
- `search`: Busca la excedencia vigente para los parámetros dados.
- `update`: Actualiza la cantidad y el importe de la excedencia encontrada.
- `reset`: Reinicia el formulario (sin efecto en backend).

## 3. Stored Procedures PostgreSQL
- **sp_adeudos_updexed_search**: Busca la excedencia vigente.
- **sp_adeudos_updexed_update**: Actualiza la cantidad e importe.
- **sp_adeudos_updexed_catalogs**: (No es un SP, pero se usan queries directas para catálogos).

## 4. Vue.js Frontend
- Página independiente, sin tabs.
- Formulario de búsqueda y, si existe, formulario de actualización.
- Validaciones de campos.
- Mensajes de error y éxito.

## 5. Seguridad
- El usuario debe ser autenticado (en ejemplo, el id_usuario se pasa como parámetro; en producción debe obtenerse del token/session).
- Todas las operaciones de actualización usan transacciones.

## 6. Validaciones
- Todos los campos requeridos deben estar presentes y ser válidos.
- No se permite actualizar si no existe la excedencia vigente.

## 7. Flujo de Uso
1. El usuario ingresa los datos de búsqueda y ejecuta la búsqueda.
2. Si existe la excedencia, se muestra el formulario de actualización.
3. El usuario ingresa la nueva cantidad y opcionalmente el oficio, y ejecuta la actualización.
4. El sistema responde con éxito o error.

## 8. Errores Comunes
- Contrato no existe: mensaje de error.
- Excedencia no vigente: mensaje de error.
- Error de base de datos: mensaje de error detallado.

## 9. Pruebas
- Pruebas unitarias y de integración deben cubrir todos los caminos (búsqueda exitosa, fallida, actualización exitosa, fallida, etc).

## 10. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otros formularios siguiendo el mismo patrón.

---


## Casos de Prueba

## Casos de Prueba: Adeudos_UpdExed

### 1. Búsqueda exitosa de excedencia
- **Entrada:** contrato=12345, ctrol_aseo=9, ejercicio=2024, mes=6, ctrol_operacion=7
- **Acción:** Buscar
- **Esperado:** Se muestra la cantidad actual de excedencias y formulario de actualización.

### 2. Actualización exitosa de excedencia
- **Entrada:** contrato=12345, ctrol_aseo=9, ejercicio=2024, mes=6, ctrol_operacion=7, cantidad=20, oficio="OF-2024-002", usuario=1
- **Acción:** Actualizar
- **Esperado:** Mensaje de éxito y la cantidad se actualiza en la base de datos.

### 3. Búsqueda de excedencia inexistente
- **Entrada:** contrato=99999, ctrol_aseo=9, ejercicio=2024, mes=6, ctrol_operacion=7
- **Acción:** Buscar
- **Esperado:** Mensaje de error "No existe excedencia vigente".

### 4. Validación de campos obligatorios
- **Entrada:** contrato vacío, ctrol_aseo=9, ejercicio=2024, mes=6, ctrol_operacion=7
- **Acción:** Buscar
- **Esperado:** Mensaje de error "Datos incompletos".

### 5. Error de base de datos
- **Simulación:** Desconectar base de datos y realizar búsqueda
- **Esperado:** Mensaje de error técnico.

### 6. Catálogos
- **Acción:** Cargar página
- **Esperado:** Se cargan correctamente los catálogos de tipos de aseo, tipos de operación y meses.


## Casos de Uso

# Casos de Uso - Adeudos_UpdExed

**Categoría:** Form

## Caso de Uso 1: Modificar cantidad de excedencias para un contrato vigente

**Descripción:** El usuario busca una excedencia vigente y actualiza la cantidad.

**Precondiciones:**
El contrato, periodo y tipo de operación existen y están vigentes.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato, tipo de aseo, año, mes y tipo de movimiento.
2. Presiona 'Buscar'.
3. El sistema muestra la cantidad actual de excedencias.
4. El usuario ingresa la nueva cantidad y el oficio.
5. Presiona 'Actualizar'.

**Resultado esperado:**
La cantidad de excedencias y el importe se actualizan correctamente. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 9, "ejercicio": 2024, "mes": 6, "ctrol_operacion": 7, "cantidad": 15, "oficio": "OF-2024-001", "usuario": 1 }

---

## Caso de Uso 2: Intentar modificar excedencia inexistente

**Descripción:** El usuario intenta buscar una excedencia que no existe.

**Precondiciones:**
No existe excedencia vigente para los parámetros dados.

**Pasos a seguir:**
1. El usuario ingresa datos de búsqueda incorrectos.
2. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra mensaje de error indicando que no existe excedencia vigente.

**Datos de prueba:**
{ "contrato": 99999, "ctrol_aseo": 9, "ejercicio": 2024, "mes": 6, "ctrol_operacion": 7 }

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta buscar o actualizar sin llenar todos los campos requeridos.

**Precondiciones:**
El usuario deja campos vacíos o con datos inválidos.

**Pasos a seguir:**
1. El usuario deja vacío el campo 'contrato' y presiona 'Buscar'.
2. El usuario deja vacío el campo 'cantidad' y presiona 'Actualizar'.

**Resultado esperado:**
El sistema muestra mensajes de error de validación.

**Datos de prueba:**
{ "contrato": "", "ctrol_aseo": 9, "ejercicio": 2024, "mes": 6, "ctrol_operacion": 7 }

---



---
**Componente:** `Adeudos_UpdExed.vue`
**MÃ³dulo:** `aseo_contratado`

