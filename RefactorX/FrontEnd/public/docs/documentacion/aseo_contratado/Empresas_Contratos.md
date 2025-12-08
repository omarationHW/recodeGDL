# DocumentaciÃ³n TÃ©cnica: Empresas_Contratos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario Empresas_Contratos

## 1. Descripción General
Este módulo permite consultar la relación de empresas y sus contratos asociados, filtrando por opción de búsqueda, tipo de aseo y vigencia. La migración incluye:
- Backend: Laravel Controller con endpoint unificado `/api/execute`.
- Frontend: Componente Vue.js como página independiente.
- Base de datos: Stored Procedure en PostgreSQL.
- API: Patrón eRequest/eResponse.

## 2. Arquitectura
- **Backend**: Laravel 10+, PHP 8+, PostgreSQL 13+
- **Frontend**: Vue.js 2/3 compatible, Axios para llamadas API
- **API**: Endpoint único `/api/execute` que recibe `{ eRequest, params }` y retorna `{ status, message, data }`
- **DB**: Stored Procedure `sp16_empresa_contratos` para lógica de consulta

## 3. Endpoint API
- **URL**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "eRequest": "empresas_contratos_list",
    "params": {
      "parOpc": "A|T",
      "parDescrip": "Texto a buscar",
      "parTipo": "C|H|O|T",
      "parVigencia": "V|N|C|S|T"
    }
  }
  ```
- **Respuesta**:
  ```json
  {
    "status": "success|error",
    "message": "Mensaje",
    "data": [ ... ]
  }
  ```

## 4. Stored Procedure PostgreSQL
- **Nombre**: `sp16_empresa_contratos`
- **Entradas**: `parOpc`, `parDescrip`, `parTipo`, `parVigencia`
- **Salida**: Tabla con todos los campos requeridos para la vista
- **Lógica**: Permite búsqueda por filtro o todos, y filtra por tipo de aseo y vigencia

## 5. Frontend Vue.js
- Página independiente, sin tabs
- Filtros: Opción, Dato a buscar, Tipo de Aseo, Vigencia
- Tabla con todos los campos
- Botón para exportar a Excel (CSV)
- Mensajes de error y carga

## 6. Backend Laravel
- Controlador: `EmpresasContratosController`
- Método principal: `execute(Request $request)`
- Llama al stored procedure vía DB::select('CALL ...')
- Maneja errores y retorna respuesta estándar

## 7. Seguridad
- Validar que los parámetros sean correctos
- Limitar tamaño de búsqueda
- Sanitizar entradas

## 8. Extensibilidad
- El endpoint `/api/execute` puede manejar otros eRequest para otros formularios
- El stored procedure puede ampliarse para más filtros

## 9. Pruebas
- Casos de uso y pruebas unitarias incluidas abajo

---


## Casos de Prueba

# Casos de Prueba: Empresas_Contratos

## Caso 1: Consulta general (sin filtros)
- **Entrada:**
  - parOpc: 'T'
  - parDescrip: ''
  - parTipo: 'T'
  - parVigencia: 'T'
- **Acción:** POST /api/execute con eRequest=empresas_contratos_list
- **Resultado esperado:**
  - status: 'success'
  - data: lista de todas las empresas y contratos

## Caso 2: Búsqueda por filtro (nombre de empresa)
- **Entrada:**
  - parOpc: 'A'
  - parDescrip: 'FARMACIA'
  - parTipo: 'T'
  - parVigencia: 'T'
- **Acción:** POST /api/execute con eRequest=empresas_contratos_list
- **Resultado esperado:**
  - status: 'success'
  - data: solo empresas cuyo nombre o representante contiene 'FARMACIA'

## Caso 3: Filtro por tipo de aseo y vigencia
- **Entrada:**
  - parOpc: 'T'
  - parDescrip: ''
  - parTipo: 'O'
  - parVigencia: 'V'
- **Acción:** POST /api/execute con eRequest=empresas_contratos_list
- **Resultado esperado:**
  - status: 'success'
  - data: solo contratos ordinarios vigentes

## Caso 4: Filtro sin resultados
- **Entrada:**
  - parOpc: 'A'
  - parDescrip: 'ZZZZZZZZ'
  - parTipo: 'T'
  - parVigencia: 'T'
- **Acción:** POST /api/execute con eRequest=empresas_contratos_list
- **Resultado esperado:**
  - status: 'success'
  - data: [] (vacío)

## Caso 5: Error de parámetros
- **Entrada:**
  - parOpc: 'A'
  - parDescrip: ''
  - parTipo: 'T'
  - parVigencia: 'T'
- **Acción:** POST /api/execute con eRequest=empresas_contratos_list
- **Resultado esperado:**
  - status: 'error'
  - message: 'Falta el dato de búsqueda' o validación frontend


## Casos de Uso

# Casos de Uso - Empresas_Contratos

**Categoría:** Form

## Caso de Uso 1: Consulta general de todas las empresas y contratos

**Descripción:** El usuario desea ver la lista completa de todas las empresas y sus contratos, sin aplicar ningún filtro.

**Precondiciones:**
El usuario tiene acceso al sistema y existen empresas y contratos en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página 'Empresas y Contratos'.
2. Deja la opción en 'T = Todos'.
3. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con todas las empresas y todos sus contratos, sin filtrar.

**Datos de prueba:**
parOpc: 'T', parDescrip: '', parTipo: 'T', parVigencia: 'T'

---

## Caso de Uso 2: Búsqueda por nombre de empresa vigente y tipo de aseo hospitalario

**Descripción:** El usuario busca empresas cuyo nombre contiene 'HOSPITAL', solo contratos vigentes y tipo de aseo hospitalario.

**Precondiciones:**
Existen empresas con nombre que contiene 'HOSPITAL' y contratos vigentes de tipo hospitalario.

**Pasos a seguir:**
1. Selecciona opción 'A = Búsqueda por Filtro'.
2. Escribe 'HOSPITAL' en 'Dato a Buscar'.
3. Selecciona 'H = Hospitalario' en tipo de aseo.
4. Selecciona 'V = VIGENTE' en vigencia.
5. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestran solo las empresas y contratos que cumplen con los filtros indicados.

**Datos de prueba:**
parOpc: 'A', parDescrip: 'HOSPITAL', parTipo: 'H', parVigencia: 'V'

---

## Caso de Uso 3: Exportar resultados filtrados a Excel

**Descripción:** El usuario realiza una búsqueda filtrada y exporta los resultados a un archivo Excel (CSV).

**Precondiciones:**
Existen resultados para los filtros aplicados.

**Pasos a seguir:**
1. Realiza una búsqueda con filtros (por ejemplo, tipo de aseo 'O = Ordinario').
2. Da clic en 'Buscar'.
3. Da clic en 'Exportar a Excel'.

**Resultado esperado:**
Se descarga un archivo CSV con los resultados mostrados en la tabla.

**Datos de prueba:**
parOpc: 'T', parDescrip: '', parTipo: 'O', parVigencia: 'T'

---



---
**Componente:** `Empresas_Contratos.vue`
**MÃ³dulo:** `aseo_contratado`

