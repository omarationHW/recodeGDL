# Documentación Técnica: Migración Formulario Rep_Bon (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario **Rep_Bon** permite consultar e imprimir reportes de oficios de bonificación por recaudadora, filtrando por pendientes o todos. La migración implementa:
- Un endpoint API único `/api/execute` (patrón eRequest/eResponse)
- Un controlador Laravel que ejecuta la lógica y llama a un stored procedure en PostgreSQL
- Un componente Vue.js como página independiente
- Un stored procedure PostgreSQL para la consulta

## 2. Arquitectura
- **Backend**: Laravel 10+, PostgreSQL 13+
- **Frontend**: Vue.js 2/3 (compatible con Nuxt o Vue Router)
- **API**: Unificada, recibe un objeto `eRequest` y responde con `eResponse`

## 3. API
### Endpoint
`POST /api/execute`

#### Request
```json
{
  "eRequest": {
    "action": "listar|imprimir",
    "recaudadora": 1-9,
    "pendientes": true|false
  }
}
```

#### Response
```json
{
  "eResponse": {
    "success": true|false,
    "data": [ ... ],
    "message": "...",
    "report": true|false
  }
}
```

## 4. Backend (Laravel)
- **Controlador**: `RepBonController`
- Valida parámetros y llama al stored procedure `sp_rep_bon_listar`
- Devuelve los datos o mensaje de error
- Si `action=imprimir`, puede devolver los datos para generar un PDF en frontend

## 5. Stored Procedure (PostgreSQL)
- **Nombre**: `sp_rep_bon_listar`
- **Entradas**: recaudadora (int), tipo ('pendientes'|'todos')
- **Salida**: Tabla con todos los campos requeridos para el reporte
- **Lógica**: Consulta la tabla `ta_13_bonifrcm` y filtra según el tipo

## 6. Frontend (Vue.js)
- Página independiente `/rep-bon`
- Formulario para recaudadora y tipo (pendientes/todos)
- Botón Buscar: llama a la API y muestra resultados en tabla
- Botón Imprimir: llama a la API con `action=imprimir` (simula generación de reporte)
- Mensajes de error y validación

## 7. Seguridad
- Validación de rango de recaudadora (1-9)
- Solo permite acciones definidas
- El stored procedure no permite SQL injection

## 8. Extensibilidad
- El endpoint puede ser extendido para otros formularios usando el mismo patrón
- El stored procedure puede ser adaptado para otros reportes

## 9. Pruebas
- Casos de uso y pruebas incluidas abajo

## 10. Consideraciones
- El reporte PDF puede ser generado en backend (con dompdf, snappy, etc.) o frontend (jsPDF, etc.)
- El frontend puede ser adaptado a cualquier framework SPA
