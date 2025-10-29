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
