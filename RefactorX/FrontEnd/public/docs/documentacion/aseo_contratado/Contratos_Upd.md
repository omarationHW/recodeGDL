# Documentación Técnica: Contratos_Upd

## Análisis

# Documentación Técnica: Migración Formulario Contratos_Upd (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la actualización de los datos principales de un contrato de recolección de residuos, incluyendo cantidad de recolección, domicilio, sector, zona, recaudadora y periodo de inicio de obligación. Además, registra el documento y descripción que avalan el cambio en un historial.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de actualización encapsulada en stored procedure `sp16_contratos_upd`.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "catalogs|search|load|update",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "ok|error",
      "message": "...",
      "data": { ... }
    }
  }
  ```

### Acciones soportadas
- `catalogs`: Devuelve catálogos de tipo de aseo, zonas, recaudadoras y sectores.
- `search`: Busca contrato por número y tipo de aseo.
- `load`: Carga contrato y catálogos para edición.
- `update`: Actualiza contrato usando stored procedure.

## 4. Stored Procedure: sp16_contratos_upd
- **Entradas:**
  - `p_control_contrato`: ID del contrato
  - `p_cantidad_recolec`: Nueva cantidad de recolección
  - `p_domicilio`: Nuevo domicilio
  - `p_sector`: Nuevo sector
  - `p_ctrol_zona`: Nueva zona
  - `p_id_rec`: Nueva recaudadora
  - `p_aso_mes_oblig`: Nueva fecha de inicio de obligación
  - `p_documento`: Documento de soporte
  - `p_descripcion_docto`: Descripción del documento
  - `p_usuario`: ID usuario que realiza el cambio
- **Salidas:**
  - `status`: 0=OK, 1=Error
  - `leyenda`: Mensaje descriptivo
- **Lógica:**
  - Valida existencia del contrato
  - Actualiza los campos principales
  - Inserta registro en historial de cambios

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite buscar contrato, editar campos y actualizar.
- Muestra mensajes de éxito/error.
- Usa API unificada.

## 6. Seguridad
- Validación de datos en backend (Laravel Validator).
- El usuario debe estar autenticado y su ID debe enviarse en la petición.

## 7. Consideraciones
- El historial de cambios se almacena en `ta_16_contratos_historial`.
- El stored procedure puede ser extendido para validar reglas adicionales.

## 8. Errores comunes
- Contrato no existe: status=1, leyenda="Contrato no encontrado"
- Faltan parámetros: status=error, message="Faltan parámetros"
- Error de validación: status=error, message="..."

## 9. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- El frontend puede ser extendido para otros formularios siguiendo el mismo patrón.


## Casos de Uso

# Casos de Uso - Contratos_Upd

**Categoría:** Form

## Caso de Uso 1: Actualización de domicilio y zona de un contrato vigente

**Descripción:** El usuario necesita actualizar el domicilio y la zona de un contrato vigente, registrando el documento de soporte.

**Precondiciones:**
El contrato existe y está vigente. El usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario accede a la página de actualización de contratos.
2. Ingresa el número de contrato y selecciona el tipo de aseo.
3. Presiona 'Buscar Contrato'.
4. El sistema carga los datos actuales del contrato.
5. El usuario modifica el domicilio y selecciona una nueva zona.
6. Ingresa el documento y descripción del cambio.
7. Presiona 'Actualizar Contrato'.

**Resultado esperado:**
El contrato es actualizado correctamente, el cambio queda registrado en el historial y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "num_contrato": 12345,
  "ctrol_aseo": 9,
  "domicilio": "AV. NUEVA 123",
  "ctrol_zona": 100002,
  "documento": "DR/2024/001",
  "descripcion_docto": "Cambio de domicilio por reubicación",
  "usuario": 5
}

---

## Caso de Uso 2: Intento de actualización con cantidad de recolección inválida

**Descripción:** El usuario intenta actualizar la cantidad de recolección a cero, lo cual no es permitido.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. Intenta poner la cantidad de recolección en 0.
3. Presiona 'Actualizar Contrato'.

**Resultado esperado:**
El sistema rechaza la actualización y muestra un mensaje de error indicando que la cantidad debe ser mayor a cero.

**Datos de prueba:**
{
  "num_contrato": 12345,
  "ctrol_aseo": 9,
  "cantidad_recolec": 0,
  "usuario": 5
}

---

## Caso de Uso 3: Actualización de recaudadora y registro de documento

**Descripción:** El usuario cambia la recaudadora asignada al contrato y registra el documento de soporte.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. Cambia la recaudadora seleccionada.
3. Ingresa el documento y descripción.
4. Presiona 'Actualizar Contrato'.

**Resultado esperado:**
El contrato es actualizado y el cambio queda registrado en el historial.

**Datos de prueba:**
{
  "num_contrato": 12345,
  "ctrol_aseo": 9,
  "id_rec": 3,
  "documento": "DR/2024/002",
  "descripcion_docto": "Cambio de recaudadora por solicitud",
  "usuario": 5
}

---



## Casos de Prueba

# Casos de Prueba: Contratos_Upd

## 1. Actualización exitosa de contrato
- **Entrada:** Todos los campos requeridos, valores válidos
- **Acción:** POST /api/execute con action=update
- **Resultado esperado:** status=ok, mensaje de éxito, datos actualizados en BD

## 2. Contrato no existe
- **Entrada:** control_contrato inexistente
- **Acción:** POST /api/execute con action=update
- **Resultado esperado:** status=error, mensaje="Contrato no encontrado"

## 3. Validación de cantidad de recolección
- **Entrada:** cantidad_recolec=0
- **Acción:** POST /api/execute con action=update
- **Resultado esperado:** status=error, mensaje="El campo cantidad_recolec debe ser al menos 1."

## 4. Validación de sector
- **Entrada:** sector='Z'
- **Acción:** POST /api/execute con action=update
- **Resultado esperado:** status=error, mensaje="El campo sector debe ser uno de H,J,R,L."

## 5. Registro de historial
- **Entrada:** Actualización válida
- **Acción:** POST /api/execute con action=update
- **Resultado esperado:** status=ok, registro insertado en ta_16_contratos_historial

## 6. Carga de catálogos
- **Acción:** POST /api/execute con action=catalogs
- **Resultado esperado:** status=ok, data contiene arrays de tipoAseo, zonas, recaudadoras, sectores

## 7. Búsqueda de contrato
- **Entrada:** num_contrato y ctrol_aseo válidos
- **Acción:** POST /api/execute con action=load
- **Resultado esperado:** status=ok, data.contrato contiene datos del contrato


