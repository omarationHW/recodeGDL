# Documentación Técnica: Migración de Formulario TrDocumentos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la consulta y generación de archivos de transferencia electrónica de documentos (cheques y transferencias) a partir de la información almacenada en la base de datos. El proceso incluye filtros por fecha, cuenta y tipo de documento, así como la generación de archivos de texto para su procesamiento bancario.

## 2. Arquitectura
- **Backend**: Laravel API con endpoint unificado `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente, con navegación y tabla de resultados.
- **Base de Datos**: PostgreSQL, con lógica de negocio encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato de entrada**:
  ```json
  {
    "eRequest": {
      "operation": "getDocumentos|getCuentasTrans|getBancosPagadores|generarTransferencia",
      "params": { ... }
    }
  }
  ```
- **Formato de salida**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [...],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- **sp_get_documentos**: Consulta documentos filtrados.
- **sp_get_cuenta_trans**: Devuelve la cuenta de transferencia asociada a una cuenta.
- **sp_get_bancos_pagadores**: Devuelve bancos pagadores activos.
- **sp_generar_transferencia**: Genera el archivo de transferencia y retorna la URL de descarga.

## 5. Flujo de la Aplicación
1. El usuario selecciona fecha, cuenta y tipo de documento.
2. Al buscar, se consulta la API (`getDocumentos`) y se muestran los resultados.
3. El usuario puede generar el archivo de transferencia, que se descarga desde el backend (`generarTransferencia`).

## 6. Seguridad
- Validación de parámetros en backend.
- Los archivos generados se almacenan en un directorio seguro y se exponen sólo para descarga autenticada.

## 7. Consideraciones
- El frontend asume que las cuentas y bancos pueden ser precargados o consultados vía API.
- El archivo de transferencia se genera en el servidor y se expone vía URL para descarga.
- El proceso de generación de archivo es atómico y seguro.

## 8. Extensibilidad
- Se pueden agregar nuevos tipos de documentos o formatos de archivo modificando el stored procedure `sp_generar_transferencia`.

---
