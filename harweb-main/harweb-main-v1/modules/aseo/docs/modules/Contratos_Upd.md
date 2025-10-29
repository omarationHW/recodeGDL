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
