# PasoAdeudos

## AnÃ¡lisis TÃ©cnico

# PasoAdeudos (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Descripción General
El formulario PasoAdeudos permite generar e insertar adeudos masivos para los locales del Tianguis (Mercado 214) en un año y trimestre específico. El proceso consiste en:

1. Consultar los locales del tianguis y su cuota vigente para el año seleccionado.
2. Calcular el importe de adeudo para cada local.
3. Previsualizar los adeudos generados.
4. Insertar los adeudos en la tabla `ta_11_adeudo_local`.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## API (Laravel)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "generarAdeudos", // o "insertarAdeudos", "getTianguisLocales"
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

### Acciones soportadas
- `getTianguisLocales`: Devuelve los locales del tianguis para un año.
- `generarAdeudos`: Devuelve la matriz de adeudos calculados para previsualización.
- `insertarAdeudos`: Inserta los adeudos generados en la base de datos.

## Stored Procedures
- `sp_insertar_adeudo_local`: Inserta un adeudo local.
- `sp_get_tianguis_locales`: Devuelve los locales del tianguis y su cuota para un año.

## Frontend (Vue.js)
- Página independiente `/paso-adeudos`.
- Selección de trimestre y año.
- Botón para generar/previsualizar adeudos.
- Tabla de previsualización.
- Botón para insertar adeudos.
- Mensajes de éxito/error.

## Seguridad
- El endpoint requiere autenticación (token JWT o sesión Laravel).
- El usuario debe tener permisos para ejecutar la acción.

## Validaciones
- El año debe ser >= 2009.
- El trimestre debe estar entre 1 y 4.
- No se permite insertar adeudos duplicados para el mismo local/año/periodo.

## Errores comunes
- Año/trimestre fuera de rango.
- Error de conexión a base de datos.
- Adeudos ya existentes para el periodo.

## Ejemplo de flujo
1. Usuario selecciona año y trimestre.
2. Presiona "Generar Adeudos" → ve la tabla de previsualización.
3. Presiona "Insertar Adeudos" → se insertan los registros en la base de datos.
4. Mensaje de éxito.

## Tablas involucradas
- `ta_11_locales` (Mercado 214)
- `ta_11_cuo_locales` (Cuotas por año)
- `ta_11_adeudo_local` (Adeudos generados)

## Notas
- El cálculo del importe es: `superficie * importe_cuota * 13`.
- El proceso es idempotente si se valida la no duplicidad antes de insertar.


## Casos de Uso

# Casos de Uso - PasoAdeudos

**Categoría:** Form

## Caso de Uso 1: Generar y Previsualizar Adeudos para el Tianguis

**Descripción:** El usuario desea generar los adeudos del primer trimestre del año 2024 para todos los locales del tianguis.

**Precondiciones:**
El usuario tiene permisos de administrador y existen cuotas vigentes para 2024.

**Pasos a seguir:**
1. Acceder a la página Paso Adeudos.
2. Seleccionar trimestre 1 y año 2024.
3. Presionar 'Generar Adeudos'.

**Resultado esperado:**
Se muestra una tabla con los adeudos calculados para cada local del tianguis.

**Datos de prueba:**
trimestre: 1, ano: 2024

---

## Caso de Uso 2: Insertar Adeudos Generados

**Descripción:** El usuario, tras previsualizar los adeudos, decide insertarlos en la base de datos.

**Precondiciones:**
Se han generado los adeudos y no existen registros previos para ese año/trimestre.

**Pasos a seguir:**
1. Tras la previsualización, presionar 'Insertar Adeudos'.
2. Confirmar la operación si es necesario.

**Resultado esperado:**
Los adeudos se insertan correctamente en la base de datos y se muestra un mensaje de éxito.

**Datos de prueba:**
adeudos: [{id_local: 123, ano: 2024, periodo: 1, importe: 1234.56, ...}, ...]

---

## Caso de Uso 3: Intentar Insertar Adeudos Duplicados

**Descripción:** El usuario intenta insertar adeudos para un año/trimestre ya existente.

**Precondiciones:**
Ya existen adeudos para el año/trimestre seleccionado.

**Pasos a seguir:**
1. Generar e intentar insertar adeudos para el mismo año/trimestre dos veces.

**Resultado esperado:**
El sistema rechaza la segunda inserción y muestra un mensaje de error indicando duplicidad.

**Datos de prueba:**
adeudos: [{id_local: 123, ano: 2024, periodo: 1, importe: 1234.56, ...}, ...]

---



## Casos de Prueba

# Casos de Prueba PasoAdeudos

## 1. Generación y Previsualización de Adeudos
- **Entrada:** año=2024, trimestre=1
- **Acción:** POST /api/execute { action: 'generarAdeudos', params: { ano: 2024, trimestre: 1 } }
- **Esperado:** Respuesta success=true, data contiene lista de adeudos con campos correctos.

## 2. Inserción Correcta de Adeudos
- **Entrada:** Lista de adeudos generados
- **Acción:** POST /api/execute { action: 'insertarAdeudos', params: { adeudos: [...] } }
- **Esperado:** Respuesta success=true, data.insertados = cantidad de adeudos insertados.

## 3. Prevención de Duplicados
- **Entrada:** Lista de adeudos ya existentes
- **Acción:** POST /api/execute { action: 'insertarAdeudos', params: { adeudos: [...] } }
- **Esperado:** Respuesta success=false, message indica error de duplicidad.

## 4. Validación de Año y Trimestre
- **Entrada:** año=1990, trimestre=5
- **Acción:** POST /api/execute { action: 'generarAdeudos', params: { ano: 1990, trimestre: 5 } }
- **Esperado:** Respuesta success=false, message indica error de validación.

## 5. Error de Base de Datos
- **Simulación:** Desconectar base de datos
- **Acción:** POST /api/execute { action: 'insertarAdeudos', params: { ... } }
- **Esperado:** Respuesta success=false, message indica error de conexión.



