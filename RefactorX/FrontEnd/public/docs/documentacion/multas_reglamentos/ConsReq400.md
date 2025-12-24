# Documentación: ConsReq400

## Análisis Técnico

# Documentación Técnica: Migración Formulario ConsReq400 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario ConsReq400 permite consultar requerimientos realizados en el sistema AS-400, filtrando por recaudadora, UR y cuenta. La migración implementa:
- **Backend**: Laravel Controller con endpoint unificado `/api/execute`.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: Stored Procedure en PostgreSQL para encapsular la lógica SQL.

## 2. Arquitectura
- **API Unificada**: Todas las operaciones se realizan mediante el endpoint `/api/execute`, usando el patrón `eRequest`/`eResponse`.
- **Stored Procedure**: Toda la lógica de consulta reside en el SP `sp_get_consreq400`.
- **Frontend**: Página Vue.js que permite la consulta y muestra los resultados en tabla.

## 3. Detalle de Componentes
### 3.1 Laravel Controller
- **Ruta**: POST `/api/execute`
- **Entrada**: JSON `{ eRequest: { operation: 'getConsReq400', params: { ofnar, tpr, ctarfc } } }`
- **Salida**: JSON `{ eResponse: { success, message, data } }`
- **Validación**: Se valida que los parámetros requeridos estén presentes y sean cadenas.
- **Llamada a SP**: Se ejecuta el SP `sp_get_consreq400` con los parámetros recibidos.

### 3.2 Stored Procedure PostgreSQL
- **Nombre**: `sp_get_consreq400`
- **Parámetros**: `ofnar`, `tpr`, `ctarfc` (todos VARCHAR)
- **Retorno**: Tabla con todos los campos de la tabla `req_400`.
- **Lógica**: Realiza un SELECT filtrando por los tres parámetros.

### 3.3 Componente Vue.js
- **Página independiente**: No usa tabs ni está embebida en otras vistas.
- **Formulario**: Tres campos (Recaudadora, UR, Cuenta) con validación básica.
- **Navegación**: Breadcrumb para contexto de usuario.
- **Tabla de resultados**: Se muestra sólo si hay datos.
- **Mensajes**: Se informa si no hay resultados o si ocurre un error.
- **UX**: Navegación con Enter entre campos, botón Buscar.

## 4. Flujo de Datos
1. Usuario ingresa los datos y presiona Buscar.
2. Vue.js envía POST a `/api/execute` con la operación y parámetros.
3. Laravel recibe, valida y ejecuta el SP.
4. El resultado se retorna en `eResponse`.
5. Vue.js muestra los datos en tabla o mensaje correspondiente.

## 5. Consideraciones Técnicas
- **Padding de campos**: Se replica la lógica Delphi para rellenar con ceros a la izquierda los campos `recaud` (2 dígitos) y `cuenta` (6 dígitos).
- **Seguridad**: El endpoint valida los parámetros y maneja errores.
- **Extensibilidad**: El endpoint unificado permite agregar más operaciones fácilmente.

## 6. Ejemplo de Request/Response
### Request
```json
{
  "eRequest": {
    "operation": "getConsReq400",
    "params": {
      "ofnar": "0001",
      "tpr": "2",
      "ctarfc": "001234"
    }
  }
}
```
### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Datos encontrados.",
    "data": [
      { "folreq": "...", ... }
    ]
  }
}
```

## 7. Errores Comunes
- **Parámetros faltantes**: El API retorna error 422 con mensaje descriptivo.
- **Sin resultados**: El mensaje indica que no se localizaron requerimientos.
- **Error de servidor**: Mensaje genérico y código 500.

## Casos de Uso

> ⚠️ Pendiente de documentar

## Casos de Prueba

> ⚠️ Pendiente de documentar

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

