# Documentación Técnica: Migración de Formulario DrecgoTrans (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de descuentos en recargos de transmisiones patrimoniales. Incluye búsqueda de folios, alta/cancelación de descuentos, validación de permisos y consulta de funcionarios autorizados. La migración implementa:
- Backend: Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- Frontend: Componente Vue.js como página independiente
- Base de datos: PostgreSQL con stored procedures para lógica de negocio

## 2. API Backend (Laravel)
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "search_folio|search_diferencia|alta_descuento|cancelar_descuento|get_autorizadores",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": "..."
    }
  }
  ```
- **Acciones soportadas:**
  - `search_folio`: Busca folio de transmisión (completa)
  - `search_diferencia`: Busca diferencias de transmisión
  - `alta_descuento`: Da de alta un descuento
  - `cancelar_descuento`: Cancela un descuento
  - `get_autorizadores`: Lista funcionarios autorizados

## 3. Frontend (Vue.js)
- Página independiente `/descuentos-transmisiones`
- Permite:
  - Buscar folio (completo/diferencia)
  - Visualizar resultados y estado
  - Alta de descuento (formulario modal)
  - Cancelar descuento vigente
  - Validación de porcentaje según funcionario autorizado
- Navegación breadcrumb incluida
- Mensajes de error y éxito claros

## 4. Stored Procedures (PostgreSQL)
- Toda la lógica de negocio (alta, baja, consulta, permisos) está en stored procedures para seguridad y mantenibilidad.
- Los procedimientos devuelven datos en formato tabla para fácil consumo por el API.

## 5. Seguridad
- El endpoint requiere autenticación (token Laravel o sesión).
- El usuario se pasa a los SP para auditoría.
- Validación de permisos en SP y en frontend.

## 6. Integración
- El frontend consume el endpoint único `/api/execute` usando eRequest/eResponse.
- Los parámetros de cada acción se documentan en la sección de casos de uso.

## 7. Consideraciones de Migración
- No se usan tabs: cada formulario es una página Vue independiente.
- El formulario es autosuficiente y no depende de otros módulos.
- El código es desacoplado y preparado para pruebas unitarias y de integración.

## 8. Estructura de la Base de Datos
- Tablas principales: `impuestotransp`, `diferencias_glosa`, `descrectrans`, `c_autdescrec`, `autoriza`, `usuarios`, `deptos`
- Los SP usan JOINs y validaciones para mantener la lógica original.

## 9. Pruebas y Validación
- Casos de uso y pruebas incluidas para asegurar la funcionalidad y robustez.

---
